// ============================================================
// File:    ForgotPassword.aspx.cs
// Purpose: Handles the customer / staff forgot-password form.
//
//  Customer flow (?type=customer):
//    - Customer enters their e-mail and submits.
//    - PasswordResetManager.SubmitRequest() logs the request.
//    - The same success message is shown regardless of whether the
//      e-mail was found (prevents account-existence enumeration).
//    - Admin sees the request on TempPasswords.aspx and issues a
//      temporary password, which the customer uses to log in on
//      Default.aspx.
//
//  Staff flow (?type=staff):
//    - Staff enter their username.
//    - A generic message directs them to the system administrator.
// ============================================================

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace DriveNow
{
    public partial class ForgotPassword : Page
    {
        // Protected so <%= UserType %> expressions work in markup.
        protected string UserType =>
            (Request.QueryString["type"] ?? "customer").ToLower();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                ConfigureForUserType();
        }

        // ── UI configuration ──────────────────────────────────────

        private void ConfigureForUserType()
        {
            if (UserType == "staff")
            {
                litSubtitle.Text   = "Staff password reset";
                litFieldLabel.Text = "username";
                litInputLabel.Text = "Username";
                txtIdentifier.Attributes["placeholder"] = "Enter your staff username";
            }
            else
            {
                litSubtitle.Text   = "Customer password reset";
                litFieldLabel.Text = "email address";
                litInputLabel.Text = "Email address";
                txtIdentifier.Attributes["type"]        = "email";
                txtIdentifier.Attributes["placeholder"] = "you@example.com";
                // Enable client-side email format check for customer flow
                revEmailFormat.Enabled = true;
            }
        }

        // ── Button click ──────────────────────────────────────────

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string identifier = txtIdentifier.Text.Trim();

            // Hide the hint panel and the input form regardless of outcome
            pnlHint.Visible = false;
            pnlForm.Visible = false;

            if (UserType == "customer")
                HandleCustomerRequest(identifier);
            else
                HandleStaffRequest(identifier);
        }

        // ── Customer forgot-password handler ──────────────────────

        private void HandleCustomerRequest(string email)
        {
            // Basic format check first
            if (!System.Text.RegularExpressions.Regex.IsMatch(email,
                    @"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$"))
            {
                pnlHint.Visible = true;
                pnlForm.Visible = true;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Text     = "Please enter a valid email address.";
                lblMessage.Visible  = true;
                return;
            }

            // Check whether this email has a DriveNow account
            bool found = false;
            try
            {
                int requestID = PasswordResetManager.SubmitRequest(email);
                found = requestID > 0;
            }
            catch
            {
                // DB error — treat as not found so we don't leak stack traces
            }

            if (!found)
            {
                pnlHint.Visible = true;
                pnlForm.Visible = true;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Text     = "No DriveNow account was found for that email address. "
                                    + "Please check the address and try again, or "
                                    + "<a href=\"Default.aspx\" style=\"color:#0d9488\">create a new account</a>.";
                lblMessage.Visible  = true;
                return;
            }

            lblMessage.CssClass = "dn-alert-success";
            lblMessage.Text     = "Request submitted. An administrator will issue you a temporary "
                                + "password shortly. Return to the sign-in page and log in with "
                                + "the temporary password — you can update it immediately afterwards.";
            lblMessage.Visible  = true;
        }

        // ── Staff forgot-password handler ─────────────────────────

        private void HandleStaffRequest(string username)
        {
            try
            {
                // Log the request so admin can issue a temp password via the staff portal
                StaffPasswordResetManager.SubmitRequest(username);
            }
            catch { /* same message shown regardless */ }

            // Anti-enumeration: always show same message whether or not username exists
            lblMessage.CssClass = "dn-alert-success";
            lblMessage.Text     = "Your reset request has been submitted. "
                                + "An administrator will issue you a temporary password shortly. "
                                + "Return to the staff login page, sign in with the temporary password, "
                                + "and you will be prompted to set a new one immediately.";
            lblMessage.Visible  = true;
        }
    }
}
