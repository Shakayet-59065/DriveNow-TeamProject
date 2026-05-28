-- ============================================================
-- DriveNow — Script 14: spUpdateCustomerPassword
-- Run AFTER Script 13.
-- Adds a dedicated stored procedure that replaces a customer's
-- password hash.  Called by SetNewPassword.aspx.cs after a
-- customer logs in with a temporary password and sets a new one.
-- ============================================================

USE DriveNow;
GO

CREATE OR ALTER PROCEDURE spUpdateCustomerPassword
    @CustomerID   INT,
    @PasswordHash NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblCustomer
    SET    PasswordHash = @PasswordHash
    WHERE  CustomerID   = @CustomerID
      AND  IsActive     = 1;
END;
GO

PRINT 'Script 14 complete — spUpdateCustomerPassword created.';
GO
