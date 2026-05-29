-- ============================================================
-- DriveNow — Script 3: Update Vehicles to Premium Fleet
-- Run this AFTER Script 1 (tables must exist).
-- Replaces the generic test vehicles with premium cars that
-- match the Default.aspx home-page showcase.
-- ============================================================

USE DriveNow;
GO

-- Delete existing FK-dependent trips first (safe for dev/test only)
-- Comment these out if you want to keep trip history
DELETE FROM tblCustomerTrip;
DELETE FROM tblTrip;

-- Replace vehicle data
DELETE FROM tblVehicle;

-- Re-seed identity to start from 1
DBCC CHECKIDENT ('tblVehicle', RESEED, 0);

INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable) VALUES
('GT3-911',  'Porsche',  '911 GT3',  299.99, '2026-01-05', 1),
('BMW-7S25', 'BMW',      '7 Series', 199.99, '2026-02-10', 1),
('MER-SCL',  'Mercedes', 'S-Class',  249.99, '2026-03-01', 1),
('TES-MS25', 'Tesla',    'Model S',  179.99, '2026-03-20', 1),
('AUD-A825', 'Audi',     'A8',       189.99, '2026-04-01', 1);

PRINT 'tblVehicle updated: 5 premium vehicles inserted.';
GO

SELECT VehicleID, Make, Model, DailyRate, IsAvailable FROM tblVehicle ORDER BY VehicleID;
GO
