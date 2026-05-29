// DriveNow — CustomerEdit.aspx Code-Behind
// Loads an existing customer record by ID from the URL and lets staff update their details.
// The customer's ID is stored in a hidden field so it is sent back with the form on Save.
// Module: CTEC2713N

using System;
using System.Data;
namespace DriveNow
{
    public partial class CustomerEdit : System.Web.UI.Page
    {
        // CustomerManager handles all customer database operations
        CustomerManager cm = new CustomerManager();

        // Runs on page load — checks authentication and loads the customer if this is the first visit
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security check — send unauthenticated users to the login page
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
            // Only load the customer data on first visit, not when the form is submitted
            if (!IsPostBack)
            {
                string id = Request.QueryString["id"]; // Read the ?id= value from the URL
                if (!string.IsNullOrEmpty(id)) { hdnCustomerID.Value = id; LoadCustomer(Convert.ToInt32(id)); }
            }
        }

        // Fetches the customer record from the database and pre-fills the form fields
        private void LoadCustomer(int customerID)
        {
            DataTable dt = cm.FindCustomer(customerID, null);
            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                // Pre-fill each field with the current saved values
                txtFullName.Text    = r["FullName"].ToString();
                txtEmail.Text       = r["Email"].ToString();
                txtPhone.Text       = r["Phone"].ToString();
                // Tick the Active checkbox if the customer account is currently active
                chkIsActive.Checked = Convert.ToBoolean(r["IsActive"]);
            }
        }

        // Handles the Save button click — validates the updated details and saves them
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ASP.NET validators must all pass before we proceed
            if (!Page.IsValid) return;
            // Run the name/email/phone format validation from CustomerManager
            string err = cm.ValidateCustomer(txtFullName.Text.Trim(), txtEmail.Text.Trim(), txtPhone.Text.Trim());
            if (!string.IsNullOrEmpty(err)) { lblError.Text = err; lblError.Visible = true; return; }
            // Save the updated details — uses the hidden CustomerID to identify which record to update
            cm.EditCustomer(Convert.ToInt32(hdnCustomerID.Value), txtFullName.Text.Trim(), txtEmail.Text.Trim(), txtPhone.Text.Trim(), chkIsActive.Checked);
            lblMessage.Text = "Customer updated successfully."; lblMessage.Visible = true; lblError.Visible = false;
        }

        // Back button — returns to the customer list without saving
        protected void btnBack_Click(object sender, EventArgs e) { Response.Redirect("CustomerList.aspx"); }
    }
}
