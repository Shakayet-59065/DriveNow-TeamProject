-- ============================================================
-- Script 21: Vehicle Availability Check, Loyalty Tier, Spend Fix
-- Run after all previous scripts (1-20).
-- Safe to re-run: uses CREATE OR ALTER and IF EXISTS guards.
-- ============================================================

USE DriveNow;
GO

-- ============================================================
-- 1. spCheckVehicleAvailability
--    Returns number of conflicting active bookings for a vehicle
--    in the requested date window. ConflictCount > 0 = unavailable.
-- ============================================================
CREATE OR ALTER PROCEDURE spCheckVehicleAvailability
    @VehicleID   INT,
    @PickupDate  DATETIME,
    @DropoffDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS ConflictCount
    FROM   tblCustomerTrip ct
    INNER JOIN tblTrip t ON ct.TripID = t.TripID
    WHERE  t.VehicleID    = @VehicleID
    AND    ct.IsActive    = 1
    AND    t.IsActive     = 1
    AND    ct.PickupDate  < @DropoffDate
    AND    ct.DropoffDate > @PickupDate;
END;
GO

-- ============================================================
-- 2. spGetBusyVehicleIDs
--    Returns VehicleIDs that have active bookings overlapping
--    a given date window. Used by BrowseFleet to mark unavailable.
-- ============================================================
CREATE OR ALTER PROCEDURE spGetBusyVehicleIDs
    @FromDate DATETIME,
    @ToDate   DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DISTINCT t.VehicleID
    FROM   tblCustomerTrip ct
    INNER JOIN tblTrip t ON ct.TripID = t.TripID
    WHERE  ct.IsActive    = 1
    AND    t.IsActive     = 1
    AND    ct.PickupDate  < @ToDate
    AND    ct.DropoffDate > @FromDate;
END;
GO

-- ============================================================
-- 3. spCancelCustomerTrip (FIX)
--    Previous version matched CustomerTripID against tblTrip.TripID
--    which is wrong. This version correctly soft-deletes BOTH
--    tblCustomerTrip and tblTrip rows, with ownership verification.
-- ============================================================
CREATE OR ALTER PROCEDURE spCancelCustomerTrip
    @CustomerTripID INT,
    @CustomerID     INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Look up TripID from tblCustomerTrip (ownership check: CustomerID must match)
    DECLARE @TripID INT;
    SELECT @TripID = TripID
    FROM   tblCustomerTrip
    WHERE  CustomerTripID = @CustomerTripID
    AND    CustomerID     = @CustomerID
    AND    IsActive       = 1;

    IF @TripID IS NOT NULL
    BEGIN
        -- Soft-cancel the booking detail record
        UPDATE tblCustomerTrip
        SET    IsActive = 0
        WHERE  CustomerTripID = @CustomerTripID
        AND    CustomerID     = @CustomerID;

        -- Soft-cancel the parent trip record
        UPDATE tblTrip
        SET    IsActive = 0
        WHERE  TripID = @TripID;
    END
END;
GO

-- ============================================================
-- 4. spListCustomerTrips (UPDATE)
--    Add VehicleDailyRate and TripDays to support accurate
--    spend calculation in CustomerPortal.
-- ============================================================
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
    AND    ct.IsActive   = 1
    ORDER  BY ct.PickupDate DESC;
END;
GO

-- ============================================================
-- 5. spGetCustomerLoyaltyStats
--    Returns completed trip count and calculated loyalty tier.
-- ============================================================
CREATE OR ALTER PROCEDURE spGetCustomerLoyaltyStats
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Completed INT;
    SELECT @Completed = COUNT(*)
    FROM   tblCustomerTrip ct
    INNER JOIN tblTrip t ON ct.TripID = t.TripID
    WHERE  ct.CustomerID    = @CustomerID
    AND    ct.IsActive      = 1
    AND    ct.DropoffDate  <= GETDATE();

    SELECT
        @Completed AS CompletedTrips,
        CASE
            WHEN @Completed >= 20 THEN 'Platinum'
            WHEN @Completed >= 10 THEN 'Gold'
            WHEN @Completed >= 5  THEN 'Silver'
            WHEN @Completed >= 1  THEN 'Bronze'
            ELSE                       'Guest'
        END AS LoyaltyTier,
        CASE
            WHEN @Completed >= 20 THEN 20
            WHEN @Completed >= 10 THEN 10
            WHEN @Completed >= 5  THEN 5
            WHEN @Completed >= 1  THEN 1
            ELSE                       0
        END AS TierThreshold,
        CASE
            WHEN @Completed >= 20 THEN 9999
            WHEN @Completed >= 10 THEN 20
            WHEN @Completed >= 5  THEN 10
            WHEN @Completed >= 1  THEN 5
            ELSE                       1
        END AS NextThreshold;
END;
GO

PRINT 'Script 21 complete: spCheckVehicleAvailability, spGetBusyVehicleIDs, spCancelCustomerTrip (fixed), spListCustomerTrips (updated), spGetCustomerLoyaltyStats';
GO
