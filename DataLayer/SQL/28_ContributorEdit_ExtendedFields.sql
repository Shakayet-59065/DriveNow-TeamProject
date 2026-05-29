-- ============================================================
-- Script 28 — Contributor Edit: Extended Fields
-- Run AFTER Script 27.
-- Adds LicenceIssueDate and LicenceExpiryDate to tblContributor
-- (referenced in ContributorView.aspx.cs but missing from the schema).
-- Upgrades spFindContributor to return all extended columns.
-- Upgrades spEditContributor to save all extended columns and
-- also upsert the tblContribVehicle record for vehicle owners.
-- ============================================================

USE DriveNow;
GO

-- ============================================================
-- 1. Add missing licence date columns to tblContributor
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('tblContributor') AND name = 'LicenceIssueDate')
    ALTER TABLE tblContributor ADD LicenceIssueDate DATE NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('tblContributor') AND name = 'LicenceExpiryDate')
    ALTER TABLE tblContributor ADD LicenceExpiryDate DATE NULL;
GO

-- ============================================================
-- 2. Upgrade spFindContributor — return all extended columns
--    so ContributorEdit.aspx.cs can pre-fill every field.
-- ============================================================

CREATE OR ALTER PROCEDURE spFindContributor
    @ContributorID INT          = NULL,
    @FullName      VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ContributorID, FullName, Email, Phone, ContributorType,
           ApplicationDate, IsApproved,
           LicenceNumber, DateOfBirth, LicenceIssueDate, LicenceExpiryDate,
           DailyRate, VehiclePhotoUrl, ProfilePhotoUrl,
           Notes, Colour, Seats,
           PromotedDriverID, PromotedVehicleID
    FROM   tblContributor
    WHERE  (@ContributorID IS NULL OR ContributorID = @ContributorID)
    AND    (@FullName      IS NULL OR FullName LIKE '%' + @FullName + '%')
    ORDER  BY ApplicationDate DESC;
END;
GO

-- ============================================================
-- 3. Upgrade spEditContributor — update all extended columns
--    on tblContributor and upsert tblContribVehicle for owners.
-- ============================================================

CREATE OR ALTER PROCEDURE spEditContributor
    @ContributorID      INT,
    @FullName           VARCHAR(100),
    @Email              VARCHAR(150),
    @Phone              VARCHAR(20),
    @ContributorType    VARCHAR(20),
    @IsApproved         BIT,
    -- Driver credential fields (NULL = leave unchanged for Driver/OwnerDriver)
    @LicenceNumber      VARCHAR(50)   = NULL,
    @DateOfBirth        DATE          = NULL,
    @LicenceIssueDate   DATE          = NULL,
    @LicenceExpiryDate  DATE          = NULL,
    @ProfilePhotoUrl    VARCHAR(500)  = NULL,
    @Notes              VARCHAR(1000) = NULL,
    -- Vehicle fields (NULL = leave unchanged for VehicleOwner/OwnerDriver)
    @VehicleMake        VARCHAR(50)   = NULL,
    @VehicleModel       VARCHAR(50)   = NULL,
    @VehicleYear        INT           = NULL,
    @VehicleReg         VARCHAR(20)   = NULL,
    @VehicleColour      VARCHAR(30)   = NULL,
    @VehicleSeats       INT           = NULL,
    @VehicleDailyRate   DECIMAL(8,2)  = NULL,
    @VehiclePhotoUrl    VARCHAR(500)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Update core + extended contributor columns
    UPDATE tblContributor
    SET
        FullName          = @FullName,
        Email             = @Email,
        Phone             = @Phone,
        ContributorType   = @ContributorType,
        IsApproved        = @IsApproved,
        LicenceNumber     = @LicenceNumber,
        DateOfBirth       = @DateOfBirth,
        LicenceIssueDate  = @LicenceIssueDate,
        LicenceExpiryDate = @LicenceExpiryDate,
        ProfilePhotoUrl   = @ProfilePhotoUrl,
        Notes             = @Notes,
        DailyRate         = ISNULL(@VehicleDailyRate, DailyRate),
        Colour            = ISNULL(@VehicleColour, Colour),
        Seats             = ISNULL(@VehicleSeats, Seats),
        VehiclePhotoUrl   = ISNULL(@VehiclePhotoUrl, VehiclePhotoUrl)
    WHERE ContributorID = @ContributorID;

    -- Upsert tblContribVehicle only when vehicle fields are supplied
    IF @ContributorType IN ('VehicleOwner', 'OwnerDriver')
       AND (@VehicleMake IS NOT NULL OR @VehicleModel IS NOT NULL OR @VehicleReg IS NOT NULL)
    BEGIN
        IF EXISTS (SELECT 1 FROM tblContribVehicle WHERE ContributorID = @ContributorID)
        BEGIN
            -- Update the most recent vehicle record for this contributor
            UPDATE tblContribVehicle
            SET
                Make            = ISNULL(@VehicleMake,      Make),
                Model           = ISNULL(@VehicleModel,     Model),
                Year            = ISNULL(@VehicleYear,      Year),
                RegistrationNo  = ISNULL(@VehicleReg,       RegistrationNo),
                Colour          = ISNULL(@VehicleColour,    Colour),
                Seats           = ISNULL(@VehicleSeats,     Seats),
                DailyRate       = ISNULL(@VehicleDailyRate, DailyRate),
                VehiclePhotoUrl = ISNULL(@VehiclePhotoUrl,  VehiclePhotoUrl)
            WHERE ContribVehicleID = (
                SELECT TOP 1 ContribVehicleID
                FROM tblContribVehicle
                WHERE ContributorID = @ContributorID
                ORDER BY ContribVehicleID DESC
            );
        END
        ELSE
        BEGIN
            -- Insert a new tblContribVehicle row (first vehicle for this contributor)
            INSERT INTO tblContribVehicle
                (ContributorID, Make, Model, Year, RegistrationNo,
                 Colour, Seats, DailyRate, VehiclePhotoUrl, IsAvailable)
            VALUES
                (@ContributorID,
                 ISNULL(@VehicleMake,      'Unknown'),
                 ISNULL(@VehicleModel,     'Unknown'),
                 ISNULL(@VehicleYear,      YEAR(GETDATE())),
                 ISNULL(@VehicleReg,       'PENDING'),
                 @VehicleColour,
                 @VehicleSeats,
                 @VehicleDailyRate,
                 @VehiclePhotoUrl,
                 1);
        END

        -- Also sync PromotedVehicleID record in tblVehicle if contributor is already approved
        IF EXISTS (SELECT 1 FROM tblContributor
                   WHERE ContributorID = @ContributorID
                     AND IsApproved = 1
                     AND PromotedVehicleID IS NOT NULL)
        BEGIN
            DECLARE @VID INT;
            SELECT @VID = PromotedVehicleID
            FROM tblContributor WHERE ContributorID = @ContributorID;

            UPDATE tblVehicle
            SET
                Make           = ISNULL(@VehicleMake,      Make),
                Model          = ISNULL(@VehicleModel,     Model),
                RegistrationNo = ISNULL(@VehicleReg,       RegistrationNo),
                Seats          = ISNULL(@VehicleSeats,     Seats),
                DailyRate      = ISNULL(@VehicleDailyRate, DailyRate)
            WHERE VehicleID = @VID;
        END
    END

    -- Sync PromotedDriverID record if contributor is a driver and already approved
    IF @ContributorType IN ('Driver', 'OwnerDriver')
       AND EXISTS (SELECT 1 FROM tblContributor
                   WHERE ContributorID = @ContributorID
                     AND IsApproved = 1
                     AND PromotedDriverID IS NOT NULL)
    BEGIN
        DECLARE @DID INT;
        SELECT @DID = PromotedDriverID
        FROM tblContributor WHERE ContributorID = @ContributorID;

        UPDATE tblDriver
        SET
            FullName      = @FullName,
            Phone         = @Phone,
            LicenceNumber = ISNULL(@LicenceNumber, LicenceNumber),
            DateOfBirth   = ISNULL(@DateOfBirth,   DateOfBirth)
        WHERE DriverID = @DID;
    END
END;
GO

-- ============================================================
-- 4. Upgrade spApproveContributorFull to also copy
--    VehiclePhotoUrl -> PhotoUrl when promoting into tblVehicle.
--    (Script 26 wrote this SP before PhotoUrl existed in tblVehicle.)
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
    UPDATE tblContributor SET IsApproved = 1 WHERE ContributorID = @ContributorID;

    -- ---- DRIVER promotion ----
    IF @ContribType IN ('Driver', 'OwnerDriver')
    BEGIN
        -- Only insert if not already promoted
        IF NOT EXISTS (SELECT 1 FROM tblContributor
                       WHERE ContributorID = @ContributorID AND PromotedDriverID IS NOT NULL)
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
        ELSE
        BEGIN
            SELECT @NewDriverID = PromotedDriverID FROM tblContributor WHERE ContributorID = @ContributorID;
        END
    END

    -- ---- VEHICLE promotion ----
    IF @ContribType IN ('VehicleOwner', 'OwnerDriver')
    BEGIN
        -- Only insert if not already promoted
        IF NOT EXISTS (SELECT 1 FROM tblContributor
                       WHERE ContributorID = @ContributorID AND PromotedVehicleID IS NOT NULL)
        BEGIN
            DECLARE @VehicleMake        VARCHAR(50);
            DECLARE @VehicleModel       VARCHAR(50);
            DECLARE @VehicleReg         VARCHAR(20);
            DECLARE @VehicleDailyRate   DECIMAL(8,2);
            DECLARE @VehicleSeats       INT;
            DECLARE @VehiclePhotoUrl    VARCHAR(500);

            -- Pull top vehicle record for this contributor from tblContribVehicle
            SELECT TOP 1
                @VehicleMake       = Make,
                @VehicleModel      = Model,
                @VehicleReg        = RegistrationNo,
                @VehicleDailyRate  = ISNULL(DailyRate, @DailyRate),
                @VehicleSeats      = Seats,
                @VehiclePhotoUrl   = VehiclePhotoUrl
            FROM tblContribVehicle
            WHERE ContributorID = @ContributorID
            ORDER BY ContribVehicleID DESC;

            -- Fallback daily rate
            SET @VehicleDailyRate = ISNULL(@VehicleDailyRate, @DailyRate);

            INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats, PhotoUrl)
            VALUES (
                ISNULL(@VehicleReg, 'PENDING'),
                ISNULL(@VehicleMake, 'Unknown'),
                ISNULL(@VehicleModel, 'Unknown'),
                ISNULL(@VehicleDailyRate, 50.00),
                GETDATE(),
                1,
                ISNULL(@VehicleSeats, 5),
                @VehiclePhotoUrl
            );
            SET @NewVehicleID = SCOPE_IDENTITY();

            UPDATE tblContributor
            SET PromotedVehicleID = @NewVehicleID
            WHERE ContributorID = @ContributorID;
        END
        ELSE
        BEGIN
            SELECT @NewVehicleID = PromotedVehicleID FROM tblContributor WHERE ContributorID = @ContributorID;
        END
    END

    -- Return the newly created IDs (NULL if not created / already existed)
    SELECT @NewDriverID AS NewDriverID, @NewVehicleID AS NewVehicleID;
END;
GO

PRINT 'Script 28 complete — LicenceIssueDate/ExpiryDate added, spFindContributor, spEditContributor, and spApproveContributorFull upgraded.';
GO
