using System;
using System.Web.UI;

namespace DriveNow
{
    public partial class ResendVerification : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Pre-fill email from query string (passed from login error message)
                string email = Request.QueryString["email"];
                if (!string.IsNullOrEmpty(email))
                    txtEmail.Text = email;
            }
        }

        protected void btnResend_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            pnlForm.Visible = false;

            try
            {
                int customerID;
                string token = EmailVerificationManager.ResendToken(email, out customerID);

                if (customerID > 0 && !string.IsNullOrEmpty(token))
                {
                    string verifyUrl = ResolveUrl("~/VerifyEmail.aspx?token=" + Uri.EscapeDataString(token));
                    lblMessage.Text = "A new verification link has been generated for <strong>" + Server.HtmlEncode(email) + "</strong>.<br />"
                                    + "In a real deployment this is emailed to you. For this demo: "
                                    + "<a href=\"" + verifyUrl + "\" style=\"color:#14b8a6;font-weight:700;\">Click here to verify your email</a>.";
                    lblMessage.CssClass = "alert alert-success";
                }
                else
                {
                    lblMessage.Text     = "No unverified account found with that email address. "
                                        + "It may already be verified, or the email may be incorrect.";
                    lblMessage.CssClass = "alert alert-error";
                }
            }
            catch
            {
                lblMessage.Text     = "An error occurred. Please try again or contact support.";
                lblMessage.CssClass = "alert alert-error";
            }

            lblMessage.Visible = true;
        }
    }
}
