-- ============================================================
-- DriveNow — Script 10: Dashboard Stats + Customer Profile SPs
-- Run AFTER Script 9.
-- Fixes three-tier architecture violations in MainMenu and
-- CustomerPortal by replacing inline SQL with stored procedures.
-- Also adds spListTripsByCustomer used by TripManager.
-- Safe to re-run: uses CREATE OR ALTER.
-- ============================================================

USE DriveNow;
GO

-- ============================================================
-- Dashboard stats — replaces inline COUNT queries in MainMenu
-- Returns a single row with counts for every stat card
-- ============================================================
CREATE OR ALTER PROCEDURE spGetDashboardStats
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*) FROM tblTrip)                          AS TripCount,
        (SELECT COUNT(*) FROM tblTripType  WHERE IsActive = 1)  AS TripTypeCount,
        (SELECT COUNT(*) FROM tblCustomer  WHERE IsActive = 1)  AS CustomerCount,
        (SELECT COUNT(*) FROM tblDriver    WHERE IsActive = 1)  AS DriverCount,
        (SELECT COUNT(*) FROM tblContributor)                   AS ContributorCount;
END;
GO

-- ============================================================
-- Customer profile read — replaces inline SELECT in CustomerPortal
-- ============================================================
CREATE OR ALTER PROCEDURE spGetCustomerProfile
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Email, Phone
    FROM   tblCustomer
    WHERE  CustomerID = @CustomerID
    AND    IsActive   = 1;
END;
GO

-- ============================================================
-- Customer profile update — replaces inline UPDATE in CustomerPortal
-- ============================================================
CREATE OR ALTER PROCEDURE spUpdateCustomerProfile
    @CustomerID INT,
    @Email      VARCHAR(150),
    @Phone      VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblCustomer
    SET    Email = @Email,
           Phone = @Phone
    WHERE  CustomerID = @CustomerID
    AND    IsActive   = 1;
END;
GO

-- ============================================================
-- List active trips for one customer
-- Fixes the dead-method bug in TripManager.ListTripsByCustomer()
-- ============================================================
CREATE OR ALTER PROCEDURE spListTripsByCustomer
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.TripID, t.CustomerID, t.VehicleID, t.DriverID,
           t.TripTypeID, tt.TypeName, t.TripDate, t.IsActive
    FROM   tblTrip t
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE  t.CustomerID = @CustomerID
    AND    t.IsActive   = 1
    ORDER  BY t.TripDate DESC;
END;
GO

PRINT 'Script 10 complete — spGetDashboardStats, spGetCustomerProfile, spUpdateCustomerProfile, spListTripsByCustomer created.';
GO
