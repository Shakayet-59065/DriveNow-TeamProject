// ============================================================
// File: ContribVehicleList.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Presentation Layer
// Purpose: Displays all active vehicles linked to a specific
//          contributor. ContributorID is passed via query string
//          (?id=) from the Vehicles button on ListContributors.
//          Contributor name shown in page subtitle for context.
//          Add Vehicle button link built dynamically with the ID
//          so the new vehicle is automatically linked correctly.
//          Edit redirects to EditContribVehicle with both IDs.
//          Delete performs soft delete (IsAvailable = 0) —
//          vehicle records are never permanently removed.
//          ContributorID stored in ViewState to survive postbacks.
// ============================================================

using System;
using System.Data;
using System.Web.UI.WebControls;


namespace DriveNow
{
    public partial class ListContribVehicles : System.Web.UI.Page
    {
        // ViewState property to persist ContributorID across postbacks
        // Without this the ID would be lost when Delete button is clicked
        private int ContributorID
        {
            get
            {
                return ViewState["ContributorID"] != null
                ? (int)ViewState["ContributorID"] : 0;
            }
            set { ViewState["ContributorID"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Session check — redirect to login if not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                // Read ContributorID from query string on first load only
                if (Request.QueryString["id"] != null)
                {
                    ContributorID = Convert.ToInt32(Request.QueryString["id"]);

                    // Build Add Vehicle link with ContributorID so new vehicle
                    // is automatically linked to the correct contributor
                    hlAddVehicle.NavigateUrl = "ContribVehicleAdd.aspx?id=" + ContributorID;

                    // Look up contributor name to show in page subtitle
                    // Gives staff context about whose vehicles they are viewing
                    DataTable dt = ContributorManager.Find(ContributorID, null);
                    if (dt.Rows.Count > 0)
                        lblContributorName.Text = "#CON-"
                            + ContributorID.ToString("D3")
                            + " — " + dt.Rows[0]["FullName"].ToString();

                    LoadVehicles();
                }
                else
                {
                    // No ID provided — cannot show vehicles without knowing contributor
                    Response.Redirect("ContributorList.aspx");
                }
            }
        }

        /// <summary>
        /// Fetches all active vehicles for this contributor via
        /// ContributorManager.ListVehicles() and binds to GridView.
        /// Only returns records where IsAvailable = 1.
        /// Called on first load and after any delete operation.
        /// </summary>
        private void LoadVehicles()
        {
            try
            {
                DataTable dt = ContributorManager.ListVehicles(ContributorID);
                gvVehicles.DataSource = dt;
                gvVehicles.DataBind();
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error loading vehicles: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }

        /// <summary>
        /// Redirects to ContribVehicleEdit.aspx passing both the
        /// ContribVehicleID and the ContributorID in the query string.
        /// Both are needed so the edit page can load the correct record
        /// and return to the correct vehicle list afterwards.
        /// </summary>
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            int vehicleID = Convert.ToInt32(btn.CommandArgument);

            // Pass both IDs — edit page needs vehicle ID to load record
            // and contributor ID to set the Back button link correctly
            Response.Redirect("ContribVehicleEdit.aspx?id=" + vehicleID
                + "&cid=" + ContributorID);
        }

        /// <summary>
        /// Soft deletes the selected vehicle by setting IsAvailable = 0.
        /// Record stays in the database — preserves history and prevents
        /// broken foreign key references if vehicle is linked elsewhere.
        /// Reloads the vehicle list after deletion.
        /// </summary>
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                int vehicleID = Convert.ToInt32(btn.CommandArgument);

                // Soft delete — sets IsAvailable = 0, never hard deletes
                ContributorManager.DeleteVehicle(vehicleID);

                // Reload list so deleted vehicle disappears from view
                LoadVehicles();

                lblMessage.Text = "Vehicle deleted successfully.";
                lblMessage.CssClass = "dn-alert-success";
                lblMessage.Visible = true;
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error deleting vehicle: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }
    }
}