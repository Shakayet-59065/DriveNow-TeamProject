USE DriveNow;
GO

-- =============================================
-- tblStaff - for staff login
-- =============================================
IF OBJECT_ID('dbo.tblStaff', 'U') IS NOT NULL DROP TABLE dbo.tblStaff;
GO

CREATE TABLE tblStaff
(
    StaffID      INT          IDENTITY(1,1) NOT NULL,
    Username     VARCHAR(50)                NOT NULL,
    PasswordHash VARCHAR(255)               NOT NULL,
    FullName     VARCHAR(100)               NOT NULL,
    IsActive     BIT          DEFAULT 1     NOT NULL,
    CONSTRAINT PK_tblStaff   PRIMARY KEY (StaffID),
    CONSTRAINT UQ_Username   UNIQUE      (Username)
);
GO

-- Insert test staff accounts (password stored as plain text for dev testing)
INSERT INTO tblStaff (Username, PasswordHash, FullName, IsActive) VALUES
('admin',   'admin123',   'Admin User',    1),
('musanna', 'pass123',    'Musanna',       1),
('prodip',  'pass123',    'Prodip',        1),
('redoy',   'pass123',    'Redoy',         1),
('ushno',   'pass123',    'Ushno',         1),
('tahmid',  'pass123',    'Tahmid',        1);
GO

-- =============================================
-- spStaffLogin
-- =============================================
IF OBJECT_ID('dbo.spStaffLogin', 'P') IS NOT NULL DROP PROCEDURE dbo.spStaffLogin;
GO
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

-- =============================================
-- spCustomerLogin
-- =============================================
IF OBJECT_ID('dbo.spCustomerLogin', 'P') IS NOT NULL DROP PROCEDURE dbo.spCustomerLogin;
GO
CREATE PROCEDURE spCustomerLogin
    @Email    VARCHAR(150),
    @Password VARCHAR(255)
AS
BEGIN
    SELECT CustomerID, FullName, Email
    FROM   tblCustomer
    WHERE  Email        = @Email
    AND    PasswordHash = @Password
    AND    IsActive     = 1;
END;
GO

-- =============================================
-- Customer stored procedures (used by CustomerManager)
-- =============================================
IF OBJECT_ID('dbo.spAddCustomer', 'P') IS NOT NULL DROP PROCEDURE dbo.spAddCustomer;
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

IF OBJECT_ID('dbo.spEditCustomer', 'P') IS NOT NULL DROP PROCEDURE dbo.spEditCustomer;
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
    SET    FullName = @FullName, Email = @Email, Phone = @Phone, IsActive = @IsActive
    WHERE  CustomerID = @CustomerID;
END;
GO

IF OBJECT_ID('dbo.spDeleteCustomer', 'P') IS NOT NULL DROP PROCEDURE dbo.spDeleteCustomer;
GO
CREATE PROCEDURE spDeleteCustomer
    @CustomerID INT
AS
BEGIN
    UPDATE tblCustomer SET IsActive = 0 WHERE CustomerID = @CustomerID;
END;
GO

IF OBJECT_ID('dbo.spListCustomers', 'P') IS NOT NULL DROP PROCEDURE dbo.spListCustomers;
GO
CREATE PROCEDURE spListCustomers
AS
BEGIN
    SELECT CustomerID, FullName, Email, Phone, RegisterDate, IsActive
    FROM   tblCustomer
    WHERE  IsActive = 1
    ORDER  BY FullName;
END;
GO

IF OBJECT_ID('dbo.spFindCustomer', 'P') IS NOT NULL DROP PROCEDURE dbo.spFindCustomer;
GO
CREATE PROCEDURE spFindCustomer
    @CustomerID INT  = NULL,
    @FullName   VARCHAR(100) = NULL
AS
BEGIN
    SELECT CustomerID, FullName, Email, Phone, RegisterDate, IsActive
    FROM   tblCustomer
    WHERE  (@CustomerID IS NULL OR CustomerID = @CustomerID)
    AND    (@FullName   IS NULL OR FullName LIKE '%' + @FullName + '%');
END;
GO

IF OBJECT_ID('dbo.spFilterCustomers', 'P') IS NOT NULL DROP PROCEDURE dbo.spFilterCustomers;
GO
CREATE PROCEDURE spFilterCustomers
    @RegisterDateFrom DATE = NULL,
    @IsActive         BIT  = NULL
AS
BEGIN
    SELECT CustomerID, FullName, Email, Phone, RegisterDate, IsActive
    FROM   tblCustomer
    WHERE  (@RegisterDateFrom IS NULL OR RegisterDate >= @RegisterDateFrom)
    AND    (@IsActive         IS NULL OR IsActive      = @IsActive)
    ORDER  BY FullName;
END;
GO

-- =============================================
-- VERIFY
-- =============================================
SELECT 'tblStaff' AS TableName, COUNT(*) AS Rows FROM tblStaff
UNION ALL
SELECT 'tblCustomer', COUNT(*) FROM tblCustomer;

SELECT name AS CreatedProcedures FROM sys.objects WHERE type = 'P' ORDER BY name;
