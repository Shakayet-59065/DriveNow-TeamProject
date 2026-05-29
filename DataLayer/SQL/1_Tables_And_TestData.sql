-- ============================================================
-- DriveNow — Script 1: Tables and Test Data
-- Run this FIRST on a brand-new database.
-- Safe to re-run: tables are only created if they don't exist.
--
-- Order matters — FKs require parent tables to exist first:
--   TripType → (no deps)
--   Customer → (no deps)
--   Vehicle  → (no deps)
--   Driver   → (no deps)
--   Staff    → (no deps)
--   Trip     → Customer, Vehicle, Driver, TripType
--   CustomerTrip → Trip, Customer
--   Contributor  → (no deps)
--   ContribVehicle → Contributor
-- ============================================================

USE DriveNow;
GO

-- ------------------------------------------------------------
-- tblTripType
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.tblTripType','U') IS NULL
BEGIN
    CREATE TABLE tblTripType (
        TripTypeID  INT          IDENTITY(1,1) NOT NULL,
        TypeName    VARCHAR(50)               NOT NULL,
        Description VARCHAR(200)              NULL,
        BaseRate    DECIMAL(8,2)              NOT NULL,
        CreatedDate DATE                      NOT NULL,
        IsActive    BIT          DEFAULT 1    NOT NULL,
        CONSTRAINT PK_tblTripType PRIMARY KEY (TripTypeID),
        CONSTRAINT UQ_TypeName    UNIQUE (TypeName)
    );
    INSERT INTO tblTripType (TypeName, Description, BaseRate, CreatedDate, IsActive) VALUES
    ('Short Ride',         'A short point-to-point journey with a driver.',        5.99,  '2026-04-20', 1),
    ('Chauffeured Rental', 'Longer hire with a DriveNow driver included.',          15.99, '2026-04-20', 1),
    ('Self-Drive Rental',  'Vehicle hire with no driver. Customer drives.',         12.99, '2026-04-20', 1),
    ('Airport Transfer',   'Dedicated airport transfer with a driver.',             20.99, '2026-04-20', 1),
    ('Corporate Hire',     'Extended chauffeured hire for business. Full day.',     49.99, '2026-04-20', 1);
    PRINT 'Created tblTripType with 5 rows';
END
ELSE PRINT 'tblTripType already exists';
GO

-- ------------------------------------------------------------
-- tblCustomer
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.tblCustomer','U') IS NULL
BEGIN
    CREATE TABLE tblCustomer (
        CustomerID   INT          IDENTITY(1,1) NOT NULL,
        FullName     VARCHAR(100)               NOT NULL,
        Email        VARCHAR(150)               NOT NULL,
        Phone        VARCHAR(20)                NOT NULL,
        PasswordHash VARCHAR(255)               NOT NULL,
        RegisterDate DATE                       NOT NULL,
        IsActive     BIT          DEFAULT 1     NOT NULL,
        CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerID)
    );
    -- Test customers — password is the plain text value (PasswordHelper accepts plain text for dev)
    INSERT INTO tblCustomer (FullName, Email, Phone, PasswordHash, RegisterDate, IsActive) VALUES
    ('Alice Jensen', 'alice@email.com', '+4512345678', 'pass123', '2026-01-10', 1),
    ('Bob Nielsen',  'bob@email.com',   '+4598765432', 'pass123', '2026-02-15', 1),
    ('Clara Madsen', 'clara@email.com', '+4511223344', 'pass123', '2026-03-01', 1),
    ('David Holm',   'david@email.com', '+4544556677', 'pass123', '2026-03-15', 1),
    ('Emma Bro',     'emma@email.com',  '+4566778899', 'pass123', '2026-04-01', 1);
    PRINT 'Created tblCustomer with 5 test rows (password = pass123)';
END
ELSE PRINT 'tblCustomer already exists';
GO

-- ------------------------------------------------------------
-- tblVehicle
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.tblVehicle','U') IS NULL
BEGIN
    CREATE TABLE tblVehicle (
        VehicleID      INT          IDENTITY(1,1) NOT NULL,
        RegistrationNo VARCHAR(20)                NOT NULL,
        Make           VARCHAR(50)                NOT NULL,
        Model          VARCHAR(50)                NOT NULL,
        DailyRate      DECIMAL(8,2)               NOT NULL,
        DateAdded      DATE                       NOT NULL,
        IsAvailable    BIT          DEFAULT 1     NOT NULL,
        CONSTRAINT PK_tblVehicle PRIMARY KEY (VehicleID)
    );
    INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable) VALUES
    ('AB12345', 'Toyota',   'Corolla',  45.00,  '2026-01-05', 1),
    ('CD67890', 'BMW',      '5 Series', 120.00, '2026-02-10', 1),
    ('EF11223', 'Tesla',    'Model 3',  95.00,  '2026-03-20', 1),
    ('GH44556', 'Ford',     'Focus',    40.00,  '2026-03-25', 1),
    ('IJ77889', 'Mercedes', 'E-Class',  130.00, '2026-04-01', 1);
    PRINT 'Created tblVehicle with 5 test rows';
END
ELSE PRINT 'tblVehicle already exists';
GO

-- ------------------------------------------------------------
-- tblDriver
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.tblDriver','U') IS NULL
BEGIN
    CREATE TABLE tblDriver (
        DriverID      INT          IDENTITY(1,1) NOT NULL,
        FullName      VARCHAR(100)               NOT NULL,
        Phone         VARCHAR(20)                NOT NULL,
        LicenceNumber VARCHAR(30)                NOT NULL,
        DateOfBirth   DATE                       NOT NULL,
        JoinDate      DATE                       NOT NULL,
        IsActive      BIT          DEFAULT 1     NOT NULL,
        CONSTRAINT PK_tblDriver PRIMARY KEY (DriverID)
    );
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive) VALUES
    ('Mads Hansen', '+4522334455', 'DK-123456', '1990-05-15', '2026-01-15', 1),
    ('Sara Larsen', '+4533445566', 'DK-789012', '1988-08-22', '2026-02-01', 1),
    ('Jonas Berg',  '+4544556677', 'DK-345678', '1992-03-10', '2026-02-20', 1),
    ('Maja Koch',   '+4555667788', 'DK-901234', '1995-07-30', '2026-03-05', 1),
    ('Erik Dahl',   '+4566778899', 'DK-567890', '1985-11-12', '2026-03-15', 1);
    PRINT 'Created tblDriver with 5 test rows';
END
ELSE PRINT 'tblDriver already exists';
GO

-- ------------------------------------------------------------
-- tblStaff
-- Column name is PasswordHash (not Password)
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.tblStaff','U') IS NULL
BEGIN
    CREATE TABLE tblStaff (
        StaffID      INT          IDENTITY(1,1) NOT NULL,
        Username     VARCHAR(50)                NOT NULL,
        PasswordHash VARCHAR(255)               NOT NULL,
        FullName     VARCHAR(100)               NOT NULL,
        IsActive     BIT          DEFAULT 1     NOT NULL,
        CONSTRAINT PK_tblStaff  PRIMARY KEY (StaffID),
        CONSTRAINT UQ_Username  UNIQUE (Username)
    );
    INSERT INTO tblStaff (Username, PasswordHash, FullName, IsActive) VALUES
    ('admin',   'admin123', 'Admin User', 1),
    ('musanna', 'pass123',  'Musanna',    1),
    ('prodip',  'pass123',  'Prodip',     1),
    ('redoy',   'pass123',  'Redoy',      1),
    ('ushno',   'pass123',  'Ushno',      1),
    ('tahmid',  'pass123',  'Tahmid',     1);
    PRINT 'Created tblStaff (staff login: admin/admin123 or username/pass123)';
END
ELSE PRINT 'tblStaff already exists';
GO

-- ------------------------------------------------------------
-- tblTrip (needs Customer, Vehicle, Driver, TripType first)
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.tblTrip','U') IS NULL
BEGIN
    CREATE TABLE tblTrip (
        TripID     INT  IDENTITY(1,1) NOT NULL,
        CustomerID INT                NOT NULL,
        VehicleID  INT                NOT NULL,
        DriverID   INT                NULL,
        TripTypeID INT                NOT NULL,
        TripDate   DATE               NOT NULL,
        IsActive   BIT  DEFAULT 1     NOT NULL,
        CONSTRAINT PK_tblTrip       PRIMARY KEY (TripID),
        CONSTRAINT FK_Trip_Customer FOREIGN KEY (CustomerID) REFERENCES tblCustomer(CustomerID),
        CONSTRAINT FK_Trip_Vehicle  FOREIGN KEY (VehicleID)  REFERENCES tblVehicle(VehicleID),
        CONSTRAINT FK_Trip_Driver   FOREIGN KEY (DriverID)   REFERENCES tblDriver(DriverID),
        CONSTRAINT FK_Trip_TripType FOREIGN KEY (TripTypeID) REFERENCES tblTripType(TripTypeID)
    );
    INSERT INTO tblTrip (CustomerID, VehicleID, DriverID, TripTypeID, TripDate, IsActive) VALUES
    (1, 1, 1,    1, '2026-04-21', 1),
    (2, 2, 2,    2, '2026-04-22', 1),
    (3, 3, NULL, 3, '2026-04-22', 1),
    (4, 4, NULL, 3, '2026-04-23', 1),
    (5, 2, 1,    4, '2026-04-24', 1);
    PRINT 'Created tblTrip with 5 test rows';
END
ELSE PRINT 'tblTrip already exists';
GO

-- ------------------------------------------------------------
-- tblCustomerTrip (needs Trip + Customer)
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.tblCustomerTrip','U') IS NULL
BEGIN
    CREATE TABLE tblCustomerTrip (
        CustomerTripID  INT          IDENTITY(1,1) NOT NULL,
        TripID          INT                        NOT NULL,
        CustomerID      INT                        NOT NULL,
        PickupLocation  VARCHAR(200)               NOT NULL,
        PickupDate      DATETIME                   NOT NULL,
        DropoffLocation VARCHAR(200)               NOT NULL,
        DropoffDate     DATETIME                   NOT NULL,
        Notes           VARCHAR(500)               NULL,
        IsActive        BIT          DEFAULT 1     NOT NULL,
        CONSTRAINT PK_tblCustomerTrip       PRIMARY KEY (CustomerTripID),
        CONSTRAINT FK_CustomerTrip_Trip     FOREIGN KEY (TripID)     REFERENCES tblTrip(TripID),
        CONSTRAINT FK_CustomerTrip_Customer FOREIGN KEY (CustomerID) REFERENCES tblCustomer(CustomerID),
        CONSTRAINT CK_CustomerTrip_Dates    CHECK (DropoffDate > PickupDate)
    );
    INSERT INTO tblCustomerTrip (TripID, CustomerID, PickupLocation, PickupDate, DropoffLocation, DropoffDate, Notes, IsActive) VALUES
    (1, 1, 'Niels Brock Copenhagen, Danasvej 3', '2026-04-21 09:00', 'Copenhagen Central Station',        '2026-04-21 10:30', 'Morning commute',             1),
    (2, 2, 'Hotel Marriott, Kalvebod Brygge',    '2026-04-22 14:00', 'Copenhagen Airport, Terminal 2',    '2026-04-22 15:45', 'Airport transfer - business', 1),
    (3, 3, 'Norreport Station',                  '2026-04-22 11:00', 'Tivoli Gardens, Vesterbrogade 3',   '2026-04-22 13:00', 'Self-drive sightseeing',      1),
    (4, 4, 'Frederiksberg Alle 1',               '2026-04-23 08:30', 'DTU Lyngby Campus',                 '2026-04-23 09:30', 'Self-drive to university',    1),
    (5, 2, 'Copenhagen Airport, Arrivals Hall',  '2026-04-24 16:00', 'Radisson Blu, Amager Blvd 70',      '2026-04-24 17:00', 'Return airport transfer',     1);
    PRINT 'Created tblCustomerTrip with 5 test rows';
END
ELSE PRINT 'tblCustomerTrip already exists';
GO

-- ------------------------------------------------------------
-- tblContributor
-- Columns: ContributorID, FullName, Email, Phone,
--          ContributorType (Driver/VehicleOwner), ApplicationDate, IsApproved
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.tblContributor','U') IS NULL
BEGIN
    CREATE TABLE tblContributor (
        ContributorID   INT          IDENTITY(1,1) NOT NULL,
        FullName        VARCHAR(100)               NOT NULL,
        Email           VARCHAR(150)               NOT NULL,
        Phone           VARCHAR(20)                NOT NULL,
        ContributorType VARCHAR(20)                NOT NULL,
        ApplicationDate DATE                       NOT NULL,
        IsApproved      BIT          DEFAULT 0     NOT NULL,
        CONSTRAINT PK_tblContributor PRIMARY KEY (ContributorID),
        CONSTRAINT CK_ContribType    CHECK (ContributorType IN ('Driver','VehicleOwner'))
    );
    PRINT 'Created tblContributor';
END
ELSE PRINT 'tblContributor already exists';
GO

-- ------------------------------------------------------------
-- tblContribVehicle
-- Columns: ContribVehicleID, ContributorID, Make, Model,
--          Year, RegistrationNo, IsAvailable
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.tblContribVehicle','U') IS NULL
BEGIN
    CREATE TABLE tblContribVehicle (
        ContribVehicleID INT          IDENTITY(1,1) NOT NULL,
        ContributorID    INT                        NOT NULL,
        Make             VARCHAR(50)                NOT NULL,
        Model            VARCHAR(50)                NOT NULL,
        Year             INT                        NOT NULL,
        RegistrationNo   VARCHAR(20)                NOT NULL,
        IsAvailable      BIT          DEFAULT 1     NOT NULL,
        CONSTRAINT PK_tblContribVehicle              PRIMARY KEY (ContribVehicleID),
        CONSTRAINT FK_ContribVehicle_Contributor     FOREIGN KEY (ContributorID)
            REFERENCES tblContributor(ContributorID)
    );
    PRINT 'Created tblContribVehicle';
END
ELSE PRINT 'tblContribVehicle already exists';
GO

-- ------------------------------------------------------------
-- Final check
-- ------------------------------------------------------------
SELECT name AS [Table], create_date AS [Created]
FROM   sys.objects
WHERE  type = 'U'
ORDER  BY create_date;
PRINT 'Script 1 complete.';
GO
