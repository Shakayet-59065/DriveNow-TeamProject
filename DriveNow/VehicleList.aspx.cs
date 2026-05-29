using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// DriveNow — Vehicle List Code-Behind
// Lists available or removed vehicles depending on tab query-string.
// Supports soft-delete (Remove), Restore (reactivate), and Hard Delete (permanent remove).
// Module: CTEC2713N | Developer: Ushna

namespace DriveNow
{
    public partial class VehicleList : Page
    {
        // Creates a VehicleManager object to handle all vehicle database operations
        VehicleManager manager = new VehicleManager();

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // If no staff session exists, send the user to the login page
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Load vehicle data only on the first visit — not after every button click
            if (!IsPostBack)
                LoadVehicles();
        }

        // Fetches all vehicles from the database, calculates stats, and fills the grid
        private void LoadVehicles()
        {
            // Get every vehicle from the database (both active and removed) into one list
            List<Vehicle> allVehicles     = manager.FilterVehicles(null, null);
            List<Vehicle> activeVehicles  = allVehicles.FindAll(v => v.IsAvailable);
            List<Vehicle> removedVehicles = allVehicles.FindAll(v => !v.IsAvailable);

            // Calculate counts for the stat cards at the top of the page
            int total   = allVehicles.Count;
            int active  = activeVehicles.Count;
            int removed = removedVehicles.Count;

            // Calculate the average daily hire rate across all active vehicles
            decimal avgRate = 0;
            if (active > 0)
            {
                decimal totalRate = 0;
                foreach (Vehicle v in activeVehicles) totalRate += v.DailyRate;
                avgRate = totalRate / active;
            }

            // Show ALL vehicles in one single list — active rows show Remove, inactive rows show Restore
            gvVehicles.DataSource = allVehicles;
            gvVehicles.DataBind();
            gvVehicles.EmptyDataText = "No vehicles found.";

            // Update the stat labels at the top of the page with the live counts
            lblTotalVehicles.Text   = total.ToString();
            lblActiveVehicles.Text  = active.ToString();
            lblRemovedVehicles.Text = removed.ToString();
            lblAvgRate.Text         = "£" + avgRate.ToString("F2");
            hfAvgRateGbp.Value      = avgRate.ToString("F2");
        }

        // Handles button actions in the vehicle grid (Edit, Remove from Service, Restore, Hard Delete)
        protected void gvVehicles_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Read the Vehicle ID from the button that was clicked
            int vehicleID = Convert.ToInt32(e.CommandArgument);

            // Redirect to the Edit page for this vehicle
            if (e.CommandName == "EditVehicle")
            {
                Response.Redirect("VehicleEdit.aspx?id=" + vehicleID);
            }
            // Soft-delete: marks the vehicle as unavailable but keeps the record for auditing
            else if (e.CommandName == "DeleteVehicle")
            {
                try
                {
                    manager.DeleteVehicle(vehicleID);
                    ShowMessage("Vehicle removed from service. Record retained for audit.", "dn-alert-success");
                    LoadVehicles(); // Refresh the grid to move this vehicle to the Removed tab
                }
                catch (Exception ex)
                {
                    ShowMessage("Error removing vehicle: " + ex.Message, "dn-alert-error");
                }
            }
            // Restore: puts the vehicle back into active service
            else if (e.CommandName == "RestoreVehicle")
            {
                try
                {
                    manager.RestoreVehicle(vehicleID);
                    ShowMessage("Vehicle restored to active service.", "dn-alert-success");
                    LoadVehicles(); // Refresh so the vehicle appears back on the Active tab
                }
                catch (Exception ex)
                {
                    ShowMessage("Error restoring vehicle: " + ex.Message, "dn-alert-error");
                }
            }
            // Hard Delete: permanently removes the vehicle record from the database
            else if (e.CommandName == "HardDeleteVehicle")
            {
                try
                {
                    manager.HardDeleteVehicle(vehicleID);
                    ShowMessage("Vehicle permanently deleted.", "dn-alert-success");
                    LoadVehicles(); // Refresh after permanent deletion
                }
                catch (Exception ex)
                {
                    ShowMessage("Error: " + ex.Message, "dn-alert-error");
                }
            }
        }

        // Helper method: shows a success or error message banner at the top of the page
        private void ShowMessage(string text, string cssClass)
        {
            lblMessage.Text     = text;
            lblMessage.CssClass = cssClass;
            lblMessage.Visible  = true;
        }

        // ── CSV Export ────────────────────────────────────────────────────────
        // Exports ALL vehicles (active + removed) as a CSV file that opens in Excel.
        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT VehicleID      AS [ID],
                             RegistrationNo AS [Registration No],
                             Make,
                             Model,
                             Seats,
                             DailyRate      AS [Daily Rate (GBP)],
                             DateAdded      AS [Date Added],
                             CASE WHEN IsAvailable=1 THEN 'Active' ELSE 'Removed' END AS [Status]
                      FROM   tblVehicle
                      ORDER  BY VehicleID", conn))
                {
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Export failed: " + ex.Message, "dn-alert-error");
                return;
            }
            DataExport.DownloadCsv(Response, dt, "DriveNow_Vehicles");
        }
    }
}
