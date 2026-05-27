-- ============================================================
-- Script 30 — Uniqueness constraints & duplicate-check helpers
-- DriveNow | CTEC2713N
-- Run AFTER scripts 1–29.
-- ============================================================
-- Adds:
--   1. UNIQUE index on tblVehicle.RegistrationNo
--   2. UNIQUE index on tblContributor.LicenceNumber (nullable — allows NULLs freely)
--   3. Stored procedure spCheckDuplicateLicence
--   4. Stored procedure spCheckDuplicateVehicleReg
-- ============================================================

-- ⚠  Select YOUR database from the SSMS dropdown before running.
--    Do not hard-code a USE statement — the database name differs per machine.

-- ── 1. Unique index on Vehicle Registration Number ─────────────────────
-- DROP existing if already created under a different name
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_tblVehicle_RegistrationNo' AND object_id = OBJECT_ID('tblVehicle'))
    DROP INDEX UQ_tblVehicle_RegistrationNo ON tblVehicle;
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_tblVehicle_RegistrationNo
    ON tblVehicle (RegistrationNo);
GO

-- ── 2. Unique index on Contributor Licence Number (NULLs not restricted) ──
-- SQL Server unique indexes ignore NULLs for uniqueness, so contributors
-- without a licence (VehicleOwner only) are unaffected.
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_tblContributor_LicenceNumber' AND object_id = OBJECT_ID('tblContributor'))
    DROP INDEX UQ_tblContributor_LicenceNumber ON tblContributor;
GO

IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='tblContributor' AND COLUMN_NAME='LicenceNumber')
BEGIN
    EXEC('
    CREATE UNIQUE NONCLUSTERED INDEX UQ_tblContributor_LicenceNumber
        ON tblContributor (LicenceNumber)
        WHERE LicenceNumber IS NOT NULL;');
END
GO

-- ── 3. Also unique on tblDriver.LicenceNumber ──────────────────────────
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_tblDriver_LicenceNumber' AND object_id = OBJECT_ID('tblDriver'))
    DROP INDEX UQ_tblDriver_LicenceNumber ON tblDriver;
GO

IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='tblDriver' AND COLUMN_NAME='LicenceNumber')
BEGIN
    EXEC('
    CREATE UNIQUE NONCLUSTERED INDEX UQ_tblDriver_LicenceNumber
        ON tblDriver (LicenceNumber)
        WHERE LicenceNumber IS NOT NULL;');
END
GO

-- ── 4. spCheckDuplicateLicence ─────────────────────────────────────────
-- Returns 1 if the licence number is already used by ANOTHER contributor
-- or driver (excludes the current record).  Returns 0 if the number is free.
--
-- Parameters:
--   @LicenceNumber   NVARCHAR(50)  — number to check (stored UPPER-CASE)
--   @ExcludeContribID INT = NULL    — ContributorID to exclude (edit scenario)
--   @ExcludeDriverID  INT = NULL    — DriverID to exclude (edit scenario)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('spCheckDuplicateLicence', 'P') IS NOT NULL DROP PROCEDURE spCheckDuplicateLicence;
GO
CREATE PROCEDURE spCheckDuplicateLicence
    @LicenceNumber    NVARCHAR(50),
    @ExcludeContribID INT = NULL,
    @ExcludeDriverID  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CountContrib INT = 0, @CountDriver INT = 0;

    -- Check tblContributor
    IF OBJECT_ID('tblContributor','U') IS NOT NULL
    BEGIN
        SELECT @CountContrib = COUNT(1)
        FROM   tblContributor
        WHERE  UPPER(LicenceNumber) = UPPER(@LicenceNumber)
          AND  (@ExcludeContribID IS NULL OR ContributorID <> @ExcludeContribID);
    END

    -- Check tblDriver
    IF OBJECT_ID('tblDriver','U') IS NOT NULL
    BEGIN
        SELECT @CountDriver = COUNT(1)
        FROM   tblDriver
        WHERE  UPPER(LicenceNumber) = UPPER(@LicenceNumber)
          AND  (@ExcludeDriverID IS NULL OR DriverID <> @ExcludeDriverID);
    END

    SELECT CASE WHEN (@CountContrib + @CountDriver) > 0 THEN 1 ELSE 0 END AS IsDuplicate;
END
GO

-- ── 5. spCheckDuplicateVehicleReg ─────────────────────────────────────
-- Returns 1 if the registration number is already used in tblVehicle
-- by a record OTHER than the one being edited.
--
-- Parameters:
--   @RegistrationNo  NVARCHAR(20)
--   @ExcludeVehicleID INT = NULL   — VehicleID to exclude (edit scenario)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('spCheckDuplicateVehicleReg', 'P') IS NOT NULL DROP PROCEDURE spCheckDuplicateVehicleReg;
GO
CREATE PROCEDURE spCheckDuplicateVehicleReg
    @RegistrationNo  NVARCHAR(20),
    @ExcludeVehicleID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CASE
        WHEN COUNT(1) > 0 THEN 1
        ELSE 0
    END AS IsDuplicate
    FROM  tblVehicle
    WHERE UPPER(RegistrationNo) = UPPER(@RegistrationNo)
      AND (@ExcludeVehicleID IS NULL OR VehicleID <> @ExcludeVehicleID);
END
GO

PRINT 'Script 30 complete — unique indexes and duplicate-check stored procedures created.';
GO
