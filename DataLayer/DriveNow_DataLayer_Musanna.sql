-- =============================================
-- DriveNow — Data Layer
-- Developer: Musanna
-- Component: Trip Records & Trip Type Catalogue
-- Module: CTEC2713N | Niels Brock Copenhagen
-- Date: May 2026
-- =============================================
-- HOW TO USE:
-- 1. Open SSMS and connect to (localdb)\MSSQLLocalDB
-- 2. Run this entire script top to bottom
-- 3. It will create the DriveNow database, all tables,
--    test data, and all stored procedures
-- =============================================

-- =============================================
-- STEP 1 — Create and select the database
-- =============================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DriveNow')
BEGIN
    CREATE DATABASE DriveNow;
END
GO

USE DriveNow;
GO

-- =============================================
-- STEP 2 — Drop tables if they exist (clean run)
-- =============================================

IF OBJECT_ID('dbo.tblTrip', 'U') IS NOT NULL DROP TABLE dbo.tblTrip;
IF OBJECT_ID('dbo.tblTripType', 'U') IS NOT NULL DROP TABLE dbo.tblTripType;
IF OBJECT_ID('dbo.tblCustomer', 'U') IS NOT NULL DROP TABLE dbo.tblCustomer;
IF OBJECT_ID('dbo.tblVehicle', 'U') IS NOT NULL DROP TABLE dbo.tblVehicle;
IF OBJECT_ID('dbo.tblDriver', 'U') IS NOT NULL DROP TABLE dbo.tblDriver;
GO

-- =============================================
-- STEP 3 — Create tblTripType
-- Owner: Musanna
-- =============================================

CREATE TABLE tblTripType
(
    TripTypeID  INT          IDENTITY(1,1) NOT NULL,
    TypeName    VARCHAR(50)               NOT NULL,
    Description VARCHAR(200)              NULL,
    BaseRate    DECIMAL(8,2)              NOT NULL,
    CreatedDate DATE                      NOT NULL,
    IsActive    BIT          DEFAULT 1    NOT NULL,

    CONSTRAINT PK_tblTripType PRIMARY KEY (TripTypeID),
    CONSTRAINT UQ_TypeName    UNIQUE      (TypeName)
);
GO

-- =============================================
-- STEP 4 — Create dummy tables for teammate FKs
-- These will be replaced when teammates push
-- their own scripts. Schema matches their specs.
-- =============================================

-- tblCustomer (Tahmid)
CREATE TABLE tblCustomer
(
    CustomerID   INT          IDENTITY(1,1) NOT NULL,
    FullName     VARCHAR(100)               NOT NULL,
    Email        VARCHAR(150)               NOT NULL,
    Phone        VARCHAR(20)                NOT NULL,
    PasswordHash VARCHAR(255)               NOT NULL,
    RegisterDate DATE                       NOT NULL,
    IsActive     BIT          DEFAULT 1     NOT NULL,
    CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerID)
);
GO

-- tblVehicle (Prodip)
CREATE TABLE tblVehicle
(
    VehicleID      INT          IDENTITY(1,1) NOT NULL,
    RegistrationNo VARCHAR(20)                NOT NULL,
    Make           VARCHAR(50)                NOT NULL,
    Model          VARCHAR(50)                NOT NULL,
    DailyRate      DECIMAL(8,2)               NOT NULL,
    DateAdded      DATE                       NOT NULL,
    IsAvailable    BIT          DEFAULT 1     NOT NULL,
    CONSTRAINT PK_tblVehicle PRIMARY KEY (VehicleID)
);
GO

-- tblDriver (Redoy)
CREATE TABLE tblDriver
(
    DriverID      INT          IDENTITY(1,1) NOT NULL,
    FullName      VARCHAR(100)               NOT NULL,
    Phone         VARCHAR(20)                NOT NULL,
    LicenceNumber VARCHAR(30)                NOT NULL,
    DateOfBirth   DATE                       NOT NULL,
    JoinDate      DATE                       NOT NULL,
    IsActive      BIT          DEFAULT 1     NOT NULL,
    CONSTRAINT PK_tblDriver PRIMARY KEY (DriverID)
);
GO

-- =============================================
-- STEP 5 — Create tblTrip
-- Owner: Musanna
-- =============================================

CREATE TABLE tblTrip
(
    TripID     INT  IDENTITY(1,1) NOT NULL,
    CustomerID INT                NOT NULL,
    VehicleID  INT                NOT NULL,
    DriverID   INT                NULL,
    TripTypeID INT                NOT NULL,
    TripDate   DATE               NOT NULL,
    IsActive   BIT  DEFAULT 1     NOT NULL,

    CONSTRAINT PK_tblTrip        PRIMARY KEY (TripID),
    CONSTRAINT FK_Trip_Customer  FOREIGN KEY (CustomerID)
        REFERENCES tblCustomer(CustomerID),
    CONSTRAINT FK_Trip_Vehicle   FOREIGN KEY (VehicleID)
        REFERENCES tblVehicle(VehicleID),
    CONSTRAINT FK_Trip_Driver    FOREIGN KEY (DriverID)
        REFERENCES tblDriver(DriverID),
    CONSTRAINT FK_Trip_TripType  FOREIGN KEY (TripTypeID)
        REFERENCES tblTripType(TripTypeID)
);
GO

-- =============================================
-- STEP 6 — Insert test data into tblTripType
-- =============================================

INSERT INTO tblTripType (TypeName, Description, BaseRate, CreatedDate, IsActive)
VALUES
('Short Ride',         'A short point-to-point journey with a DriveNow driver.',          5.99,  '2026-04-20', 1),
('Chauffeured Rental', 'A longer hire period with a DriveNow driver included.',           15.99, '2026-04-20', 1),
('Self-Drive Rental',  'A vehicle hire with no driver. Customer drives themselves.',       12.99, '2026-04-20', 1),
('Airport Transfer',   'A dedicated transfer to or from the airport with a driver.',      20.99, '2026-04-20', 1),
('Corporate Hire',     'Extended chauffeured hire for business clients. Full day.',        49.99, '2026-04-20', 1);
GO

-- =============================================
-- STEP 7 — Insert dummy test data for FK tables
-- =============================================

INSERT INTO tblCustomer (FullName, Email, Phone, PasswordHash, RegisterDate, IsActive)
VALUES
('Alice Jensen', 'alice@email.com',  '+4512345678', 'hash1', '2026-01-10', 1),
('Bob Nielsen',  'bob@email.com',    '+4598765432', 'hash2', '2026-02-15', 1),
('Clara Madsen', 'clara@email.com',  '+4511223344', 'hash3', '2026-03-01', 1),
('David Holm',   'david@email.com',  '+4544556677', 'hash4', '2026-03-15', 1),
('Emma Bro',     'emma@email.com',   '+4566778899', 'hash5', '2026-04-01', 1);
GO

INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable)
VALUES
('AB12345', 'Toyota',   'Corolla',  45.00,  '2026-01-05', 1),
('CD67890', 'BMW',      '5 Series', 120.00, '2026-02-10', 1),
('EF11223', 'Tesla',    'Model 3',  95.00,  '2026-03-20', 1),
('GH44556', 'Ford',     'Focus',    40.00,  '2026-03-25', 1),
('IJ77889', 'Mercedes', 'E-Class',  130.00, '2026-04-01', 1);
GO

INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
VALUES
('Mads Hansen', '+4522334455', 'DK-123456', '1990-05-15', '2026-01-15', 1),
('Sara Larsen', '+4533445566', 'DK-789012', '1988-08-22', '2026-02-01', 1),
('Jonas Berg',  '+4544556677', 'DK-345678', '1992-03-10', '2026-02-20', 1),
('Maja Koch',   '+4555667788', 'DK-901234', '1995-07-30', '2026-03-05', 1),
('Erik Dahl',   '+4566778899', 'DK-567890', '1985-11-12', '2026-03-15', 1);
GO

-- =============================================
-- STEP 8 — Insert test data into tblTrip
-- =============================================

INSERT INTO tblTrip (CustomerID, VehicleID, DriverID, TripTypeID, TripDate, IsActive)
VALUES
(1, 1, 1,    1, '2026-04-21', 1),
(2, 2, 2,    2, '2026-04-22', 1),
(3, 3, NULL, 3, '2026-04-22', 1),
(4, 4, NULL, 3, '2026-04-23', 1),
(5, 2, 1,    4, '2026-04-24', 1);
GO

-- =============================================
-- STEP 9 — Stored Procedures for tblTripType
-- =============================================

-- List all active trip types
CREATE PROCEDURE spListTripTypes
AS
BEGIN
    -- Returns all active trip types ordered by name
    SELECT TripTypeID, TypeName, Description, BaseRate, CreatedDate, IsActive
    FROM   tblTripType
    WHERE  IsActive = 1
    ORDER BY TypeName;
END;
GO

-- Add a new trip type
CREATE PROCEDURE spAddTripType
    @TypeName    VARCHAR(50),
    @Description VARCHAR(200) = NULL,
    @BaseRate    DECIMAL(8,2),
    @NewID       INT OUTPUT
AS
BEGIN
    -- Insert new trip type and return new ID
    INSERT INTO tblTripType (TypeName, Description, BaseRate, CreatedDate, IsActive)
    VALUES (@TypeName, @Description, @BaseRate, GETDATE(), 1);
    SET @NewID = SCOPE_IDENTITY();
END;
GO

-- Edit an existing trip type
CREATE PROCEDURE spEditTripType
    @TripTypeID  INT,
    @TypeName    VARCHAR(50),
    @Description VARCHAR(200) = NULL,
    @BaseRate    DECIMAL(8,2)
AS
BEGIN
    -- Update trip type details by ID
    UPDATE tblTripType
    SET    TypeName    = @TypeName,
           Description = @Description,
           BaseRate    = @BaseRate
    WHERE  TripTypeID  = @TripTypeID;
END;
GO

-- Soft delete a trip type
CREATE PROCEDURE spDeleteTripType
    @TripTypeID INT
AS
BEGIN
    -- Set IsActive to 0 — never hard delete
    UPDATE tblTripType
    SET    IsActive   = 0
    WHERE  TripTypeID = @TripTypeID;
END;
GO

-- Find a trip type by ID
CREATE PROCEDURE spFindTripType
    @TripTypeID INT
AS
BEGIN
    -- Return single trip type record
    SELECT TripTypeID, TypeName, Description, BaseRate, CreatedDate, IsActive
    FROM   tblTripType
    WHERE  TripTypeID = @TripTypeID;
END;
GO

-- Filter trip types by name keyword
CREATE PROCEDURE spFilterTripTypes
    @TypeName VARCHAR(50) = NULL
AS
BEGIN
    -- Filter active trip types by optional name keyword
    SELECT TripTypeID, TypeName, Description, BaseRate, CreatedDate, IsActive
    FROM   tblTripType
    WHERE  IsActive = 1
    AND   (@TypeName IS NULL OR TypeName LIKE '%' + @TypeName + '%')
    ORDER BY TypeName;
END;
GO

-- =============================================
-- STEP 10 — Stored Procedures for tblTrip
-- =============================================

-- List all active trips
CREATE PROCEDURE spListTrips
AS
BEGIN
    -- Returns all active trips joined with trip type name
    SELECT t.TripID, t.CustomerID, t.VehicleID, t.DriverID,
           t.TripTypeID, tt.TypeName, t.TripDate, t.IsActive
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.IsActive = 1
    ORDER BY t.TripDate DESC;
END;
GO

-- Add a new trip
CREATE PROCEDURE spAddTrip
    @CustomerID INT,
    @VehicleID  INT,
    @DriverID   INT = NULL,
    @TripTypeID INT,
    @TripDate   DATE,
    @NewTripID  INT OUTPUT
AS
BEGIN
    -- Insert new trip and return new TripID
    INSERT INTO tblTrip (CustomerID, VehicleID, DriverID, TripTypeID, TripDate, IsActive)
    VALUES (@CustomerID, @VehicleID, @DriverID, @TripTypeID, @TripDate, 1);
    SET @NewTripID = SCOPE_IDENTITY();
END;
GO

-- Edit an existing trip
CREATE PROCEDURE spEditTrip
    @TripID     INT,
    @CustomerID INT,
    @VehicleID  INT,
    @DriverID   INT = NULL,
    @TripTypeID INT,
    @TripDate   DATE
AS
BEGIN
    -- Update trip record fields by TripID
    UPDATE tblTrip
    SET    CustomerID = @CustomerID,
           VehicleID  = @VehicleID,
           DriverID   = @DriverID,
           TripTypeID = @TripTypeID,
           TripDate   = @TripDate
    WHERE  TripID     = @TripID;
END;
GO

-- Soft delete a trip
CREATE PROCEDURE spDeleteTrip
    @TripID INT
AS
BEGIN
    -- Set IsActive to 0 — never hard delete
    UPDATE tblTrip
    SET    IsActive = 0
    WHERE  TripID   = @TripID;
END;
GO

-- Find a trip by ID
CREATE PROCEDURE spFindTrip
    @TripID INT
AS
BEGIN
    -- Return single trip record joined with trip type name
    SELECT t.TripID, t.CustomerID, t.VehicleID, t.DriverID,
           t.TripTypeID, tt.TypeName, t.TripDate, t.IsActive
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.TripID = @TripID;
END;
GO

-- Filter trips by trip type or date
CREATE PROCEDURE spFilterTrips
    @TripTypeID INT  = NULL,
    @TripDate   DATE = NULL
AS
BEGIN
    -- Filter active trips by optional trip type and/or date
    SELECT t.TripID, t.CustomerID, t.VehicleID, t.DriverID,
           t.TripTypeID, tt.TypeName, t.TripDate, t.IsActive
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.IsActive   = 1
    AND   (@TripTypeID IS NULL OR t.TripTypeID = @TripTypeID)
    AND   (@TripDate   IS NULL OR t.TripDate   = @TripDate)
    ORDER BY t.TripDate DESC;
END;
GO

-- =============================================
-- STEP 11 — Advanced filter stored procedure for TripTypeFilter.aspx
-- =============================================

-- Advanced filter: status and/or base rate range
CREATE PROCEDURE spFilterTripTypesAdvanced
    @IsActive  BIT          = NULL,
    @MinRate   DECIMAL(8,2) = NULL,
    @MaxRate   DECIMAL(8,2) = NULL
AS
BEGIN
    -- Return trip types matching all supplied filter criteria.
    -- NULL parameter means skip that criterion (return all for that field).
    SELECT TripTypeID, TypeName, Description, BaseRate, CreatedDate, IsActive
    FROM   tblTripType
    WHERE  (@IsActive IS NULL OR IsActive  = @IsActive)
    AND    (@MinRate  IS NULL OR BaseRate  >= @MinRate)
    AND    (@MaxRate  IS NULL OR BaseRate  <= @MaxRate)
    ORDER BY TripTypeID;
END;
GO

-- =============================================
-- VERIFICATION — Run this to confirm everything
-- =============================================

SELECT 'tblTripType'  AS TableName, COUNT(*) AS Rows FROM tblTripType
UNION ALL
SELECT 'tblTrip',     COUNT(*) FROM tblTrip
UNION ALL
SELECT 'tblCustomer', COUNT(*) FROM tblCustomer
UNION ALL
SELECT 'tblVehicle',  COUNT(*) FROM tblVehicle
UNION ALL
SELECT 'tblDriver',   COUNT(*) FROM tblDriver;

SELECT name AS StoredProcedure
FROM   sys.objects
WHERE  type = 'P'
ORDER BY name;
