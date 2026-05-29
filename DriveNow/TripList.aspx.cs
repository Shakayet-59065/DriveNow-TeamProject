using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

// DriveNow — Trip List Code-Behind
// Lists active or inactive trips depending on tab query-string.
// Supports soft-delete (Deactivate), Restore (reactivate), and Hard Delete (permanent remove).
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripList : System.Web.UI.Page
    {
        // Creates a TripManager object to handle all database operations for trips
        TripManager manager = new TripManager();

        // Returns the CSS class for the active/inactive tab — highlights which tab the user is on
        protected string TabCss(string tabName)
        {
            // Reads the ?tab= value from the URL; defaults to "active" if not provided
            string current = Request.QueryString["tab"] ?? "active";
            return current == tabName ? "dn-pill active" : "dn-pill";
        }

        // Runs automatically when the page first loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // If the user is not logged in, send them to the login page immediately
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Only load the trip list on first visit — not on every button click (PostBack)
            if (!IsPostBack)
                LoadTrips();
        }

        // Fetches trip records from the database and binds them to the grid on screen
        private void LoadTrips()
        {
            try
            {
                // Decide which list to show — active trips or inactive/deactivated trips
                bool showInactive = Request.QueryString["tab"] == "inactive";
                gvTrips.DataSource = showInactive ? manager.ListInactiveTrips() : manager.ListTrips();
                gvTrips.DataBind();

                // Show a helpful empty message if no trips are found for the selected tab
                gvTrips.EmptyDataText = showInactive ? "No inactive trips found." : "No active trips found.";
            }
            catch (Exception ex)
            {
                // Display the database error to the admin so they know something went wrong
                lblError.Text    = "Error loading trips: " + ex.Message;
                lblError.Visible = true;
            }
        }

        // Handles all button actions in the trips grid (Edit, Deactivate, Restore, Delete, Mark Returned)
        protected void gvTrips_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Read the Trip ID that was passed from the button in the grid row
            int tripID = int.Parse(e.CommandArgument.ToString());

            // Redirect to the Edit page for this trip
            if (e.CommandName == "EditTrip")
            {
                Response.Redirect("TripEdit.aspx?id=" + tripID);
            }
            // Soft-delete: marks the trip as inactive but keeps the record in the database
            else if (e.CommandName == "DeleteTrip")
            {
                try
                {
                    manager.DeleteTrip(tripID);
                    lblError.Text    = "Trip deactivated. Record retained for audit.";
                    lblError.CssClass = "dn-alert-success";
                    lblError.Visible = true;
                    LoadTrips(); // Refresh the list to reflect the change
                }
                catch (Exception ex)
                {
                    lblError.Text    = "Error deactivating trip: " + ex.Message;
                    lblError.CssClass = "dn-alert-error";
                    lblError.Visible = true;
                }
            }
            // Restore: brings a previously deactivated trip back to active status
            else if (e.CommandName == "RestoreTrip")
            {
                try
                {
                    manager.RestoreTrip(tripID);
                    lblError.Text    = "Trip restored to active status.";
                    lblError.CssClass = "dn-alert-success";
                    lblError.Visible = true;
                    LoadTrips(); // Refresh the list to show the restored trip
                }
                catch (Exception ex)
                {
                    lblError.Text    = "Error restoring trip: " + ex.Message;
                    lblError.CssClass = "dn-alert-error";
                    lblError.Visible = true;
                }
            }
            // Hard Delete: permanently removes the trip record from the database — cannot be undone
            else if (e.CommandName == "HardDeleteTrip")
            {
                try
                {
                    manager.HardDeleteTrip(tripID);
                    lblError.Text    = "Trip permanently deleted.";
                    lblError.CssClass = "dn-alert-success";
                    lblError.Visible = true;
                    LoadTrips(); // Refresh the list after permanent deletion
                }
                catch (Exception ex)
                {
                    lblError.Text    = "Error: " + ex.Message;
                    lblError.CssClass = "dn-alert-error";
                    lblError.Visible = true;
                }
            }
            // Mark Car Returned: records that the customer has returned the vehicle
            else if (e.CommandName == "MarkCarReturned")
            {
                try
                {
                    // Call the stored procedure directly to update the CarReturned flag in the database
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand("spMarkCarReturned", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@TripID", tripID);
                        cmd.ExecuteNonQuery();
                    }
                    lblError.Text     = "Vehicle marked as returned.";
                    lblError.CssClass = "dn-alert-success";
                    lblError.Visible  = true;
                    LoadTrips(); // Refresh so the tick icon appears on this trip row
                }
                catch (Exception ex)
                {
                    lblError.Text    = "Error marking car returned: " + ex.Message;
                    lblError.CssClass = "dn-alert-error";
                    lblError.Visible = true;
                }
            }
        }

        // Returns the correct colour badge CSS class based on the trip's current status text
        protected string GetStatusCss(string status)
        {
            switch (status)
            {
                case "In Progress":           return "dn-badge dn-badge-green";
                case "Upcoming":              return "dn-badge dn-badge-blue";
                case "Cancelled by Admin":    return "dn-badge dn-badge-red";
                case "Cancelled by Customer": return "dn-badge dn-badge-orange";
                case "Car Returned":          return "dn-badge dn-badge-teal";
                default:                      return "dn-badge dn-badge-grey";
            }
        }

        // ── CSV Export ────────────────────────────────────────────────────────
        // Exports ALL trips (active + inactive) as a CSV file that opens in Excel.
        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT t.TripID                       AS [Trip ID],
                             c.FullName                     AS [Customer],
                             c.Email                        AS [Customer Email],
                             v.RegistrationNo               AS [Vehicle Reg],
                             v.Make + ' ' + v.Model         AS [Vehicle],
                             ISNULL(d.FullName, 'Self-Drive') AS [Driver],
                             tt.TypeName                    AS [Trip Type],
                             t.TripDate                     AS [Trip Date],
                             ISNULL(CONVERT(NVARCHAR,ct.PickupDate,103),'')  AS [Pickup Date],
                             ISNULL(ct.PickupLocation,'')   AS [Pickup Location],
                             ISNULL(CONVERT(NVARCHAR,ct.DropoffDate,103),'') AS [Dropoff Date],
                             ISNULL(ct.DropoffLocation,'')  AS [Dropoff Location],
                             CASE
                                 WHEN t.IsActive = 0 THEN 'Cancelled'
                                 WHEN ct.DropoffDate IS NOT NULL AND ct.DropoffDate <= GETDATE() THEN 'Completed'
                                 ELSE 'Active'
                             END AS [Status]
                      FROM   tblTrip t
                      JOIN   tblCustomer  c  ON c.CustomerID  = t.CustomerID
                      JOIN   tblVehicle   v  ON v.VehicleID   = t.VehicleID
                      LEFT JOIN tblDriver d  ON d.DriverID    = t.DriverID
                      JOIN   tblTripType  tt ON tt.TripTypeID = t.TripTypeID
                      LEFT JOIN tblCustomerTrip ct ON ct.TripID = t.TripID AND ct.IsActive = 1
                      ORDER  BY t.TripID", conn))
                {
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex)
            {
                lblError.Text     = "Export failed: " + ex.Message;
                lblError.CssClass = "dn-alert-error";
                lblError.Visible  = true;
                return;
            }
            DataExport.DownloadCsv(Response, dt, "DriveNow_Trips");
        }
    }
}
