USE DriveNow;
GO

IF OBJECT_ID('dbo.spListTripsByCustomer','P') IS NOT NULL DROP PROCEDURE dbo.spListTripsByCustomer;
GO
CREATE PROCEDURE spListTripsByCustomer
    @CustomerId INT
AS
BEGIN
    SELECT
        t.TripID,
        t.CustomerID,
        t.VehicleID,
        t.DriverID,
        t.TripTypeID,
        tt.TypeName,
        tt.BaseRate,
        t.TripDate,
        t.IsActive,
        v.Make        AS VehicleMake,
        v.Model       AS VehicleModel,
        v.DailyRate   AS VehicleDailyRate,
        d.FullName    AS DriverName
    FROM   tblTrip t
    INNER  JOIN tblTripType tt ON t.TripTypeID = tt.TripTypeID
    INNER  JOIN tblVehicle  v  ON t.VehicleID  = v.VehicleID
    LEFT   JOIN tblDriver   d  ON t.DriverID   = d.DriverID
    WHERE  t.CustomerID = @CustomerId
    ORDER  BY t.TripDate DESC;
END;
GO
