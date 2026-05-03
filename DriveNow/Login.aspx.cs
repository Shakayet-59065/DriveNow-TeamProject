using System;


namespace DriveNow
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to main menu if already logged in
            if (Session["LoggedIn"] != null && (bool)Session["LoggedIn"])
            {
                Response.Redirect("MainMenu.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Get username and password from form
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Basic validation — check fields are not empty
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Please enter both username and password.";
                lblError.Visible = true;
                return;
            }

            // Hardcoded admin login for prototype
            // In a full system this would call a stored procedure
            if (username == "admin" && password == "admin123")
            {
                // Store login state in session
                Session["LoggedIn"] = true;
                Session["Username"] = username;

                // Redirect to main menu
                Response.Redirect("MainMenu.aspx");
            }
            else
            {
                lblError.Text = "Invalid username or password. Please try again.";
                lblError.Visible = true;
            }
        }
    }
}
