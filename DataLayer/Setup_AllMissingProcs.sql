USE DriveNow;
GO

-- =============================================
-- VEHICLE stored procedures (Prodip)
-- =============================================

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
    SET    RegistrationNo = @RegistrationNo,
           Make           = @Make,
           Model          = @Model,
           DailyRate      = @DailyRate,
           DateAdded      = @DateAdded
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

-- =============================================
-- DRIVER stored procedures (Redoy)
-- =============================================

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
    SET    FullName      = @FullName,
           Phone         = @Phone,
           LicenceNumber = @LicenceNumber,
           DateOfBirth   = @DateOfBirth,
           JoinDate      = @JoinDate
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

-- =============================================
-- CONTRIBUTOR tables + stored procedures (Ushno)
-- =============================================

IF OBJECT_ID('dbo.tblContribVehicle','U') IS NOT NULL DROP TABLE dbo.tblContribVehicle;
IF OBJECT_ID('dbo.tblContributor','U')    IS NOT NULL DROP TABLE dbo.tblContributor;
GO

CREATE TABLE tblContributor
(
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
GO

CREATE TABLE tblContribVehicle
(
    ContribVehicleID INT          IDENTITY(1,1) NOT NULL,
    ContributorID    INT                        NOT NULL,
    Make             VARCHAR(50)                NOT NULL,
    Model            VARCHAR(50)                NOT NULL,
    Year             INT                        NOT NULL,
    RegistrationNo   VARCHAR(20)                NOT NULL,
    IsAvailable      BIT          DEFAULT 1     NOT NULL,
    CONSTRAINT PK_tblContribVehicle PRIMARY KEY (ContribVehicleID),
    CONSTRAINT FK_ContribVehicle_Contributor FOREIGN KEY (ContributorID)
        REFERENCES tblContributor(ContributorID)
);
GO

-- Contributor CRUD
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
    SET    FullName        = @FullName,
           Email           = @Email,
           Phone           = @Phone,
           ContributorType = @ContributorType,
           IsApproved      = @IsApproved
    WHERE  ContributorID   = @ContributorID;
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

-- ContribVehicle CRUD
IF OBJECT_ID('dbo.spAddContribVehicle','P') IS NOT NULL DROP PROCEDURE dbo.spAddContribVehicle;
GO
CREATE PROCEDURE spAddContribVehicle
    @ContributorID INT,
    @Make          VARCHAR(50),
    @Model         VARCHAR(50),
    @Year          INT,
    @RegistrationNo VARCHAR(20),
    @NewID         INT OUTPUT
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
    SET    Make           = @Make,
           Model          = @Model,
           Year           = @Year,
           RegistrationNo = @RegistrationNo
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

-- =============================================
-- VERIFY — shows all stored procedures now in DB
-- =============================================
SELECT name AS AllStoredProcedures FROM sys.objects WHERE type = 'P' ORDER BY name;
