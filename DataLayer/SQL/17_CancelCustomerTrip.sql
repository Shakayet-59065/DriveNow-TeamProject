-- =============================================
-- Script:  17_CancelCustomerTrip.sql
-- Purpose: Adds spCancelCustomerTrip, called by CustomerPortal.aspx
--          when a customer cancels an upcoming booking.
--          Soft-cancels only (IsActive = 0) — record kept for audit.
--          Ownership check: CustomerID must match the logged-in customer.
-- Developer: Musanna | CTEC2713N | Niels Brock Copenhagen
-- Run after: 1_Tables_And_TestData.sql (tblTrip must exist)
-- =============================================

USE DriveNow;
GO

-- Drop if it already exists so this script can be re-run safely
IF OBJECT_ID('dbo.spCancelCustomerTrip', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCancelCustomerTrip;
GO

-- =============================================
-- spCancelCustomerTrip
-- Soft-deletes a trip row belonging to the given customer.
-- Parameters:
--   @CustomerTripID — TripID to cancel
--   @CustomerID     — CustomerID from session (ownership check — prevents one
--                     customer cancelling another customer's trip)
-- =============================================
CREATE PROCEDURE spCancelCustomerTrip
    @CustomerTripID INT,
    @CustomerID     INT
AS
BEGIN
    -- Only cancel if the trip belongs to this customer (GDPR ownership check)
    UPDATE tblTrip
    SET    IsActive = 0
    WHERE  TripID      = @CustomerTripID
    AND    CustomerID  = @CustomerID;
END;
GO

-- Verify the procedure was created
SELECT 'spCancelCustomerTrip created successfully' AS Result;
GO
