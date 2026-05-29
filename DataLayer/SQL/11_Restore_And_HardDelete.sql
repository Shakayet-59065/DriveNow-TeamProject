-- ============================================================
-- DriveNow — Script 11: Restore + Hard Delete for all entities
-- Run AFTER Script 10.
-- Adds Restore (reactivate) and HardDelete (permanent remove)
-- stored procedures for Driver, Trip, TripType, Vehicle, Customer.
-- Contributors already have hard delete via Script 8.
-- ============================================================

USE DriveNow;
GO

-- ============================================================
-- DRIVER
-- ============================================================
CREATE OR ALTER PROCEDURE spRestoreDriver
    @DriverID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblDriver SET IsActive = 1 WHERE DriverID = @DriverID;
END;
GO

CREATE OR ALTER PROCEDURE spHardDeleteDriver
    @DriverID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- DriverID is a nullable FK in tblTrip — NULL it out before deleting
    UPDATE tblTrip SET DriverID = NULL WHERE DriverID = @DriverID;
    DELETE FROM tblDriver WHERE DriverID = @DriverID;
END;
GO

-- ============================================================
-- TRIP
-- ============================================================
CREATE OR ALTER PROCEDURE spRestoreTrip
    @TripID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblTrip SET IsActive = 1 WHERE TripID = @TripID;
END;
GO

CREATE OR ALTER PROCEDURE spHardDeleteTrip
    @TripID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Remove any CustomerTrip bookings that reference this trip
    DELETE FROM tblCustomerTrip WHERE TripID = @TripID;
    DELETE FROM tblTrip          WHERE TripID = @TripID;
END;
GO

-- ============================================================
-- TRIP TYPE
-- ============================================================
CREATE OR ALTER PROCEDURE spRestoreTripType
    @TripTypeID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblTripType SET IsActive = 1 WHERE TripTypeID = @TripTypeID;
END;
GO

CREATE OR ALTER PROCEDURE spHardDeleteTripType
    @TripTypeID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Refuse if any trips still reference this type (FK constraint protection)
    IF EXISTS (SELECT 1 FROM tblTrip WHERE TripTypeID = @TripTypeID)
    BEGIN
        RAISERROR('Cannot permanently delete this trip type — existing trip records still reference it. Soft-delete and archive those trips first.', 16, 1);
        RETURN;
    END
    DELETE FROM tblTripType WHERE TripTypeID = @TripTypeID;
END;
GO

-- ============================================================
-- VEHICLE
-- ============================================================
CREATE OR ALTER PROCEDURE spRestoreVehicle
    @VehicleID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblVehicle SET IsAvailable = 1 WHERE VehicleID = @VehicleID;
END;
GO

CREATE OR ALTER PROCEDURE spHardDeleteVehicle
    @VehicleID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Refuse if trips still reference this vehicle (FK constraint protection)
    IF EXISTS (SELECT 1 FROM tblTrip WHERE VehicleID = @VehicleID)
    BEGIN
        RAISERROR('Cannot permanently delete this vehicle — existing trip records still reference it. Soft-delete and archive those trips first.', 16, 1);
        RETURN;
    END
    DELETE FROM tblVehicle WHERE VehicleID = @VehicleID;
END;
GO

-- ============================================================
-- CUSTOMER
-- ============================================================
CREATE OR ALTER PROCEDURE spRestoreCustomer
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblCustomer SET IsActive = 1 WHERE CustomerID = @CustomerID;
END;
GO

CREATE OR ALTER PROCEDURE spHardDeleteCustomer
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Remove CustomerTrip bookings for this customer
    DELETE FROM tblCustomerTrip WHERE CustomerID = @CustomerID;
    -- Refuse if tblTrip still has rows for this customer (not nullable FK)
    IF EXISTS (SELECT 1 FROM tblTrip WHERE CustomerID = @CustomerID)
    BEGIN
        RAISERROR('Cannot permanently delete this customer — trip records still reference them. Soft-delete those trips first, then retry.', 16, 1);
        RETURN;
    END
    DELETE FROM tblCustomer WHERE CustomerID = @CustomerID;
END;
GO

PRINT 'Script 11 complete — Restore + HardDelete stored procedures created for all entities.';
GO
