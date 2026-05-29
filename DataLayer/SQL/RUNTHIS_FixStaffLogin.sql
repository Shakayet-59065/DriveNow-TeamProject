-- =============================================
-- QUICK FIX — Run this in SSMS if admin login is broken
-- Fixes spStaffLogin to return hash for C# BCrypt verification
-- Connect to: (localdb)\MSSQLLocalDB  Database: DriveNow
-- =============================================

USE DriveNow;
GO

IF OBJECT_ID('dbo.spStaffLogin', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spStaffLogin;
GO

CREATE PROCEDURE spStaffLogin
    @Username VARCHAR(50)
AS
BEGIN
    SELECT StaffID, FullName, Username, PasswordHash
    FROM   tblStaff
    WHERE  Username = @Username
    AND    IsActive = 1;
END;
GO

IF OBJECT_ID('dbo.spUpdateStaffPassword', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spUpdateStaffPassword;
GO

CREATE PROCEDURE spUpdateStaffPassword
    @StaffID      INT,
    @PasswordHash VARCHAR(255)
AS
BEGIN
    UPDATE tblStaff SET PasswordHash = @PasswordHash WHERE StaffID = @StaffID;
END;
GO

SELECT 'spStaffLogin fixed — try logging in now' AS Result;
SELECT StaffID, Username, FullName, PasswordHash, IsActive FROM tblStaff;
GO
