// DriveNow — Login.aspx Code-Behind (Staff Login Page)
// Handles the sign-in logic for admin staff accounts.
// Supports: hashed passwords (PBKDF2), legacy plain-text passwords (auto-upgrades them),
//           and admin-issued temporary passwords via the password reset system.
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow
{
    public partial class Login : System.Web.UI.Page
    {
        // Runs when the login page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // If someone lands here with ?type=Customer (e.g. from BrowseFleet links),
                // redirect them to the homepage where the customer login modal lives
                string requestedType = Request.QueryString["type"];
                if (string.Equals(requestedType, "Customer", StringComparison.OrdinalIgnoreCase))
                {
                    // Preserve the return URL so the customer can be sent back after logging in
                    string returnUrl = Request.QueryString["returnUrl"];
                    if (!string.IsNullOrEmpty(returnUrl))
                        Response.Redirect("Default.aspx?returnUrl=" + Server.UrlEncode(returnUrl));
                    else
                        Response.Redirect("Default.aspx");
                    return;
                }

                // If the staff member is already logged in, skip the login page and go to the dashboard
                if (Session["LoggedIn"] != null && (bool)Session["LoggedIn"])
                    Response.Redirect("MainMenu.aspx");
            }
        }

        // Handles the Sign In button click — validates input and attempts login
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            lblError.Visible = false;
            // Read the username and password from the form
            string username = txtUsername.Text.Trim();
            string password = txtStaffPassword.Text.Trim();

            // Basic presence check — both fields must be filled in
            if (string.IsNullOrEmpty(username)) { lblError.Text = "Username is required."; lblError.Visible = true; return; }
            if (string.IsNullOrEmpty(password)) { lblError.Text = "Password is required."; lblError.Visible = true; return; }

            // Try regular password first (new SP → PBKDF2/plain-text), then legacy SP fallback
            bool loginOk = TryLoginNew(username, password) || TryLoginLegacy(username, password);

            // If regular login failed, check whether admin issued a temp password for this account
            if (!loginOk)
                loginOk = TryStaffTempPassword(username, password);

            // If all login attempts failed, show an error message
            if (!loginOk)
            {
                lblError.Text    = "Invalid username or password. Please try again.";
                lblError.Visible = true;
            }
        }

        // Attempts login using the modern stored procedure that returns the password hash.
        // Works when the updated spStaffLogin (no @Password param) is in the DB.
        private bool TryLoginNew(string username, string password)
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spStaffLogin", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Username", username);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        // No row returned means username not found
                        if (!dr.Read()) return false;

                        int    staffID    = Convert.ToInt32(dr["StaffID"]);
                        string fullName   = dr["FullName"].ToString();
                        string storedHash = dr["PasswordHash"].ToString();
                        dr.Close();

                        // PasswordHelper.VerifyPassword handles both PBKDF2 hashes and plain-text
                        bool verified = PasswordHelper.VerifyPassword(password, storedHash);

                        // On first successful login with a plain-text password, silently upgrade to PBKDF2
                        if (verified && !PasswordHelper.IsHashedPassword(storedHash))
                            TryMigrateHash(staffID, password);

                        // If password matched, create the session and redirect to the dashboard
                        if (verified) SetSessionAndRedirect(username, fullName);
                        return verified;
                    }
                }
            }
            catch (SqlException sqlex)
            {
                // Error 201 = procedure expects a parameter not supplied (@Password)
                // This means the old stored procedure is still in the DB — fall through to TryLoginLegacy
                if (sqlex.Number == 201 ||
                    sqlex.Message.IndexOf("Password", StringComparison.OrdinalIgnoreCase) >= 0)
                    return false;
                throw;
            }
            catch { return false; }
        }

        // Legacy fallback login for databases still using the old stored procedure (passes password in SQL).
        // Only reached if the DB still has the pre-Script-18 stored procedure.
        private bool TryLoginLegacy(string username, string password)
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spStaffLogin", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Password", password); // Old SP does comparison in SQL

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return false;

                        string fullName = dr["FullName"].ToString();
                        dr.Close();

                        // Login succeeded with old SP — create session and redirect
                        SetSessionAndRedirect(username, fullName);
                        return true;
                    }
                }
            }
            catch { return false; }
        }

        // Silently upgrades a plain-text stored password to a secure PBKDF2 hash on first login
        private void TryMigrateHash(int staffID, string plainPassword)
        {
            try
            {
                string newHash = PasswordHelper.HashPassword(plainPassword);
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spUpdateStaffPassword", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@StaffID",      staffID);
                    cmd.Parameters.AddWithValue("@PasswordHash", newHash);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Never block login if migration fails */ }
        }

        // Checks whether an admin-issued temporary password is active for this staff username
        private bool TryStaffTempPassword(string username, string password)
        {
            try
            {
                // Look up any pending temp-password reset request for this username
                var req = StaffPasswordResetManager.GetActiveRequest(username);
                if (req == null) return false;
                // Verify the typed password against the stored temp password hash
                if (!PasswordHelper.VerifyPassword(password, req.TempPasswordHash)) return false;

                // Temp password correct — mark it as resolved (so it can't be reused), then force password change
                StaffPasswordResetManager.MarkResolved(req.ResetID);
                Session["LoggedIn"]           = true;
                Session["Username"]           = req.FullName;
                Session["StaffLoginName"]     = req.Username;
                Session["MustChangePassword"] = true;
                // Redirect to the Set New Password page — staff must change their password before continuing
                Response.Redirect("SetNewPassword.aspx?type=staff");
                return true;
            }
            catch { return false; }
        }

        // Sets up the session data after a successful login and redirects to the dashboard
        private void SetSessionAndRedirect(string username, string fullName)
        {
            // Store login state and staff name in session — checked on every admin page load
            Session["LoggedIn"]       = true;
            Session["Username"]       = fullName;
            Session["StaffLoginName"] = username;

            // Also fetch the staff member's role (Admin or Staff) so admin-only pages can gate access
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT Role FROM tblStaff WHERE Username = @u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", username);
                    object result = cmd.ExecuteScalar();
                    // Default to "Staff" role if the Role column is not set
                    Session["Role"] = (result != null && result != DBNull.Value)
                                    ? result.ToString() : "Staff";
                }
            }
            catch { Session["Role"] = "Staff"; }

            // Take the staff member to the dashboard
            Response.Redirect("MainMenu.aspx");
        }
    }
}
