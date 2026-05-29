// ============================================================
// File: ContributorFilter.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Presentation Layer
// Purpose: Filters contributor records by ContributorType and/or
//          approval status. Both dropdowns default to "All" which
//          passes null to the stored procedure — null parameters
//          in spFilterContributors mean "include all values".
//          Results panel hidden until filter is applied.
//          Clear button resets both dropdowns and hides results.
//          Edit button redirects to EditContributor for any result row.
// ============================================================

using System;
using System.Data;
using System.Web.UI.WebControls;


namespace DriveNow
{
    public partial class FilterContributors : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session check — redirect to login if not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Results panel hidden on first load — shown only after filter applied
        }

        /// <summary>
        /// Fires when Apply Filter button is clicked.
        /// Converts dropdown values to the correct types for the stored procedure:
        /// Empty string → null (means include all values for that filter).
        /// "true"/"false" string → bool (IsApproved is a BIT in SQL Server).
        /// </summary>
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            try
            {
                // Convert dropdown to null if "All Types" selected
                // null tells spFilterContributors to skip this filter
                string contributorType = string.IsNullOrEmpty(ddlContributorType.SelectedValue)
                    ? null
                    : ddlContributorType.SelectedValue;

                // Convert dropdown to null if "All Statuses" selected
                // Otherwise convert string "true"/"false" to bool
                object isApproved = null;
                if (!string.IsNullOrEmpty(ddlIsApproved.SelectedValue))
                    isApproved = ddlIsApproved.SelectedValue == "true";

                DataTable dt = ContributorManager.Filter(contributorType, isApproved);

                // Show results panel with filtered data
                pnlResults.Visible = true;
                gvResults.DataSource = dt;
                gvResults.DataBind();

                // Show count so staff can see how many records matched the filter
                lblResultCount.Text = dt.Rows.Count + " record(s) found";
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error filtering contributors: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }

        /// <summary>
        /// Resets both filter dropdowns to "All" and hides the results panel.
        /// Gives staff a quick way to clear the filter without refreshing the page.
        /// </summary>
        protected void btnClear_Click(object sender, EventArgs e)
        {
            // Reset both dropdowns to first item (All values)
            ddlContributorType.SelectedIndex = 0;
            ddlIsApproved.SelectedIndex = 0;

            // Hide results panel — clean state until next filter applied
            pnlResults.Visible = false;
            lblMessage.Visible = false;
        }

        /// <summary>
        /// Redirects to ContributorEdit.aspx with the ContributorID
        /// of the selected result row in the query string.
        /// </summary>
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            int contributorID = Convert.ToInt32(btn.CommandArgument);
            Response.Redirect("ContributorEdit.aspx?id=" + contributorID);
        }
    }
}