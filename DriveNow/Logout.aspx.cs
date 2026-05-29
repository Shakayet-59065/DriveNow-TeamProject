// DriveNow — Logout.aspx Code-Behind
// Handles sign-out for both customers and staff.
// Clears all session data and redirects to the appropriate page:
//   - Customers → Default.aspx (public homepage)
//   - Staff → Login.aspx (staff sign-in page)
// Module: CTEC2713N

using System;

namespace DriveNow
{
    public partial class Logout : System.Web.UI.Page
    {
        // Runs as soon as the Logout page is visited — immediately clears the session and redirects
        protected void Page_Load(object sender, EventArgs e)
        {
            // Determine who is logging out before clearing the session
            bool wasCustomer = Session["CustomerLoggedIn"] != null && (bool)Session["CustomerLoggedIn"];
            bool wasStaff    = Session["LoggedIn"]         != null && (bool)Session["LoggedIn"];

            // Wipe all session data — this logs the user out completely
            Session.Clear();
            Session.Abandon();

            // Customers go back to the public homepage; staff go to the staff login page
            if (wasCustomer)
                Response.Redirect("Default.aspx");
            else
                Response.Redirect("Login.aspx");
        }
    }
}