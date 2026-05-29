// DriveNow — AddStaff.aspx Code-Behind
// Admin-only page for creating new staff (admin) accounts.
// Validates username format, full name, password strength, and saves with a PBKDF2 hashed password.
// Only users with Role = "Admin" can access this page.
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow
{
    public partial class AddStaff : System.Web.UI.Page
    {
        // Security check — must be logged in AND be an Admin role to access this page
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
            // Regular staff cannot create new accounts — only super-admin (Role = Admin) can
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
                Response.Redirect("StaffList.aspx");
        }

        // Handles the Save button — validates all fields and creates the new staff account
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Read all form fields
            string username  = txtUsername.Text.Trim();
            string fullName  = txtFullName.Text.Trim();
            string password  = txtPassword.Text;
            string confirm   = txtConfirmPw.Text;
            string role      = ddlRole.SelectedValue; // "Admin" or "Staff"

            // Username validation rules
            if (string.IsNullOrWhiteSpace(username))  { ShowMsg("Username is required.", false); return; }
            if (username.Length > 50)                  { ShowMsg("Username must not exceed 50 characters.", false); return; }
            // Only letters, numbers, and underscores allowed — no spaces or special chars
            if (!System.Text.RegularExpressions.Regex.IsMatch(username, @"^[a-zA-Z0-9_]+$"))
                                                       { ShowMsg("Username may only contain letters, digits and underscores.", false); return; }
            // Full name validation
            if (string.IsNullOrWhiteSpace(fullName))   { ShowMsg("Full name is required.", false); return; }
            if (System.Text.RegularExpressions.Regex.IsMatch(fullName.Trim(), @"\d"))
                                                       { ShowMsg("Full name must not contain numbers.", false); return; }
            // Password strength validation
            if (string.IsNullOrWhiteSpace(password))   { ShowMsg("Password is required.", false); return; }
            if (password.Length < 8)                   { ShowMsg("Password must be at least 8 characters.", false); return; }
            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"[A-Z]") ||
                !System.Text.RegularExpressions.Regex.IsMatch(password, @"\d"))
                                                       { ShowMsg("Password must contain at least 1 uppercase letter and 1 number.", false); return; }
            if (password != confirm)                   { ShowMsg("Passwords do not match.", false); return; }

            try
            {
                // Hash the password securely before saving — never store plain text
                string hash = PasswordHelper.HashPassword(password);
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spAddStaff", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Username",     username);
                    cmd.Parameters.AddWithValue("@PasswordHash", hash);
                    cmd.Parameters.AddWithValue("@FullName",     fullName);
                    cmd.Parameters.AddWithValue("@Role",         role);
                    // OUTPUT parameter — the stored procedure returns the new StaffID
                    SqlParameter outID = new SqlParameter("@NewStaffID", SqlDbType.Int)
                                        { Direction = ParameterDirection.Output };
                    cmd.Parameters.Add(outID);
                    cmd.ExecuteNonQuery();
                }
                ShowMsg("Staff member '" + username + "' added successfully. Password is PBKDF2 hashed.", true);
                // Clear the form so admin can add another staff member immediately
                txtUsername.Text = txtFullName.Text = txtPassword.Text = txtConfirmPw.Text = "";
            }
            catch (Exception ex)
            {
                // Handle duplicate username gracefully — database enforces UNIQUE on username
                if (ex.Message.Contains("UNIQUE") || ex.Message.Contains("duplicate"))
                    ShowMsg("Username '" + username + "' is already taken. Choose a different username.", false);
                else
                    ShowMsg("Error: " + ex.Message, false);
            }
        }

        // Helper: shows a success (green) or error (red) message label
        private void ShowMsg(string msg, bool success)
        {
            lblMsg.Text     = msg;
            lblMsg.CssClass = success ? "dn-alert dn-alert-success" : "dn-alert dn-alert-error";
            lblMsg.Visible  = true;
        }
    }
}
