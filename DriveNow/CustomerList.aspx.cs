using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

// DriveNow — Customer List Code-Behind
// Lists active or inactive customers depending on tab query-string.
// Supports soft-delete (Deactivate), Restore (reactivate), and Hard Delete (permanent remove).
// Module: CTEC2713N | Developer: Tahmid

namespace DriveNow
{
    public partial class CustomerList : System.Web.UI.Page
    {
        // Creates a CustomerManager object to handle all customer database operations
        CustomerManager cm = new CustomerManager();

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // Block access if the user is not logged in — redirect to login page
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Load customer data only on the first page visit, not on every form action
            if (!IsPostBack)
                LoadCustomers();
        }

        // Fetches ALL customer records (active + inactive) into one unified list
        private void LoadCustomers()
        {
            // Load all customers — active and inactive — into a single combined list
            DataTable all = cm.ListCustomers();
            lblTotal.Text = all.Rows.Count.ToString();

            // Count active customers for the stat label
            int active = 0;
            foreach (DataRow r in all.Rows)
                if (Convert.ToBoolean(r["IsActive"])) active++;
            lblActive.Text = active.ToString();

            // Show ALL customers in one list — Status column shows Active/Inactive per row
            gvCustomers.DataSource = all;
            gvCustomers.DataBind();
            gvCustomers.EmptyDataText = "No customers found.";
        }

        // Handles button actions in the customer grid (Edit, Deactivate, Restore, Hard Delete)
        protected void gvCustomers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Read the Customer ID passed from the button in the grid row
            int customerID = Convert.ToInt32(e.CommandArgument);

            // Redirect to the Edit page for this customer
            if (e.CommandName == "EditCustomer")
            {
                Response.Redirect("CustomerEdit.aspx?id=" + customerID);
            }
            // Soft-delete: marks the customer as inactive but keeps their record for audit history
            else if (e.CommandName == "DeleteCustomer")
            {
                try
                {
                    cm.DeleteCustomer(customerID);
                    ShowMessage("Customer deactivated. Record retained for audit.", "dn-alert-success");
                    LoadCustomers(); // Refresh the grid to reflect the deactivation
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deactivating customer: " + ex.Message, "dn-alert-error");
                }
            }
            // Restore: reactivates a previously deactivated customer account
            else if (e.CommandName == "RestoreCustomer")
            {
                try
                {
                    cm.RestoreCustomer(customerID);
                    ShowMessage("Customer restored to active status.", "dn-alert-success");
                    LoadCustomers(); // Refresh to show the customer back on the active tab
                }
                catch (Exception ex)
                {
                    ShowMessage("Error restoring customer: " + ex.Message, "dn-alert-error");
                }
            }
            // Hard Delete: permanently removes the customer record — this cannot be undone
            else if (e.CommandName == "HardDeleteCustomer")
            {
                try
                {
                    cm.HardDeleteCustomer(customerID);
                    ShowMessage("Customer permanently deleted.", "dn-alert-success");
                    LoadCustomers(); // Refresh the grid after permanent deletion
                }
                catch (Exception ex)
                {
                    ShowMessage("Error: " + ex.Message, "dn-alert-error");
                }
            }
        }

        // Helper method: shows a success or error message at the top of the page
        private void ShowMessage(string text, string cssClass)
        {
            lblMessage.Text     = text;
            lblMessage.CssClass = cssClass;
            lblMessage.Visible  = true;
        }

        // ── CSV Export ────────────────────────────────────────────────────────
        // Exports ALL customers (active + inactive) as a CSV file that opens in Excel.
        // Passwords and security tokens are deliberately excluded.
        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT c.CustomerID   AS [ID],
                             c.FullName     AS [Full Name],
                             c.Email,
                             c.Phone,
                             c.RegisterDate AS [Registered],
                             CASE
                                 WHEN trips.TripCount >= 20 THEN 'Platinum'
                                 WHEN trips.TripCount >= 10 THEN 'Gold'
                                 WHEN trips.TripCount >= 5  THEN 'Silver'
                                 WHEN trips.TripCount >= 1  THEN 'Bronze'
                                 ELSE 'Guest'
                             END AS [Loyalty Tier],
                             CASE WHEN c.IsActive=1 THEN 'Active' ELSE 'Inactive' END AS [Status]
                      FROM   tblCustomer c
                      LEFT JOIN (
                          SELECT ct.CustomerID, COUNT(1) AS TripCount
                          FROM   tblCustomerTrip ct
                          WHERE  ct.IsActive = 1 AND ct.DropoffDate <= GETDATE()
                          GROUP  BY ct.CustomerID
                      ) trips ON trips.CustomerID = c.CustomerID
                      ORDER  BY c.CustomerID", conn))
                {
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Export failed: " + ex.Message, "dn-alert-error");
                return;
            }
            DataExport.DownloadCsv(Response, dt, "DriveNow_Customers");
        }
    }
}
