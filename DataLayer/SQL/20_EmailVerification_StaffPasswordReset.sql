-- =============================================
-- Script 20: Email Verification + Staff Password Reset
-- Developer: Musanna | CTEC2713N | Niels Brock Copenhagen
-- Run after Script 19.
-- =============================================

USE DriveNow;
GO

-- ── PART A: EMAIL VERIFICATION ───────────────────────────────────────────────

-- Add verification columns to tblCustomer (safe to re-run)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tblCustomer') AND name = 'IsEmailVerified')
    ALTER TABLE dbo.tblCustomer ADD IsEmailVerified BIT NOT NULL DEFAULT 0;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tblCustomer') AND name = 'EmailVerificationToken')
    ALTER TABLE dbo.tblCustomer ADD EmailVerificationToken VARCHAR(64) NULL;
GO

-- Mark existing customers as verified so they can still log in
UPDATE dbo.tblCustomer SET IsEmailVerified = 1 WHERE IsEmailVerified = 0;
GO

-- spGenerateEmailVerificationToken — called after registration
-- Generates a random 40-char hex token, stores it, and returns it to C#
CREATE OR ALTER PROCEDURE spGenerateEmailVerificationToken
    @CustomerID INT,
    @Token      VARCHAR(64) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    -- Build a 40-char hex token from NEWID() + timestamp entropy
    SET @Token = LOWER(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''))
               + LOWER(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''));
    SET @Token = LEFT(@Token, 40);

    UPDATE tblCustomer
    SET    EmailVerificationToken = @Token,
           IsEmailVerified        = 0
    WHERE  CustomerID = @CustomerID;
END;
GO

-- spVerifyEmailToken — called from VerifyEmail.aspx
CREATE OR ALTER PROCEDURE spVerifyEmailToken
    @Token      VARCHAR(64),
    @CustomerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @CustomerID = 0;

    SELECT @CustomerID = CustomerID
    FROM   tblCustomer
    WHERE  EmailVerificationToken = @Token
      AND  IsEmailVerified = 0
      AND  IsActive = 1;

    IF @CustomerID > 0
    BEGIN
        UPDATE tblCustomer
        SET    IsEmailVerified        = 1,
               EmailVerificationToken = NULL
        WHERE  CustomerID = @CustomerID;
    END;
END;
GO

-- spResendEmailVerificationToken — regenerates token for existing unverified account
CREATE OR ALTER PROCEDURE spResendEmailVerificationToken
    @Email      NVARCHAR(150),
    @CustomerID INT OUTPUT,
    @Token      VARCHAR(64) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @CustomerID = 0;
    SET @Token      = NULL;

    SELECT @CustomerID = CustomerID
    FROM   tblCustomer
    WHERE  Email          = @Email
      AND  IsEmailVerified = 0
      AND  IsActive        = 1;

    IF @CustomerID > 0
    BEGIN
        SET @Token = LEFT(LOWER(REPLACE(CONVERT(VARCHAR(36),NEWID()),'-',''))
                       + LOWER(REPLACE(CONVERT(VARCHAR(36),NEWID()),'-','')), 40);

        UPDATE tblCustomer
        SET    EmailVerificationToken = @Token
        WHERE  CustomerID = @CustomerID;
    END;
END;
GO

-- Update spCustomerLogin to also return IsEmailVerified
CREATE OR ALTER PROCEDURE spCustomerLogin
    @Email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CustomerID, FullName, Email, Phone, PasswordHash, IsEmailVerified
    FROM   tblCustomer
    WHERE  Email    = @Email
      AND  IsActive = 1;
END;
GO

-- ── PART B: STAFF PASSWORD RESET ────────────────────────────────────────────

-- Staff password reset requests table
IF OBJECT_ID('dbo.tblStaffPasswordResetRequest', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tblStaffPasswordResetRequest (
        ResetID             INT           IDENTITY(1,1) NOT NULL,
        StaffID             INT           NOT NULL,
        RequestDate         DATETIME      NOT NULL DEFAULT GETDATE(),
        TempPasswordHash    NVARCHAR(255) NULL,
        TempPasswordDisplay NVARCHAR(50)  NULL,
        IsIssued            BIT           NOT NULL DEFAULT 0,
        IssuedDate          DATETIME      NULL,
        IsResolved          BIT           NOT NULL DEFAULT 0,
        ResolvedDate        DATETIME      NULL,
        CONSTRAINT PK_StaffPwdReset    PRIMARY KEY (ResetID),
        CONSTRAINT FK_StaffPwdReset_Staff FOREIGN KEY (StaffID)
            REFERENCES tblStaff(StaffID)
    );
    PRINT 'tblStaffPasswordResetRequest created.';
END
ELSE
    PRINT 'tblStaffPasswordResetRequest already exists.';
GO

-- spSubmitStaffPasswordResetRequest — staff submits forgot password request
CREATE OR ALTER PROCEDURE spSubmitStaffPasswordResetRequest
    @Username VARCHAR(50),
    @ResetID  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @ResetID = 0;

    DECLARE @StaffID INT;
    SELECT @StaffID = StaffID FROM tblStaff
    WHERE  Username = @Username AND IsActive = 1;

    IF @StaffID IS NULL RETURN; -- same message shown regardless (prevent enumeration)

    INSERT INTO tblStaffPasswordResetRequest (StaffID) VALUES (@StaffID);
    SET @ResetID = SCOPE_IDENTITY();
END;
GO

-- spListStaffPasswordResetRequests — admin view of staff reset requests
CREATE OR ALTER PROCEDURE spListStaffPasswordResetRequests
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        r.ResetID,
        r.StaffID,
        s.FullName,
        s.Username,
        r.RequestDate,
        r.TempPasswordDisplay,
        r.IsIssued,
        r.IssuedDate,
        r.IsResolved,
        r.ResolvedDate
    FROM   tblStaffPasswordResetRequest r
    INNER JOIN tblStaff s ON r.StaffID = s.StaffID
    ORDER BY r.IsResolved ASC, r.RequestDate DESC;
END;
GO

-- spIssueStaffTempPassword — admin issues temp password for a staff member
CREATE OR ALTER PROCEDURE spIssueStaffTempPassword
    @ResetID             INT,
    @TempPasswordHash    NVARCHAR(255),
    @TempPasswordDisplay NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblStaffPasswordResetRequest
    SET    TempPasswordHash    = @TempPasswordHash,
           TempPasswordDisplay = @TempPasswordDisplay,
           IsIssued            = 1,
           IssuedDate          = GETDATE()
    WHERE  ResetID = @ResetID;
END;
GO

-- spGetActiveStaffResetRequest — called during staff login when password fails
CREATE OR ALTER PROCEDURE spGetActiveStaffResetRequest
    @Username VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1
        r.ResetID,
        r.StaffID,
        r.TempPasswordHash,
        s.FullName,
        s.Username
    FROM   tblStaffPasswordResetRequest r
    INNER JOIN tblStaff s ON r.StaffID = s.StaffID
    WHERE  s.Username  = @Username
      AND  r.IsIssued  = 1
      AND  r.IsResolved = 0
    ORDER BY r.IssuedDate DESC;
END;
GO

-- spResolveStaffPasswordRequest — mark resolved, clear plain-text
CREATE OR ALTER PROCEDURE spResolveStaffPasswordRequest
    @ResetID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tblStaffPasswordResetRequest
    SET    IsResolved          = 1,
           ResolvedDate        = GETDATE(),
           TempPasswordDisplay = NULL
    WHERE  ResetID = @ResetID;
END;
GO

-- ── VERIFICATION ─────────────────────────────────────────────────────────────
SELECT 'Script 20 complete — Email verification + Staff password reset ready' AS Result;
SELECT CustomerID, FullName, Email, IsEmailVerified FROM tblCustomer ORDER BY CustomerID;
GO
