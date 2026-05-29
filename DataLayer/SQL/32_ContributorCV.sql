-- ============================================================
-- DriveNow — Script 32: Contributor CV Storage
-- Run AFTER Script 31.
-- Adds CVFilePath and CVLinkUrl columns to tblContributor so
-- staff can store a contributor's uploaded CV file path
-- and/or an optional online CV link (Google Drive, etc.).
-- Updates spAddContributor, spEditContributor, and
-- spFindContributor to include the new columns.
-- ============================================================

USE DriveNow;
GO

-- ============================================================
-- 1. Add new CV columns to tblContributor (safe IF NOT EXISTS)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('tblContributor') AND name = 'CVFilePath')
    ALTER TABLE tblContributor ADD CVFilePath NVARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('tblContributor') AND name = 'CVLinkUrl')
    ALTER TABLE tblContributor ADD CVLinkUrl NVARCHAR(500) NULL;
GO

-- ============================================================
-- 2. Upgrade spAddContributor to include CV fields
--    (replaces version in Script 26)
-- ============================================================

CREATE OR ALTER PROCEDURE spAddContributor
    @FullName           VARCHAR(100),
    @Email              VARCHAR(150),
    @Phone              VARCHAR(20),
    @ContributorType    VARCHAR(20),
    @ApplicationDate    DATE,
    @NewID              INT OUTPUT,
    -- Extended optional fields (all default to NULL)
    @LicenceNumber      VARCHAR(50)   = NULL,
    @DateOfBirth        DATE          = NULL,
    @DailyRate          DECIMAL(8,2)  = NULL,
    @VehiclePhotoUrl    VARCHAR(500)  = NULL,
    @ProfilePhotoUrl    VARCHAR(500)  = NULL,
    @Notes              VARCHAR(1000) = NULL,
    @Colour             VARCHAR(30)   = NULL,
    @Seats              INT           = NULL,
    -- CV fields
    @CVFilePath         NVARCHAR(500) = NULL,
    @CVLinkUrl          NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tblContributor
        (FullName, Email, Phone, ContributorType, ApplicationDate, IsApproved,
         LicenceNumber, DateOfBirth, DailyRate, VehiclePhotoUrl, ProfilePhotoUrl,
         Notes, Colour, Seats, CVFilePath, CVLinkUrl)
    VALUES
        (@FullName, @Email, @Phone, @ContributorType, @ApplicationDate, 0,
         @LicenceNumber, @DateOfBirth, @DailyRate, @VehiclePhotoUrl, @ProfilePhotoUrl,
         @Notes, @Colour, @Seats, @CVFilePath, @CVLinkUrl);

    SET @NewID = SCOPE_IDENTITY();
END;
GO

-- ============================================================
-- 3. Upgrade spEditContributor to include CV fields
--    (replaces version in Script 28)
-- ============================================================

CREATE OR ALTER PROCEDURE spEditContributor
    @ContributorID      INT,
    @FullName           VARCHAR(100),
    @Email              VARCHAR(150),
    @Phone              VARCHAR(20),
    @ContributorType    VARCHAR(20),
    @IsApproved         BIT,
    -- Driver credential fields (NULL = leave unchanged)
    @LicenceNumber      VARCHAR(50)   = NULL,
    @DateOfBirth        DATE          = NULL,
    @LicenceIssueDate   DATE          = NULL,
    @LicenceExpiryDate  DATE          = NULL,
    @ProfilePhotoUrl    VARCHAR(500)  = NULL,
    @Notes              VARCHAR(1000) = NULL,
    -- Vehicle fields (NULL = leave unchanged)
    @VehicleMake        VARCHAR(50)   = NULL,
    @VehicleModel       VARCHAR(50)   = NULL,
    @VehicleYear        INT           = NULL,
    @VehicleReg         VARCHAR(20)   = NULL,
    @VehicleColour      VARCHAR(30)   = NULL,
    @VehicleSeats       INT           = NULL,
    @VehicleDailyRate   DECIMAL(8,2)  = NULL,
    @VehiclePhotoUrl    VARCHAR(500)  = NULL,
    -- CV fields (NULL = leave existing value unchanged)
    @CVFilePath         NVARCHAR(500) = NULL,
    @CVLinkUrl          NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Update core + extended contributor columns
    -- CV columns: NULL means "no new file uploaded, keep existing" —
    -- so use ISNULL to preserve the stored value when no new upload is made.
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
        Colour            = ISNULL(@VehicleColour,    Colour),
        Seats             = ISNULL(@VehicleSeats,     Seats),
        VehiclePhotoUrl   = ISNULL(@VehiclePhotoUrl,  VehiclePhotoUrl),
        CVFilePath        = ISNULL(@CVFilePath,        CVFilePath),
        CVLinkUrl         = @CVLinkUrl   -- always overwrite link (empty string clears it)
    WHERE ContributorID = @ContributorID;

    -- Upsert tblContribVehicle only when vehicle fields are supplied
    IF @ContributorType IN ('VehicleOwner', 'OwnerDriver')
       AND (@VehicleMake IS NOT NULL OR @VehicleModel IS NOT NULL OR @VehicleReg IS NOT NULL)
    BEGIN
        IF EXISTS (SELECT 1 FROM tblContribVehicle WHERE ContributorID = @ContributorID)
        BEGIN
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
            INSERT INTO tblContribVehicle
                (ContributorID, Make, Model, Year, RegistrationNo,
                 Colour, Seats, DailyRate, VehiclePhotoUrl, IsAvailable)
            VALUES
                (@ContributorID,
                 ISNULL(@VehicleMake,  'Unknown'),
                 ISNULL(@VehicleModel, 'Unknown'),
                 ISNULL(@VehicleYear,  YEAR(GETDATE())),
                 ISNULL(@VehicleReg,   'PENDING'),
                 @VehicleColour,
                 @VehicleSeats,
                 @VehicleDailyRate,
                 @VehiclePhotoUrl,
                 1);
        END

        -- Sync PromotedVehicleID record in tblVehicle if already approved
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
-- 4. Upgrade spFindContributor to return CV fields
--    (replaces version in Script 28)
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
           PromotedDriverID, PromotedVehicleID,
           CVFilePath, CVLinkUrl
    FROM   tblContributor
    WHERE  (@ContributorID IS NULL OR ContributorID = @ContributorID)
    AND    (@FullName      IS NULL OR FullName LIKE '%' + @FullName + '%')
    ORDER  BY ApplicationDate DESC;
END;
GO

PRINT 'Script 32 complete — CVFilePath and CVLinkUrl added to tblContributor; spAddContributor, spEditContributor, spFindContributor upgraded.';
GO
