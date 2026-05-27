// ============================================================
// File: ContributorFind.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Presentation Layer
// Purpose: Allows staff to search for a specific contributor
//          by ContributorID (exact match) or FullName (partial
//          LIKE match). Both fields are optional — leaving both
//          empty returns all records. Results are displayed in
//          a GridView with an Edit action link per row.
//          The results panel is hidden until a search is performed
//          to keep the page clean on first load.
// ============================================================

using System;
using System.Data;
using System.Web.UI.WebControls;


namespace DriveNow
{
    public partial class FindContributor : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session check — redirect to login if not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Results panel hidden on first load — only shown after search
        }

        /// <summary>
        /// Fires when the Search button is clicked.
        /// Parses the ContributorID field — uses 0 if empty so the
        /// stored procedure knows to skip the ID filter.
        /// Parses the FullName field — uses null if empty so the
        /// stored procedure knows to skip the name filter.
        /// Displays result count above the GridView.
        /// </summary>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            try
            {
                // Parse ContributorID — TryParse returns 0 if field is empty
                // 0 tells spFindContributor to ignore the ID filter
                int id = 0;
                if (!string.IsNullOrWhiteSpace(txtContributorID.Text))
                    int.TryParse(txtContributorID.Text.Trim(), out id);

                // Null tells spFindContributor to ignore the name filter
                string name = string.IsNullOrWhiteSpace(txtFullName.Text)
                    ? null
                    : txtFullName.Text.Trim();

                DataTable dt = ContributorManager.Find(id, name);

                // Show results panel — hidden by default on page load
                pnlResults.Visible = true;
                gvResults.DataSource = dt;
                gvResults.DataBind();

                // Show count so staff know how many records matched
                lblResultCount.Text = dt.Rows.Count + " record(s) found";
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error searching contributors: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }

        /// <summary>
        /// Redirects to ContributorEdit.aspx passing the ContributorID
        /// of the selected search result in the query string.
        /// </summary>
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            int contributorID = Convert.ToInt32(btn.CommandArgument);
            Response.Redirect("ContributorEdit.aspx?id=" + contributorID);
        }
    }
}