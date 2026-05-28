-- =============================================
-- Script:  16_EmailExists.sql
-- Purpose: Adds spEmailExists stored procedure used by CustomerManager.EmailExists()
--          to check for duplicate email addresses before registration.
--          Prevents the bug where the same email could be used to create
--          multiple accounts with different names.
-- Developer: Musanna | CTEC2713N
-- =============================================

USE DriveNow;
GO

IF OBJECT_ID('dbo.spEmailExists', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spEmailExists;
GO

-- Returns count of customers with the given email (case-insensitive).
-- 0 = email not found (safe to register), 1 = already registered.
CREATE PROCEDURE spEmailExists
    @Email VARCHAR(150)
AS
BEGIN
    SELECT COUNT(*) FROM tblCustomer WHERE Email = @Email AND IsActive = 1;
END;
GO
