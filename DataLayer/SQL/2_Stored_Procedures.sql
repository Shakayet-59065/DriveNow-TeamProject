-- ============================================================
-- DriveNow — Script 2: All Stored Procedures
-- Run AFTER Script 1 (tables must exist first).
-- Safe to re-run: uses DROP IF EXISTS before every CREATE.
-- ============================================================

USE DriveNow;
GO

-- ============================================================
-- STAFF AUTH
-- ============================================================

IF OBJECT_ID('dbo.spStaffLogin','P') IS NOT NULL DROP PROCEDURE dbo.spStaffLogin;
GO
-- Column in tblStaff is PasswordHash (not Password)
CREATE PROCEDURE spStaffLogin
    @Username VARCHAR(50),
    @Password VARCHAR(255)
AS
BEGIN
    SELECT StaffID, FullName, Username
    FROM   tblStaff
    WHERE  Username     = @Username
    AND    PasswordHash = @Password
    AND    IsActive     = 1;
END;
GO

IF OBJECT_ID('dbo.spCustomerLogin','P') IS NOT NULL DROP PROCEDURE dbo.spCustomerLogin;
GO
-- Returns row by email only — password verified in C# via PasswordHelper
CREATE PROCEDURE spCustomerLogin
    @Email VARCHAR(150)
AS
BEGIN
    SELECT CustomerID, FullName, Email, PasswordHash
    FROM   tblCustomer
    WHERE  Email    = @Email
    AND    IsActive = 1;
END;
GO

-- ============================================================
-- CUSTOMER (Tahmid)
-- ============================================================

IF OBJECT_ID('dbo.spListCustomers','P') IS NOT NULL DROP PROCEDURE dbo.spListCustomers;
GO
CREATE PROCEDURE spListCustomers
AS
BEGIN
    SELECT CustomerID, FullName, Email, Phone, RegisterDate, IsActive
    FROM   tblCustomer
    ORDER  BY FullName;
END;
GO

IF OBJECT_ID('dbo.spFindCustomer','P') IS NOT NULL DROP PROCEDURE dbo.spFindCustomer;
GO
CREATE PROCEDURE spFindCustomer
    @CustomerID INT          = NULL,
    @FullName   VARCHAR(100) = NULL
AS
BEGIN
    SELECT CustomerID, FullName, Email, Phone, RegisterDate, IsActive
    FROM   tblCustomer
    WHERE  (@CustomerID IS NULL OR CustomerID = @CustomerID)
    AND    (@FullName   IS NULL OR FullName LIKE '%' + @FullName + '%');
END;
GO

IF OBJECT_ID('dbo.spAddCustomer','P') IS NOT NULL DROP PROCEDURE dbo.spAddCustomer;
GO
CREATE PROCEDURE spAddCustomer
    @FullName     VARCHAR(100),
    @Email        VARCHAR(150),
    @Phone        VARCHAR(20),
    @PasswordHash VARCHAR(255)
AS
BEGIN
    INSERT INTO tblCustomer (FullName, Email, Phone, PasswordHash, RegisterDate, IsActive)
    VALUES (@FullName, @Email, @Phone, @PasswordHash, GETDATE(), 1);
    SELECT SCOPE_IDENTITY();
END;
GO

IF OBJECT_ID('dbo.spEditCustomer','P') IS NOT NULL DROP PROCEDURE dbo.spEditCustomer;
GO
CREATE PROCEDURE spEditCustomer
    @CustomerID INT,
    @FullName   VARCHAR(100),
    @Email      VARCHAR(150),
    @Phone      VARCHAR(20),
    @IsActive   BIT
AS
BEGIN
    UPDATE tblCustomer
    SET    FullName = @FullName, Email = @Email,
           Phone   = @Phone,    IsActive = @IsActive
    WHERE  CustomerID = @CustomerID;
END;
GO

IF OBJECT_ID('dbo.spDeleteCustomer','P') IS NOT NULL DROP PROCEDURE dbo.spDeleteCustomer;
GO
CREATE PROCEDURE spDeleteCustomer
    @CustomerID INT
AS
BEGIN
    UPDATE tblCustomer SET IsActive = 0 WHERE CustomerID = @CustomerID;
END;
GO

IF OBJECT_ID('dbo.spFilterCustomers','P') IS NOT NULL DROP PROCEDURE dbo.spFilterCustomers;
GO
CREATE PROCEDURE spFilterCustomers
    @RegisterDateFrom DATE = NULL,
    @IsActive         BIT  = NULL
AS
BEGIN
    SELECT CustomerID, FullName, Email, Phone, RegisterDate, IsActive
    FROM   tblCustomer
    WHERE  (@RegisterDateFrom IS NULL OR RegisterDate >= @RegisterDateFrom)
    AND    (@IsActive         IS NULL OR IsActive     = @IsActive)
    ORDER  BY FullName;
END;
GO

-- ============================================================
-- TRIP TYPE (Musanna)
-- ============================================================

IF OBJECT_ID('dbo.spListTripTypes','P') IS NOT NULL DROP PROCEDURE dbo.spListTripTypes;
GO
CREATE PROCEDURE spListTripTypes
AS
BEGIN
    SELECT TripTypeID, TypeName, Description, BaseRate, CreatedDate, IsActive
    FROM   tblTripType
    WHERE  IsActive = 1
    ORDER  BY TypeName;
END;
GO

IF OBJECT_ID('dbo.spFindTripType','P') IS NOT NULL DROP PROCEDURE dbo.spFindTripType;
GO
CREATE PROCEDURE spFindTripType
    @TripTypeID INT
AS
BEGIN
    SELECT TripTypeID, TypeName, Description, BaseRate, CreatedDate, IsActive
    FROM   tblTripType
    WHERE  TripTypeID = @TripTypeID;
END;
GO

IF OBJECT_ID('dbo.spAddTripType','P') IS NOT NULL DROP PROCEDURE dbo.spAddTripType;
GO
CREATE PROCEDURE spAddTripType
    @TypeName    VARCHAR(50),
    @Description VARCHAR(200) = NULL,
    @BaseRate    DECIMAL(8,2),
    @NewID       INT OUTPUT
AS
BEGIN
    INSERT INTO tblTripType (TypeName, Description, BaseRate, CreatedDate, IsActive)
    VALUES (@TypeName, @Description, @BaseRate, GETDATE(), 1);
    SET @NewID = SCOPE_IDENTITY();
END;
GO

IF OBJECT_ID('dbo.spEditTripType','P') IS NOT NULL DROP PROCEDURE dbo.spEditTripType;
GO
CREATE PROCEDURE spEditTripType
    @TripTypeID  INT,
    @TypeName    VARCHAR(50),
    @Description VARCHAR(200) = NULL,
    @BaseRate    DECIMAL(8,2)
AS
BEGIN
    UPDATE tblTripType
    SET    TypeName = @TypeName, Description = @Description, BaseRate = @BaseRate
    WHERE  TripTypeID = @TripTypeID;
END;
GO

IF OBJECT_ID('dbo.spDeleteTripType','P') IS NOT NULL DROP PROCEDURE dbo.spDeleteTripType;
GO
CREATE PROCEDURE spDeleteTripType
    @TripTypeID INT
AS
BEGIN
    UPDATE tblTripType SET IsActive = 0 WHERE TripTypeID = @TripTypeID;
END;
GO

IF OBJECT_ID('dbo.spFilterTripTypes','P') IS NOT NULL DROP PROCEDURE dbo.spFilterTripTypes;
GO
CREATE PROCEDURE spFilterTripTypes
    @TypeName VARCHAR(50) = NULL
AS
BEGIN
    SELECT TripTypeID, TypeName, Description, BaseRate, CreatedDate, IsActive
    FROM   tblTripType
    WHERE  IsActive = 1
    AND    (@TypeName IS NULL OR TypeName LIKE '%' + @TypeName + '%')
    ORDER  BY TypeName;
END;
GO

-- ============================================================
-- TRIP (Musanna)
-- ============================================================

IF OBJECT_ID('dbo.spListTrips','P') IS NOT NULL DROP PROCEDURE dbo.spListTrips;
GO
CREATE PROCEDURE spListTrips
AS
BEGIN
    SELECT t.TripID, t.CustomerID, t.VehicleID, t.DriverID,
           t.TripTypeID, tt.TypeName, t.TripDate, t.IsActive
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.IsActive = 1
    ORDER  BY t.TripDate DESC;
END;
GO

IF OBJECT_ID('dbo.spFindTrip','P') IS NOT NULL DROP PROCEDURE dbo.spFindTrip;
GO
CREATE PROCEDURE spFindTrip
    @TripID INT
AS
BEGIN
    SELECT t.TripID, t.CustomerID, t.VehicleID, t.DriverID,
           t.TripTypeID, tt.TypeName, t.TripDate, t.IsActive
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.TripID = @TripID;
END;
GO

IF OBJECT_ID('dbo.spAddTrip','P') IS NOT NULL DROP PROCEDURE dbo.spAddTrip;
GO
CREATE PROCEDURE spAddTrip
    @CustomerID INT,
    @VehicleID  INT,
    @DriverID   INT = NULL,
    @TripTypeID INT,
    @TripDate   DATE,
    @NewTripID  INT OUTPUT
AS
BEGIN
    INSERT INTO tblTrip (CustomerID, VehicleID, DriverID, TripTypeID, TripDate, IsActive)
    VALUES (@CustomerID, @VehicleID, @DriverID, @TripTypeID, @TripDate, 1);
    SET @NewTripID = SCOPE_IDENTITY();
END;
GO

IF OBJECT_ID('dbo.spEditTrip','P') IS NOT NULL DROP PROCEDURE dbo.spEditTrip;
GO
CREATE PROCEDURE spEditTrip
    @TripID     INT,
    @CustomerID INT,
    @VehicleID  INT,
    @DriverID   INT = NULL,
    @TripTypeID INT,
    @TripDate   DATE
AS
BEGIN
    UPDATE tblTrip
    SET    CustomerID = @CustomerID, VehicleID = @VehicleID,
           DriverID   = @DriverID,   TripTypeID = @TripTypeID,
           TripDate   = @TripDate
    WHERE  TripID = @TripID;
END;
GO

IF OBJECT_ID('dbo.spDeleteTrip','P') IS NOT NULL DROP PROCEDURE dbo.spDeleteTrip;
GO
CREATE PROCEDURE spDeleteTrip
    @TripID INT
AS
BEGIN
    UPDATE tblTrip SET IsActive = 0 WHERE TripID = @TripID;
END;
GO

IF OBJECT_ID('dbo.spFilterTrips','P') IS NOT NULL DROP PROCEDURE dbo.spFilterTrips;
GO
CREATE PROCEDURE spFilterTrips
    @TripTypeID INT  = NULL,
    @TripDate   DATE = NULL
AS
BEGIN
    SELECT t.TripID, t.CustomerID, t.VehicleID, t.DriverID,
           t.TripTypeID, tt.TypeName, t.TripDate, t.IsActive
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.IsActive = 1
    AND    (@TripTypeID IS NULL OR t.TripTypeID = @TripTypeID)
    AND    (@TripDate   IS NULL OR t.TripDate   = @TripDate)
    ORDER  BY t.TripDate DESC;
END;
GO

-- ============================================================
-- CUSTOMER TRIP
-- ============================================================

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

IF OBJECT_ID('dbo.spListCustomerTrips','P') IS NOT NULL DROP PROCEDURE dbo.spListCustomerTrips;
GO
CREATE PROCEDURE spListCustomerTrips
    @CustomerID INT
AS
BEGIN
    SELECT
        ct.CustomerTripID, ct.TripID, ct.CustomerID,
        ct.PickupLocation, ct.PickupDate,
        ct.DropoffLocation, ct.DropoffDate,
        ct.Notes, ct.IsActive,
        tt.TypeName, tt.BaseRate,
        v.Make  AS VehicleMake, v.Model AS VehicleModel, v.RegistrationNo,
        d.FullName AS DriverName
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

IF OBJECT_ID('dbo.spFindCustomerTrip','P') IS NOT NULL DROP PROCEDURE dbo.spFindCustomerTrip;
GO
CREATE PROCEDURE spFindCustomerTrip
    @CustomerTripID INT
AS
BEGIN
    SELECT
        ct.CustomerTripID, ct.TripID, ct.CustomerID,
        ct.PickupLocation, ct.PickupDate,
        ct.DropoffLocation, ct.DropoffDate,
        ct.Notes, ct.IsActive,
        tt.TypeName, tt.BaseRate,
        v.Make  AS VehicleMake, v.Model AS VehicleModel, v.RegistrationNo,
        d.FullName AS DriverName
    FROM   tblCustomerTrip ct
    INNER JOIN tblTrip     t  ON ct.TripID    = t.TripID
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    INNER JOIN tblVehicle  v  ON t.VehicleID  = v.VehicleID
    LEFT  JOIN tblDriver   d  ON t.DriverID   = d.DriverID
    WHERE  ct.CustomerTripID = @CustomerTripID;
END;
GO

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
    SET    PickupLocation  = @PickupLocation, PickupDate      = @PickupDate,
           DropoffLocation = @DropoffLocation, DropoffDate    = @DropoffDate,
           Notes           = @Notes
    WHERE  CustomerTripID  = @CustomerTripID;
END;
GO

IF OBJECT_ID('dbo.spDeleteCustomerTrip','P') IS NOT NULL DROP PROCEDURE dbo.spDeleteCustomerTrip;
GO
CREATE PROCEDURE spDeleteCustomerTrip
    @CustomerTripID INT
AS
BEGIN
    UPDATE tblCustomerTrip SET IsActive = 0 WHERE CustomerTripID = @CustomerTripID;
END;
GO

-- ============================================================
-- VEHICLE (Prodip)
-- ============================================================

IF OBJECT_ID('dbo.spListVehicles','P') IS NOT NULL DROP PROCEDURE dbo.spListVehicles;
GO
CREATE PROCEDURE spListVehicles
AS
BEGIN
    SELECT VehicleID, RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable
    FROM   tblVehicle
    WHERE  IsAvailable = 1
    ORDER  BY Make, Model;
END;
GO

IF OBJECT_ID('dbo.spFindVehicle','P') IS NOT NULL DROP PROCEDURE dbo.spFindVehicle;
GO
CREATE PROCEDURE spFindVehicle
    @VehicleID INT
AS
BEGIN
    SELECT VehicleID, RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable
    FROM   tblVehicle
    WHERE  VehicleID = @VehicleID;
END;
GO

IF OBJECT_ID('dbo.spAddVehicle','P') IS NOT NULL DROP PROCEDURE dbo.spAddVehicle;
GO
CREATE PROCEDURE spAddVehicle
    @RegistrationNo VARCHAR(20),
    @Make           VARCHAR(50),
    @Model          VARCHAR(50),
    @DailyRate      DECIMAL(8,2),
    @DateAdded      DATE
AS
BEGIN
    INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable)
    VALUES (@RegistrationNo, @Make, @Model, @DailyRate, @DateAdded, 1);
    SELECT SCOPE_IDENTITY();
END;
GO

IF OBJECT_ID('dbo.spEditVehicle','P') IS NOT NULL DROP PROCEDURE dbo.spEditVehicle;
GO
CREATE PROCEDURE spEditVehicle
    @VehicleID      INT,
    @RegistrationNo VARCHAR(20),
    @Make           VARCHAR(50),
    @Model          VARCHAR(50),
    @DailyRate      DECIMAL(8,2),
    @DateAdded      DATE
AS
BEGIN
    UPDATE tblVehicle
    SET    RegistrationNo = @RegistrationNo, Make = @Make, Model = @Model,
           DailyRate      = @DailyRate,      DateAdded = @DateAdded
    WHERE  VehicleID = @VehicleID;
END;
GO

IF OBJECT_ID('dbo.spDeleteVehicle','P') IS NOT NULL DROP PROCEDURE dbo.spDeleteVehicle;
GO
CREATE PROCEDURE spDeleteVehicle
    @VehicleID INT
AS
BEGIN
    UPDATE tblVehicle SET IsAvailable = 0 WHERE VehicleID = @VehicleID;
END;
GO

IF OBJECT_ID('dbo.spFilterVehicles','P') IS NOT NULL DROP PROCEDURE dbo.spFilterVehicles;
GO
CREATE PROCEDURE spFilterVehicles
    @AvailabilityFilter BIT  = NULL,
    @DateAddedFrom      DATE = NULL
AS
BEGIN
    SELECT VehicleID, RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable
    FROM   tblVehicle
    WHERE  (@AvailabilityFilter IS NULL OR IsAvailable = @AvailabilityFilter)
    AND    (@DateAddedFrom      IS NULL OR DateAdded  >= @DateAddedFrom)
    ORDER  BY Make, Model;
END;
GO

-- ============================================================
-- DRIVER (Redoy)
-- ============================================================

IF OBJECT_ID('dbo.spListDrivers','P') IS NOT NULL DROP PROCEDURE dbo.spListDrivers;
GO
CREATE PROCEDURE spListDrivers
AS
BEGIN
    SELECT DriverID, FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive
    FROM   tblDriver
    WHERE  IsActive = 1
    ORDER  BY FullName;
END;
GO

IF OBJECT_ID('dbo.spFindDriver','P') IS NOT NULL DROP PROCEDURE dbo.spFindDriver;
GO
CREATE PROCEDURE spFindDriver
    @DriverID INT          = NULL,
    @FullName VARCHAR(100) = NULL
AS
BEGIN
    SELECT DriverID, FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive
    FROM   tblDriver
    WHERE  (@DriverID IS NULL OR DriverID = @DriverID)
    AND    (@FullName IS NULL OR FullName LIKE '%' + @FullName + '%');
END;
GO

IF OBJECT_ID('dbo.spAddDriver','P') IS NOT NULL DROP PROCEDURE dbo.spAddDriver;
GO
CREATE PROCEDURE spAddDriver
    @FullName      VARCHAR(100),
    @Phone         VARCHAR(20),
    @LicenceNumber VARCHAR(30),
    @DateOfBirth   DATE,
    @JoinDate      DATE
AS
BEGIN
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES (@FullName, @Phone, @LicenceNumber, @DateOfBirth, @JoinDate, 1);
    SELECT SCOPE_IDENTITY();
END;
GO

IF OBJECT_ID('dbo.spEditDriver','P') IS NOT NULL DROP PROCEDURE dbo.spEditDriver;
GO
CREATE PROCEDURE spEditDriver
    @DriverID      INT,
    @FullName      VARCHAR(100),
    @Phone         VARCHAR(20),
    @LicenceNumber VARCHAR(30),
    @DateOfBirth   DATE,
    @JoinDate      DATE
AS
BEGIN
    UPDATE tblDriver
    SET    FullName = @FullName, Phone = @Phone, LicenceNumber = @LicenceNumber,
           DateOfBirth = @DateOfBirth, JoinDate = @JoinDate
    WHERE  DriverID = @DriverID;
END;
GO

IF OBJECT_ID('dbo.spDeleteDriver','P') IS NOT NULL DROP PROCEDURE dbo.spDeleteDriver;
GO
CREATE PROCEDURE spDeleteDriver
    @DriverID INT
AS
BEGIN
    UPDATE tblDriver SET IsActive = 0 WHERE DriverID = @DriverID;
END;
GO

IF OBJECT_ID('dbo.spFilterDrivers','P') IS NOT NULL DROP PROCEDURE dbo.spFilterDrivers;
GO
CREATE PROCEDURE spFilterDrivers
    @JoinDateFrom DATE = NULL,
    @JoinDateTo   DATE = NULL,
    @IsActive     BIT  = NULL
AS
BEGIN
    SELECT DriverID, FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive
    FROM   tblDriver
    WHERE  (@JoinDateFrom IS NULL OR JoinDate >= @JoinDateFrom)
    AND    (@JoinDateTo   IS NULL OR JoinDate <= @JoinDateTo)
    AND    (@IsActive     IS NULL OR IsActive  = @IsActive)
    ORDER  BY FullName;
END;
GO

-- ============================================================
-- CONTRIBUTOR (Ushno)
-- Table columns: ContributorID, FullName, Email, Phone,
--                ContributorType (Driver/VehicleOwner),
--                ApplicationDate, IsApproved
-- ============================================================

IF OBJECT_ID('dbo.spListContributors','P') IS NOT NULL DROP PROCEDURE dbo.spListContributors;
GO
CREATE PROCEDURE spListContributors
AS
BEGIN
    SELECT ContributorID, FullName, Email, Phone, ContributorType, ApplicationDate, IsApproved
    FROM   tblContributor
    ORDER  BY ApplicationDate DESC;
END;
GO

IF OBJECT_ID('dbo.spFindContributor','P') IS NOT NULL DROP PROCEDURE dbo.spFindContributor;
GO
CREATE PROCEDURE spFindContributor
    @ContributorID INT          = NULL,
    @FullName      VARCHAR(100) = NULL
AS
BEGIN
    SELECT ContributorID, FullName, Email, Phone, ContributorType, ApplicationDate, IsApproved
    FROM   tblContributor
    WHERE  (@ContributorID IS NULL OR ContributorID = @ContributorID)
    AND    (@FullName      IS NULL OR FullName LIKE '%' + @FullName + '%');
END;
GO

IF OBJECT_ID('dbo.spAddContributor','P') IS NOT NULL DROP PROCEDURE dbo.spAddContributor;
GO
CREATE PROCEDURE spAddContributor
    @FullName        VARCHAR(100),
    @Email           VARCHAR(150),
    @Phone           VARCHAR(20),
    @ContributorType VARCHAR(20),
    @ApplicationDate DATE,
    @NewID           INT OUTPUT
AS
BEGIN
    INSERT INTO tblContributor (FullName, Email, Phone, ContributorType, ApplicationDate, IsApproved)
    VALUES (@FullName, @Email, @Phone, @ContributorType, @ApplicationDate, 0);
    SET @NewID = SCOPE_IDENTITY();
END;
GO

IF OBJECT_ID('dbo.spEditContributor','P') IS NOT NULL DROP PROCEDURE dbo.spEditContributor;
GO
CREATE PROCEDURE spEditContributor
    @ContributorID   INT,
    @FullName        VARCHAR(100),
    @Email           VARCHAR(150),
    @Phone           VARCHAR(20),
    @ContributorType VARCHAR(20),
    @IsApproved      BIT
AS
BEGIN
    UPDATE tblContributor
    SET    FullName = @FullName, Email = @Email, Phone = @Phone,
           ContributorType = @ContributorType, IsApproved = @IsApproved
    WHERE  ContributorID = @ContributorID;
END;
GO

IF OBJECT_ID('dbo.spDeleteContributor','P') IS NOT NULL DROP PROCEDURE dbo.spDeleteContributor;
GO
CREATE PROCEDURE spDeleteContributor
    @ContributorID INT
AS
BEGIN
    UPDATE tblContribVehicle SET IsAvailable = 0 WHERE ContributorID = @ContributorID;
    UPDATE tblContributor    SET IsApproved  = 0 WHERE ContributorID = @ContributorID;
END;
GO

IF OBJECT_ID('dbo.spFilterContributors','P') IS NOT NULL DROP PROCEDURE dbo.spFilterContributors;
GO
CREATE PROCEDURE spFilterContributors
    @ContributorType VARCHAR(20) = NULL,
    @IsApproved      BIT         = NULL
AS
BEGIN
    SELECT ContributorID, FullName, Email, Phone, ContributorType, ApplicationDate, IsApproved
    FROM   tblContributor
    WHERE  (@ContributorType IS NULL OR ContributorType = @ContributorType)
    AND    (@IsApproved      IS NULL OR IsApproved      = @IsApproved)
    ORDER  BY ApplicationDate DESC;
END;
GO

-- ============================================================
-- CONTRIB VEHICLE (Ushno)
-- Table columns: ContribVehicleID, ContributorID,
--                Make, Model, Year, RegistrationNo, IsAvailable
-- ============================================================

IF OBJECT_ID('dbo.spListContribVehicles','P') IS NOT NULL DROP PROCEDURE dbo.spListContribVehicles;
GO
CREATE PROCEDURE spListContribVehicles
    @ContributorID INT
AS
BEGIN
    SELECT ContribVehicleID, ContributorID, Make, Model, Year, RegistrationNo, IsAvailable
    FROM   tblContribVehicle
    WHERE  ContributorID = @ContributorID
    AND    IsAvailable   = 1;
END;
GO

IF OBJECT_ID('dbo.spFindContribVehicle','P') IS NOT NULL DROP PROCEDURE dbo.spFindContribVehicle;
GO
CREATE PROCEDURE spFindContribVehicle
    @ContribVehicleID INT
AS
BEGIN
    SELECT ContribVehicleID, ContributorID, Make, Model, Year, RegistrationNo, IsAvailable
    FROM   tblContribVehicle
    WHERE  ContribVehicleID = @ContribVehicleID;
END;
GO

IF OBJECT_ID('dbo.spAddContribVehicle','P') IS NOT NULL DROP PROCEDURE dbo.spAddContribVehicle;
GO
CREATE PROCEDURE spAddContribVehicle
    @ContributorID  INT,
    @Make           VARCHAR(50),
    @Model          VARCHAR(50),
    @Year           INT,
    @RegistrationNo VARCHAR(20),
    @NewID          INT OUTPUT
AS
BEGIN
    INSERT INTO tblContribVehicle (ContributorID, Make, Model, Year, RegistrationNo, IsAvailable)
    VALUES (@ContributorID, @Make, @Model, @Year, @RegistrationNo, 1);
    SET @NewID = SCOPE_IDENTITY();
END;
GO

IF OBJECT_ID('dbo.spEditContribVehicle','P') IS NOT NULL DROP PROCEDURE dbo.spEditContribVehicle;
GO
CREATE PROCEDURE spEditContribVehicle
    @ContribVehicleID INT,
    @Make             VARCHAR(50),
    @Model            VARCHAR(50),
    @Year             INT,
    @RegistrationNo   VARCHAR(20)
AS
BEGIN
    UPDATE tblContribVehicle
    SET    Make = @Make, Model = @Model, Year = @Year, RegistrationNo = @RegistrationNo
    WHERE  ContribVehicleID = @ContribVehicleID;
END;
GO

IF OBJECT_ID('dbo.spDeleteContribVehicle','P') IS NOT NULL DROP PROCEDURE dbo.spDeleteContribVehicle;
GO
CREATE PROCEDURE spDeleteContribVehicle
    @ContribVehicleID INT
AS
BEGIN
    UPDATE tblContribVehicle SET IsAvailable = 0 WHERE ContribVehicleID = @ContribVehicleID;
END;
GO

-- ------------------------------------------------------------
-- Verify
-- ------------------------------------------------------------
SELECT name AS [Stored Procedure] FROM sys.objects WHERE type = 'P' ORDER BY name;
PRINT 'Script 2 complete — all stored procedures created/updated.';
GO
