// DriveNow — CustomerFind.aspx Code-Behind
// Lets staff search for a specific customer by their ID number or by name.
// Results are shown in a grid — staff can then click Edit or Deactivate from the results.
// Module: CTEC2713N

using System;
namespace DriveNow
{
    public partial class CustomerFind : System.Web.UI.Page
    {
        // CustomerManager handles all customer database operations
        CustomerManager cm = new CustomerManager();

        // Security check on page load
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
        }

        // Handles the Find/Search button click — searches by ID or name and shows results
        protected void btnFind_Click(object sender, EventArgs e)
        {
            // Parse the Customer ID if provided — null means don't filter by ID
            int? id = null;
            int parsed;
            if (!string.IsNullOrWhiteSpace(txtCustomerID.Text) && int.TryParse(txtCustomerID.Text.Trim(), out parsed)) id = parsed;

            // Read the name search term — null means don't filter by name
            string name = string.IsNullOrWhiteSpace(txtFullName.Text) ? null : txtFullName.Text.Trim();

            // Fetch matching customers from the database and show them in the grid
            var dt = cm.FindCustomer(id, name);
            gvResults.DataSource = dt;
            gvResults.DataBind();
            // Show "No customers found" if the search returned nothing
            if (dt.Rows.Count == 0) { lblMessage.Text = "No customers found."; lblMessage.CssClass = "dn-alert-error"; lblMessage.Visible = true; }
            else lblMessage.Visible = false;
        }

        // Clear button — resets all search fields and clears the results grid
        protected void btnClear_Click(object sender, EventArgs e)
        { txtCustomerID.Text = txtFullName.Text = ""; gvResults.DataSource = null; gvResults.DataBind(); lblMessage.Visible = false; }

        // Back button — returns to the full customer list
        protected void btnBack_Click(object sender, EventArgs e) { Response.Redirect("CustomerList.aspx"); }
    }
}
