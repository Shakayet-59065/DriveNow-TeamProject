// ============================================================
// File: ContributorList.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Presentation Layer
// Purpose: Displays all contributor application records from
//          tblContributor in a styled GridView table.
//          Stat cards show live counts — total, approved, pending,
//          and driver applications — calculated from the DataTable.
//          Edit button redirects to ContributorEdit.aspx with ID.
//          Delete performs a soft delete (IsApproved = 0) — records
//          are never permanently removed from the database.
//          Vehicles button only shown for VehicleOwner contributors
//          and redirects to ContribVehicleList.aspx with the ID.
// ============================================================

using System;
using System.Data;
using System.Web.UI.WebControls;


namespace DriveNow
{
    public partial class ListContributors : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session check — redirect to login if not authenticated
            // This runs on every page load to prevent unauthorised access
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Show today's date in the topbar
            lblDate.Text = DateTime.Today.ToString("dd MMM yyyy");

            // Only load data on first page load — not on button postbacks
            // IsPostBack prevents the grid reloading and losing button context
            if (!IsPostBack)
            {
                LoadContributors();
            }
        }

        /// <summary>
        /// Fetches all contributor records via ContributorManager.List()
        /// and binds them to the GridView. Also calculates and updates
        /// the four stat card counts from the returned DataTable.
        /// Called on first load and after any delete operation.
        /// </summary>
        private void LoadContributors()
        {
            try
            {
                DataTable dt = ContributorManager.List();

                // Bind data to GridView — DataBinder.Eval in ASPX reads from this
                gvContributors.DataSource = dt;
                gvContributors.DataBind();

                // Calculate stat card values by looping through the DataTable
                // This avoids extra database calls for each count
                int total = dt.Rows.Count;
                int approved = 0;
                int pending = 0;
                int drivers = 0;

                foreach (DataRow row in dt.Rows)
                {
                    // Count approved vs pending based on IsApproved BIT value
                    if (Convert.ToBoolean(row["IsApproved"])) approved++;
                    else pending++;

                    // Count driver-type contributors separately
                    if (row["ContributorType"].ToString() == "Driver") drivers++;
                }

                // Update stat card labels with calculated values
                lblTotalCount.Text = total.ToString();
                lblApprovedCount.Text = approved.ToString();
                lblPendingCount.Text = pending.ToString();
                lblDriverCount.Text = drivers.ToString();
            }
            catch (Exception ex)
            {
                // Show error on page rather than crashing — better user experience
                lblError.Text = "Error loading contributors: " + ex.Message;
                lblError.CssClass = "dn-alert-error";
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Redirects to ContributorEdit.aspx passing the ContributorID
        /// in the query string so the edit form can load the correct record.
        /// </summary>
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            // Get the ContributorID stored in the button's CommandArgument
            Button btn = (Button)sender;
            int contributorID = Convert.ToInt32(btn.CommandArgument);

            // Pass ID via query string — EditContributor reads Request.QueryString["id"]
            Response.Redirect("ContributorEdit.aspx?id=" + contributorID);
        }

        /// <summary>
        /// Soft deletes the selected contributor by setting IsApproved = 0.
        /// The record stays in the database — this preserves audit history
        /// and prevents orphaned vehicle records in tblContribVehicle.
        /// Reloads the list after deletion and shows confirmation message.
        /// </summary>
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                int contributorID = Convert.ToInt32(btn.CommandArgument);

                // Create instance and set ID — Delete() uses ContributorID property
                ContributorManager cm = new ContributorManager();
                cm.ContributorID = contributorID;
                cm.Delete();

                // Reload the list so the deleted record disappears
                LoadContributors();

                // Confirm deletion to staff
                lblError.Text = "Contributor deleted successfully.";
                lblError.CssClass = "dn-alert-success";
                lblError.Visible = true;
            }
            catch (Exception ex)
            {
                lblError.Text = "Error deleting contributor: " + ex.Message;
                lblError.CssClass = "dn-alert-error";
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Redirects to ContribVehicleList.aspx for VehicleOwner contributors.
        /// This button is only visible on VehicleOwner rows — controlled by
        /// the Visible property in the ASPX GridView template field.
        /// </summary>
        protected void btnVehicles_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            int contributorID = Convert.ToInt32(btn.CommandArgument);

            // Pass ContributorID so the vehicles page loads the correct records
            Response.Redirect("ContribVehicleList.aspx?id=" + contributorID);
        }
    }
}