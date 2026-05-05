using System;

// DriveNow Admin System — Login Code-Behind
// Handles staff authentication for the DriveNow admin portal
// Module: CTEC2713N | Developer: Musanna | Niels Brock Copenhagen

namespace DriveNow
{
    public partial class Login : System.Web.UI.Page
    {
        /// <summary>
        /// Page load — if already logged in, redirect to main menu
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            // If session shows user is already logged in, skip the login page
            if (Session["LoggedIn"] != null && (bool)Session["LoggedIn"])
            {
                Response.Redirect("MainMenu.aspx");
            }
        }

        /// <summary>
        /// Login button click — validates credentials and creates session
        /// Prototype uses hardcoded admin credentials
        /// In production this would call a stored procedure against tblStaff
        /// </summary>
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Read username and password from form fields
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Validate that both fields have been filled in
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Please enter both your username and password.";
                lblError.Visible = true;
                return;
            }

            // Hardcoded admin credentials for prototype
            // Username: admin | Password: admin123
            if (username == "admin" && password == "admin123")
            {
                // Store login state and username in session
                Session["LoggedIn"] = true;
                Session["Username"] = username;

                // Redirect to the main dashboard
                Response.Redirect("MainMenu.aspx");
            }
            else
            {
                // Show error for invalid credentials
                lblError.Text = "Invalid username or password. Please try again.";
                lblError.Visible = true;
            }
        }
    }
}
