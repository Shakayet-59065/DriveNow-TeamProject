-- ============================================================
-- Script 9: Add Email and Phone columns to tblStaff
-- Run this ONCE against your (localdb)\MSSQLLocalDB DriveNow database
-- ============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.tblStaff') AND name = 'Email'
)
BEGIN
    ALTER TABLE dbo.tblStaff ADD Email VARCHAR(150) NULL;
    PRINT 'Added Email column to tblStaff';
END
ELSE
    PRINT 'Email column already exists in tblStaff';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.tblStaff') AND name = 'Phone'
)
BEGIN
    ALTER TABLE dbo.tblStaff ADD Phone VARCHAR(20) NULL;
    PRINT 'Added Phone column to tblStaff';
END
ELSE
    PRINT 'Phone column already exists in tblStaff';
GO

-- Seed example values for existing staff so profile page shows something
UPDATE dbo.tblStaff SET Email = 'admin@drivenow.dk',   Phone = '+45 70 00 00 01' WHERE Username = 'admin'   AND Email IS NULL;
UPDATE dbo.tblStaff SET Email = 'musanna@drivenow.dk', Phone = '+45 70 00 00 02' WHERE Username = 'musanna' AND Email IS NULL;
UPDATE dbo.tblStaff SET Email = 'prodip@drivenow.dk',  Phone = '+45 70 00 00 03' WHERE Username = 'prodip'  AND Email IS NULL;
UPDATE dbo.tblStaff SET Email = 'redoy@drivenow.dk',   Phone = '+45 70 00 00 04' WHERE Username = 'redoy'   AND Email IS NULL;
UPDATE dbo.tblStaff SET Email = 'ushno@drivenow.dk',   Phone = '+45 70 00 00 05' WHERE Username = 'ushno'   AND Email IS NULL;
UPDATE dbo.tblStaff SET Email = 'tahmid@drivenow.dk',  Phone = '+45 70 00 00 06' WHERE Username = 'tahmid'  AND Email IS NULL;
PRINT 'Seeded default Email/Phone values for existing staff';
GO
