using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

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
                string username = Session["Username"] != null ? Session["Username"].ToString() : "Admin";
                lblUsername.Text = username;

                // Dynamic time-of-day greeting
                int hour = DateTime.Now.Hour;
                string timeOfDay = hour < 12 ? "morning" : hour < 17 ? "afternoon" : "evening";
                lblGreeting.Text = "Good " + timeOfDay + ", " + System.Web.HttpUtility.HtmlEncode(username);

                // Display today's date in the top bar
                lblDate.Text = DateTime.Now.ToString("ddd, d MMM yyyy");

                // Load live stat counts from the database
                LoadStats();

                // Load recent trips into the dashboard table
                LoadRecentTrips();
            }
        }

        /// <summary>
        /// Loads all live stat counts via spGetDashboardStats (Script 10).
        /// Single stored procedure call — no inline SQL in the presentation layer.
        /// All five counts are returned in one DataRow to keep DB round-trips minimal.
        /// </summary>
        private void LoadStats()
        {
            try
            {
                System.Data.DataRow stats = manager.GetDashboardStats();
                if (stats != null)
                {
                    lblTripCount.Text        = stats["TripCount"].ToString();
                    lblTripTypeCount.Text    = stats["TripTypeCount"].ToString();
                    lblCustomerCount.Text    = stats["CustomerCount"].ToString();
                    lblDriverCount.Text      = stats["DriverCount"].ToString();
                    lblContributorCount.Text = stats["ContributorCount"].ToString();
                }
            }
            catch
            {
                // If the SP is not yet deployed, degrade gracefully
                lblTripCount.Text = lblTripTypeCount.Text = lblCustomerCount.Text =
                lblDriverCount.Text = lblContributorCount.Text = "0";
            }
        }

        /// <summary>
        /// Loads active and upcoming trips (excludes completed and returned) into the dashboard GridView.
        /// Filters out CarReturned trips so they disappear from the dashboard after being marked returned.
        /// </summary>
        private void LoadRecentTrips()
        {
            try
            {
                var trips = manager.ListTrips()
                    .Where(t => (t.TripStatus == "Upcoming" || t.TripStatus == "In Progress")
                                && !t.CarReturned)
                    .OrderBy(t => t.TripDate)
                    .Take(10)
                    .ToList();

                gvRecentTrips.DataSource = trips;
                gvRecentTrips.DataBind();
            }
            catch (Exception)
            {
                gvRecentTrips.DataSource = null;
                gvRecentTrips.DataBind();
            }
        }

        /// <summary>
        /// Handles the "Mark Returned" button in the GridView.
        /// Calls spMarkCarReturned — sets CarReturned=1 on tblTrip.
        /// This is the same stored procedure used by TripList, keeping both views in sync.
        /// </summary>
        protected void gvRecentTrips_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "MarkReturned")
            {
                int tripID = Convert.ToInt32(e.CommandArgument);
                try
                {
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand("spMarkCarReturned", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@TripID", tripID);
                        cmd.ExecuteNonQuery();
                    }
                    LoadRecentTrips(); // refresh — CarReturned trips no longer appear here
                }
                catch (Exception ex)
                {
                    throw new Exception("Could not mark trip as returned: " + ex.Message);
                }
            }
        }

        /// <summary>
        /// Returns an HTML status badge string based on TripStatus computed property.
        /// Called from the GridView ItemTemplate via <%# GetTripStatusBadge(...) %>.
        /// </summary>
        protected string GetTripStatusBadge(string status)
        {
            switch (status)
            {
                case "In Progress":
                    return "<span class=\"dn-status\"><span class=\"dn-dot dn-dot-green\"></span>In Progress</span>";
                case "Upcoming":
                    return "<span class=\"dn-status\" style=\"color:#93c5fd;\"><span class=\"dn-dot\" style=\"background:#3b82f6;\"></span>Upcoming</span>";
                default:
                    return "<span class=\"dn-status\" style=\"color:#94a3b8;\"><span class=\"dn-dot\" style=\"background:#94a3b8;\"></span>" + System.Web.HttpUtility.HtmlEncode(status) + "</span>";
            }
        }
    }
}
