// ============================================================
// File:    SetNewPassword.aspx.cs
// Purpose: Forces a customer who logged in with an admin-issued
//          temporary password to choose a permanent new password
//          before accessing their dashboard.
//
//  Access guard:
//    - Session["CustomerLoggedIn"] must be true  (they are logged in)
//    - Session["TempPwLogin"]      must be true  (they used a temp pw)
//    If either is missing the page redirects away.
//
//  On success:
//    - Password hash updated in tblCustomer via spUpdateCustomerPassword.
//    - Session["TempPwLogin"] cleared.
//    - Customer redirected to CustomerPortal.aspx with a welcome flash.
// ============================================================

using System;
using System.Web.UI;

namespace DriveNow
{
    public partial class SetNewPassword : Page
    {
        // ── Page lifecycle ────────────────────────────────────────

        protected void Page_Load(object sender, EventArgs e)
        {
            // Must be logged in
            if (Session["CustomerLoggedIn"] == null || !(bool)Session["CustomerLoggedIn"])
            {
                Response.Redirect("Default.aspx");
                return;
            }

            // Must have arrived via a temp-password login — otherwise redirect
            // to portal (they already have a permanent password)
            if (Session["TempPwLogin"] == null || !(bool)Session["TempPwLogin"])
            {
                Response.Redirect("CustomerPortal.aspx");
                return;
            }
        }

        // ── Button handler ────────────────────────────────────────

        protected void btnSetPassword_Click(object sender, EventArgs e)
        {
            // Page.IsValid is checked automatically by ASP.NET validators,
            // but we double-check server-side for safety.
            if (!Page.IsValid) return;

            string newPassword     = txtNewPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            // Server-side match check (in case JS validation was bypassed)
            if (newPassword != confirmPassword)
            {
                lblMessage.Text    = "Passwords do not match. Please try again.";
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible  = true;
                return;
            }

            if (newPassword.Length < 8)
            {
                lblMessage.Text     = "Password must be at least 8 characters.";
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible  = true;
                return;
            }

            int customerID = Convert.ToInt32(Session["CustomerID"]);

            try
            {
                // Hash the new password and update the record
                string hash = PasswordHelper.HashPassword(newPassword);
                CustomerManager.UpdatePassword(customerID, hash);

                // Clear the temp-login flag — customer now has a permanent password
                Session.Remove("TempPwLogin");

                // Set a flash message for the portal welcome screen
                string name = Convert.ToString(Session["CustomerName"]);
                Session["FlashMessage"] = "welcome_back:" + name;

                // Redirect to the customer dashboard
                Response.Redirect("CustomerPortal.aspx");
            }
            catch (Exception ex)
            {
                lblMessage.Text     = "Unable to update your password. Please try again. ("
                                    + ex.Message + ")";
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible  = true;
            }
        }
    }
}
