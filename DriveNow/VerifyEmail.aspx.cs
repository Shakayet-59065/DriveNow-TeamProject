// DriveNow — VerifyEmail.aspx Code-Behind
// Handles the email verification link that new customers receive after registering.
// The link contains a unique token — this page checks the token and marks the email as verified.
// Once verified, the customer can log in to their account.
// Module: CTEC2713N

using System;
using System.Web.UI;

namespace DriveNow
{
    public partial class VerifyEmail : Page
    {
        // Runs when the customer clicks the verification link in their email
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // Read the verification token from the URL (e.g. ?token=abc123...)
            string token = Request.QueryString["token"];

            if (string.IsNullOrEmpty(token))
            {
                ShowResult(false, "No verification token found.",
                    "Please check the link in your email and try again.");
                return;
            }

            try
            {
                int customerID = EmailVerificationManager.VerifyToken(token);
                if (customerID > 0)
                {
                    ShowResult(true,
                        "Email verified successfully!",
                        "Your DriveNow account is now active. You can sign in and start booking.");
                }
                else
                {
                    ShowResult(false,
                        "Invalid or expired link.",
                        "This verification link has already been used or has expired. "
                        + "If you need a new link, use the resend option on the login page.");
                }
            }
            catch
            {
                ShowResult(false,
                    "Something went wrong.",
                    "We couldn't verify your email right now. Please try again or contact support.");
            }
        }

        private void ShowResult(bool success, string title, string body)
        {
            litIcon.Text  = success ? "✅" : "❌";
            litTitle.Text = title;
            litBody.Text  = body;

            if (success)
            {
                lnkAction.Text        = "Sign In Now →";
                lnkAction.NavigateUrl = "Default.aspx?openlogin=1";
                lnkAction.Visible     = true;
            }
            else
            {
                lnkAction.Text        = "← Back to Home";
                lnkAction.NavigateUrl = "Default.aspx";
                lnkAction.Visible     = true;
            }
        }
    }
}
