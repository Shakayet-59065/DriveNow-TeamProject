USE DriveNow;
GO

-- Fix spCustomerLogin to return full row by email only
-- Password verification is done in C# using PasswordHelper
IF OBJECT_ID('dbo.spCustomerLogin','P') IS NOT NULL DROP PROCEDURE dbo.spCustomerLogin;
GO
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
