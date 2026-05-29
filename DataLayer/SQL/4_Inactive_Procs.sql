-- ============================================================
-- 4_Inactive_Procs.sql
-- DriveNow — Inactive Record Stored Procedures
-- Run this script in SSMS against the DriveNow database
-- to enable the Active/Inactive toggle on staff list pages.
-- ============================================================

-- Returns trips where IsActive = 0 (soft-deleted trips)
-- Mirrors spListTrips but filters for inactive records
CREATE OR ALTER PROCEDURE spListInactiveTrips
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  t.TripID,
            t.CustomerId,
            t.VehicleID,
            t.DriverID,
            t.TripTypeID,
            tt.TypeName,
            t.TripDate,
            t.IsActive
    FROM    tblTrip     t
    JOIN    tblTripType tt ON t.TripTypeID = tt.TripTypeID
    WHERE   t.IsActive = 0
    ORDER BY t.TripID DESC;
END
GO

-- Returns trip types where IsActive = 0 (soft-deleted trip types)
CREATE OR ALTER PROCEDURE spListInactiveTripTypes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  TripTypeID,
            TypeName,
            Description,
            BaseRate,
            CreatedDate,
            IsActive
    FROM    tblTripType
    WHERE   IsActive = 0
    ORDER BY TypeName;
END
GO
