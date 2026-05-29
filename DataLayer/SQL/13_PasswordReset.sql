-- ============================================================
-- DriveNow — Script 13: Customer Password Reset System
-- Run AFTER Script 12.
-- Creates tblPasswordResetRequest and all stored procedures
-- needed for the customer forgot-password workflow:
--   1. Customer submits email on ForgotPassword.aspx
--   2. Admin sees the request on TempPasswords.aspx
--   3. Admin issues a generated temporary password
--   4. Customer logs in with temp password -> redirected to portal
--   5. Request is marked resolved; temp password cleared
-- ============================================================

USE DriveNow;
GO

-- ── TABLE ────────────────────────────────────────────────────
CREATE TABLE tblPasswordResetRequest (
    RequestID            INT           IDENTITY(1,1) NOT NULL,
    CustomerID           INT           NOT NULL,
    RequestDate          DATETIME      NOT NULL DEFAULT GETDATE(),
    TempPasswordHash     NVARCHAR(255) NULL,      -- BCrypt hash used for auth
    TempPasswordDisplay  NVARCHAR(50)  NULL,      -- Plain text shown to admin only; cleared on resolve
    IsIssued             BIT           NOT NULL DEFAULT 0,
    IssuedDate           DATETIME      NULL,
    IsResolved           BIT           NOT NULL DEFAULT 0,
    ResolvedDate         DATETIME      NULL,
    CONSTRAINT PK_PasswordResetRequest PRIMARY KEY (RequestID),
    CONSTRAINT FK_PwdReset_Customer    FOREIGN KEY (CustomerID)
        REFERENCES tblCustomer(CustomerID)
);
GO

PRINT 'tblPasswordResetRequest created.';
GO

-- ── spSubmitPasswordResetRequest ─────────────────────────────
-- Called by ForgotPassword.aspx when a customer submits their email.
-- Looks up the customer, creates a pending request.
-- Returns 0 in @RequestID when email is not found (prevents enumeration
-- because the page shows the same success message either way).
CREATE OR ALTER PROCEDURE spSubmitPasswordResetRequest
    @Email     NVARCHAR(150),
    @RequestID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CustID INT;
    SELECT @CustID = CustomerID
    FROM   tblCustomer
    WHERE  Email    = @Email
      AND  IsActive = 1;

    IF @CustID IS NULL
    BEGIN
        SET @RequestID = 0;   -- not revealed to caller/user
        RETURN;
    END;

    INSERT INTO tblPasswordResetRequest (CustomerID)
    VALUES (@CustID);

    SET @RequestID = SCOPE_IDENTITY();
END;
GO

-- ── spListPasswordResetRequests ──────────────────────────────
-- Returns all requests with joined customer details for the admin grid.
-- Unresolved requests appear first; newest requests within each group first.
CREATE OR ALTER PROCEDURE spListPasswordResetRequests
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.RequestID,
        r.CustomerID,
        c.FullName,
        c.Email,
        c.Phone,
        r.RequestDate,
        r.TempPasswordDisplay,
        r.IsIssued,
        r.IssuedDate,
        r.IsResolved,
        r.ResolvedDate
    FROM   tblPasswordResetRequest r
    INNER JOIN tblCustomer c ON r.CustomerID = c.CustomerID
    ORDER BY r.IsResolved ASC, r.RequestDate DESC;
END;
GO

-- ── spIssueTempPassword ──────────────────────────────────────
-- Admin triggers this after generating a random temporary password.
-- Stores the BCrypt hash (for auth) and plain text (for admin display).
CREATE OR ALTER PROCEDURE spIssueTempPassword
    @RequestID           INT,
    @TempPasswordHash    NVARCHAR(255),
    @TempPasswordDisplay NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tblPasswordResetRequest
    SET TempPasswordHash    = @TempPasswordHash,
        TempPasswordDisplay = @TempPasswordDisplay,
        IsIssued            = 1,
        IssuedDate          = GETDATE()
    WHERE RequestID = @RequestID;
END;
GO

-- ── spGetActiveResetRequest ───────────────────────────────────
-- Called during customer login when regular password fails.
-- Returns the most recently issued-but-unresolved request for the email.
-- Returns FullName and Email so the login handler can populate the session.
CREATE OR ALTER PROCEDURE spGetActiveResetRequest
    @Email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        r.RequestID,
        r.CustomerID,
        r.TempPasswordHash,
        c.FullName,
        c.Email
    FROM   tblPasswordResetRequest r
    INNER JOIN tblCustomer c ON r.CustomerID = c.CustomerID
    WHERE  c.Email     = @Email
      AND  r.IsIssued  = 1
      AND  r.IsResolved = 0
    ORDER BY r.IssuedDate DESC;
END;
GO

-- ── spResolvePasswordRequest ─────────────────────────────────
-- Called after a customer successfully logs in with a temp password.
-- Marks the request resolved and clears the plain-text display value
-- so it is no longer visible in the admin view.
CREATE OR ALTER PROCEDURE spResolvePasswordRequest
    @RequestID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tblPasswordResetRequest
    SET IsResolved          = 1,
        ResolvedDate        = GETDATE(),
        TempPasswordDisplay = NULL   -- remove plain text after use
    WHERE RequestID = @RequestID;
END;
GO

PRINT 'Script 13 complete — tblPasswordResetRequest and 5 stored procedures created.';
GO
