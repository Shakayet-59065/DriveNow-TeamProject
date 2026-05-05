using System;

namespace DriveNow
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Clear all session data — removes login state
            Session.Clear();
            Session.Abandon();

            // Redirect to login page after logout
            Response.Redirect("Login.aspx");
        }
    }
}