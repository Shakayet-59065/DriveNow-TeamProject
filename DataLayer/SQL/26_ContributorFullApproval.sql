-- ============================================================
-- DriveNow — Script 26: Contributor Full Approval
-- Run AFTER Script 25.
-- Adds extended columns to tblContributor and tblContribVehicle,
-- updates the CK_ContribType check constraint to allow 'OwnerDriver',
-- makes tblDriver.DateOfBirth nullable,
-- and creates spApproveContributorFull which auto-promotes
-- approved contributors into tblDriver and/or tblVehicle.
-- ============================================================

USE DriveNow;
GO

-- ============================================================
-- 1. Add new columns to tblContributor (safe — check existence first)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'LicenceNumber')
    ALTER TABLE tblContributor ADD LicenceNumber VARCHAR(50) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'DateOfBirth')
    ALTER TABLE tblContributor ADD DateOfBirth DATE NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'DailyRate')
    ALTER TABLE tblContributor ADD DailyRate DECIMAL(8,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'VehiclePhotoUrl')
    ALTER TABLE tblContributor ADD VehiclePhotoUrl VARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'ProfilePhotoUrl')
    ALTER TABLE tblContributor ADD ProfilePhotoUrl VARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'Notes')
    ALTER TABLE tblContributor ADD Notes VARCHAR(1000) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'Colour')
    ALTER TABLE tblContributor ADD Colour VARCHAR(30) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'Seats')
    ALTER TABLE tblContributor ADD Seats INT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'PromotedDriverID')
    ALTER TABLE tblContributor ADD PromotedDriverID INT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContributor') AND name = 'PromotedVehicleID')
    ALTER TABLE tblContributor ADD PromotedVehicleID INT NULL;
GO

-- ============================================================
-- 2. Drop and recreate CK_ContribType to allow 'OwnerDriver'
-- ============================================================

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ContribType' AND parent_object_id = OBJECT_ID('tblContributor'))
    ALTER TABLE tblContributor DROP CONSTRAINT CK_ContribType;
GO

ALTER TABLE tblContributor
    ADD CONSTRAINT CK_ContribType
    CHECK (ContributorType IN ('Driver', 'VehicleOwner', 'OwnerDriver'));
GO

-- ============================================================
-- 3. Make tblDriver.DateOfBirth nullable (was NOT NULL)
-- ============================================================

ALTER TABLE tblDriver ALTER COLUMN DateOfBirth DATE NULL;
GO

-- ============================================================
-- 4. Add new columns to tblContribVehicle (safe — check existence first)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContribVehicle') AND name = 'DailyRate')
    ALTER TABLE tblContribVehicle ADD DailyRate DECIMAL(8,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContribVehicle') AND name = 'VehiclePhotoUrl')
    ALTER TABLE tblContribVehicle ADD VehiclePhotoUrl VARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContribVehicle') AND name = 'Colour')
    ALTER TABLE tblContribVehicle ADD Colour VARCHAR(30) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tblContribVehicle') AND name = 'Seats')
    ALTER TABLE tblContribVehicle ADD Seats INT NULL;
GO

-- ============================================================
-- 5. spApproveContributorFull
--    Approves the contributor and promotes them into tblDriver
--    and/or tblVehicle depending on their ContributorType.
-- ============================================================

CREATE OR ALTER PROCEDURE spApproveContributorFull
    @ContributorID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FullName       VARCHAR(100);
    DECLARE @Phone          VARCHAR(20);
    DECLARE @LicenceNumber  VARCHAR(50);
    DECLARE @DateOfBirth    DATE;
    DECLARE @ContribType    VARCHAR(20);
    DECLARE @DailyRate      DECIMAL(8,2);
    DECLARE @NewDriverID    INT  = NULL;
    DECLARE @NewVehicleID   INT  = NULL;

    -- Fetch contributor details
    SELECT
        @FullName      = FullName,
        @Phone         = Phone,
        @LicenceNumber = LicenceNumber,
        @DateOfBirth   = DateOfBirth,
        @ContribType   = ContributorType,
        @DailyRate     = DailyRate
    FROM tblContributor
    WHERE ContributorID = @ContributorID;

    -- Mark as approved
    UPDATE tblContributor
    SET IsApproved = 1
    WHERE ContributorID = @ContributorID;

    -- ---- DRIVER promotion ----
    IF @ContribType IN ('Driver', 'OwnerDriver')
    BEGIN
        INSERT INTO tblDriver (FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive)
        VALUES (
            @FullName,
            @Phone,
            ISNULL(@LicenceNumber, 'PENDING'),
            @DateOfBirth,
            GETDATE(),
            1
        );
        SET @NewDriverID = SCOPE_IDENTITY();

        UPDATE tblContributor
        SET PromotedDriverID = @NewDriverID
        WHERE ContributorID = @ContributorID;
    END

    -- ---- VEHICLE promotion ----
    IF @ContribType IN ('VehicleOwner', 'OwnerDriver')
    BEGIN
        DECLARE @VehicleMake        VARCHAR(50);
        DECLARE @VehicleModel       VARCHAR(50);
        DECLARE @VehicleReg         VARCHAR(20);
        DECLARE @VehicleDailyRate   DECIMAL(8,2);
        DECLARE @VehicleSeats       INT;

        -- Pull top vehicle record for this contributor from tblContribVehicle
        SELECT TOP 1
            @VehicleMake      = Make,
            @VehicleModel     = Model,
            @VehicleReg       = RegistrationNo,
            @VehicleDailyRate = ISNULL(DailyRate, @DailyRate),
            @VehicleSeats     = Seats
        FROM tblContribVehicle
        WHERE ContributorID = @ContributorID
        ORDER BY ContribVehicleID DESC;

        -- Fallback to contributor-level DailyRate if vehicle row had none
        SET @VehicleDailyRate = ISNULL(@VehicleDailyRate, @DailyRate);

        INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats)
        VALUES (
            ISNULL(@VehicleReg, 'PENDING'),
            ISNULL(@VehicleMake, 'Unknown'),
            ISNULL(@VehicleModel, 'Unknown'),
            ISNULL(@VehicleDailyRate, 50.00),
            GETDATE(),
            1,
            ISNULL(@VehicleSeats, 5)
        );
        SET @NewVehicleID = SCOPE_IDENTITY();

        UPDATE tblContributor
        SET PromotedVehicleID = @NewVehicleID
        WHERE ContributorID = @ContributorID;
    END

    -- Return the newly created IDs (NULL if not created)
    SELECT @NewDriverID AS NewDriverID, @NewVehicleID AS NewVehicleID;
END;
GO

-- ============================================================
-- 6. Update spAddContributor to accept the new optional fields
-- ============================================================

CREATE OR ALTER PROCEDURE spAddContributor
    @FullName           VARCHAR(100),
    @Email              VARCHAR(150),
    @Phone              VARCHAR(20),
    @ContributorType    VARCHAR(20),
    @ApplicationDate    DATE,
    @NewID              INT OUTPUT,
    -- Extended optional fields (all default to NULL)
    @LicenceNumber      VARCHAR(50)  = NULL,
    @DateOfBirth        DATE         = NULL,
    @DailyRate          DECIMAL(8,2) = NULL,
    @VehiclePhotoUrl    VARCHAR(500) = NULL,
    @ProfilePhotoUrl    VARCHAR(500) = NULL,
    @Notes              VARCHAR(1000)= NULL,
    @Colour             VARCHAR(30)  = NULL,
    @Seats              INT          = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tblContributor
        (FullName, Email, Phone, ContributorType, ApplicationDate, IsApproved,
         LicenceNumber, DateOfBirth, DailyRate, VehiclePhotoUrl, ProfilePhotoUrl,
         Notes, Colour, Seats)
    VALUES
        (@FullName, @Email, @Phone, @ContributorType, @ApplicationDate, 0,
         @LicenceNumber, @DateOfBirth, @DailyRate, @VehiclePhotoUrl, @ProfilePhotoUrl,
         @Notes, @Colour, @Seats);

    SET @NewID = SCOPE_IDENTITY();
END;
GO

PRINT 'Script 26 complete — Contributor Full Approval columns, constraints, and procedures created.';
GO
