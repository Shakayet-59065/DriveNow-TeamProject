-- ============================================================
-- Script 31 — CustomerTrip extended fields + supporting procs
-- DriveNow | CTEC2713N
-- Run AFTER scripts 1–30.
-- ============================================================
-- Adds InsuranceTier and Addons columns to tblCustomerTrip,
-- then creates/updates the stored procedures used by TripEdit,
-- TripAdd, BookTrip, and the customer portal.
-- ============================================================

-- ⚠  Select YOUR database from the SSMS dropdown before running.

-- ── 1. Add InsuranceTier to tblCustomerTrip ───────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='tblCustomerTrip' AND COLUMN_NAME='InsuranceTier')
BEGIN
    ALTER TABLE tblCustomerTrip
        ADD InsuranceTier NVARCHAR(20) NOT NULL DEFAULT 'Basic';
    PRINT 'Added InsuranceTier column to tblCustomerTrip.';
END
ELSE PRINT 'InsuranceTier column already exists.';
GO

-- ── 2. Add Addons to tblCustomerTrip ─────────────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='tblCustomerTrip' AND COLUMN_NAME='Addons')
BEGIN
    ALTER TABLE tblCustomerTrip
        ADD Addons NVARCHAR(500) NULL;
    PRINT 'Added Addons column to tblCustomerTrip.';
END
ELSE PRINT 'Addons column already exists.';
GO

-- ── 3. spGetCustomerTripByTripID ──────────────────────────────────────
-- Returns the single tblCustomerTrip row for a given TripID.
-- Used by TripEdit to pre-fill pickup/dropoff/insurance/addons fields.
IF OBJECT_ID('spGetCustomerTripByTripID','P') IS NOT NULL
    DROP PROCEDURE spGetCustomerTripByTripID;
GO
CREATE PROCEDURE spGetCustomerTripByTripID
    @TripID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1
        CustomerTripID,
        TripID,
        CustomerID,
        PickupLocation,
        PickupDate,
        DropoffLocation,
        DropoffDate,
        Notes,
        ISNULL(InsuranceTier,'Basic') AS InsuranceTier,
        ISNULL(Addons,'')            AS Addons,
        IsActive
    FROM tblCustomerTrip
    WHERE TripID = @TripID
    ORDER BY CustomerTripID DESC;  -- latest booking row first
END
GO

-- ── 4. spEditCustomerTripDetails ─────────────────────────────────────
-- Updates pickup/dropoff/notes/insurance/addons for an existing booking.
-- Called by TripEdit when staff saves changes.
IF OBJECT_ID('spEditCustomerTripDetails','P') IS NOT NULL
    DROP PROCEDURE spEditCustomerTripDetails;
GO
CREATE PROCEDURE spEditCustomerTripDetails
    @CustomerTripID  INT,
    @PickupLocation  NVARCHAR(200),
    @PickupDate      DATETIME,
    @DropoffLocation NVARCHAR(200),
    @DropoffDate     DATETIME,
    @Notes           NVARCHAR(500) = NULL,
    @InsuranceTier   NVARCHAR(20)  = 'Basic',
    @Addons          NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblCustomerTrip
    SET
        PickupLocation  = @PickupLocation,
        PickupDate      = @PickupDate,
        DropoffLocation = @DropoffLocation,
        DropoffDate     = @DropoffDate,
        Notes           = @Notes,
        InsuranceTier   = @InsuranceTier,
        Addons          = @Addons
    WHERE CustomerTripID = @CustomerTripID;
END
GO

-- ── 5. spAddCustomerTripFull ─────────────────────────────────────────
-- Creates a new tblCustomerTrip row with all fields including
-- InsuranceTier and Addons. Used by TripAdd (staff) and BookTrip (customer).
IF OBJECT_ID('spAddCustomerTripFull','P') IS NOT NULL
    DROP PROCEDURE spAddCustomerTripFull;
GO
CREATE PROCEDURE spAddCustomerTripFull
    @TripID          INT,
    @CustomerID      INT,
    @PickupLocation  NVARCHAR(200),
    @PickupDate      DATETIME,
    @DropoffLocation NVARCHAR(200),
    @DropoffDate     DATETIME,
    @Notes           NVARCHAR(500) = NULL,
    @InsuranceTier   NVARCHAR(20)  = 'Basic',
    @Addons          NVARCHAR(500) = NULL,
    @NewID           INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tblCustomerTrip
        (TripID, CustomerID, PickupLocation, PickupDate, DropoffLocation, DropoffDate, Notes, InsuranceTier, Addons, IsActive)
    VALUES
        (@TripID, @CustomerID, @PickupLocation, @PickupDate, @DropoffLocation, @DropoffDate,
         @Notes, ISNULL(@InsuranceTier,'Basic'), @Addons, 1);
    SET @NewID = SCOPE_IDENTITY();
END
GO

-- ── 6. Update spListCustomerTrips to return InsuranceTier and Addons ─
-- (Latest version — supersedes all previous versions from scripts 21–24)
CREATE OR ALTER PROCEDURE spListCustomerTrips
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ct.CustomerTripID,
        ct.TripID,
        ct.CustomerID,
        ct.PickupLocation,
        ct.PickupDate,
        ct.DropoffLocation,
        ct.DropoffDate,
        ct.Notes,
        ISNULL(ct.InsuranceTier,'Basic') AS InsuranceTier,
        ISNULL(ct.Addons,'')            AS Addons,
        ct.IsActive,
        t.IsActive              AS TripIsActive,
        ISNULL(t.CarReturned,0) AS CarReturned,
        t.DriverID,
        tt.TypeName,
        tt.BaseRate,
        v.Make           AS VehicleMake,
        v.Model          AS VehicleModel,
        v.RegistrationNo,
        v.DailyRate      AS VehicleDailyRate,
        d.FullName       AS DriverName,
        CASE
            WHEN ct.DropoffDate > ct.PickupDate
            THEN CEILING(CAST(DATEDIFF(MINUTE, ct.PickupDate, ct.DropoffDate) AS FLOAT) / 1440.0)
            ELSE 1
        END              AS TripDays
    FROM   tblCustomerTrip ct
    INNER JOIN tblTrip     t  ON ct.TripID    = t.TripID
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    INNER JOIN tblVehicle  v  ON t.VehicleID  = v.VehicleID
    LEFT  JOIN tblDriver   d  ON t.DriverID   = d.DriverID
    WHERE  ct.CustomerID = @CustomerID
    AND    ct.IsActive   = 1
    ORDER  BY ct.PickupDate DESC;
END;
GO

PRINT 'Script 31 complete — InsuranceTier/Addons columns added, 4 stored procedures created/updated.';
GO
