-- =============================================
-- DriveNow — Run This In SSMS To Fix All Missing Database Objects
-- Safe to re-run: uses IF NOT EXISTS / CREATE OR ALTER
-- RUN THIS ENTIRE SCRIPT FROM TOP TO BOTTOM IN SSMS
-- =============================================

USE DriveNow;
GO

-- =============================================
-- 1. Ensure tblStaff exists (for staff login)
-- =============================================
IF OBJECT_ID('dbo.tblStaff','U') IS NULL
BEGIN
    CREATE TABLE tblStaff (
        StaffID   INT          IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Username  VARCHAR(50)  NOT NULL UNIQUE,
        FullName  VARCHAR(100) NOT NULL,
        Password  VARCHAR(255) NOT NULL,
        IsActive  BIT DEFAULT 1 NOT NULL
    );
    INSERT INTO tblStaff (Username, FullName, Password) VALUES
    ('admin',   'Administrator', 'admin123'),
    ('musanna', 'Musanna',       'pass123'),
    ('prodip',  'Prodip',        'pass123'),
    ('redoy',   'Redoy',         'pass123'),
    ('ushno',   'Ushno',         'pass123'),
    ('tahmid',  'Tahmid',        'pass123');
    PRINT 'Created tblStaff with test accounts';
END
ELSE PRINT 'tblStaff already exists';
GO

-- =============================================
-- 2. spStaffLogin
-- =============================================
IF OBJECT_ID('dbo.spStaffLogin','P') IS NULL
    EXEC('CREATE PROCEDURE spStaffLogin @Username VARCHAR(50), @Password VARCHAR(255)
    AS BEGIN
        SELECT StaffID, Username, FullName FROM tblStaff
        WHERE Username=@Username AND Password=@Password AND IsActive=1;
    END');
GO

-- =============================================
-- 3. spCustomerLogin (returns row by email only — C# does hash verify)
-- =============================================
IF OBJECT_ID('dbo.spCustomerLogin','P') IS NOT NULL DROP PROCEDURE spCustomerLogin;
GO
CREATE PROCEDURE spCustomerLogin @Email VARCHAR(150)
AS BEGIN
    SELECT CustomerID, FullName, Email, PasswordHash
    FROM   tblCustomer
    WHERE  Email = @Email AND IsActive = 1;
END;
GO

-- =============================================
-- 4. Customer stored procedures
-- =============================================
IF OBJECT_ID('dbo.spListCustomers','P') IS NULL
    EXEC('CREATE PROCEDURE spListCustomers AS BEGIN
        SELECT CustomerID, FullName, Email, Phone, PasswordHash, RegisterDate, IsActive
        FROM tblCustomer ORDER BY FullName; END');
GO

IF OBJECT_ID('dbo.spFindCustomer','P') IS NULL
    EXEC('CREATE PROCEDURE spFindCustomer @CustomerID INT=NULL, @FullName VARCHAR(100)=NULL AS BEGIN
        SELECT CustomerID, FullName, Email, Phone, RegisterDate, IsActive FROM tblCustomer
        WHERE (@CustomerID IS NULL OR CustomerID=@CustomerID)
        AND   (@FullName   IS NULL OR FullName LIKE ''%''+@FullName+''%''); END');
GO

IF OBJECT_ID('dbo.spAddCustomer','P') IS NULL
    EXEC('CREATE PROCEDURE spAddCustomer
        @FullName VARCHAR(100), @Email VARCHAR(150), @Phone VARCHAR(20), @PasswordHash VARCHAR(255)
    AS BEGIN
        INSERT INTO tblCustomer (FullName, Email, Phone, PasswordHash, RegisterDate, IsActive)
        VALUES (@FullName, @Email, @Phone, @PasswordHash, GETDATE(), 1);
        SELECT SCOPE_IDENTITY();
    END');
GO

IF OBJECT_ID('dbo.spEditCustomer','P') IS NULL
    EXEC('CREATE PROCEDURE spEditCustomer
        @CustomerID INT, @FullName VARCHAR(100), @Email VARCHAR(150), @Phone VARCHAR(20), @IsActive BIT
    AS BEGIN
        UPDATE tblCustomer SET FullName=@FullName, Email=@Email, Phone=@Phone, IsActive=@IsActive
        WHERE CustomerID=@CustomerID; END');
GO

IF OBJECT_ID('dbo.spDeleteCustomer','P') IS NULL
    EXEC('CREATE PROCEDURE spDeleteCustomer @CustomerID INT AS BEGIN
        UPDATE tblCustomer SET IsActive=0 WHERE CustomerID=@CustomerID; END');
GO

IF OBJECT_ID('dbo.spFilterCustomers','P') IS NULL
    EXEC('CREATE PROCEDURE spFilterCustomers @RegisterDateFrom DATE=NULL, @IsActive BIT=NULL
    AS BEGIN
        SELECT CustomerID, FullName, Email, Phone, RegisterDate, IsActive FROM tblCustomer
        WHERE (@RegisterDateFrom IS NULL OR RegisterDate>=@RegisterDateFrom)
        AND   (@IsActive         IS NULL OR IsActive=@IsActive)
        ORDER BY FullName; END');
GO

-- =============================================
-- 5. Vehicle stored procedures
-- =============================================
IF OBJECT_ID('dbo.spListVehicles','P') IS NULL
    EXEC('CREATE PROCEDURE spListVehicles AS BEGIN
        SELECT VehicleID,RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable
        FROM tblVehicle WHERE IsAvailable=1 ORDER BY Make,Model; END');
GO

IF OBJECT_ID('dbo.spFindVehicle','P') IS NULL
    EXEC('CREATE PROCEDURE spFindVehicle @VehicleID INT AS BEGIN
        SELECT VehicleID,RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable
        FROM tblVehicle WHERE VehicleID=@VehicleID; END');
GO

IF OBJECT_ID('dbo.spAddVehicle','P') IS NULL
    EXEC('CREATE PROCEDURE spAddVehicle
        @RegistrationNo VARCHAR(20),@Make VARCHAR(50),@Model VARCHAR(50),@DailyRate DECIMAL(8,2),@DateAdded DATE
    AS BEGIN
        INSERT INTO tblVehicle (RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable)
        VALUES (@RegistrationNo,@Make,@Model,@DailyRate,@DateAdded,1);
        SELECT SCOPE_IDENTITY();
    END');
GO

IF OBJECT_ID('dbo.spEditVehicle','P') IS NULL
    EXEC('CREATE PROCEDURE spEditVehicle
        @VehicleID INT,@RegistrationNo VARCHAR(20),@Make VARCHAR(50),@Model VARCHAR(50),@DailyRate DECIMAL(8,2),@DateAdded DATE
    AS BEGIN
        UPDATE tblVehicle SET RegistrationNo=@RegistrationNo,Make=@Make,Model=@Model,DailyRate=@DailyRate,DateAdded=@DateAdded
        WHERE VehicleID=@VehicleID; END');
GO

IF OBJECT_ID('dbo.spDeleteVehicle','P') IS NULL
    EXEC('CREATE PROCEDURE spDeleteVehicle @VehicleID INT AS BEGIN
        UPDATE tblVehicle SET IsAvailable=0 WHERE VehicleID=@VehicleID; END');
GO

IF OBJECT_ID('dbo.spFilterVehicles','P') IS NULL
    EXEC('CREATE PROCEDURE spFilterVehicles @AvailabilityFilter BIT=NULL, @DateAddedFrom DATE=NULL
    AS BEGIN
        SELECT VehicleID,RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable FROM tblVehicle
        WHERE (@AvailabilityFilter IS NULL OR IsAvailable=@AvailabilityFilter)
        AND   (@DateAddedFrom      IS NULL OR DateAdded>=@DateAddedFrom)
        ORDER BY Make,Model; END');
GO

-- =============================================
-- 6. Driver stored procedures
-- =============================================
IF OBJECT_ID('dbo.spListDrivers','P') IS NULL
    EXEC('CREATE PROCEDURE spListDrivers AS BEGIN
        SELECT DriverID,FullName,Phone,LicenceNumber,DateOfBirth,JoinDate,IsActive
        FROM tblDriver WHERE IsActive=1 ORDER BY FullName; END');
GO

IF OBJECT_ID('dbo.spFindDriver','P') IS NULL
    EXEC('CREATE PROCEDURE spFindDriver @DriverID INT AS BEGIN
        SELECT DriverID,FullName,Phone,LicenceNumber,DateOfBirth,JoinDate,IsActive
        FROM tblDriver WHERE DriverID=@DriverID; END');
GO

IF OBJECT_ID('dbo.spAddDriver','P') IS NULL
    EXEC('CREATE PROCEDURE spAddDriver
        @FullName VARCHAR(100),@Phone VARCHAR(20),@LicenceNumber VARCHAR(30),@DateOfBirth DATE,@JoinDate DATE
    AS BEGIN
        INSERT INTO tblDriver (FullName,Phone,LicenceNumber,DateOfBirth,JoinDate,IsActive)
        VALUES (@FullName,@Phone,@LicenceNumber,@DateOfBirth,@JoinDate,1);
        SELECT SCOPE_IDENTITY();
    END');
GO

IF OBJECT_ID('dbo.spEditDriver','P') IS NULL
    EXEC('CREATE PROCEDURE spEditDriver
        @DriverID INT,@FullName VARCHAR(100),@Phone VARCHAR(20),@LicenceNumber VARCHAR(30),@DateOfBirth DATE,@JoinDate DATE
    AS BEGIN
        UPDATE tblDriver SET FullName=@FullName,Phone=@Phone,LicenceNumber=@LicenceNumber,
        DateOfBirth=@DateOfBirth,JoinDate=@JoinDate WHERE DriverID=@DriverID; END');
GO

IF OBJECT_ID('dbo.spDeleteDriver','P') IS NULL
    EXEC('CREATE PROCEDURE spDeleteDriver @DriverID INT AS BEGIN
        UPDATE tblDriver SET IsActive=0 WHERE DriverID=@DriverID; END');
GO

IF OBJECT_ID('dbo.spFilterDrivers','P') IS NULL
    EXEC('CREATE PROCEDURE spFilterDrivers @FullName VARCHAR(100)=NULL
    AS BEGIN
        SELECT DriverID,FullName,Phone,LicenceNumber,DateOfBirth,JoinDate,IsActive FROM tblDriver
        WHERE IsActive=1 AND (@FullName IS NULL OR FullName LIKE ''%''+@FullName+''%'')
        ORDER BY FullName; END');
GO

-- =============================================
-- 7. tblCustomerTrip table
-- =============================================
IF OBJECT_ID('dbo.tblCustomerTrip','U') IS NULL
BEGIN
    CREATE TABLE tblCustomerTrip (
        CustomerTripID   INT          IDENTITY(1,1) NOT NULL,
        TripID           INT          NOT NULL,
        CustomerID       INT          NOT NULL,
        PickupLocation   VARCHAR(200) NOT NULL,
        PickupDate       DATETIME     NOT NULL,
        DropoffLocation  VARCHAR(200) NOT NULL,
        DropoffDate      DATETIME     NOT NULL,
        Notes            VARCHAR(500) NULL,
        IsActive         BIT DEFAULT 1 NOT NULL,
        CONSTRAINT PK_tblCustomerTrip       PRIMARY KEY (CustomerTripID),
        CONSTRAINT FK_CustomerTrip_Trip     FOREIGN KEY (TripID)     REFERENCES tblTrip(TripID),
        CONSTRAINT FK_CustomerTrip_Customer FOREIGN KEY (CustomerID) REFERENCES tblCustomer(CustomerID),
        CONSTRAINT CK_CustomerTrip_Dates    CHECK (DropoffDate > PickupDate)
    );
    PRINT 'Created tblCustomerTrip';
END
ELSE PRINT 'tblCustomerTrip already exists';
GO

-- =============================================
-- 8. CustomerTrip stored procedures
-- =============================================
IF OBJECT_ID('dbo.spAddCustomerTrip','P') IS NOT NULL DROP PROCEDURE spAddCustomerTrip;
GO
CREATE PROCEDURE spAddCustomerTrip
    @TripID         INT, @CustomerID INT,
    @PickupLocation VARCHAR(200), @PickupDate DATETIME,
    @DropoffLocation VARCHAR(200), @DropoffDate DATETIME,
    @Notes          VARCHAR(500) = NULL,
    @NewID          INT OUTPUT
AS BEGIN
    INSERT INTO tblCustomerTrip (TripID,CustomerID,PickupLocation,PickupDate,DropoffLocation,DropoffDate,Notes,IsActive)
    VALUES (@TripID,@CustomerID,@PickupLocation,@PickupDate,@DropoffLocation,@DropoffDate,@Notes,1);
    SET @NewID = SCOPE_IDENTITY();
END;
GO

IF OBJECT_ID('dbo.spListCustomerTrips','P') IS NOT NULL DROP PROCEDURE spListCustomerTrips;
GO
CREATE PROCEDURE spListCustomerTrips @CustomerID INT
AS BEGIN
    SELECT
        ct.CustomerTripID, ct.TripID, ct.CustomerID,
        ct.PickupLocation, ct.PickupDate, ct.DropoffLocation, ct.DropoffDate,
        ct.Notes, ct.IsActive,
        tt.TypeName, tt.BaseRate,
        v.Make AS VehicleMake, v.Model AS VehicleModel, v.RegistrationNo,
        d.FullName AS DriverName
    FROM   tblCustomerTrip ct
    INNER JOIN tblTrip     t  ON ct.TripID    = t.TripID
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    INNER JOIN tblVehicle  v  ON t.VehicleID  = v.VehicleID
    LEFT  JOIN tblDriver   d  ON t.DriverID   = d.DriverID
    WHERE ct.CustomerID = @CustomerID AND ct.IsActive = 1
    ORDER BY ct.PickupDate DESC;
END;
GO

-- =============================================
-- 9. tblContributor and ContribVehicle
-- =============================================
IF OBJECT_ID('dbo.tblContributor','U') IS NULL
BEGIN
    CREATE TABLE tblContributor (
        ContributorID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        FullName      VARCHAR(100) NOT NULL,
        Email         VARCHAR(150) NOT NULL,
        Phone         VARCHAR(20)  NOT NULL,
        JoinDate      DATE         NOT NULL,
        IsActive      BIT DEFAULT 1 NOT NULL
    );
    PRINT 'Created tblContributor';
END;
GO

IF OBJECT_ID('dbo.tblContribVehicle','U') IS NULL
BEGIN
    CREATE TABLE tblContribVehicle (
        ContribVehicleID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ContributorID    INT NOT NULL REFERENCES tblContributor(ContributorID),
        VehicleID        INT NOT NULL REFERENCES tblVehicle(VehicleID),
        StartDate        DATE NOT NULL,
        EndDate          DATE NULL,
        IsActive         BIT DEFAULT 1 NOT NULL
    );
    PRINT 'Created tblContribVehicle';
END;
GO

-- Contributor stored procs
IF OBJECT_ID('dbo.spListContributors','P') IS NULL
    EXEC('CREATE PROCEDURE spListContributors AS BEGIN
        SELECT ContributorID,FullName,Email,Phone,JoinDate,IsActive FROM tblContributor WHERE IsActive=1 ORDER BY FullName; END');
GO
IF OBJECT_ID('dbo.spFindContributor','P') IS NULL
    EXEC('CREATE PROCEDURE spFindContributor @ContributorID INT AS BEGIN
        SELECT ContributorID,FullName,Email,Phone,JoinDate,IsActive FROM tblContributor WHERE ContributorID=@ContributorID; END');
GO
IF OBJECT_ID('dbo.spAddContributor','P') IS NULL
    EXEC('CREATE PROCEDURE spAddContributor @FullName VARCHAR(100),@Email VARCHAR(150),@Phone VARCHAR(20),@JoinDate DATE,@NewID INT OUTPUT
    AS BEGIN
        INSERT INTO tblContributor (FullName,Email,Phone,JoinDate,IsActive) VALUES (@FullName,@Email,@Phone,@JoinDate,1);
        SET @NewID=SCOPE_IDENTITY(); END');
GO
IF OBJECT_ID('dbo.spEditContributor','P') IS NULL
    EXEC('CREATE PROCEDURE spEditContributor @ContributorID INT,@FullName VARCHAR(100),@Email VARCHAR(150),@Phone VARCHAR(20),@JoinDate DATE
    AS BEGIN UPDATE tblContributor SET FullName=@FullName,Email=@Email,Phone=@Phone,JoinDate=@JoinDate WHERE ContributorID=@ContributorID; END');
GO
IF OBJECT_ID('dbo.spDeleteContributor','P') IS NULL
    EXEC('CREATE PROCEDURE spDeleteContributor @ContributorID INT AS BEGIN
        UPDATE tblContributor SET IsActive=0 WHERE ContributorID=@ContributorID; END');
GO
IF OBJECT_ID('dbo.spFilterContributors','P') IS NULL
    EXEC('CREATE PROCEDURE spFilterContributors @FullName VARCHAR(100)=NULL
    AS BEGIN
        SELECT ContributorID,FullName,Email,Phone,JoinDate,IsActive FROM tblContributor
        WHERE IsActive=1 AND (@FullName IS NULL OR FullName LIKE ''%''+@FullName+''%'')
        ORDER BY FullName; END');
GO

IF OBJECT_ID('dbo.spListContribVehicles','P') IS NULL
    EXEC('CREATE PROCEDURE spListContribVehicles @ContributorID INT AS BEGIN
        SELECT cv.ContribVehicleID,cv.ContributorID,cv.VehicleID,v.Make,v.Model,v.RegistrationNo,cv.StartDate,cv.EndDate,cv.IsActive
        FROM tblContribVehicle cv JOIN tblVehicle v ON cv.VehicleID=v.VehicleID
        WHERE cv.ContributorID=@ContributorID AND cv.IsActive=1; END');
GO
IF OBJECT_ID('dbo.spAddContribVehicle','P') IS NULL
    EXEC('CREATE PROCEDURE spAddContribVehicle @ContributorID INT,@VehicleID INT,@StartDate DATE,@EndDate DATE=NULL,@NewID INT OUTPUT
    AS BEGIN
        INSERT INTO tblContribVehicle (ContributorID,VehicleID,StartDate,EndDate,IsActive) VALUES (@ContributorID,@VehicleID,@StartDate,@EndDate,1);
        SET @NewID=SCOPE_IDENTITY(); END');
GO
IF OBJECT_ID('dbo.spEditContribVehicle','P') IS NULL
    EXEC('CREATE PROCEDURE spEditContribVehicle @ContribVehicleID INT,@StartDate DATE,@EndDate DATE=NULL
    AS BEGIN UPDATE tblContribVehicle SET StartDate=@StartDate,EndDate=@EndDate WHERE ContribVehicleID=@ContribVehicleID; END');
GO
IF OBJECT_ID('dbo.spDeleteContribVehicle','P') IS NULL
    EXEC('CREATE PROCEDURE spDeleteContribVehicle @ContribVehicleID INT AS BEGIN
        UPDATE tblContribVehicle SET IsActive=0 WHERE ContribVehicleID=@ContribVehicleID; END');
GO
IF OBJECT_ID('dbo.spFindContribVehicle','P') IS NULL
    EXEC('CREATE PROCEDURE spFindContribVehicle @ContribVehicleID INT AS BEGIN
        SELECT cv.ContribVehicleID,cv.ContributorID,cv.VehicleID,v.Make,v.Model,v.RegistrationNo,cv.StartDate,cv.EndDate,cv.IsActive
        FROM tblContribVehicle cv JOIN tblVehicle v ON cv.VehicleID=v.VehicleID
        WHERE cv.ContribVehicleID=@ContribVehicleID; END');
GO

-- =============================================
-- VERIFY — run this to see what exists
-- =============================================
SELECT name AS [Stored Procedure] FROM sys.objects WHERE type='P' ORDER BY name;
SELECT name AS [Table] FROM sys.objects WHERE type='U' ORDER BY name;
PRINT 'Done — all missing objects created.';
GO
