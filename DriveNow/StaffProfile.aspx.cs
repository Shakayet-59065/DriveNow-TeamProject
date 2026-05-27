// DriveNow — StaffProfile.aspx Code-Behind
// Shows the currently logged-in staff member's own profile page.
// Allows them to update their display name, email, phone, and password.
// Also shows live system stat counts (trips, customers, etc.) for quick reference.
// Module: CTEC2713N

using System;
using System.Data.SqlClient;

namespace DriveNow
{
    public partial class StaffProfile : System.Web.UI.Page
    {
        // Runs when the staff profile page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security check — staff must be logged in to view this page
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Only load data on first visit — not on every form submission
            if (!IsPostBack)
            {
                LoadProfile(); // Pre-fill the profile edit form with current values

                // Load live stat counts directly from the database for the summary cards
                lblTripCount.Text        = SafeCount("SELECT COUNT(*) FROM tblTrip");
                lblTripTypeCount.Text    = SafeCount("SELECT COUNT(*) FROM tblTripType");
                lblCustomerCount.Text    = SafeCount("SELECT COUNT(*) FROM tblCustomer WHERE IsActive = 1");
                lblDriverCount.Text      = SafeCount("SELECT COUNT(*) FROM tblDriver   WHERE IsActive = 1");
                lblContributorCount.Text = SafeCount("SELECT COUNT(*) FROM tblContributor");
            }
        }

        // ── Load current profile from DB ─────────────────────────────

        // Loads the staff member's profile info from the database and fills the form and display fields
        private void LoadProfile()
        {
            string loginName = GetLoginName();
            // FullName is stored in session after login — use it for the display name
            string fullName  = Session["Username"] != null ? Session["Username"].ToString() : "Admin";
            // Use the first letter of the name as the avatar initial (e.g. "M" for Musanna)
            string initial   = fullName.Length > 0 ? fullName[0].ToString().ToUpper() : "A";

            lblFullName.Text     = fullName;
            lblUsername.Text     = loginName;
            lblSidebarName.Text  = fullName;
            lblAvatarLetter.Text = initial;
            lblSessionDate.Text  = DateTime.Now.ToString("ddd, d MMM yyyy HH:mm");

            // Pre-populate edit fields
            txtEditFullName.Text = fullName;
            txtEditUsername.Text = loginName;

            // Load Email, Phone, and Role from DB
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT Email, Phone, Role FROM tblStaff WHERE Username = @u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", loginName);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string email = dr["Email"] != DBNull.Value ? dr["Email"].ToString() : "";
                            string phone = dr["Phone"] != DBNull.Value ? dr["Phone"].ToString() : "";
                            string role  = dr["Role"]  != DBNull.Value ? dr["Role"].ToString()  : "Staff";

                            lblCurrentEmail.Text = string.IsNullOrEmpty(email) ? "—" : email;
                            lblCurrentPhone.Text = string.IsNullOrEmpty(phone) ? "—" : phone;
                            txtEditEmail.Text    = email;
                            txtEditPhone.Text    = phone;

                            lblRole.Text        = role;
                            lblRoleDisplay.Text = role + " — DriveNow Staff";
                        }
                    }
                }
            }
            catch
            {
                // Email/Phone/Role columns don't exist yet — run SQL script 9
                lblCurrentEmail.Text = "Run script 9 to enable";
                lblCurrentPhone.Text = "Run script 9 to enable";
            }
        }

        // ── Save profile changes ─────────────────────────────────────
        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            // Consent required
            if (!chkProfileConsent.Checked)
            {
                lblConsentError.Visible = true;
                lblProfileMsg.Visible   = false;
                return;
            }
            lblConsentError.Visible = false;

            string loginName = GetLoginName();
            string fullName  = txtEditFullName.Text.Trim();
            string email     = txtEditEmail.Text.Trim();
            string phone     = txtEditPhone.Text.Trim();
            string newPwd    = txtNewPassword.Text;
            string confPwd   = txtConfirmPassword.Text;

            // Basic validation
            if (string.IsNullOrEmpty(fullName))
            {
                ShowError("Display name cannot be empty.");
                return;
            }

            // Password change validation
            bool changePwd = !string.IsNullOrEmpty(newPwd);
            if (changePwd)
            {
                if (newPwd.Length < 6)
                {
                    ShowError("New password must be at least 6 characters.");
                    return;
                }
                if (newPwd != confPwd)
                {
                    ShowError("New password and confirmation do not match.");
                    return;
                }
            }

            try
            {
                string sql = changePwd
                    ? "UPDATE tblStaff SET FullName=@fn, Email=@em, Phone=@ph, PasswordHash=@pw WHERE Username=@u"
                    : "UPDATE tblStaff SET FullName=@fn, Email=@em, Phone=@ph               WHERE Username=@u";

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@fn", fullName);
                    cmd.Parameters.AddWithValue("@em", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
                    cmd.Parameters.AddWithValue("@ph", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                    cmd.Parameters.AddWithValue("@u",  loginName);
                    if (changePwd)
                        cmd.Parameters.AddWithValue("@pw", PasswordHelper.HashPassword(newPwd));

                    cmd.ExecuteNonQuery();
                }

                // Update session display name
                Session["Username"] = fullName;

                // Refresh displayed values
                lblFullName.Text     = fullName;
                lblSidebarName.Text  = fullName;
                lblAvatarLetter.Text = fullName.Length > 0 ? fullName[0].ToString().ToUpper() : "A";
                lblCurrentEmail.Text = string.IsNullOrEmpty(email) ? "—" : email;
                lblCurrentPhone.Text = string.IsNullOrEmpty(phone) ? "—" : phone;

                // Clear password boxes
                txtNewPassword.Text     = "";
                txtConfirmPassword.Text = "";
                chkProfileConsent.Checked = false;

                ShowSuccess("Your profile has been updated successfully.");
            }
            catch (Exception ex)
            {
                ShowError("Could not save changes: " + ex.Message +
                          " (If this is about missing columns, run SQL script 9 first.)");
            }
        }

        // ── Helpers ──────────────────────────────────────────────────
        private string GetLoginName()
        {
            // StaffLoginName stores the actual DB username; fall back to "admin"
            return Session["StaffLoginName"] != null
                ? Session["StaffLoginName"].ToString()
                : "admin";
        }

        private void ShowSuccess(string msg)
        {
            lblProfileMsg.CssClass = "alert-success";
            lblProfileMsg.Text     = msg;
            lblProfileMsg.Visible  = true;
        }

        private void ShowError(string msg)
        {
            lblProfileMsg.CssClass = "alert-error";
            lblProfileMsg.Text     = msg;
            lblProfileMsg.Visible  = true;
        }

        // Runs a COUNT(*) query and returns the result as a string — returns "0" if the query fails
        private string SafeCount(string sql)
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    object result = cmd.ExecuteScalar();
                    return result != null ? result.ToString() : "0";
                }
            }
            catch { return "0"; } // Return 0 rather than crashing if a table doesn't exist yet
        }
    }
}
