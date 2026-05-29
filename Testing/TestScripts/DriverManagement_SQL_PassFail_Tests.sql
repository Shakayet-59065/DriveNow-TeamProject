/*
    DriveNow - Driver Management PASS/FAIL SQL Tests
    Component: Driver Management
    Student: Redoy
    P-number: 59065

    How to use:
    1. Open this file in SQL Server Management Studio.
    2. Make sure the DriveNow database has already been created with the SQL scripts in DataLayer/SQL.
    3. Run this whole script.
    4. The final result grid shows PASS / FAIL for each database and stored procedure test.

    Note:
    This script tests the SQL/database side of Driver Management. Page validation such as
    "driver must be at least 18" and "join date cannot be in the future" is mainly checked
    in the C# DriverManager/page code, so those are documented in the portfolio test logs.
*/

USE DriveNow;
GO

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#DriverTestResults') IS NOT NULL
    DROP TABLE #DriverTestResults;

CREATE TABLE #DriverTestResults
(
    TestNo INT IDENTITY(1,1) PRIMARY KEY,
    TestName VARCHAR(160),
    ExpectedResult VARCHAR(300),
    ActualResult VARCHAR(500),
    Status VARCHAR(10),
    Notes VARCHAR(500)
);

DECLARE @DriverID INT = NULL;
DECLARE @Licence VARCHAR(30) = LEFT('PF-' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 30);
DECLARE @EditedLicence VARCHAR(30) = LEFT('PFE-' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 30);
DECLARE @BadRatingLicence VARCHAR(30) = LEFT('PFR-' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 30);
DECLARE @ActualCount INT = 0;
DECLARE @Msg VARCHAR(500);

-- Test 1: database context
IF DB_ID('DriveNow') IS NOT NULL
    INSERT INTO #DriverTestResults VALUES
    ('Database exists', 'DriveNow database should exist.', 'DriveNow database found.', 'PASS', 'Database context is available.');
ELSE
    INSERT INTO #DriverTestResults VALUES
    ('Database exists', 'DriveNow database should exist.', 'DriveNow database was not found.', 'FAIL', 'Run the setup SQL scripts first.');

-- Test 2: driver table exists
IF OBJECT_ID('dbo.tblDriver', 'U') IS NOT NULL
    INSERT INTO #DriverTestResults VALUES
    ('tblDriver exists', 'Driver table should exist.', 'dbo.tblDriver exists.', 'PASS', 'Main driver table is available.');
ELSE
    INSERT INTO #DriverTestResults VALUES
    ('tblDriver exists', 'Driver table should exist.', 'dbo.tblDriver missing.', 'FAIL', 'Run DataLayer/SQL/1_Tables_And_TestData.sql first.');

-- Test 3: core driver columns
SELECT @ActualCount = COUNT(*)
FROM sys.columns
WHERE object_id = OBJECT_ID('dbo.tblDriver')
AND name IN ('DriverID', 'FullName', 'Phone', 'LicenceNumber', 'DateOfBirth', 'JoinDate', 'IsActive');

IF @ActualCount = 7
    INSERT INTO #DriverTestResults VALUES
    ('Core driver columns', 'Seven core tblDriver columns should exist.', 'All seven core columns found.', 'PASS', 'DriverID, FullName, Phone, LicenceNumber, DateOfBirth, JoinDate and IsActive are present.');
ELSE
    INSERT INTO #DriverTestResults VALUES
    ('Core driver columns', 'Seven core tblDriver columns should exist.', CONCAT(@ActualCount, ' of 7 core columns found.'), 'FAIL', 'Check tblDriver schema.');

-- Test 4: profile columns from later scripts
SELECT @ActualCount = COUNT(*)
FROM sys.columns
WHERE object_id = OBJECT_ID('dbo.tblDriver')
AND name IN ('PhotoUrl', 'Bio', 'Rating', 'Gender', 'Specialty');

IF @ActualCount = 5
    INSERT INTO #DriverTestResults VALUES
    ('Driver profile columns', 'PhotoUrl, Bio, Rating, Gender and Specialty should exist.', 'All five profile columns found.', 'PASS', 'Scripts 24 and 25 have been applied.');
ELSE
    INSERT INTO #DriverTestResults VALUES
    ('Driver profile columns', 'PhotoUrl, Bio, Rating, Gender and Specialty should exist.', CONCAT(@ActualCount, ' of 5 profile columns found.'), 'FAIL', 'Run DataLayer/SQL/24_DriverProfile.sql and 25_DriverRatingGenderSpecialty.sql.');

-- Test 5: required Driver Management procedures
SELECT @ActualCount = COUNT(*)
FROM sys.procedures
WHERE name IN
(
    'spAddDriver',
    'spEditDriver',
    'spDeleteDriver',
    'spListDrivers',
    'spFindDriver',
    'spFilterDrivers',
    'spRestoreDriver',
    'spHardDeleteDriver',
    'spListActiveDriversPublic',
    'spGetDriverPublicProfile',
    'spGetDriverAdminProfile'
);

IF @ActualCount = 11
    INSERT INTO #DriverTestResults VALUES
    ('Driver procedures exist', 'All Driver Management stored procedures should exist.', 'All 11 expected procedures found.', 'PASS', 'Driver database API is available.');
ELSE
    INSERT INTO #DriverTestResults VALUES
    ('Driver procedures exist', 'All Driver Management stored procedures should exist.', CONCAT(@ActualCount, ' of 11 expected procedures found.'), 'FAIL', 'Run the SQL scripts in DataLayer/SQL in order.');

-- Test 6: contributor approval sync procedure exists
IF OBJECT_ID('dbo.spApproveContributorFull', 'P') IS NOT NULL
    INSERT INTO #DriverTestResults VALUES
    ('Contributor to driver sync procedure', 'spApproveContributorFull should exist.', 'spApproveContributorFull found.', 'PASS', 'Approved driver contributor sync procedure is available.');
ELSE
    INSERT INTO #DriverTestResults VALUES
    ('Contributor to driver sync procedure', 'spApproveContributorFull should exist.', 'spApproveContributorFull missing.', 'FAIL', 'Run DataLayer/SQL/26_ContributorFullApproval.sql or later contributor scripts.');

-- Test 7: add driver through stored procedure
BEGIN TRY
    IF OBJECT_ID('tempdb..#NewDriverID') IS NOT NULL DROP TABLE #NewDriverID;
    CREATE TABLE #NewDriverID (NewDriverID NUMERIC(38,0));

    INSERT INTO #NewDriverID
    EXEC dbo.spAddDriver
        @FullName = 'PASS FAIL Test Driver',
        @Phone = '07123 456789',
        @LicenceNumber = @Licence,
        @DateOfBirth = '1998-05-29',
        @JoinDate = '2026-05-29',
        @PhotoUrl = NULL,
        @Bio = 'SQL pass/fail test driver',
        @Rating = 4.5,
        @Gender = 'X',
        @Specialty = 'Portfolio testing';

    SELECT TOP 1 @DriverID = CAST(NewDriverID AS INT) FROM #NewDriverID;

    IF EXISTS (SELECT 1 FROM dbo.tblDriver WHERE DriverID = @DriverID AND LicenceNumber = @Licence AND IsActive = 1)
        INSERT INTO #DriverTestResults VALUES
        ('spAddDriver inserts driver', 'Stored procedure should insert one active driver.', CONCAT('Inserted DriverID ', @DriverID, '.'), 'PASS', 'spAddDriver works with the current profile-field signature.');
    ELSE
        INSERT INTO #DriverTestResults VALUES
        ('spAddDriver inserts driver', 'Stored procedure should insert one active driver.', 'No matching inserted driver found.', 'FAIL', 'Check spAddDriver and tblDriver.');
END TRY
BEGIN CATCH
    SET @Msg = ERROR_MESSAGE();
    INSERT INTO #DriverTestResults VALUES
    ('spAddDriver inserts driver', 'Stored procedure should insert one active driver.', @Msg, 'FAIL', 'The add-driver stored procedure failed.');
END CATCH;

-- Test 8: list drivers procedure smoke test
BEGIN TRY
    IF @DriverID IS NOT NULL
    BEGIN
        IF OBJECT_ID('tempdb..#ListDrivers') IS NOT NULL DROP TABLE #ListDrivers;
        CREATE TABLE #ListDrivers
        (
            DriverID INT,
            FullName VARCHAR(100),
            Phone VARCHAR(20),
            LicenceNumber VARCHAR(30),
            DateOfBirth DATE,
            JoinDate DATE,
            IsActive BIT
        );

        INSERT INTO #ListDrivers
        EXEC dbo.spListDrivers;

        IF EXISTS (SELECT 1 FROM #ListDrivers WHERE DriverID = @DriverID)
            INSERT INTO #DriverTestResults VALUES
            ('spListDrivers returns active driver', 'New active driver should appear in list.', 'Inserted test driver appears in spListDrivers.', 'PASS', 'List driver workflow works.');
        ELSE
            INSERT INTO #DriverTestResults VALUES
            ('spListDrivers returns active driver', 'New active driver should appear in list.', 'Inserted test driver not found in spListDrivers.', 'FAIL', 'Check list procedure or active filtering.');
    END
END TRY
BEGIN CATCH
    SET @Msg = ERROR_MESSAGE();
    INSERT INTO #DriverTestResults VALUES
    ('spListDrivers returns active driver', 'New active driver should appear in list.', @Msg, 'FAIL', 'spListDrivers failed.');
END CATCH;

-- Test 9: find driver procedure
BEGIN TRY
    IF @DriverID IS NOT NULL
    BEGIN
        IF OBJECT_ID('tempdb..#FindDriver') IS NOT NULL DROP TABLE #FindDriver;
        CREATE TABLE #FindDriver
        (
            DriverID INT,
            FullName VARCHAR(100),
            Phone VARCHAR(20),
            LicenceNumber VARCHAR(30),
            DateOfBirth DATE,
            JoinDate DATE,
            IsActive BIT
        );

        INSERT INTO #FindDriver
        EXEC dbo.spFindDriver @DriverID = @DriverID;

        IF EXISTS (SELECT 1 FROM #FindDriver WHERE DriverID = @DriverID)
            INSERT INTO #DriverTestResults VALUES
            ('spFindDriver finds driver', 'Find procedure should return the selected DriverID.', 'Inserted driver was found.', 'PASS', 'Find workflow works.');
        ELSE
            INSERT INTO #DriverTestResults VALUES
            ('spFindDriver finds driver', 'Find procedure should return the selected DriverID.', 'Inserted driver was not returned.', 'FAIL', 'Check spFindDriver.');
    END
END TRY
BEGIN CATCH
    SET @Msg = ERROR_MESSAGE();
    INSERT INTO #DriverTestResults VALUES
    ('spFindDriver finds driver', 'Find procedure should return the selected DriverID.', @Msg, 'FAIL', 'spFindDriver failed.');
END CATCH;

-- Test 10: filter driver procedure
BEGIN TRY
    IF @DriverID IS NOT NULL
    BEGIN
        IF OBJECT_ID('tempdb..#FilterDrivers') IS NOT NULL DROP TABLE #FilterDrivers;
        CREATE TABLE #FilterDrivers
        (
            DriverID INT,
            FullName VARCHAR(100),
            Phone VARCHAR(20),
            LicenceNumber VARCHAR(30),
            DateOfBirth DATE,
            JoinDate DATE,
            IsActive BIT
        );

        INSERT INTO #FilterDrivers
        EXEC dbo.spFilterDrivers
            @JoinDateFrom = '2026-05-29',
            @JoinDateTo = '2026-05-29',
            @IsActive = 1;

        IF EXISTS (SELECT 1 FROM #FilterDrivers WHERE DriverID = @DriverID)
            INSERT INTO #DriverTestResults VALUES
            ('spFilterDrivers filters driver', 'Filter should return the active test driver for matching date.', 'Inserted driver was returned by filter.', 'PASS', 'Filter workflow works.');
        ELSE
            INSERT INTO #DriverTestResults VALUES
            ('spFilterDrivers filters driver', 'Filter should return the active test driver for matching date.', 'Inserted driver was not returned by filter.', 'FAIL', 'Check spFilterDrivers date/active parameters.');
    END
END TRY
BEGIN CATCH
    SET @Msg = ERROR_MESSAGE();
    INSERT INTO #DriverTestResults VALUES
    ('spFilterDrivers filters driver', 'Filter should return the active test driver for matching date.', @Msg, 'FAIL', 'spFilterDrivers failed.');
END CATCH;

-- Test 11: edit driver
BEGIN TRY
    IF @DriverID IS NOT NULL
    BEGIN
        EXEC dbo.spEditDriver
            @DriverID = @DriverID,
            @FullName = 'PASS FAIL Test Driver Edited',
            @Phone = '07123 456780',
            @LicenceNumber = @EditedLicence,
            @DateOfBirth = '1998-05-29',
            @JoinDate = '2026-05-29';

        IF EXISTS (SELECT 1 FROM dbo.tblDriver WHERE DriverID = @DriverID AND FullName = 'PASS FAIL Test Driver Edited' AND LicenceNumber = @EditedLicence)
            INSERT INTO #DriverTestResults VALUES
            ('spEditDriver updates driver', 'Stored procedure should update driver details.', 'Driver row updated successfully.', 'PASS', 'Edit workflow works.');
        ELSE
            INSERT INTO #DriverTestResults VALUES
            ('spEditDriver updates driver', 'Stored procedure should update driver details.', 'Driver row was not updated.', 'FAIL', 'Check spEditDriver.');
    END
END TRY
BEGIN CATCH
    SET @Msg = ERROR_MESSAGE();
    INSERT INTO #DriverTestResults VALUES
    ('spEditDriver updates driver', 'Stored procedure should update driver details.', @Msg, 'FAIL', 'spEditDriver failed.');
END CATCH;

-- Test 12: soft delete
BEGIN TRY
    IF @DriverID IS NOT NULL
    BEGIN
        EXEC dbo.spDeleteDriver @DriverID = @DriverID;

        IF EXISTS (SELECT 1 FROM dbo.tblDriver WHERE DriverID = @DriverID AND IsActive = 0)
            INSERT INTO #DriverTestResults VALUES
            ('spDeleteDriver soft deletes driver', 'Soft delete should set IsActive to 0.', 'Driver IsActive is now 0.', 'PASS', 'Soft delete workflow works.');
        ELSE
            INSERT INTO #DriverTestResults VALUES
            ('spDeleteDriver soft deletes driver', 'Soft delete should set IsActive to 0.', 'Driver was not marked inactive.', 'FAIL', 'Check spDeleteDriver.');
    END
END TRY
BEGIN CATCH
    SET @Msg = ERROR_MESSAGE();
    INSERT INTO #DriverTestResults VALUES
    ('spDeleteDriver soft deletes driver', 'Soft delete should set IsActive to 0.', @Msg, 'FAIL', 'spDeleteDriver failed.');
END CATCH;

-- Test 13: restore
BEGIN TRY
    IF @DriverID IS NOT NULL
    BEGIN
        EXEC dbo.spRestoreDriver @DriverID = @DriverID;

        IF EXISTS (SELECT 1 FROM dbo.tblDriver WHERE DriverID = @DriverID AND IsActive = 1)
            INSERT INTO #DriverTestResults VALUES
            ('spRestoreDriver restores driver', 'Restore should set IsActive to 1.', 'Driver IsActive is now 1.', 'PASS', 'Restore workflow works.');
        ELSE
            INSERT INTO #DriverTestResults VALUES
            ('spRestoreDriver restores driver', 'Restore should set IsActive to 1.', 'Driver was not restored.', 'FAIL', 'Check spRestoreDriver.');
    END
END TRY
BEGIN CATCH
    SET @Msg = ERROR_MESSAGE();
    INSERT INTO #DriverTestResults VALUES
    ('spRestoreDriver restores driver', 'Restore should set IsActive to 1.', @Msg, 'FAIL', 'spRestoreDriver failed.');
END CATCH;

-- Test 14: rating check constraint
BEGIN TRY
    INSERT INTO dbo.tblDriver
        (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, Rating)
    VALUES
        ('Invalid Rating Test Driver', '07123 456700', @BadRatingLicence, '1998-05-29', '2026-05-29', 1, 5.1);

    DELETE FROM dbo.tblDriver WHERE LicenceNumber = @BadRatingLicence;

    INSERT INTO #DriverTestResults VALUES
    ('Rating boundary rejects 5.1', 'Database should reject rating above 5.0.', 'Rating 5.1 was accepted.', 'FAIL', 'Check chk_DriverRating constraint from Script 25.');
END TRY
BEGIN CATCH
    INSERT INTO #DriverTestResults VALUES
    ('Rating boundary rejects 5.1', 'Database should reject rating above 5.0.', 'SQL Server rejected rating 5.1.', 'PASS', 'Rating check constraint is working.');
END CATCH;

-- Test 15: hard delete cleanup
BEGIN TRY
    IF @DriverID IS NOT NULL
    BEGIN
        EXEC dbo.spHardDeleteDriver @DriverID = @DriverID;

        IF NOT EXISTS (SELECT 1 FROM dbo.tblDriver WHERE DriverID = @DriverID)
            INSERT INTO #DriverTestResults VALUES
            ('spHardDeleteDriver removes driver', 'Hard delete should permanently remove the test driver.', 'Test driver was removed.', 'PASS', 'Hard delete workflow works and test data cleaned up.');
        ELSE
            INSERT INTO #DriverTestResults VALUES
            ('spHardDeleteDriver removes driver', 'Hard delete should permanently remove the test driver.', 'Test driver still exists.', 'FAIL', 'Check spHardDeleteDriver.');
    END
END TRY
BEGIN CATCH
    SET @Msg = ERROR_MESSAGE();
    INSERT INTO #DriverTestResults VALUES
    ('spHardDeleteDriver removes driver', 'Hard delete should permanently remove the test driver.', @Msg, 'FAIL', 'spHardDeleteDriver failed.');
END CATCH;

-- Final result grid for Portfolio 2 evidence
SELECT
    TestNo,
    TestName,
    ExpectedResult,
    ActualResult,
    Status,
    Notes
FROM #DriverTestResults
ORDER BY TestNo;

SELECT
    COUNT(*) AS TotalTests,
    SUM(CASE WHEN Status = 'PASS' THEN 1 ELSE 0 END) AS PassedTests,
    SUM(CASE WHEN Status = 'FAIL' THEN 1 ELSE 0 END) AS FailedTests,
    SUM(CASE WHEN Status LIKE 'PASS%' THEN 1 ELSE 0 END) AS PassOrPassWithNote
FROM #DriverTestResults;
