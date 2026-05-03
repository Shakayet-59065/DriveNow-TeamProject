using System;

namespace DriveNow
{
    public partial class MainMenu : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to login if not logged in
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
            {
                Response.Redirect("Login.aspx");
            }

            // Show the logged in username in the navbar
            if (!IsPostBack)
            {
                lblUsername.Text = Session["Username"] != null ? Session["Username"].ToString() : "Admin";
            }
        }
    }
}
