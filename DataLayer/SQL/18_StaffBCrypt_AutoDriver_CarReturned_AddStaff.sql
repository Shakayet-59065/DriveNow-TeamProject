-- =============================================
-- Script 18: BCrypt staff auth migration, spAutoAssignDriver, CarReturned column, spAddStaff
-- Developer: Musanna | CTEC2713N | Niels Brock Copenhagen
-- Run after: all previous scripts (tblStaff, tblTrip, tblDriver must exist)
-- Safe to re-run: uses DROP IF EXISTS before every CREATE/ALTER PROCEDURE;
--                 ALTER TABLE section uses IF NOT EXISTS guard.
-- =============================================

USE DriveNow;
GO

-- ============================================================
-- SECTION 1 — Update spStaffLogin to return hash row (BCrypt
--              comparison done in C# via BCrypt.Verify)
-- ============================================================

IF OBJECT_ID('dbo.spStaffLogin', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spStaffLogin;
GO

CREATE PROCEDURE spStaffLogin
    @Username VARCHAR(50)
AS
BEGIN
    -- Returns the full row (including PasswordHash) so the C# layer
    -- can call BCrypt.Verify(@plainText, row.PasswordHash) directly.
    -- No password comparison is done in SQL — avoids plain-text compare.
    SELECT StaffID, FullName, Username, PasswordHash
    FROM   tblStaff
    WHERE  Username = @Username
    AND    IsActive = 1;
END;
GO

-- ============================================================
-- SECTION 2 — spUpdateStaffPassword
--              Used by the lazy-migration in Login.aspx.cs to
--              re-hash a plain-text stored password to BCrypt.
-- ============================================================

IF OBJECT_ID('dbo.spUpdateStaffPassword', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spUpdateStaffPassword;
GO

CREATE PROCEDURE spUpdateStaffPassword
    @StaffID      INT,
    @PasswordHash VARCHAR(255)
AS
BEGIN
    UPDATE tblStaff
    SET    PasswordHash = @PasswordHash
    WHERE  StaffID = @StaffID;
END;
GO

-- ============================================================
-- SECTION 3 — spAddStaff
--              Used by the Add Staff admin page to create a new
--              staff member with a BCrypt-hashed password.
-- ============================================================

IF OBJECT_ID('dbo.spAddStaff', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spAddStaff;
GO

CREATE PROCEDURE spAddStaff
    @Username     VARCHAR(50),
    @PasswordHash VARCHAR(255),
    @FullName     VARCHAR(100),
    @NewStaffID   INT OUTPUT
AS
BEGIN
    INSERT INTO tblStaff (Username, PasswordHash, FullName, IsActive)
    VALUES (@Username, @PasswordHash, @FullName, 1);
    SET @NewStaffID = SCOPE_IDENTITY();
END;
GO

-- ============================================================
-- SECTION 4 — spAutoAssignDriver
--              Picks a random active driver, marks them inactive
--              (unavailable), and returns their DriverID.
--              Called when booking a Chauffeured / Short Ride trip.
-- ============================================================

IF OBJECT_ID('dbo.spAutoAssignDriver', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spAutoAssignDriver;
GO

CREATE PROCEDURE spAutoAssignDriver
    @AssignedDriverID INT OUTPUT
AS
BEGIN
    SET @AssignedDriverID = NULL;

    -- Pick one active driver at random
    SELECT TOP 1 @AssignedDriverID = DriverID
    FROM   tblDriver
    WHERE  IsActive = 1
    ORDER  BY NEWID();   -- random selection

    -- Mark the selected driver inactive (on a trip, unavailable)
    IF @AssignedDriverID IS NOT NULL
        UPDATE tblDriver SET IsActive = 0 WHERE DriverID = @AssignedDriverID;
END;
GO

-- ============================================================
-- SECTION 5 — Add CarReturned column to tblTrip
--              Tracks whether the vehicle was returned after the trip.
--              Guard ensures this is idempotent on re-run.
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM   sys.columns
    WHERE  object_id = OBJECT_ID('dbo.tblTrip')
    AND    name      = 'CarReturned'
)
    ALTER TABLE dbo.tblTrip
        ADD CarReturned BIT NOT NULL DEFAULT 0;
GO

-- ============================================================
-- SECTION 6 — Rebuild spListTrips to include CarReturned and
--              a computed TripStatus column.
--
--   TripStatus logic:
--     'Car Returned'  — CarReturned = 1 (override, highest priority)
--     'Upcoming'      — TripDate > today
--     'In Progress'   — TripDate = today
--     'Completed'     — TripDate < today
-- ============================================================

IF OBJECT_ID('dbo.spListTrips', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spListTrips;
GO

CREATE PROCEDURE spListTrips
AS
BEGIN
    SELECT
        t.TripID,
        t.CustomerID,
        t.VehicleID,
        t.DriverID,
        t.TripTypeID,
        tt.TypeName,
        t.TripDate,
        t.IsActive,
        t.CarReturned,
        CASE
            WHEN t.CarReturned = 1                          THEN 'Car Returned'
            WHEN t.TripDate > CAST(GETDATE() AS DATE)       THEN 'Upcoming'
            WHEN t.TripDate = CAST(GETDATE() AS DATE)       THEN 'In Progress'
            ELSE                                                 'Completed'
        END AS TripStatus
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.IsActive = 1
    ORDER  BY t.TripDate DESC;
END;
GO

-- ============================================================
-- SECTION 7 — spMarkCarReturned
--              Admin clicks a button to mark the car as returned
--              for a given trip.
-- ============================================================

IF OBJECT_ID('dbo.spMarkCarReturned', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spMarkCarReturned;
GO

CREATE PROCEDURE spMarkCarReturned
    @TripID INT
AS
BEGIN
    UPDATE tblTrip SET CarReturned = 1 WHERE TripID = @TripID;
END;
GO

-- ============================================================
-- SECTION 8 — spListInactiveTrips
--              Update (or create) to include CarReturned and
--              TripStatus using the same computed logic as
--              spListTrips.
-- ============================================================

IF OBJECT_ID('dbo.spListInactiveTrips', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spListInactiveTrips;
GO

CREATE PROCEDURE spListInactiveTrips
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.TripID,
        t.CustomerID,
        t.VehicleID,
        t.DriverID,
        t.TripTypeID,
        tt.TypeName,
        t.TripDate,
        t.IsActive,
        t.CarReturned,
        CASE
            WHEN t.CarReturned = 1                          THEN 'Car Returned'
            WHEN t.TripDate > CAST(GETDATE() AS DATE)       THEN 'Upcoming'
            WHEN t.TripDate = CAST(GETDATE() AS DATE)       THEN 'In Progress'
            ELSE                                                 'Completed'
        END AS TripStatus
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.IsActive = 0
    ORDER  BY t.TripID DESC;
END;
GO

-- ============================================================
-- SECTION 9 — Rebuild spFindTrip to include CarReturned and
--              TripStatus (same computed logic as spListTrips).
-- ============================================================

IF OBJECT_ID('dbo.spFindTrip', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spFindTrip;
GO

CREATE PROCEDURE spFindTrip
    @TripID INT
AS
BEGIN
    SELECT
        t.TripID,
        t.CustomerID,
        t.VehicleID,
        t.DriverID,
        t.TripTypeID,
        tt.TypeName,
        t.TripDate,
        t.IsActive,
        t.CarReturned,
        CASE
            WHEN t.CarReturned = 1                          THEN 'Car Returned'
            WHEN t.TripDate > CAST(GETDATE() AS DATE)       THEN 'Upcoming'
            WHEN t.TripDate = CAST(GETDATE() AS DATE)       THEN 'In Progress'
            ELSE                                                 'Completed'
        END AS TripStatus
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.TripID = @TripID;
END;
GO

-- ============================================================
-- SECTION 10 — Verification
-- ============================================================

SELECT 'Script 18 complete' AS Result;

SELECT name
FROM   sys.objects
WHERE  type = 'P'
AND    name IN (
    'spStaffLogin',
    'spUpdateStaffPassword',
    'spAddStaff',
    'spAutoAssignDriver',
    'spMarkCarReturned'
)
ORDER BY name;
GO
