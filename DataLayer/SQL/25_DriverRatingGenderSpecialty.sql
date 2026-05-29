-- ============================================================
-- Script 25: Driver rating, gender, and specialty
-- Run ONCE against the DriveNow LocalDB database.
-- Adds Rating, Gender, Specialty columns to tblDriver and
-- updates public/admin profile stored procedures.
-- ============================================================

-- 1. Add new optional columns (safe to re-run)
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('tblDriver') AND name = 'Rating')
    ALTER TABLE tblDriver ADD Rating DECIMAL(3,1) NULL
        CONSTRAINT chk_DriverRating CHECK (Rating >= 0.0 AND Rating <= 5.0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('tblDriver') AND name = 'Gender')
    ALTER TABLE tblDriver ADD Gender CHAR(1) NULL
        CONSTRAINT chk_DriverGender CHECK (Gender IN ('M', 'F', 'X'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('tblDriver') AND name = 'Specialty')
    ALTER TABLE tblDriver ADD Specialty VARCHAR(100) NULL;
GO

-- 2. Rebuild spAddDriver with all optional profile columns
CREATE OR ALTER PROCEDURE spAddDriver
    @FullName      VARCHAR(100),
    @Phone         VARCHAR(20),
    @LicenceNumber VARCHAR(30),
    @DateOfBirth   DATE,
    @JoinDate      DATE,
    @PhotoUrl      VARCHAR(500) = NULL,
    @Bio           VARCHAR(300) = NULL,
    @Rating        DECIMAL(3,1) = NULL,
    @Gender        CHAR(1)      = NULL,
    @Specialty     VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tblDriver
        (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive,
         PhotoUrl, Bio, Rating, Gender, Specialty)
    VALUES
        (@FullName, @Phone, @LicenceNumber, @DateOfBirth, @JoinDate, 1,
         @PhotoUrl, @Bio, @Rating, @Gender, @Specialty);
    SELECT SCOPE_IDENTITY();
END
GO

-- 3. Public driver listing — includes rating / gender / specialty (no licence / DOB)
CREATE OR ALTER PROCEDURE spListActiveDriversPublic
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DriverID, FullName, PhotoUrl, Bio, JoinDate, Rating, Gender, Specialty
    FROM   tblDriver
    WHERE  IsActive = 1
    ORDER  BY ISNULL(Rating, 0) DESC, FullName;
END
GO

-- 4. Public driver detail — includes rating / gender / specialty (no licence / DOB)
CREATE OR ALTER PROCEDURE spGetDriverPublicProfile
    @DriverID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DriverID, FullName, PhotoUrl, Bio, JoinDate, Rating, Gender, Specialty
    FROM   tblDriver
    WHERE  DriverID = @DriverID AND IsActive = 1;
END
GO

-- 5. Admin driver detail — all fields
CREATE OR ALTER PROCEDURE spGetDriverAdminProfile
    @DriverID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DriverID, FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive,
           PhotoUrl, Bio, Rating, Gender, Specialty
    FROM   tblDriver
    WHERE  DriverID = @DriverID;
END
GO

PRINT 'Script 25 complete: Rating, Gender, Specialty columns + updated stored procedures.';
GO
