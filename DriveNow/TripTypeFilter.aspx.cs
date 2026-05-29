using System;

// DriveNow — Filter Trip Types Code-Behind
// Filters the trip type catalogue by active status and/or base rate range.
// All database access goes through TripManager — no inline SQL.
// Calls spFilterTripTypesAdvanced via TripManager.FilterTripTypesAdvanced().
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripTypeFilter : System.Web.UI.Page
    {
        // Middle-layer instance — all DB calls go through here
        TripManager manager = new TripManager();

        /// <summary>
        /// Page load — enforces session authentication.
        /// Unauthenticated users are redirected to Login.aspx.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
        }

        /// <summary>
        /// Filter button — filters trip types by status and/or base rate range.
        /// All three filter parameters are optional:
        ///   - Status: all / active (IsActive=1) / inactive (IsActive=0)
        ///   - Min Rate: lower bound for BaseRate (inclusive)
        ///   - Max Rate: upper bound for BaseRate (inclusive)
        /// Calls TripManager.FilterTripTypesAdvanced() via spFilterTripTypesAdvanced.
        /// Results are bound to gvResults GridView.
        /// </summary>
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            try
            {
                // Parse optional IsActive filter from the status dropdown
                bool? isActive = null;
                if (ddlStatus.SelectedValue == "active")   isActive = true;
                if (ddlStatus.SelectedValue == "inactive") isActive = false;
                // "all" leaves isActive as null — stored procedure returns all statuses

                // Parse optional minimum base rate — blank means no lower bound
                decimal? minRate = null;
                decimal parsedMin;
                if (!string.IsNullOrWhiteSpace(txtMinRate.Text) &&
                    decimal.TryParse(txtMinRate.Text.Trim(), out parsedMin))
                    minRate = parsedMin;

                // Parse optional maximum base rate — blank means no upper bound
                decimal? maxRate = null;
                decimal parsedMax;
                if (!string.IsNullOrWhiteSpace(txtMaxRate.Text) &&
                    decimal.TryParse(txtMaxRate.Text.Trim(), out parsedMax))
                    maxRate = parsedMax;

                // Run the filter via spFilterTripTypesAdvanced stored procedure
                var results = manager.FilterTripTypesAdvanced(isActive, minRate, maxRate);

                // Bind results to the GridView
                gvResults.DataSource = results;
                gvResults.DataBind();
                gvResults.Visible  = true;
                lblMessage.Visible = false;
            }
            catch (Exception ex)
            {
                // Database or middle-layer error — show message, hide grid
                lblMessage.Text    = "Filter error: " + ex.Message;
                lblMessage.Visible = true;
                gvResults.Visible  = false;
            }
        }

        /// <summary>
        /// Clear button — resets all filter controls and clears the results grid.
        /// </summary>
        protected void btnClear_Click(object sender, EventArgs e)
        {
            // Reset all filter fields to their defaults
            ddlStatus.SelectedIndex = 0;
            txtMinRate.Text = "";
            txtMaxRate.Text = "";

            // Clear the results grid
            gvResults.DataSource = null;
            gvResults.DataBind();
            lblMessage.Visible = false;
        }
    }
}
