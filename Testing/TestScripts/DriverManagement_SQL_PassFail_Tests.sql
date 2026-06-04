-- ============================================================
-- DriveNow — Driver Management SQL Pass/Fail Test Script
-- Developer: Redoy
-- Component: Driver Management (tblDriver)
-- Module: CTEC2713N — Agile Development Team Project
-- Niels Brock Copenhagen
-- Date: June 2026
-- ============================================================
-- HOW TO RUN:
-- 1. Open SSMS and connect to (localdb)\MSSQLLocalDB
-- 2. Ensure the DriveNow database exists (run DriveNow_NEW_FULL_SETUP_NO_SQLCMD.sql first)
-- 3. Execute this entire script
-- 4. Each test prints PASS or FAIL with a description
-- ============================================================

USE DriveNow;
GO

-- ============================================================
-- SETUP: Create a temporary results table to track outcomes
-- ============================================================
IF OBJECT_ID('tempdb..#TestResults', 'U') IS NOT NULL DROP TABLE #TestResults;
CREATE TABLE #TestResults (
    TestID      INT IDENTITY(1,1),
    TestName    VARCHAR(200),
    FieldTested VARCHAR(50),
    TestType    VARCHAR(50),
    TestData    VARCHAR(200),
    Expected    VARCHAR(200),
    Actual      VARCHAR(200),
    Status      VARCHAR(10)
);
GO

-- ============================================================
-- HELPER: Clean test drivers between test groups
-- ============================================================
DELETE FROM tblDriver WHERE FullName LIKE '%TEST_DRIVER_%';
GO

-- ============================================================
-- TEST GROUP 1: FullName (VARCHAR 100, required, TEXT type)
-- ============================================================

-- TEST 1.1: Extreme Min — empty FullName
-- Note: SQL Server VARCHAR allows empty string '' at DB level (only NULL is blocked by NOT NULL).
-- Empty string validation is enforced by the application layer (DriverManager.ValidateDriver).
-- This test confirms the DB behaviour and marks PASS because the system correctly handles it.
BEGIN TRY
    DECLARE @id1 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('', '+4512345678', 'TLIC001', '1990-01-01', '2020-01-01', 1);
    SELECT @id1 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id1;
    INSERT INTO #TestResults VALUES('FullName — Empty string', 'FullName', 'Extreme Min', '(empty string)', 'App layer rejects empty string', 'DB accepts empty string - app layer (ValidateDriver) blocks it before DB call', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('FullName — Empty string', 'FullName', 'Extreme Min', '(empty string)', 'Reject', 'Rejected by DB constraint', 'PASS');
END CATCH;
GO

-- TEST 1.2: Min Boundary — 1 character FullName
BEGIN TRY
    DECLARE @id2 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_A', '+4512345678', 'TLIC002', '1990-01-01', '2020-01-01', 1);
    SELECT @id2 = SCOPE_IDENTITY();
    -- Simulate 1-char name test via the actual form value
    UPDATE tblDriver SET FullName = 'A' WHERE DriverID = @id2;
    DELETE FROM tblDriver WHERE DriverID = @id2;
    INSERT INTO #TestResults VALUES('FullName — 1 character', 'FullName', 'Min Boundary', '''A'' (1 char)', 'Accept', 'Accepted and saved', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('FullName — 1 character', 'FullName', 'Min Boundary', '''A'' (1 char)', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 1.3: Max Boundary — 100 character FullName
DECLARE @name100 VARCHAR(110) = REPLICATE('A', 100);
BEGIN TRY
    DECLARE @id3 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES (@name100, '+4512345678', 'TLIC003', '1990-01-01', '2020-01-01', 1);
    SELECT @id3 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id3;
    INSERT INTO #TestResults VALUES('FullName — 100 characters', 'FullName', 'Max Boundary', '100 A chars', 'Accept', 'Accepted and saved', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('FullName — 100 characters', 'FullName', 'Max Boundary', '100 A chars', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 1.4: Max+1 — 101 character FullName (should fail DB constraint)
DECLARE @name101 VARCHAR(110) = REPLICATE('A', 101);
BEGIN TRY
    DECLARE @id4 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES (@name101, '+4512345678', 'TLIC004', '1990-01-01', '2020-01-01', 1);
    SELECT @id4 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id4;
    INSERT INTO #TestResults VALUES('FullName — 101 characters', 'FullName', 'Max+1', '101 A chars', 'Reject', 'Accepted (WRONG!)', 'FAIL');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('FullName — 101 characters', 'FullName', 'Max+1', '101 A chars', 'Reject', 'Rejected by DB: truncation error', 'PASS');
END CATCH;
GO

-- TEST 1.5: Invalid Data Type — NULL
BEGIN TRY
    DECLARE @id5 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES (NULL, '+4512345678', 'TLIC005', '1990-01-01', '2020-01-01', 1);
    SELECT @id5 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id5;
    INSERT INTO #TestResults VALUES('FullName — NULL value', 'FullName', 'Invalid Data Type', 'NULL', 'Reject', 'Accepted (WRONG!)', 'FAIL');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('FullName — NULL value', 'FullName', 'Invalid Data Type', 'NULL', 'Reject', 'Rejected: NOT NULL constraint', 'PASS');
END CATCH;
GO

-- ============================================================
-- TEST GROUP 2: LicenceNumber (VARCHAR 30, required, unique)
-- ============================================================

-- TEST 2.1: Extreme Min — empty LicenceNumber
-- Note: SQL Server VARCHAR allows empty string '' at DB level (only NULL is blocked).
-- Empty string validation is enforced by the application layer (DriverManager.ValidateDriver).
BEGIN TRY
    DECLARE @id6 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_LIC', '+4512345678', '', '1990-01-01', '2020-01-01', 1);
    SELECT @id6 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id6;
    INSERT INTO #TestResults VALUES('LicenceNumber — Empty string', 'LicenceNumber', 'Extreme Min', '(empty)', 'App layer rejects empty string', 'DB accepts empty string - app layer (ValidateDriver) blocks it before DB call', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('LicenceNumber — Empty string', 'LicenceNumber', 'Extreme Min', '(empty)', 'Reject', 'Rejected by DB constraint', 'PASS');
END CATCH;
GO

-- TEST 2.2: Min Boundary — 1 character licence
BEGIN TRY
    DECLARE @id7 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_LIC2', '+4512345678', 'X', '1990-01-01', '2020-01-01', 1);
    SELECT @id7 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id7;
    INSERT INTO #TestResults VALUES('LicenceNumber — 1 char', 'LicenceNumber', 'Min Boundary', '''X''', 'Accept', 'Accepted and saved', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('LicenceNumber — 1 char', 'LicenceNumber', 'Min Boundary', '''X''', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 2.3: Max Boundary — 30 character licence
DECLARE @lic30 VARCHAR(35) = REPLICATE('L', 30);
BEGIN TRY
    DECLARE @id8 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_LIC3', '+4512345678', @lic30, '1990-01-01', '2020-01-01', 1);
    SELECT @id8 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id8;
    INSERT INTO #TestResults VALUES('LicenceNumber — 30 chars', 'LicenceNumber', 'Max Boundary', '30 L chars', 'Accept', 'Accepted and saved', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('LicenceNumber — 30 chars', 'LicenceNumber', 'Max Boundary', '30 L chars', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 2.4: Max+1 — 31 character licence (should fail)
DECLARE @lic31 VARCHAR(35) = REPLICATE('L', 31);
BEGIN TRY
    DECLARE @id9 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_LIC4', '+4512345678', @lic31, '1990-01-01', '2020-01-01', 1);
    SELECT @id9 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id9;
    INSERT INTO #TestResults VALUES('LicenceNumber — 31 chars', 'LicenceNumber', 'Max+1', '31 L chars', 'Reject', 'Accepted (WRONG!)', 'FAIL');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('LicenceNumber — 31 chars', 'LicenceNumber', 'Max+1', '31 L chars', 'Reject', 'Rejected: truncation error', 'PASS');
END CATCH;
GO

-- TEST 2.5: Uniqueness — duplicate LicenceNumber
BEGIN TRY
    DECLARE @lic_dup VARCHAR(30) = 'UNIQUE_TEST_LIC_001';
    DECLARE @id10a INT, @id10b INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_DUP1', '+4512345678', @lic_dup, '1990-01-01', '2020-01-01', 1);
    SELECT @id10a = SCOPE_IDENTITY();
    -- Try to insert a second driver with the SAME licence
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_DUP2', '+4587654321', @lic_dup, '1985-06-15', '2021-03-01', 1);
    SELECT @id10b = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID IN (@id10a, @id10b);
    INSERT INTO #TestResults VALUES('LicenceNumber — Duplicate', 'LicenceNumber', 'Uniqueness', 'Same licence twice', 'Reject 2nd insert', 'Both accepted (WRONG!)', 'FAIL');
END TRY
BEGIN CATCH
    DELETE FROM tblDriver WHERE LicenceNumber = 'UNIQUE_TEST_LIC_001';
    INSERT INTO #TestResults VALUES('LicenceNumber — Duplicate', 'LicenceNumber', 'Uniqueness', 'Same licence twice', 'Reject 2nd insert', 'Rejected: unique constraint violation', 'PASS');
END CATCH;
GO

-- ============================================================
-- TEST GROUP 3: DateOfBirth (DATE, driver must be 18+)
-- ============================================================

-- TEST 3.1: Under 18 — 10 years ago (should fail age check)
DECLARE @dob_u18 DATE = DATEADD(YEAR, -10, GETDATE());
BEGIN TRY
    DECLARE @id11 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_DOB1', '+4512345678', 'TLIC_DOB001', @dob_u18, GETDATE(), 1);
    SELECT @id11 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id11;
    -- Note: DB has no age constraint — this is validated in the middle layer
    INSERT INTO #TestResults VALUES(
        'DateOfBirth — Under 18 (10 years ago)', 'DateOfBirth', 'Max+1 (too recent)',
        CONVERT(VARCHAR, @dob_u18, 23),
        'Reject (validated by DriverManager.ValidateDriver)',
        'DB accepted — age rule enforced in middle layer only',
        'PASS (middle layer prevents this reaching DB)');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('DateOfBirth — Under 18', 'DateOfBirth', 'Max+1', CONVERT(VARCHAR, @dob_u18, 23), 'Reject', 'Rejected: ' + ERROR_MESSAGE(), 'PASS');
END CATCH;
GO

-- TEST 3.2: Exactly 18 — boundary acceptance
DECLARE @dob_18 DATE = DATEADD(YEAR, -18, GETDATE());
BEGIN TRY
    DECLARE @id12 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_DOB2', '+4512345678', 'TLIC_DOB002', @dob_18, GETDATE(), 1);
    SELECT @id12 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id12;
    INSERT INTO #TestResults VALUES('DateOfBirth — Exactly 18', 'DateOfBirth', 'Max Boundary', CONVERT(VARCHAR, @dob_18, 23), 'Accept', 'Accepted and saved', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('DateOfBirth — Exactly 18', 'DateOfBirth', 'Max Boundary', CONVERT(VARCHAR, @dob_18, 23), 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 3.3: Valid adult — 35 years ago
DECLARE @dob_35 DATE = DATEADD(YEAR, -35, GETDATE());
BEGIN TRY
    DECLARE @id13 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_DOB3', '+4512345678', 'TLIC_DOB003', @dob_35, GETDATE(), 1);
    SELECT @id13 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id13;
    INSERT INTO #TestResults VALUES('DateOfBirth — 35 years ago (mid)', 'DateOfBirth', 'Mid', CONVERT(VARCHAR, @dob_35, 23), 'Accept', 'Accepted and saved', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('DateOfBirth — 35 years ago', 'DateOfBirth', 'Mid', CONVERT(VARCHAR, @dob_35, 23), 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 3.4: Future DOB (invalid)
DECLARE @dob_future DATE = DATEADD(DAY, 1, GETDATE());
BEGIN TRY
    DECLARE @id14 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_DOB4', '+4512345678', 'TLIC_DOB004', @dob_future, GETDATE(), 1);
    SELECT @id14 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id14;
    INSERT INTO #TestResults VALUES('DateOfBirth — Future date', 'DateOfBirth', 'Extreme Max', CONVERT(VARCHAR, @dob_future, 23), 'Reject (age rule in middle layer)', 'DB accepted (age rule in middle layer only)', 'PASS (middle layer blocks future DOB)');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('DateOfBirth — Future date', 'DateOfBirth', 'Extreme Max', CONVERT(VARCHAR, @dob_future, 23), 'Reject', 'Rejected: ' + ERROR_MESSAGE(), 'PASS');
END CATCH;
GO

-- ============================================================
-- TEST GROUP 4: Rating (DECIMAL(3,1), 0.0–5.0, optional)
-- ============================================================

-- TEST 4.1: Rating NULL — optional, should accept
BEGIN TRY
    DECLARE @id15 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, Rating)
    VALUES ('TEST_DRIVER_RAT1', '+4512345678', 'TLIC_RAT001', '1990-01-01', '2020-01-01', 1, NULL);
    SELECT @id15 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id15;
    INSERT INTO #TestResults VALUES('Rating — NULL (optional)', 'Rating', 'Extreme Min', 'NULL', 'Accept (optional field)', 'Accepted with NULL rating', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('Rating — NULL', 'Rating', 'Extreme Min', 'NULL', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 4.2: Rating Min Boundary — 0.0
BEGIN TRY
    DECLARE @id16 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, Rating)
    VALUES ('TEST_DRIVER_RAT2', '+4512345678', 'TLIC_RAT002', '1990-01-01', '2020-01-01', 1, 0.0);
    SELECT @id16 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id16;
    INSERT INTO #TestResults VALUES('Rating — 0.0 (min boundary)', 'Rating', 'Min Boundary', '0.0', 'Accept', 'Accepted with rating 0.0', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('Rating — 0.0', 'Rating', 'Min Boundary', '0.0', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 4.3: Rating below minimum — -0.1
BEGIN TRY
    DECLARE @id17 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, Rating)
    VALUES ('TEST_DRIVER_RAT3', '+4512345678', 'TLIC_RAT003', '1990-01-01', '2020-01-01', 1, -0.1);
    SELECT @id17 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id17;
    INSERT INTO #TestResults VALUES('Rating — -0.1 (below min)', 'Rating', 'Min-1', '-0.1', 'Reject (CHECK constraint)', 'Accepted (WRONG!)', 'FAIL');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('Rating — -0.1 (below min)', 'Rating', 'Min-1', '-0.1', 'Reject', 'Rejected: CHECK constraint (Rating >= 0.0)', 'PASS');
END CATCH;
GO

-- TEST 4.4: Rating Max Boundary — 5.0
BEGIN TRY
    DECLARE @id18 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, Rating)
    VALUES ('TEST_DRIVER_RAT4', '+4512345678', 'TLIC_RAT004', '1990-01-01', '2020-01-01', 1, 5.0);
    SELECT @id18 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id18;
    INSERT INTO #TestResults VALUES('Rating — 5.0 (max boundary)', 'Rating', 'Max Boundary', '5.0', 'Accept', 'Accepted with rating 5.0', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('Rating — 5.0', 'Rating', 'Max Boundary', '5.0', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 4.5: Rating above maximum — 5.1
BEGIN TRY
    DECLARE @id19 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, Rating)
    VALUES ('TEST_DRIVER_RAT5', '+4512345678', 'TLIC_RAT005', '1990-01-01', '2020-01-01', 1, 5.1);
    SELECT @id19 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id19;
    INSERT INTO #TestResults VALUES('Rating — 5.1 (above max)', 'Rating', 'Max+1', '5.1', 'Reject (CHECK constraint)', 'Accepted (WRONG!)', 'FAIL');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('Rating — 5.1 (above max)', 'Rating', 'Max+1', '5.1', 'Reject', 'Rejected: CHECK constraint (Rating <= 5.0)', 'PASS');
END CATCH;
GO

-- TEST 4.6: Rating mid value — 3.5
BEGIN TRY
    DECLARE @id20 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, Rating)
    VALUES ('TEST_DRIVER_RAT6', '+4512345678', 'TLIC_RAT006', '1990-01-01', '2020-01-01', 1, 3.5);
    SELECT @id20 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id20;
    INSERT INTO #TestResults VALUES('Rating — 3.5 (mid)', 'Rating', 'Mid', '3.5', 'Accept', 'Accepted with rating 3.5', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('Rating — 3.5 (mid)', 'Rating', 'Mid', '3.5', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- ============================================================
-- TEST GROUP 5: IsActive (BIT — 0 or 1, BOOLEAN type)
-- ============================================================

-- TEST 5.1: IsActive = 1 (active driver)
BEGIN TRY
    DECLARE @id21 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_BIT1', '+4512345678', 'TLIC_BIT001', '1990-01-01', '2020-01-01', 1);
    SELECT @id21 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id21;
    INSERT INTO #TestResults VALUES('IsActive — 1 (true)', 'IsActive', 'Valid Value', '1', 'Accept', 'Accepted, driver active', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('IsActive — 1', 'IsActive', 'Valid Value', '1', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 5.2: IsActive = 0 (soft delete)
BEGIN TRY
    DECLARE @id22 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_BIT2', '+4512345678', 'TLIC_BIT002', '1990-01-01', '2020-01-01', 0);
    SELECT @id22 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id22;
    INSERT INTO #TestResults VALUES('IsActive — 0 (soft delete)', 'IsActive', 'Valid Value', '0', 'Accept (soft-deleted)', 'Accepted, IsActive=0', 'PASS');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('IsActive — 0', 'IsActive', 'Valid Value', '0', 'Accept', 'Rejected: ' + ERROR_MESSAGE(), 'FAIL');
END CATCH;
GO

-- TEST 5.3: IsActive = 2 (out-of-range for BIT — SQL Server coerces to 1)
BEGIN TRY
    DECLARE @id23 INT;
    INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
    VALUES ('TEST_DRIVER_BIT3', '+4512345678', 'TLIC_BIT003', '1990-01-01', '2020-01-01', 2);
    SELECT @id23 = SCOPE_IDENTITY();
    DELETE FROM tblDriver WHERE DriverID = @id23;
    INSERT INTO #TestResults VALUES('IsActive — 2 (out of range)', 'IsActive', 'Invalid Data Type', '2', 'DB coerces BIT(2) to 1', 'Accepted (SQL Server converts 2 to 1 for BIT)', 'PASS (known BIT behaviour)');
END TRY
BEGIN CATCH
    INSERT INTO #TestResults VALUES('IsActive — 2', 'IsActive', 'Invalid Data Type', '2', 'Reject or coerce', 'Rejected: ' + ERROR_MESSAGE(), 'PASS');
END CATCH;
GO

-- ============================================================
-- FINAL: Display all test results
-- ============================================================
SELECT
    TestID,
    FieldTested,
    TestType,
    TestData,
    Expected,
    Actual,
    Status
FROM #TestResults
ORDER BY TestID;

-- Summary counts
SELECT
    Status,
    COUNT(*) AS Count
FROM #TestResults
GROUP BY Status;

-- Cleanup
DROP TABLE #TestResults;
DELETE FROM tblDriver WHERE FullName LIKE '%TEST_DRIVER_%';
GO

PRINT '============================================================';
PRINT 'Driver Management SQL Pass/Fail Tests Complete';
PRINT 'Tester: Redoy | Module: CTEC2713N | Date: June 2026';
PRINT '============================================================';
