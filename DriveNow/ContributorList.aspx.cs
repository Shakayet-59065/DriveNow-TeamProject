// DriveNow — Contributor List Code-Behind
// Contributors are vehicle owners or drivers who partner with DriveNow.
// They must be reviewed and approved by staff before becoming active.
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DriveNow
{
    public partial class ListContributors : Page
    {
        // Returns the CSS class to highlight the selected tab (All, Approved, or Pending)
        protected string TabCss(string tabName)
        {
            // Read the ?tab= URL parameter; default to "all" if not provided
            string current = Request.QueryString["tab"] ?? "all";
            return current == tabName ? "dn-pill active" : "dn-pill";
        }

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to login if the user is not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Display today's date in the page header
            lblDate.Text = DateTime.Today.ToString("dd MMM yyyy");

            // Load contributor data only on first visit — not after every form submission
            if (!IsPostBack)
                LoadContributors();
        }

        // Fetches contributor records, calculates stat counts, and fills the grid
        private void LoadContributors()
        {
            try
            {
                // Get all contributors from the database regardless of approval status
                DataTable all = ContributorManager.List();

                // Count how many are approved, pending, and of type "Driver" for the stat cards
                int total = all.Rows.Count, approved = 0, pending = 0, drivers = 0;
                foreach (DataRow row in all.Rows)
                {
                    if (Convert.ToBoolean(row["IsApproved"])) approved++;
                    else pending++;
                    if (row["ContributorType"].ToString() == "Driver") drivers++;
                }

                // Update the stat labels at the top of the page
                lblTotalCount.Text    = total.ToString();
                lblApprovedCount.Text = approved.ToString();
                lblPendingCount.Text  = pending.ToString();
                lblDriverCount.Text   = drivers.ToString();

                // Filter the grid based on which tab the user selected
                string tab = Request.QueryString["tab"] ?? "all";
                DataTable view = tab == "approved" ? ContributorManager.Filter("", true)   // Only approved
                               : tab == "pending"  ? ContributorManager.Filter("", false)  // Only pending
                               : all;                                                        // Show everyone

                gvContributors.DataSource = view;
                gvContributors.DataBind();

                // Show a friendly empty state message if no contributors match the tab
                gvContributors.EmptyDataText = tab == "approved" ? "No approved contributors found."
                                             : tab == "pending"  ? "No pending contributors found."
                                             : "No contributor records found.";
            }
            catch (Exception ex)
            {
                lblError.Text     = "Error loading contributors: " + ex.Message;
                lblError.CssClass = "dn-alert-error";
                lblError.Visible  = true;
            }
        }

        // Redirects to the full application detail page for this contributor
        protected void btnView_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            Response.Redirect("ContributorView.aspx?id=" + btn.CommandArgument);
        }

        // Approves a contributor using the full approval SP, auto-promoting into tblDriver/tblVehicle
        protected void btnApprove_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                int id = Convert.ToInt32(btn.CommandArgument);

                var result = ContributorManager.ApproveFull(id);

                string msg = "Contributor approved successfully.";
                if (result.driverID  > 0) msg += " Driver created (ID: #" + result.driverID + ").";
                if (result.vehicleID > 0) msg += " Vehicle added to fleet (ID: #" + result.vehicleID + ").";

                lblError.Text     = msg;
                lblError.CssClass = "dn-alert-success";
                lblError.Visible  = true;
                LoadContributors();
            }
            catch (Exception ex)
            {
                lblError.Text     = "Error approving contributor: " + ex.Message;
                lblError.CssClass = "dn-alert-error";
                lblError.Visible  = true;
            }
        }

        // Redirects to the Edit page to update the contributor's details
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            Response.Redirect("ContributorEdit.aspx?id=" + btn.CommandArgument);
        }

        // Soft-delete: removes the contributor from the active list (keeps the record)
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                // Create an instance, set the ID, and call Delete on the ContributorManager
                ContributorManager cm = new ContributorManager();
                cm.ContributorID = Convert.ToInt32(btn.CommandArgument);
                cm.Delete();

                lblError.Text     = "Contributor deleted successfully.";
                lblError.CssClass = "dn-alert-success";
                lblError.Visible  = true;
                LoadContributors(); // Refresh the grid after deletion
            }
            catch (Exception ex)
            {
                lblError.Text     = "Error deleting contributor: " + ex.Message;
                lblError.CssClass = "dn-alert-error";
                lblError.Visible  = true;
            }
        }

        // This server-side handler is intentionally empty — the hard-delete button is intercepted
        // by JavaScript which opens a GDPR consent modal before any server action happens
        protected void btnHardDelete_Click(object sender, EventArgs e)
        {
            // This button is intercepted by JS (openRetentionModal) so it
            // never posts back directly — only btnConfirmHardDelete does.
        }

        // Permanently deletes a contributor after the admin confirms GDPR retention consent
        protected void btnConfirmHardDelete_Click(object sender, EventArgs e)
        {
            // Only proceed if the admin has ticked the consent checkbox in the modal
            if (hfConsentConfirmed.Value != "1")
                return;

            int id;
            int months;

            // Validate the hidden Contributor ID and chosen retention period (3 or 6 months)
            if (!int.TryParse(hfHardDeleteID.Value, out id) || id <= 0)
                return;
            if (!int.TryParse(hfRetentionMonths.Value, out months) || (months != 3 && months != 6))
                return;

            try
            {
                // Permanently delete the contributor and record the chosen backup retention period
                ContributorManager.HardDelete(id, months);

                lblError.Text     = "Contributor permanently deleted. Data will be retained in backup archives for "
                                  + months + " months as per consent recorded on " + DateTime.Today.ToString("dd MMM yyyy") + ".";
                lblError.CssClass = "dn-alert-success";
                lblError.Visible  = true;

                // Reset all hidden fields so the modal cannot be re-submitted accidentally
                hfHardDeleteID.Value     = "0";
                hfRetentionMonths.Value  = "0";
                hfConsentConfirmed.Value = "0";

                LoadContributors(); // Refresh to confirm the record is gone
            }
            catch (Exception ex)
            {
                lblError.Text     = "Error permanently deleting contributor: " + ex.Message;
                lblError.CssClass = "dn-alert-error";
                lblError.Visible  = true;
            }
        }

        // Redirects to the contributor's vehicle list page to see which vehicles they own
        protected void btnVehicles_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            Response.Redirect("ContribVehicleList.aspx?id=" + btn.CommandArgument);
        }

        // ── CSV Export ────────────────────────────────────────────────────────
        // Exports ALL contributor applications as a CSV file that opens in Excel.
        // Notes, profile photos and sensitive internal flags are excluded.
        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT ContributorID                                    AS [ID],
                             FullName                                         AS [Full Name],
                             Email,
                             Phone,
                             ContributorType                                  AS [Type],
                             ApplicationDate                                  AS [Applied],
                             ISNULL(CAST(LicenceNumber AS NVARCHAR(50)),'')  AS [Licence No],
                             ISNULL(CONVERT(NVARCHAR,DateOfBirth,105),'')    AS [Date of Birth],
                             ISNULL(CONVERT(NVARCHAR,LicenceIssueDate,105),'') AS [Licence Issued],
                             ISNULL(CONVERT(NVARCHAR,LicenceExpiryDate,105),'') AS [Licence Expiry],
                             CASE WHEN IsApproved=1 THEN 'Approved' ELSE 'Pending' END AS [Status]
                      FROM   tblContributor
                      ORDER  BY ContributorID", conn))
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
            DataExport.DownloadCsv(Response, dt, "DriveNow_Contributors");
        }
    }
}
