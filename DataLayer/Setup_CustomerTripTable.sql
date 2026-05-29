USE DriveNow;
GO

-- =============================================
-- tblCustomerTrip
-- Stores pickup/dropoff details for each trip
-- FK to tblTrip for full trip info
-- FK to tblCustomer for data ownership
-- =============================================

IF OBJECT_ID('dbo.tblCustomerTrip','U') IS NOT NULL DROP TABLE dbo.tblCustomerTrip;
GO

CREATE TABLE tblCustomerTrip
(
    CustomerTripID   INT           IDENTITY(1,1) NOT NULL,
    TripID           INT                         NOT NULL,
    CustomerID       INT                         NOT NULL,
    PickupLocation   VARCHAR(200)                NOT NULL,
    PickupDate       DATETIME                    NOT NULL,
    DropoffLocation  VARCHAR(200)                NOT NULL,
    DropoffDate      DATETIME                    NOT NULL,
    Notes            VARCHAR(500)                NULL,
    IsActive         BIT           DEFAULT 1     NOT NULL,

    CONSTRAINT PK_tblCustomerTrip        PRIMARY KEY (CustomerTripID),
    CONSTRAINT FK_CustomerTrip_Trip      FOREIGN KEY (TripID)
        REFERENCES tblTrip(TripID),
    CONSTRAINT FK_CustomerTrip_Customer  FOREIGN KEY (CustomerID)
        REFERENCES tblCustomer(CustomerID),
    CONSTRAINT CK_CustomerTrip_Dates     CHECK (DropoffDate > PickupDate)
);
GO

-- =============================================
-- Insert sample data linked to existing trips
-- =============================================
INSERT INTO tblCustomerTrip (TripID, CustomerID, PickupLocation, PickupDate, DropoffLocation, DropoffDate, Notes, IsActive)
VALUES
(1, 1, 'Niels Brock Copenhagen, Danasvej 3', '2026-04-21 09:00', 'Copenhagen Central Station',            '2026-04-21 10:30', 'Morning commute',            1),
(2, 2, 'Hotel Marriott, Kalvebod Brygge',    '2026-04-22 14:00', 'Copenhagen Airport, Terminal 2',        '2026-04-22 15:45', 'Airport transfer - business',1),
(3, 3, 'Norreport Station',                  '2026-04-22 11:00', 'Tivoli Gardens, Vesterbrogade 3',       '2026-04-22 13:00', 'Self-drive sightseeing',     1),
(4, 4, 'Frederiksberg Alle 1',               '2026-04-23 08:30', 'DTU Lyngby Campus, Anker Engelundsvej', '2026-04-23 09:30', 'Self-drive to university',   1),
(5, 2, 'Copenhagen Airport, Arrivals Hall',  '2026-04-24 16:00', 'Radisson Blu, Amager Blvd 70',         '2026-04-24 17:00', 'Return airport transfer',    1);
GO

-- =============================================
-- STORED PROCEDURES
-- =============================================

-- Add a customer trip
IF OBJECT_ID('dbo.spAddCustomerTrip','P') IS NOT NULL DROP PROCEDURE dbo.spAddCustomerTrip;
GO
CREATE PROCEDURE spAddCustomerTrip
    @TripID          INT,
    @CustomerID      INT,
    @PickupLocation  VARCHAR(200),
    @PickupDate      DATETIME,
    @DropoffLocation VARCHAR(200),
    @DropoffDate     DATETIME,
    @Notes           VARCHAR(500) = NULL,
    @NewID           INT OUTPUT
AS
BEGIN
    INSERT INTO tblCustomerTrip
        (TripID, CustomerID, PickupLocation, PickupDate, DropoffLocation, DropoffDate, Notes, IsActive)
    VALUES
        (@TripID, @CustomerID, @PickupLocation, @PickupDate, @DropoffLocation, @DropoffDate, @Notes, 1);
    SET @NewID = SCOPE_IDENTITY();
END;
GO

-- List all trips for one customer (full details via joins)
IF OBJECT_ID('dbo.spListCustomerTrips','P') IS NOT NULL DROP PROCEDURE dbo.spListCustomerTrips;
GO
CREATE PROCEDURE spListCustomerTrips
    @CustomerID INT
AS
BEGIN
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
        tt.TypeName,
        tt.BaseRate,
        v.Make          AS VehicleMake,
        v.Model         AS VehicleModel,
        v.RegistrationNo,
        d.FullName      AS DriverName
    FROM   tblCustomerTrip ct
    INNER  JOIN tblTrip     t  ON ct.TripID     = t.TripID
    INNER  JOIN tblTripType tt ON t.TripTypeID  = tt.TripTypeID
    INNER  JOIN tblVehicle  v  ON t.VehicleID   = v.VehicleID
    LEFT   JOIN tblDriver   d  ON t.DriverID    = d.DriverID
    WHERE  ct.CustomerID = @CustomerID
    AND    ct.IsActive   = 1
    ORDER  BY ct.PickupDate DESC;
END;
GO

-- Find one customer trip by ID
IF OBJECT_ID('dbo.spFindCustomerTrip','P') IS NOT NULL DROP PROCEDURE dbo.spFindCustomerTrip;
GO
CREATE PROCEDURE spFindCustomerTrip
    @CustomerTripID INT
AS
BEGIN
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
        tt.TypeName,
        tt.BaseRate,
        v.Make          AS VehicleMake,
        v.Model         AS VehicleModel,
        v.RegistrationNo,
        d.FullName      AS DriverName
    FROM   tblCustomerTrip ct
    INNER  JOIN tblTrip     t  ON ct.TripID     = t.TripID
    INNER  JOIN tblTripType tt ON t.TripTypeID  = tt.TripTypeID
    INNER  JOIN tblVehicle  v  ON t.VehicleID   = v.VehicleID
    LEFT   JOIN tblDriver   d  ON t.DriverID    = d.DriverID
    WHERE  ct.CustomerTripID = @CustomerTripID;
END;
GO

-- Edit a customer trip
IF OBJECT_ID('dbo.spEditCustomerTrip','P') IS NOT NULL DROP PROCEDURE dbo.spEditCustomerTrip;
GO
CREATE PROCEDURE spEditCustomerTrip
    @CustomerTripID  INT,
    @PickupLocation  VARCHAR(200),
    @PickupDate      DATETIME,
    @DropoffLocation VARCHAR(200),
    @DropoffDate     DATETIME,
    @Notes           VARCHAR(500) = NULL
AS
BEGIN
    UPDATE tblCustomerTrip
    SET    PickupLocation  = @PickupLocation,
           PickupDate      = @PickupDate,
           DropoffLocation = @DropoffLocation,
           DropoffDate     = @DropoffDate,
           Notes           = @Notes
    WHERE  CustomerTripID  = @CustomerTripID;
END;
GO

-- Soft delete
IF OBJECT_ID('dbo.spDeleteCustomerTrip','P') IS NOT NULL DROP PROCEDURE dbo.spDeleteCustomerTrip;
GO
CREATE PROCEDURE spDeleteCustomerTrip
    @CustomerTripID INT
AS
BEGIN
    UPDATE tblCustomerTrip SET IsActive = 0 WHERE CustomerTripID = @CustomerTripID;
END;
GO

-- =============================================
-- VERIFY
-- =============================================
SELECT 'tblCustomerTrip rows' AS Info, COUNT(*) AS Total FROM tblCustomerTrip;

SELECT
    ct.CustomerTripID,
    c.FullName      AS Customer,
    ct.PickupLocation,
    ct.PickupDate,
    ct.DropoffLocation,
    ct.DropoffDate,
    v.Make + ' ' + v.Model AS Vehicle,
    tt.TypeName
FROM   tblCustomerTrip ct
JOIN   tblCustomer  c  ON ct.CustomerID  = c.CustomerID
JOIN   tblTrip      t  ON ct.TripID      = t.TripID
JOIN   tblVehicle   v  ON t.VehicleID    = v.VehicleID
JOIN   tblTripType  tt ON t.TripTypeID   = tt.TripTypeID;
GO

