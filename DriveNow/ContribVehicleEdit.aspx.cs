// ============================================================
// File: ContribVehicleEdit.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Presentation Layer
// Purpose: Loads an existing contributor vehicle record by
//          ContribVehicleID (?id=) and ContributorID (?cid=)
//          passed in the query string from ListContribVehicles.
//          Pre-populates all form fields with current values.
//          Both IDs stored in ViewState to survive postback.
//          Validates inputs then calls ContributorManager.EditVehicle().
//          Back and Cancel links built dynamically with ContributorID
//          so staff always return to the correct vehicle list.
//          Never hard deletes — all deletions handled via soft delete.
// ============================================================

using System;
using System.Data;


namespace DriveNow
{
    public partial class EditContribVehicle : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session check — redirect to login if not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                // Read both IDs from query string on first load
                if (Request.QueryString["id"] != null)
                {
                    int vehicleID = Convert.ToInt32(Request.QueryString["id"]);

                    // ContributorID needed for back/cancel links and redirect
                    // Default to 0 if not provided — handled in LoadVehicle
                    int contributorID = Request.QueryString["cid"] != null
                        ? Convert.ToInt32(Request.QueryString["cid"]) : 0;

                    // Store both IDs in ViewState — survive Save button postback
                    ViewState["VehicleID"] = vehicleID;
                    ViewState["ContributorID"] = contributorID;

                    // Build back and cancel links with correct ContributorID
                    hlBack.NavigateUrl = "ContribVehicleList.aspx?id=" + contributorID;
                    hlCancel.NavigateUrl = "ContribVehicleList.aspx?id=" + contributorID;

                    LoadVehicle(vehicleID, contributorID);
                }
                else
                {
                    // No vehicle ID — cannot edit without knowing which record
                    Response.Redirect("ContributorList.aspx");
                }
            }
        }

        /// <summary>
        /// Fetches the vehicle record from tblContribVehicle and
        /// pre-populates all form fields with the current values.
        /// Gets vehicles for the contributor then filters by vehicle ID
        /// since there is no dedicated FindVehicle stored procedure.
        /// </summary>
        /// <param name="vehicleID">ContribVehicleID to edit.</param>
        /// <param name="contributorID">ContributorID — needed to fetch vehicles.</param>
        private void LoadVehicle(int vehicleID, int contributorID)
        {
            try
            {
                // Get all active vehicles for this contributor
                DataTable dt = ContributorManager.ListVehicles(contributorID);

                // Filter to find the specific vehicle we need to edit
                DataRow[] rows = dt.Select("ContribVehicleID = " + vehicleID);

                if (rows.Length == 0)
                {
                    // Vehicle not found — redirect rather than showing empty form
                    Response.Redirect("ContribVehicleList.aspx?id=" + contributorID);
                    return;
                }

                DataRow row = rows[0];

                // Show formatted vehicle ID in page subtitle
                lblVehicleID.Text = "#VEH-" + vehicleID.ToString("D3");

                // Pre-populate form fields with current database values
                txtMake.Text = row["Make"].ToString();
                txtModel.Text = row["Model"].ToString();
                txtYear.Text = row["Year"].ToString();
                txtRegistrationNo.Text = row["RegistrationNo"].ToString();
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error loading vehicle: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }

        /// <summary>
        /// Fires when Save Changes button is clicked.
        /// Reads both IDs from ViewState — not from URL — to prevent
        /// ID tampering via the address bar.
        /// ASP.NET validators check for empty fields and year range.
        /// Calls ContributorManager.EditVehicle() with updated values.
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Stop if ASP.NET validators caught empty fields or invalid year
            if (!Page.IsValid)
                return;

            try
            {
                // Read both IDs from ViewState — set during LoadVehicle
                int vehicleID = Convert.ToInt32(ViewState["VehicleID"]);
                int contributorID = Convert.ToInt32(ViewState["ContributorID"]);

                // Update vehicle record with new values from form
                ContributorManager.EditVehicle(
                    vehicleID,
                    txtMake.Text.Trim(),
                    txtModel.Text.Trim(),
                    Convert.ToInt32(txtYear.Text.Trim()),
                    txtRegistrationNo.Text.Trim()
                );

                // Redirect back to vehicle list with edited ID in query string
                Response.Redirect("ContribVehicleList.aspx?id=" + contributorID
                    + "&edited=" + vehicleID);
            }
            catch (Exception ex)
            {
                // Duplicate registration number will cause SQL unique constraint
                // violation — caught here and shown as a friendly error message
                lblMessage.Text = "Error saving vehicle: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }
    }
}