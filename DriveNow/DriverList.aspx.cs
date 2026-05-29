using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

// DriveNow — Driver List Code-Behind
// Lists active or inactive drivers depending on tab query-string.
// Supports soft-delete (Deactivate), Restore (reactivate), and Hard Delete (permanent remove).
// Module: CTEC2713N | Developer: Redoy

namespace DriveNow
{
    public partial class DriverList : System.Web.UI.Page
    {
        // Creates a DriverManager object to handle all driver-related database operations
        DriverManager dm = new DriverManager();

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to login if the user does not have an active staff session
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Only fetch driver data on the first load — not after every button click
            if (!IsPostBack)
                LoadDrivers();
        }

        // Fetches all driver records (active + inactive) into one unified list
        private void LoadDrivers()
        {
            // Load ALL drivers — active and inactive — into a single combined list.
            // The Status column in the grid shows Active (green) or Inactive (red) per row.
            // Active rows show Edit + Deactivate; inactive rows show Restore + Hard Delete.
            DataTable all = new DataTable();
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = DatabaseHelper.GetConnection())
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    @"SELECT DriverID, FullName, Phone, LicenceNumber, DateOfBirth, JoinDate,
                             IsActive, Rating, Gender, Specialty
                      FROM   tblDriver
                      ORDER  BY FullName", conn))
                {
                    new System.Data.SqlClient.SqlDataAdapter(cmd).Fill(all);
                }
            }
            catch
            {
                // Fallback: just load active drivers via the manager if inline SQL fails
                all = dm.ListDrivers();
            }

            gvDrivers.DataSource = all;
            gvDrivers.DataBind();
            gvDrivers.EmptyDataText = "No drivers found.";
        }

        // Handles button actions in the drivers grid (Edit, Deactivate, Restore, Hard Delete)
        protected void gvDrivers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Read the Driver ID passed from the button in the grid row
            int driverID = int.Parse(e.CommandArgument.ToString());

            // Redirect to the Edit page so the admin can update this driver's details
            if (e.CommandName == "EditDriver")
            {
                Response.Redirect("DriverEdit.aspx?id=" + driverID);
            }
            // Soft-delete: flags the driver as inactive but keeps the record in the database
            else if (e.CommandName == "DeleteDriver")
            {
                try
                {
                    dm.DeleteDriver(driverID);
                    ShowMessage("Driver deactivated. Record retained for audit.", "dn-alert-success");
                    LoadDrivers(); // Refresh the list after deactivation
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deactivating driver: " + ex.Message, "dn-alert-error");
                }
            }
            // Restore: reactivates a previously deactivated driver
            else if (e.CommandName == "RestoreDriver")
            {
                try
                {
                    dm.RestoreDriver(driverID);
                    ShowMessage("Driver restored to active status.", "dn-alert-success");
                    LoadDrivers(); // Refresh to show the driver back on the active tab
                }
                catch (Exception ex)
                {
                    ShowMessage("Error restoring driver: " + ex.Message, "dn-alert-error");
                }
            }
            // Hard Delete: permanently removes the driver record from the database
            else if (e.CommandName == "HardDeleteDriver")
            {
                try
                {
                    dm.HardDeleteDriver(driverID);
                    ShowMessage("Driver permanently deleted.", "dn-alert-success");
                    LoadDrivers(); // Refresh the list after permanent deletion
                }
                catch (Exception ex)
                {
                    ShowMessage("Error: " + ex.Message, "dn-alert-error");
                }
            }
        }

        // Helper method: displays a success or error message banner at the top of the page
        private void ShowMessage(string text, string cssClass)
        {
            lblMessage.Text     = text;
            lblMessage.CssClass = cssClass;
            lblMessage.Visible  = true;
        }

        // ── CSV Export ────────────────────────────────────────────────────────
        // Exports ALL drivers (active + inactive) as a CSV file that opens in Excel.
        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT DriverID        AS [ID],
                             FullName        AS [Full Name],
                             Phone,
                             LicenceNumber   AS [Licence No],
                             DateOfBirth     AS [Date of Birth],
                             JoinDate        AS [Join Date],
                             ISNULL(CAST(Rating AS NVARCHAR(10)), '') AS [Rating],
                             ISNULL(Gender,'')   AS [Gender],
                             ISNULL(Specialty,'') AS [Specialty],
                             CASE WHEN IsActive=1 THEN 'Active' ELSE 'Inactive' END AS [Status]
                      FROM   tblDriver
                      ORDER  BY DriverID", conn))
                {
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Export failed: " + ex.Message, "dn-alert-error");
                return;
            }
            DataExport.DownloadCsv(Response, dt, "DriveNow_Drivers");
        }
    }
}
