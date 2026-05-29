-- ============================================================
-- Script 24: Driver public profile
-- Run ONCE against the DriveNow LocalDB database.
-- Adds PhotoUrl + Bio columns to tblDriver and creates
-- public/admin profile stored procedures.
-- Also updates spListCustomerTrips to include t.DriverID
-- so the customer portal can render the "View Profile" link.
-- ============================================================

-- 1. Add optional profile columns (safe to re-run)
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('tblDriver') AND name = 'PhotoUrl')
    ALTER TABLE tblDriver ADD PhotoUrl VARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('tblDriver') AND name = 'Bio')
    ALTER TABLE tblDriver ADD Bio VARCHAR(300) NULL;
GO

-- 2. Add t.DriverID to spListCustomerTrips so the customer portal
--    can show "View Profile" links for trips with an assigned driver.
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
        ct.IsActive,
        t.IsActive       AS TripIsActive,
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
    ORDER  BY ct.PickupDate DESC;
END
GO

-- 3. Rebuild spAddDriver to accept optional PhotoUrl / Bio
--    (existing callers that omit these params still work — they default to NULL)
CREATE OR ALTER PROCEDURE spAddDriver
    @FullName      VARCHAR(100),
    @Phone         VARCHAR(20),
    @LicenceNumber VARCHAR(30),
    @DateOfBirth   DATE,
    @JoinDate      DATE,
    @PhotoUrl      VARCHAR(500) = NULL,
    @Bio           VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, PhotoUrl, Bio)
    VALUES (@FullName, @Phone, @LicenceNumber, @DateOfBirth, @JoinDate, 1, @PhotoUrl, @Bio);
    SELECT SCOPE_IDENTITY();
END
GO

-- 3. Public driver listing — safe fields only (no licence / DOB)
CREATE OR ALTER PROCEDURE spListActiveDriversPublic
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DriverID, FullName, PhotoUrl, Bio, JoinDate
    FROM   tblDriver
    WHERE  IsActive = 1
    ORDER  BY FullName;
END
GO

-- 4. Public driver detail — safe fields only
CREATE OR ALTER PROCEDURE spGetDriverPublicProfile
    @DriverID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DriverID, FullName, PhotoUrl, Bio, JoinDate
    FROM   tblDriver
    WHERE  DriverID = @DriverID AND IsActive = 1;
END
GO

-- 5. Admin driver detail — all fields (staff portal only)
CREATE OR ALTER PROCEDURE spGetDriverAdminProfile
    @DriverID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DriverID, FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, PhotoUrl, Bio
    FROM   tblDriver
    WHERE  DriverID = @DriverID;
END
GO
