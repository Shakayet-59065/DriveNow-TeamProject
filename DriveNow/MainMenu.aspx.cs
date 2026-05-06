using System;
using System.Data;
using System.Data.SqlClient;

// DriveNow Admin System — Main Menu / Dashboard Code-Behind
// Loads live stat counts from the database and displays recent trips
// Module: CTEC2713N | Developer: Musanna | Niels Brock Copenhagen

namespace DriveNow
{
    public partial class MainMenu : System.Web.UI.Page
    {
        // Instance of TripManager for calling middle layer methods
        TripManager manager = new TripManager();

        /// <summary>
        /// Page load — checks session, loads stats and recent trips
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to login if user is not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                // Display logged-in username in sidebar
                lblUsername.Text = Session["Username"] != null
                    ? Session["Username"].ToString()
                    : "Admin";

                // Display today's date in the top bar
                lblDate.Text = DateTime.Now.ToString("ddd, d MMM yyyy");

                // Load live stat counts from the database
                LoadStats();

                // Load recent trips into the dashboard table
                LoadRecentTrips();
            }
        }

        /// <summary>
        /// Loads live row counts from each table into the stat cards
        /// Uses direct SQL COUNT queries via DatabaseHelper
        /// </summary>
        private void LoadStats()
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    // Count active trips from tblTrip
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM tblTrip WHERE IsActive = 1", conn))
                    {
                        lblTripCount.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Count active trip types from tblTripType
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM tblTripType WHERE IsActive = 1", conn))
                    {
                        lblTripTypeCount.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Count active Users from tblCustomer
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM tblCustomer WHERE IsActive = 1", conn))
                    {
                        lblCustomerCount.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Count active drivers from tblDriver
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM tblDriver WHERE IsActive = 1", conn))
                    {
                        lblDriverCount.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            catch (Exception)
            {
                // If database is unavailable, show zero rather than crashing
                lblTripCount.Text = "0";
                lblTripTypeCount.Text = "0";
                lblCustomerCount.Text = "0";
                lblDriverCount.Text = "0";
            }
        }

        /// <summary>
        /// Loads the most recent 5 trips into the dashboard GridView
        /// Shows a quick overview without going to the full list page
        /// </summary>
        private void LoadRecentTrips()
        {
            try
            {
                // Get all trips and take the first 5 for the dashboard
                var trips = manager.ListTrips();

                // Limit to 5 most recent trips for the dashboard view
                int count = trips.Count > 5 ? 5 : trips.Count;
                gvRecentTrips.DataSource = trips.GetRange(0, count);
                gvRecentTrips.DataBind();
            }
            catch (Exception)
            {
                // If trips cannot load, leave the table empty
                gvRecentTrips.DataSource = null;
                gvRecentTrips.DataBind();
            }
        }
    }
}
