-- ============================================================
-- Script 23: Admin-cancelled / customer-cancelled trip visibility.
--
-- Fix 1: spListCustomerTrips — expose TripIsActive so the customer
--         portal can show "Cancelled by Admin" for admin-deactivated
--         trips instead of silently keeping them "Upcoming".
--
-- Fix 2: spListInactiveTrips — add CancelledBy column so the admin
--         portal can show "Cancelled by Admin" vs "Cancelled by Customer"
--         instead of incorrectly labelling everything "Completed".
--         The LEFT JOIN is widened (no IsActive filter on ct) so
--         customer-cancelled trips (ct.IsActive=0) are detected.
--
-- Run once in SSMS against your DriveNow database.
-- ============================================================

USE DriveNow;
GO

-- ── Fix 1: spListCustomerTrips ──────────────────────────────────
CREATE OR ALTER PROCEDURE spListCustomerTrips
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ct.CustomerTripID,
        ct.TripID,
        ct.CustomerID,
        ct.PickupLocation,
        ct.PickupDate,
        ct.DropoffLocation,
        ct.DropoffDate,
        ct.Notes,
        ct.IsActive,
        t.IsActive       AS TripIsActive,    -- 0 = deactivated by admin
        tt.TypeName,
        tt.BaseRate,
        v.Make           AS VehicleMake,
        v.Model          AS VehicleModel,
        v.RegistrationNo,
        v.DailyRate      AS VehicleDailyRate,
        d.FullName       AS DriverName,
        CASE
            WHEN ct.DropoffDate > ct.PickupDate
            THEN CEILING(CAST(DATEDIFF(MINUTE, ct.PickupDate, ct.DropoffDate) AS FLOAT) / 1440.0)
            ELSE 1
        END              AS TripDays
    FROM   tblCustomerTrip ct
    INNER JOIN tblTrip     t  ON ct.TripID    = t.TripID
    INNER JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    INNER JOIN tblVehicle  v  ON t.VehicleID  = v.VehicleID
    LEFT  JOIN tblDriver   d  ON t.DriverID   = d.DriverID
    WHERE  ct.CustomerID = @CustomerID
    AND    ct.IsActive   = 1         -- hides customer-self-cancelled trips
    ORDER  BY ct.PickupDate DESC;
END;
GO

-- ── Fix 2: spListInactiveTrips ──────────────────────────────────
-- The LEFT JOIN on tblCustomerTrip intentionally has NO IsActive
-- filter so we can detect both states:
--   ct.IsActive = 0 → customer cancelled their own booking
--   ct.IsActive = 1 → admin deactivated the trip (booking was still live)
--   ct IS NULL      → admin-added trip with no customer booking, deactivated
ALTER PROCEDURE spListInactiveTrips
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.TripID,
        t.CustomerId,
        t.VehicleID,
        t.DriverID,
        t.TripTypeID,
        tt.TypeName,
        t.TripDate,
        t.IsActive,
        ISNULL(t.CarReturned, 0)  AS CarReturned,
        ct.DropoffDate,
        CASE
            WHEN ct.CustomerTripID IS NOT NULL AND ct.IsActive = 0
                THEN 'Customer'
            ELSE
                'Admin'
        END AS CancelledBy
    FROM       tblTrip         t
    JOIN       tblTripType     tt ON tt.TripTypeID = t.TripTypeID
    LEFT JOIN  tblCustomerTrip ct ON ct.TripID     = t.TripID
    WHERE t.IsActive = 0
    ORDER BY t.TripDate DESC;
END
GO

PRINT 'Script 23 complete: spListCustomerTrips (TripIsActive) + spListInactiveTrips (CancelledBy).';
GO
