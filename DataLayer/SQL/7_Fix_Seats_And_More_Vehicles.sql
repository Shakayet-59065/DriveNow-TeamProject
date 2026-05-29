-- ============================================================
-- DriveNow - Script 7: Correct Seat Counts + More Variety
-- Run AFTER Script 6. Safe to re-run (WHERE NOT EXISTS on inserts).
--
-- Fixes:
--   - Mercedes V-Class was 8 seats  → corrected to 7
--   - Lamborghini Urus was 5 seats  → corrected to 4 (supercar SUV)
--   - Ensures all vehicles have accurate seat counts
--
-- Adds variety vehicles:
--   Budget  : Smart ForTwo (2-seat), Mini Cooper S (4-seat)
--   Mid     : Mazda CX-5 (5-seat), SEAT Alhambra (7-seat MPV)
--   Premium : Rolls Royce Ghost (5-seat), Ferrari 488 (2-seat),
--             Aston Martin DB11 (4-seat), Mercedes G-Class (5-seat)
-- ============================================================

USE DriveNow;
GO

-- ── 1. Seat count corrections ────────────────────────────────────────────────

-- V-Class is a 7-seater executive van, not 8
UPDATE tblVehicle SET Seats = 7 WHERE Make = 'Mercedes' AND Model = 'V-Class';

-- Lamborghini Urus supercar SUV has 4 seats (2+2 rear)
UPDATE tblVehicle SET Seats = 4 WHERE Make = 'Lamborghini' AND Model = 'Urus';

-- Mercedes AMG GT is a 2+2 coupe (4 total)
UPDATE tblVehicle SET Seats = 4 WHERE Make = 'Mercedes' AND Model = 'AMG GT';

-- Porsche 911 GT3 is a strict 2-seater (rear seats are vestigial/removed)
UPDATE tblVehicle SET Seats = 2 WHERE Make = 'Porsche' AND Model = '911 GT3';

-- Fiat 500 is a 4-seat city car
UPDATE tblVehicle SET Seats = 4 WHERE Make = 'Fiat' AND Model = '500';

-- Bentley Bentayga long-wheelbase is usually 4 individual seats
UPDATE tblVehicle SET Seats = 4 WHERE Make = 'Bentley' AND Model = 'Bentayga';

-- BMW M5 is a 5-seat executive saloon
UPDATE tblVehicle SET Seats = 5 WHERE Make = 'BMW' AND Model = 'M5';

-- Tesla Cybertruck seats 5 (front bench + 2 rear bench)
UPDATE tblVehicle SET Seats = 5 WHERE Make = 'Tesla' AND Model = 'Cybertruck';

-- Toyota Land Cruiser 7-seater (standard 3-row)
UPDATE tblVehicle SET Seats = 7 WHERE Make = 'Toyota' AND Model = 'Land Cruiser';

-- BMW X7 is a 7-seater full-size luxury SUV
UPDATE tblVehicle SET Seats = 7 WHERE Make = 'BMW' AND Model = 'X7';

PRINT 'Seat counts corrected.';
GO

-- ── 2. Add variety vehicles ──────────────────────────────────────────────────

-- Budget — Smart ForTwo (2-seat city car)
INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats)
SELECT v.* FROM (VALUES
  ('SMT-FTW01', 'Smart',  'ForTwo',    28.99, '2026-04-01', 1, 2),
  ('MNI-CPS01', 'Mini',   'Cooper S',  49.99, '2026-04-02', 1, 4),
  ('MNI-CVT01', 'Mini',   'Convertible', 54.99,'2026-04-03', 1, 4)
) AS v(RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable,Seats)
WHERE NOT EXISTS (SELECT 1 FROM tblVehicle WHERE RegistrationNo = v.RegistrationNo);

-- Mid-Range — Mazda + SEAT Alhambra
INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats)
SELECT v.* FROM (VALUES
  ('MAZ-CX501', 'Mazda', 'CX-5',       73.99, '2026-04-04', 1, 5),
  ('SEA-ALH01', 'SEAT',  'Alhambra',   76.99, '2026-04-05', 1, 7),
  ('VOL-V90-1', 'Volvo', 'V90',        89.99, '2026-04-06', 1, 5),
  ('SUB-OUT01', 'Subaru','Outback',     67.99, '2026-04-07', 1, 5)
) AS v(RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable,Seats)
WHERE NOT EXISTS (SELECT 1 FROM tblVehicle WHERE RegistrationNo = v.RegistrationNo);

-- Premium — Ultra-luxury, sports, and iconic models
INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats)
SELECT v.* FROM (VALUES
  ('RR-GHT001', 'Rolls Royce', 'Ghost',      649.99, '2026-04-08', 1, 5),
  ('FER-488-1', 'Ferrari',     '488 GTB',    549.99, '2026-04-09', 1, 2),
  ('AST-DB-01', 'Aston Martin','DB11',       479.99, '2026-04-10', 1, 4),
  ('MER-GCL01', 'Mercedes',    'G-Class',    349.99, '2026-04-11', 1, 5),
  ('MCL-GT-01', 'McLaren',     'GT',         589.99, '2026-04-12', 1, 4),
  ('POR-911-2', 'Porsche',     '911 Turbo S',379.99, '2026-04-13', 1, 4)
) AS v(RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable,Seats)
WHERE NOT EXISTS (SELECT 1 FROM tblVehicle WHERE RegistrationNo = v.RegistrationNo);

PRINT 'Script 7 complete - seats corrected, 13 variety vehicles added.';
GO

-- ── 3. Verification query ────────────────────────────────────────────────────
SELECT
    CASE WHEN DailyRate < 60  THEN 'Budget'
         WHEN DailyRate <= 100 THEN 'Mid-Range'
         ELSE 'Premium' END AS Band,
    Seats,
    COUNT(*) AS Count
FROM tblVehicle
WHERE IsAvailable = 1
GROUP BY
    CASE WHEN DailyRate < 60  THEN 'Budget'
         WHEN DailyRate <= 100 THEN 'Mid-Range'
         ELSE 'Premium' END,
    Seats
ORDER BY Band, Seats;
GO
