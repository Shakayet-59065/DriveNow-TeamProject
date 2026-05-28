-- ============================================================
-- Script 27 — Vehicle Photo URL
-- Adds a PhotoUrl column to tblVehicle so staff-uploaded photos
-- can be stored per vehicle and shown on BrowseFleet / VehicleDetail.
-- If no photo is uploaded, CarImages.GetUrl() provides a stock image.
-- Run this script ONCE on the database before using the photo upload
-- features in VehicleAdd.aspx and VehicleEdit.aspx.
-- ============================================================

-- Add PhotoUrl to tblVehicle (idempotent — skipped if column already exists)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'tblVehicle' AND COLUMN_NAME = 'PhotoUrl'
)
BEGIN
    ALTER TABLE tblVehicle ADD PhotoUrl VARCHAR(500) NULL;
    PRINT 'PhotoUrl column added to tblVehicle.';
END
ELSE
BEGIN
    PRINT 'PhotoUrl column already exists in tblVehicle — no action taken.';
END

-- Update spListVehicles to include PhotoUrl
-- (Required so VehicleManager.MapReader can read it from the result set)
IF OBJECT_ID('spListVehicles', 'P') IS NOT NULL
    DROP PROCEDURE spListVehicles;
GO
CREATE PROCEDURE spListVehicles
AS
BEGIN
    SELECT VehicleID, RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats,
           ISNULL(PhotoUrl, '') AS PhotoUrl
    FROM   tblVehicle
    ORDER  BY DateAdded DESC;
END
GO

-- Update spFindVehicle to include PhotoUrl
IF OBJECT_ID('spFindVehicle', 'P') IS NOT NULL
    DROP PROCEDURE spFindVehicle;
GO
CREATE PROCEDURE spFindVehicle
    @VehicleID INT
AS
BEGIN
    SELECT VehicleID, RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats,
           ISNULL(PhotoUrl, '') AS PhotoUrl
    FROM   tblVehicle
    WHERE  VehicleID = @VehicleID;
END
GO

PRINT 'Script 27 complete — PhotoUrl added, spListVehicles and spFindVehicle updated.';
