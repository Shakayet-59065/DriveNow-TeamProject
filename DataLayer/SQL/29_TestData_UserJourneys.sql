-- ============================================================
-- Script 29 — Test Data: User Journey Verification
-- Run AFTER Script 28.
-- Inserts:
--   1. A new customer account  (Sarah Larsen)
--   2. A driver-only contributor application (James Kowalski)
--   3. An owner+driver contributor application (Fatima Al-Rashid)
--      with a tblContribVehicle row (Tesla Model 3)
--   4. Approves both contributors (calls spApproveContributorFull)
--      so they appear in the Drivers tab and Vehicles tab immediately.
-- ============================================================

USE DriveNow;
GO

-- ============================================================
-- 1. New customer — Sarah Larsen
--    Login: sarah.larsen@drivenow.test / SarahTest2026
--    (password stored as plain text — PasswordHelper will hash on first login)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM tblCustomer WHERE Email = 'sarah.larsen@drivenow.test')
BEGIN
    INSERT INTO tblCustomer (FullName, Email, Phone, PasswordHash, RegisterDate, IsActive)
    VALUES ('Sarah Larsen', 'sarah.larsen@drivenow.test', '+447712345001', 'SarahTest2026', GETDATE(), 1);
    PRINT 'Customer Sarah Larsen inserted.';
END
ELSE PRINT 'Customer Sarah Larsen already exists.';
GO

-- ============================================================
-- 2. Driver contributor — James Kowalski
--    ContributorType = Driver (no vehicle)
-- ============================================================

DECLARE @JamesID INT;

IF NOT EXISTS (SELECT 1 FROM tblContributor WHERE Email = 'james.kowalski@drivenow.test')
BEGIN
    INSERT INTO tblContributor
        (FullName, Email, Phone, ContributorType, ApplicationDate, IsApproved,
         LicenceNumber, DateOfBirth, Notes)
    VALUES
        ('James Kowalski', 'james.kowalski@drivenow.test', '+447700900001',
         'Driver', GETDATE(), 0,
         'JK-LIC-2019-005', '1990-03-15',
         'Experienced driver, 5 years professional driving. References available.');
    SET @JamesID = SCOPE_IDENTITY();
    PRINT 'Contributor James Kowalski inserted (ID=' + CAST(@JamesID AS VARCHAR) + ').';
END
ELSE
BEGIN
    SELECT @JamesID = ContributorID FROM tblContributor WHERE Email = 'james.kowalski@drivenow.test';
    PRINT 'Contributor James Kowalski already exists (ID=' + CAST(@JamesID AS VARCHAR) + ').';
END

-- Approve James as a driver (calls the full approval SP)
IF @JamesID IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM tblContributor WHERE ContributorID = @JamesID AND IsApproved = 1)
BEGIN
    EXEC spApproveContributorFull @ContributorID = @JamesID;
    PRINT 'James Kowalski approved — driver record created.';
END
GO

-- ============================================================
-- 3. Owner+Driver contributor — Fatima Al-Rashid
--    ContributorType = OwnerDriver (has a vehicle)
-- ============================================================

DECLARE @FatimaID INT;

IF NOT EXISTS (SELECT 1 FROM tblContributor WHERE Email = 'fatima.alrashid@drivenow.test')
BEGIN
    INSERT INTO tblContributor
        (FullName, Email, Phone, ContributorType, ApplicationDate, IsApproved,
         LicenceNumber, DateOfBirth, DailyRate, Notes, Colour, Seats)
    VALUES
        ('Fatima Al-Rashid', 'fatima.alrashid@drivenow.test', '+447700900002',
         'OwnerDriver', GETDATE(), 0,
         'FA-LIC-2020-112', '1988-07-22',
         85.00,
         'Owner of a Tesla Model 3. Available weekdays 7am-9pm.',
         'Pearl White', 5);
    SET @FatimaID = SCOPE_IDENTITY();
    PRINT 'Contributor Fatima Al-Rashid inserted (ID=' + CAST(@FatimaID AS VARCHAR) + ').';
END
ELSE
BEGIN
    SELECT @FatimaID = ContributorID FROM tblContributor WHERE Email = 'fatima.alrashid@drivenow.test';
    PRINT 'Contributor Fatima Al-Rashid already exists (ID=' + CAST(@FatimaID AS VARCHAR) + ').';
END

-- Insert her vehicle into tblContribVehicle
IF @FatimaID IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM tblContribVehicle WHERE ContributorID = @FatimaID)
BEGIN
    INSERT INTO tblContribVehicle
        (ContributorID, Make, Model, Year, RegistrationNo, Colour, Seats, DailyRate, IsAvailable)
    VALUES
        (@FatimaID, 'Tesla', 'Model 3', 2022, 'FA22 TES', 'Pearl White', 5, 85.00, 1);
    PRINT 'Vehicle Tesla Model 3 (FA22 TES) inserted for Fatima.';
END

-- Approve Fatima as owner+driver
IF @FatimaID IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM tblContributor WHERE ContributorID = @FatimaID AND IsApproved = 1)
BEGIN
    EXEC spApproveContributorFull @ContributorID = @FatimaID;
    PRINT 'Fatima Al-Rashid approved — driver + vehicle records created.';
END
GO

-- ============================================================
-- 4. Confirmation: show what was created
-- ============================================================

SELECT 'CUSTOMER' AS RecordType, FullName, Email, IsActive AS Active
FROM tblCustomer WHERE Email = 'sarah.larsen@drivenow.test'

UNION ALL

SELECT 'CONTRIBUTOR' AS RecordType, FullName, Email,
       CAST(IsApproved AS INT) AS Active
FROM tblContributor WHERE Email IN ('james.kowalski@drivenow.test','fatima.alrashid@drivenow.test')

UNION ALL

SELECT 'DRIVER' AS RecordType, d.FullName, d.Phone, d.IsActive
FROM tblDriver d
JOIN tblContributor c ON c.PromotedDriverID = d.DriverID
WHERE c.Email IN ('james.kowalski@drivenow.test','fatima.alrashid@drivenow.test')

UNION ALL

SELECT 'VEHICLE' AS RecordType, v.Make + ' ' + v.Model, v.RegistrationNo,
       CAST(v.IsAvailable AS INT)
FROM tblVehicle v
JOIN tblContributor c ON c.PromotedVehicleID = v.VehicleID
WHERE c.Email = 'fatima.alrashid@drivenow.test';

GO

PRINT 'Script 29 complete — Test data for Sarah Larsen, James Kowalski, Fatima Al-Rashid inserted and approved.';
GO
