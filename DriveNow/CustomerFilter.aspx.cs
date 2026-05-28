// DriveNow — CustomerFilter.aspx Code-Behind
// Lets staff filter the customer list by registration date range and active/inactive status.
// Results are shown in a grid below the filter form.
// Module: CTEC2713N

using System;
namespace DriveNow
{
    public partial class CustomerFilter : System.Web.UI.Page
    {
        // CustomerManager handles all customer database operations
        CustomerManager cm = new CustomerManager();

        // Security check on page load
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
        }

        // Handles the Filter button click — applies the selected filters and shows matching customers
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            // Parse the "Registered From" date — null means no date filter applied
            DateTime? regFrom = null;
            DateTime parsed;
            if (!string.IsNullOrWhiteSpace(txtRegFrom.Text) && DateTime.TryParse(txtRegFrom.Text, out parsed)) regFrom = parsed;

            // Parse the status filter dropdown — null means show all (active and inactive)
            bool? isActive = null;
            if (ddlStatus.SelectedValue == "1") isActive = true;
            else if (ddlStatus.SelectedValue == "0") isActive = false;

            // Fetch filtered results from the database and bind to the grid
            var dt = cm.FilterCustomers(regFrom, isActive);
            gvResults.DataSource = dt;
            gvResults.DataBind();
            // Show how many results were found
            lblMessage.Text     = "Showing " + dt.Rows.Count + " result(s).";
            lblMessage.CssClass = "dn-alert-success"; lblMessage.Visible = true;
        }

        // Back button — returns to the full customer list
        protected void btnBack_Click(object sender, EventArgs e) { Response.Redirect("CustomerList.aspx"); }
    }
}
