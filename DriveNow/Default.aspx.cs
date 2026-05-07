using System;
using System.Web.UI;

// DriveNow — Homepage Code-Behind (Default.aspx)
// Handles customer login and registration from the landing page
// On success redirects customer to CustomerPortal.aspx
// Staff login is handled separately by Login.aspx
// Developer: Musanna | CTEC2713N | Niels Brock Copenhagen

namespace DriveNow
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // If customer already logged in, send straight to portal
            if (Session["CustomerLoggedIn"] != null && (bool)Session["CustomerLoggedIn"])
                Response.Redirect("CustomerPortal.aspx");
        }

        /// <summary>
        /// Customer login button — validates credentials against tblCustomer
        /// On success sets session and redirects to CustomerPortal.aspx
        /// This will be fully implemented by Tahmid's customer component
        /// For now uses prototype check — replace with spCustomerLogin stored procedure
        /// </summary>
        protected void btnCustomerLogin_Click(object sender, EventArgs e)
        {
            string email = txtLoginEmail.Text.Trim();
            string password = txtLoginPassword.Text.Trim();

            // Basic validation — both fields required
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                // Show error via JavaScript — page stays open
                ScriptManager.RegisterStartupScript(this, GetType(), "err",
                    "document.getElementById('loginError').style.display='block';" +
                    "openModal('userLogin');", true);
                return;
            }

            // TODO: Replace with Tahmid's spCustomerLogin stored procedure call
            // For prototype: hardcoded test customer credentials
            if (email == "customer@drivenow.com" && password == "customer123")
            {
                // Set customer session values
                // These will be populated from the database by Tahmid's component
                Session["CustomerLoggedIn"] = true;
                Session["CustomerId"] = 1;
                Session["CustomerName"] = "Test Customer";
                Session["CustomerEmail"] = email;

                // Redirect to the customer portal dashboard
                Response.Redirect("CustomerPortal.aspx");
            }
            else
            {
                // Show error message and keep modal open
                ScriptManager.RegisterStartupScript(this, GetType(), "err",
                    "document.getElementById('loginError').style.display='block';" +
                    "openModal('userLogin');", true);
            }
        }

        /// <summary>
        /// Register button — creates a new customer account
        /// This will call Tahmid's spAddCustomer stored procedure
        /// For now shows success message — full implementation by Tahmid
        /// </summary>
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string name = txtRegName.Text.Trim();
            string email = txtRegEmail.Text.Trim();
            string password = txtRegPassword.Text.Trim();

            // Validate all fields are filled
            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                lblRegError.Text = "Please fill in all fields to create your account.";
                lblRegError.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "reg",
                    "openModal('register');", true);
                return;
            }

            // Validate password length
            if (password.Length < 6)
            {
                lblRegError.Text = "Password must be at least 6 characters.";
                lblRegError.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "reg",
                    "openModal('register');", true);
                return;
            }

            // TODO: Replace with Tahmid's spAddCustomer stored procedure
            // For prototype: simulate successful registration and auto-login
            Session["CustomerLoggedIn"] = true;
            Session["CustomerId"] = 1;
            Session["CustomerName"] = name;
            Session["CustomerEmail"] = email;

            // Redirect to portal after successful registration
            Response.Redirect("CustomerPortal.aspx");
        }
    }
}
