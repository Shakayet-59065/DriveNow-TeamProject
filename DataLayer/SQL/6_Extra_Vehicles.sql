-- ============================================================
-- DriveNow - Script 6: Extra Vehicle Data
-- Run AFTER Script 5. Safe to re-run (checks registration before insert).
-- Adds 18 more vehicles across all price bands and seat counts.
-- ============================================================

USE DriveNow;
GO

-- Budget (under 60 GBP/day)
INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats)
SELECT v.* FROM (VALUES
  ('NIS-MCR01','Nissan',    'Micra',          31.99,'2026-03-01',1,5),
  ('SKO-FAB01','Skoda',     'Fabia',          32.99,'2026-03-02',1,5),
  ('OPE-COR01','Opel',      'Corsa',          33.49,'2026-03-03',1,5),
  ('FIA-500-1','Fiat',      '500',            34.49,'2026-03-04',1,4),
  ('MIT-SPC01','Mitsubishi','Space Star',      36.49,'2026-03-05',1,5),
  ('DAC-DUS01','Dacia',     'Duster',         44.99,'2026-03-06',1,5),
  ('FOR-KUG01','Ford',      'Kuga',           54.99,'2026-03-07',1,5),
  ('TOY-CH-01','Toyota',    'CH-R',           52.99,'2026-03-08',1,5),
  ('VW-GF701', 'Volkswagen','Golf',           55.99,'2026-03-09',1,5)
) AS v(RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable,Seats)
WHERE NOT EXISTS (
    SELECT 1 FROM tblVehicle WHERE RegistrationNo = v.RegistrationNo
);

-- Mid-Range (60-100 GBP/day)
INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats)
SELECT v.* FROM (VALUES
  ('SKO-KOD01','Skoda',     'Kodiaq',         68.99,'2026-03-10',1,7),
  ('NIS-QSH01','Nissan',    'Qashqai',        72.49,'2026-03-11',1,5),
  ('HON-CR-01','Honda',     'CR-V',           77.99,'2026-03-12',1,5),
  ('TOY-RAV01','Toyota',    'RAV4',           82.99,'2026-03-13',1,5),
  ('HYU-TUC01','Hyundai',   'Tucson',         79.99,'2026-03-14',1,5),
  ('OPE-ZAF01','Opel',      'Zafira',         71.99,'2026-03-15',1,7),
  ('REN-ESO01','Renault',   'Espace',         94.99,'2026-03-16',1,7),
  ('PEU-508-1','Peugeot',   '508',            88.99,'2026-03-17',1,5),
  ('KIA-EV601','Kia',       'EV6',            96.99,'2026-03-18',1,5)
) AS v(RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable,Seats)
WHERE NOT EXISTS (
    SELECT 1 FROM tblVehicle WHERE RegistrationNo = v.RegistrationNo
);

-- Premium (over 100 GBP/day)
INSERT INTO tblVehicle (RegistrationNo, Make, Model, DailyRate, DateAdded, IsAvailable, Seats)
SELECT v.* FROM (VALUES
  ('JAG-FP-01','Jaguar',    'F-Pace',        129.99,'2026-03-19',1,5),
  ('MAS-GBT01','Maserati',  'Ghibli',        279.99,'2026-03-20',1,5),
  ('LAM-URS01','Lamborghini','Urus',          399.99,'2026-03-21',1,5),
  ('BEN-BEN01','Bentley',   'Bentayga',      449.99,'2026-03-22',1,5),
  ('RR-PHT001','Range Rover','Autobiography', 399.99,'2026-03-23',1,5),
  ('BMW-M501', 'BMW',       'M5',            259.99,'2026-03-24',1,5),
  ('MER-AMG01','Mercedes',  'AMG GT',        319.99,'2026-03-25',1,4),
  ('TES-CYB01','Tesla',     'Cybertruck',    189.99,'2026-03-26',1,5),
  ('AUD-RS601','Audi',      'RS6 Avant',     229.99,'2026-03-27',1,5)
) AS v(RegistrationNo,Make,Model,DailyRate,DateAdded,IsAvailable,Seats)
WHERE NOT EXISTS (
    SELECT 1 FROM tblVehicle WHERE RegistrationNo = v.RegistrationNo
);

PRINT 'Script 6 complete - 27 extra vehicles added (budget, mid-range, premium).';
GO

SELECT
    CASE WHEN DailyRate < 60  THEN 'Budget'
         WHEN DailyRate <= 100 THEN 'Mid-Range'
         ELSE 'Premium' END AS Band,
    COUNT(*) AS Count
FROM tblVehicle WHERE IsAvailable = 1
GROUP BY
    CASE WHEN DailyRate < 60  THEN 'Budget'
         WHEN DailyRate <= 100 THEN 'Mid-Range'
         ELSE 'Premium' END;
GO
