-- ============================================================
-- DriveNow — Script 12: spApproveContributor
-- Run AFTER Script 11.
-- Adds a dedicated stored procedure that sets a single
-- contributor's IsApproved flag to 1 (approved by staff).
-- Used by the "Approve" quick-action button in ContributorList.aspx.
-- ============================================================

USE DriveNow;
GO

CREATE OR ALTER PROCEDURE spApproveContributor
    @ContributorID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblContributor
    SET IsApproved = 1
    WHERE ContributorID = @ContributorID;
END;
GO

PRINT 'Script 12 complete — spApproveContributor created.';
GO
