-- =============================================
-- Script:  19_StaffRole.sql
-- Purpose: Adds a Role column to tblStaff and updates spAddStaff
--          to accept @Role. Also updates spStaffLogin to return Role.
-- Developer: Musanna | CTEC2713N | Niels Brock Copenhagen
-- Run after: 18_StaffBCrypt_AutoDriver_CarReturned_AddStaff.sql
-- =============================================

USE DriveNow;
GO

-- ── Add Role column to tblStaff (safe to re-run) ──────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.tblStaff') AND name = 'Role'
)
BEGIN
    ALTER TABLE dbo.tblStaff ADD Role VARCHAR(20) NOT NULL DEFAULT 'Staff';
    PRINT 'Added Role column to tblStaff (default: Staff)';
END
ELSE
    PRINT 'Role column already exists in tblStaff';
GO

-- Seed roles for existing staff rows
UPDATE dbo.tblStaff SET Role = 'Admin' WHERE Username = 'admin'   AND Role = 'Staff';
UPDATE dbo.tblStaff SET Role = 'Staff' WHERE Username = 'musanna' AND Role = 'Staff';
UPDATE dbo.tblStaff SET Role = 'Staff' WHERE Username = 'prodip'  AND Role = 'Staff';
UPDATE dbo.tblStaff SET Role = 'Staff' WHERE Username = 'redoy'   AND Role = 'Staff';
UPDATE dbo.tblStaff SET Role = 'Staff' WHERE Username = 'ushno'   AND Role = 'Staff';
UPDATE dbo.tblStaff SET Role = 'Staff' WHERE Username = 'tahmid'  AND Role = 'Staff';
GO

-- ── Update spAddStaff to accept @Role ─────────────────────────────────────
IF OBJECT_ID('dbo.spAddStaff', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spAddStaff;
GO
CREATE PROCEDURE spAddStaff
    @Username     VARCHAR(50),
    @PasswordHash VARCHAR(255),
    @FullName     VARCHAR(100),
    @Role         VARCHAR(20) = 'Staff',
    @NewStaffID   INT OUTPUT
AS
BEGIN
    -- Insert new staff member with BCrypt hashed password and role
    INSERT INTO tblStaff (Username, PasswordHash, FullName, Role, IsActive)
    VALUES (@Username, @PasswordHash, @FullName, @Role, 1);
    SET @NewStaffID = SCOPE_IDENTITY();
END;
GO

-- ── Update spStaffLogin to also return Role ───────────────────────────────
IF OBJECT_ID('dbo.spStaffLogin', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spStaffLogin;
GO
CREATE PROCEDURE spStaffLogin
    @Username VARCHAR(50)
AS
BEGIN
    -- Returns row for BCrypt verification in C# — no password check in SQL
    SELECT StaffID, FullName, Username, PasswordHash, Role
    FROM   tblStaff
    WHERE  Username = @Username
    AND    IsActive = 1;
END;
GO

-- ── Verification ──────────────────────────────────────────────────────────
SELECT 'Script 19 complete — Role column added, spAddStaff and spStaffLogin updated' AS Result;
SELECT StaffID, Username, FullName, Role, IsActive FROM tblStaff ORDER BY StaffID;
GO
