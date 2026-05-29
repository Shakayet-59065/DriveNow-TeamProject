/***************************************************************
Driver Management SQL test script for Portfolio 2 evidence
Run this in SSMS after creating the DriveNow database.
This script is designed as evidence support, not production data.
***************************************************************/

USE DriveNow;
GO

-- 1. Confirm driver table exists and inspect schema
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tblDriver'
ORDER BY ORDINAL_POSITION;
GO

-- 2. Confirm required Driver Management procedures exist
SELECT name AS ProcedureName
FROM sys.procedures
WHERE name IN (
    'spAddDriver', 'spEditDriver', 'spDeleteDriver', 'spListDrivers',
    'spFindDriver', 'spFilterDrivers', 'spRestoreDriver', 'spHardDeleteDriver',
    'spListActiveDriversPublic', 'spGetDriverPublicProfile', 'spGetDriverAdminProfile',
    'spApproveContributorFull'
)
ORDER BY name;
GO

-- 3. Example positive insert using stored procedure
DECLARE @DriverID INT;
EXEC spAddDriver
    @FullName = 'Portfolio Test Driver',
    @Phone = '07123 456789',
    @LicenceNumber = 'PTD-59065-01',
    @DateOfBirth = '1998-05-29',
    @JoinDate = '2026-05-29';

SELECT TOP 10 *
FROM tblDriver
WHERE FullName LIKE '%Portfolio Test Driver%'
ORDER BY DriverID DESC;
GO

-- 4. List/filter evidence
EXEC spListDrivers;
EXEC spFilterDrivers @FullName = 'Portfolio', @LicenceNumber = NULL, @IsActive = 1;
GO
