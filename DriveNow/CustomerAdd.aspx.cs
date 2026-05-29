// DriveNow — CustomerAdd.aspx Code-Behind
// Allows staff to manually create a new customer account from the admin panel.
// Validates name, email, phone, and password strength before saving to the database.
// Module: CTEC2713N

using System;
namespace DriveNow
{
    public partial class CustomerAdd : System.Web.UI.Page
    {
        // CustomerManager handles all customer database operations
        CustomerManager cm = new CustomerManager();

        // Security check — redirect to login if not authenticated
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
        }

        // Handles the Add Customer button click — validates fields and saves the new customer
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            // ASP.NET validators must all pass before we proceed
            if (!Page.IsValid) return;

            // Read the form fields
            string fullName = txtFullName.Text.Trim();
            string email    = txtEmail.Text.Trim();
            string phone    = txtPhone.Text.Trim();
            string password = txtPassword.Text;

            // Password must be at least 8 characters long
            if (string.IsNullOrWhiteSpace(password) || password.Length < 8)
            {
                lblError.Text    = "Password must be at least 8 characters.";
                lblError.Visible = true; return;
            }
            // Password must also contain at least one uppercase letter and one number
            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"[A-Z]") ||
                !System.Text.RegularExpressions.Regex.IsMatch(password, @"\d"))
            {
                lblError.Text    = "Password must contain at least 1 uppercase letter and 1 number.";
                lblError.Visible = true; return;
            }

            // Run the full name/email/phone format validation from the CustomerManager
            string err = cm.ValidateCustomer(fullName, email, phone);
            if (!string.IsNullOrEmpty(err)) { lblError.Text = err; lblError.Visible = true; return; }

            // Check that no existing account already uses this email address
            if (cm.EmailExists(email))
            {
                lblError.Text    = "An account with this email already exists.";
                lblError.Visible = true; return;
            }

            // Hash the password before storing — plain text must never reach the database
            string hash  = PasswordHelper.HashPassword(password);
            int    newID = cm.AddCustomer(fullName, email, phone, hash);

            if (newID > 0)
            {
                // Show success message with the new customer's ID
                lblMessage.Text    = "Customer added! ID: #CUS-" + newID.ToString("D3");
                lblMessage.Visible = true;
                lblError.Visible   = false;
                // Clear the form so staff can add another customer straight away
                txtFullName.Text = txtEmail.Text = txtPhone.Text = txtPassword.Text = "";
            }
            else
            {
                lblError.Text    = "Failed to add customer. Please try again.";
                lblError.Visible = true;
            }
        }

        // Cancel / Back button — returns to the customer list without saving
        protected void btnBack_Click(object sender, EventArgs e) { Response.Redirect("CustomerList.aspx"); }
    }
}
