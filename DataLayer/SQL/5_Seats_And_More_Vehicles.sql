-- ============================================================
-- DriveNow - Script 5: Seats Column + Fleet Expansion
-- Run AFTER Script 3. Safe to re-run (CREATE OR ALTER, IF NOT EXISTS).
--
-- What this does:
--   1. Adds a Seats column to tblVehicle (default 5)
--   2. Updates the 5 existing premium vehicles with seat counts
--   3. Inserts budget, mid-range and more premium vehicles so
--      all three filter bands show results in BrowseFleet
--   4. Updates all 5 vehicle stored procedures to include Seats
-- ============================================================

USE DriveNow;
GO

-- 1. Add Seats column (skip if it already exists)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'tblVehicle' AND COLUMN_NAME = 'Seats'
)
BEGIN
    ALTER TABLE tblVehicle ADD Seats INT NOT NULL DEFAULT 5;
    PRINT 'Added Seats column to tblVehicle (default 5)';
END
ELSE PRINT 'Seats column already exists - skipping ALTER';
GO

-- 2. Set seat counts on the 5 existing premium vehicles
UPDATE tblVehicle SET Seats = 2 WHERE Make = 'Porsche'  AND Model = '911 GT3';
UPDATE tblVehicle SET Seats = 5 WHERE Make = 'BMW'      AND Model = '7 Series';
UPDATE tblVehicle SET Seats = 5 WHERE Make = 'Mercedes' AND Model = 'S-Class';
UPDATE tblVehicle SET Seats = 5 WHERE Make = 'Tesla'    AND Model = 'Model S';
UPDATE tblVehicle SET Seats = 5 WHERE Make = 'Audi'     AND Model = 'A8';
PRINT 'Updated seat counts on existing premium vehicles';
GO

-- 3. Insert budget vehicles (under 60 GBP)
INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats) VALUES
('TOY-CRL01', 'Toyota',     'Corolla',  39.99, '2026-01-10', 1, 5),
('FOR-FOC01', 'Ford',       'Focus',    37.99, '2026-01-15', 1, 5),
('HON-CIV01', 'Honda',      'Civic',    42.99, '2026-01-20', 1, 5),
('HYU-I3001', 'Hyundai',    'i30',      35.99, '2026-02-01', 1, 5),
('KIA-CED01', 'Kia',        'Ceed',     38.99, '2026-02-05', 1, 5),
('VW-POL01',  'Volkswagen', 'Polo',     34.99, '2026-02-10', 1, 5),
('REN-CLO01', 'Renault',    'Clio',     33.99, '2026-02-15', 1, 5),
('PEU-20801', 'Peugeot',    '208',      36.99, '2026-02-20', 1, 5);

-- Insert mid-range vehicles (60-100 GBP)
INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats) VALUES
('BMW-3SR01', 'BMW',        '3 Series', 85.99, '2026-01-25', 1, 5),
('TES-MD301', 'Tesla',      'Model 3',  89.99, '2026-02-08', 1, 5),
('AUD-A4-01', 'Audi',       'A4',       79.99, '2026-02-12', 1, 5),
('VOL-XC601', 'Volvo',      'XC60',     75.99, '2026-02-18', 1, 5),
('MER-CCL01', 'Mercedes',   'C-Class',  92.99, '2026-02-22', 1, 5),
('VW-TRN01',  'Volkswagen', 'Touran',   69.99, '2026-03-01', 1, 7),
('FOR-SMA01', 'Ford',       'S-Max',    72.99, '2026-03-05', 1, 7),
('KIA-SOR01', 'Kia',        'Sorento',  78.99, '2026-03-08', 1, 7);

-- Insert more premium vehicles (over 100 GBP)
INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats) VALUES
('RR-SPT001', 'Range Rover', 'Sport',        225.99, '2026-03-10', 1, 5),
('MER-VCL01', 'Mercedes',    'V-Class',      159.99, '2026-03-12', 1, 8),
('TOY-LCR01', 'Toyota',      'Land Cruiser', 145.99, '2026-03-15', 1, 7),
('BMW-X7-01', 'BMW',         'X7',           195.99, '2026-03-18', 1, 7),
('AUD-Q8-01', 'Audi',        'Q8',           185.99, '2026-03-20', 1, 5),
('POR-CAY01', 'Porsche',     'Cayenne',      235.99, '2026-03-22', 1, 5);

PRINT 'Inserted 22 new vehicles (8 budget, 8 mid-range, 6 premium)';
GO

-- 4. Update stored procedures to include Seats

CREATE OR ALTER PROCEDURE spListVehicles
AS
BEGIN
    SET NOCOUNT ON;
    SELECT VehicleID, RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats
    FROM   tblVehicle
    WHERE  IsAvailable = 1
    ORDER  BY Make, Model;
END;
GO

CREATE OR ALTER PROCEDURE spFindVehicle
    @VehicleID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT VehicleID, RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats
    FROM   tblVehicle
    WHERE  VehicleID = @VehicleID;
END;
GO

CREATE OR ALTER PROCEDURE spAddVehicle
    @RegistrationNo VARCHAR(20),
    @Make           VARCHAR(50),
    @Model          VARCHAR(50),
    @DailyRate      DECIMAL(8,2),
    @DateAdded      DATE,
    @Seats          INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats)
    VALUES (@RegistrationNo, @Make, @Model, @DailyRate, @DateAdded, 1, @Seats);
    SELECT SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE spEditVehicle
    @VehicleID      INT,
    @RegistrationNo VARCHAR(20),
    @Make           VARCHAR(50),
    @Model          VARCHAR(50),
    @DailyRate      DECIMAL(8,2),
    @DateAdded      DATE,
    @Seats          INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblVehicle
    SET    RegistrationNo = @RegistrationNo,
           Make           = @Make,
           Model          = @Model,
           DailyRate      = @DailyRate,
           DateAdded      = @DateAdded,
           Seats          = @Seats
    WHERE  VehicleID = @VehicleID;
END;
GO

CREATE OR ALTER PROCEDURE spFilterVehicles
    @AvailabilityFilter BIT  = NULL,
    @DateAddedFrom      DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT VehicleID, RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats
    FROM   tblVehicle
    WHERE  (@AvailabilityFilter IS NULL OR IsAvailable = @AvailabilityFilter)
    AND    (@DateAddedFrom      IS NULL OR DateAdded  >= @DateAddedFrom)
    ORDER  BY Make, Model;
END;
GO

PRINT 'Script 5 complete - Seats added, fleet expanded to 27 vehicles, procedures updated.';
GO

SELECT Make, Model, DailyRate, Seats,
       CASE WHEN DailyRate < 60  THEN 'Budget'
            WHEN DailyRate <= 100 THEN 'Mid-Range'
            ELSE 'Premium' END AS PriceBand
FROM   tblVehicle
WHERE  IsAvailable = 1
ORDER  BY DailyRate;
GO
