-- =============================================
-- Script:  15_TripTypeAdvancedFilter.sql
-- Purpose: Adds spFilterTripTypesAdvanced, which is called by
--          TripTypeFilter.aspx via TripManager.FilterTripTypesAdvanced().
--          Replaces the inline SQL that previously existed in the
--          code-behind — routes all DB access through a stored procedure
--          as required by the three-tier architecture.
-- Developer: Musanna | CTEC2713N | Niels Brock Copenhagen
-- Run after: 1_Tables_And_TestData.sql (tblTripType must exist)
-- =============================================

USE DriveNow;
GO

-- Drop if it already exists so this script can be re-run safely
IF OBJECT_ID('dbo.spFilterTripTypesAdvanced', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spFilterTripTypesAdvanced;
GO

-- =============================================
-- spFilterTripTypesAdvanced
-- Filters tblTripType by active status and/or base rate range.
-- All three parameters are optional (default NULL):
--   @IsActive  — 1 = active only, 0 = inactive only, NULL = both
--   @MinRate   — lower bound for BaseRate (inclusive), NULL = no lower bound
--   @MaxRate   — upper bound for BaseRate (inclusive), NULL = no upper bound
-- =============================================
CREATE PROCEDURE spFilterTripTypesAdvanced
    @IsActive  BIT          = NULL,
    @MinRate   DECIMAL(8,2) = NULL,
    @MaxRate   DECIMAL(8,2) = NULL
AS
BEGIN
    -- Return trip types matching all supplied filter criteria.
    -- NULL parameter means that criterion is skipped (return all for that field).
    SELECT TripTypeID, TypeName, Description, BaseRate, CreatedDate, IsActive
    FROM   tblTripType
    WHERE  (@IsActive IS NULL OR IsActive  = @IsActive)
    AND    (@MinRate  IS NULL OR BaseRate  >= @MinRate)
    AND    (@MaxRate  IS NULL OR BaseRate  <= @MaxRate)
    ORDER BY TripTypeID;
END;
GO

-- Verify the procedure was created
SELECT 'spFilterTripTypesAdvanced created successfully' AS Result;
GO
