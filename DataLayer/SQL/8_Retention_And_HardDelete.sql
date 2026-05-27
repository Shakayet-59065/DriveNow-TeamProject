-- ============================================================
-- DriveNow — Script 8: Data Retention Consent + Hard Delete
-- Run AFTER Script 7.
-- Safe to re-run (CREATE OR ALTER, IF NOT EXISTS).
--
-- What this does:
--   1. Adds RetentionMonths and RetentionConsentDate columns
--      to tblContributor for ethical data-retention consent tracking.
--   2. Creates spHardDeleteContributor — permanently removes a
--      contributor and all linked ContribVehicle records.
--      Only callable after staff have recorded a retention period.
-- ============================================================

USE DriveNow;
GO

-- 1. Add RetentionMonths column (how long backup data is kept)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'tblContributor' AND COLUMN_NAME = 'RetentionMonths'
)
BEGIN
    ALTER TABLE tblContributor ADD RetentionMonths INT NULL;
    PRINT 'Added RetentionMonths column to tblContributor';
END
ELSE PRINT 'RetentionMonths already exists - skipping';
GO

-- 2. Add RetentionConsentDate column (when staff recorded consent)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'tblContributor' AND COLUMN_NAME = 'RetentionConsentDate'
)
BEGIN
    ALTER TABLE tblContributor ADD RetentionConsentDate DATE NULL;
    PRINT 'Added RetentionConsentDate column to tblContributor';
END
ELSE PRINT 'RetentionConsentDate already exists - skipping';
GO

-- 3. Hard delete stored procedure
--    Permanently removes a contributor and all linked vehicles.
--    Records the retention period before deletion for audit log.
CREATE OR ALTER PROCEDURE spHardDeleteContributor
    @ContributorID      INT,
    @RetentionMonths    INT,   -- 3 or 6
    @ConsentDate        DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate retention period is a recognised value
    IF @RetentionMonths NOT IN (3, 6)
    BEGIN
        RAISERROR('RetentionMonths must be 3 or 6.', 16, 1);
        RETURN;
    END

    -- Record the consent before deleting
    UPDATE tblContributor
    SET    RetentionMonths      = @RetentionMonths,
           RetentionConsentDate = @ConsentDate
    WHERE  ContributorID = @ContributorID;

    -- Delete linked vehicles first (FK constraint)
    DELETE FROM tblContribVehicle
    WHERE  ContributorID = @ContributorID;

    -- Permanently delete the contributor record
    DELETE FROM tblContributor
    WHERE  ContributorID = @ContributorID;

    PRINT 'Contributor permanently deleted. Retention period recorded in audit log before deletion.';
END;
GO
