-- ============================================================
-- Script 22: Update spListTrips to include DropoffDate from
--            tblCustomerTrip (LEFT JOIN — admin-added trips
--            with no customer booking will show NULL).
-- Run once in SSMS against your DriveNow database.
-- ============================================================

USE DriveNow;
GO

-- ── spListTrips ──────────────────────────────────────────────
ALTER PROCEDURE spListTrips
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
        ct.DropoffDate
    FROM       tblTrip         t
    JOIN       tblTripType     tt ON tt.TripTypeID = t.TripTypeID
    LEFT JOIN  tblCustomerTrip ct ON ct.TripID     = t.TripID
                                  AND ct.IsActive   = 1
    WHERE t.IsActive = 1
    ORDER BY t.TripDate DESC;
END
GO

-- ── spListInactiveTrips ──────────────────────────────────────
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
        ct.DropoffDate
    FROM       tblTrip         t
    JOIN       tblTripType     tt ON tt.TripTypeID = t.TripTypeID
    LEFT JOIN  tblCustomerTrip ct ON ct.TripID     = t.TripID
                                  AND ct.IsActive   = 1
    WHERE t.IsActive = 0
    ORDER BY t.TripDate DESC;
END
GO
