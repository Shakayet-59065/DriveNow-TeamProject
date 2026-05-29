-- =============================================
-- QUICK FIX — Run this in SSMS if admin/admin123 login is broken
-- Resets admin password back to plain text so TryLoginNew picks it up
-- Connect to: (localdb)\MSSQLLocalDB  Database: DriveNow
-- =============================================

USE DriveNow;
GO

-- Reset admin password to plain text 'admin123' and ensure account is active
UPDATE tblStaff
SET    PasswordHash = 'admin123',
       IsActive     = 1
WHERE  Username     = 'admin';

-- Verify the change
SELECT StaffID, Username, FullName, PasswordHash, IsActive
FROM   tblStaff
ORDER  BY StaffID;

GO
SELECT 'Admin password reset — try logging in with admin / admin123' AS Result;
