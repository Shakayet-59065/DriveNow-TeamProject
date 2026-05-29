// DriveNow — DriverEdit.aspx Code-Behind
// Loads an existing driver record and lets staff update all fields.
// Some fields (Rating, Gender, Bio, PhotoUrl, Specialty, Licence dates) were added to the
// database schema in later scripts, so they are saved in separate try/catch blocks to stay
// backward-compatible with databases that haven't run all migration scripts.
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow
{
    public partial class DriverEdit : System.Web.UI.Page
    {
        // DriverManager handles all driver database operations
        DriverManager dm = new DriverManager();

        // Runs on page load — checks authentication and loads the driver record on first visit
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security check — send unauthenticated users to the login page
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Only load the driver data on first visit (not on Save button click)
            if (!IsPostBack)
            {
                string id = Request.QueryString["id"]; // Read the ?id= from the URL
                if (!string.IsNullOrEmpty(id))
                {
                    hdnDriverID.Value = id; // Store ID in hidden field for use on Save
                    LoadDriver(Convert.ToInt32(id));
                }
            }
        }

        // Fetches the driver record from the database and pre-fills all form fields
        private void LoadDriver(int driverID)
        {
            DataTable dt = dm.FindDriver(driverID, null);
            if (dt.Rows.Count == 0) return; // Driver not found — leave form empty
            DataRow r = dt.Rows[0];

            // Pre-fill the required core fields
            txtFullName.Text      = SafeStr(r, "FullName");
            txtPhone.Text         = SafeStr(r, "Phone");
            txtLicenceNumber.Text = SafeStr(r, "LicenceNumber");

            // Pre-fill dates — stored as yyyy-MM-dd for HTML5 date inputs
            if (r["DateOfBirth"] != DBNull.Value)
                txtDateOfBirth.Text = Convert.ToDateTime(r["DateOfBirth"]).ToString("yyyy-MM-dd");
            if (r["JoinDate"] != DBNull.Value)
                txtJoinDate.Text = Convert.ToDateTime(r["JoinDate"]).ToString("yyyy-MM-dd");

            // Licence dates (added by later scripts — gracefully skip if columns don't exist yet)
            SafeDateBox(r, "LicenceIssueDate",  txtLicenceIssueDate);
            SafeDateBox(r, "LicenceExpiryDate", txtLicenceExpiryDate);

            // Profile fields (added by script 25 — skip if not yet in the schema)
            txtPhotoUrl.Text  = SafeStr(r, "PhotoUrl");
            txtBio.Text       = SafeStr(r, "Bio");
            txtSpecialty.Text = SafeStr(r, "Specialty");

            // Pre-select the gender dropdown if a value was saved
            string gender = SafeStr(r, "Gender");
            if (ddlGender.Items.FindByValue(gender) != null)
                ddlGender.SelectedValue = gender;

            // Pre-select the rating dropdown if a rating was saved
            if (r.Table.Columns.Contains("Rating") && r["Rating"] != DBNull.Value)
            {
                string rVal = Convert.ToDecimal(r["Rating"]).ToString("F1");
                if (ddlRating.Items.FindByValue(rVal) != null)
                    ddlRating.SelectedValue = rVal;
            }
        }

        // Handles the Save button click — validates required fields and saves the updated driver
        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblError.Visible   = false;
            lblMessage.Visible = false;

            // Read the required fields from the form
            string fullName      = txtFullName.Text.Trim();
            string phone         = txtPhone.Text.Trim();
            string licenceNumber = txtLicenceNumber.Text.Trim();

            // All three required fields must be filled
            if (string.IsNullOrEmpty(fullName))      { ShowError("Full name is required."); return; }
            if (string.IsNullOrEmpty(phone))         { ShowError("Phone is required."); return; }
            if (string.IsNullOrEmpty(licenceNumber)) { ShowError("Licence number is required."); return; }

            // Parse the date fields — both must be valid dates
            DateTime dob, join;
            if (!DateTime.TryParse(txtDateOfBirth.Text.Trim(), out dob))
            { ShowError("Invalid date of birth."); return; }
            if (!DateTime.TryParse(txtJoinDate.Text.Trim(), out join))
            { ShowError("Invalid join date."); return; }

            // Run business-rule validation (age check, date logic, etc.)
            string err = dm.ValidateDriver(fullName, phone, licenceNumber, dob, join);
            if (!string.IsNullOrEmpty(err)) { ShowError(err); return; }

            int driverID = Convert.ToInt32(hdnDriverID.Value);

            // Save the core required fields via the DriverManager
            bool ok = dm.EditDriver(driverID, fullName, phone, licenceNumber, dob, join);
            if (!ok) { ShowError("Failed to save core details. Please try again."); return; }

            // Save the extended/optional fields — in separate try/catch blocks since columns
            // were added to the database in later migration scripts
            TrySaveExtendedFields(driverID);

            lblMessage.Text    = "&#10003; Driver record updated successfully.";
            lblMessage.Visible = true;
        }

        // Saves all the optional fields that were added to the schema in later scripts
        // Each group is in its own try/catch so one failure doesn't stop the others
        private void TrySaveExtendedFields(int driverID)
        {
            // Save rating (0.0–5.0) — column added by a later database script
            try
            {
                string rVal = ddlRating.SelectedValue;
                // Use DBNull if no rating selected — null means unrated
                object ratingParam = string.IsNullOrEmpty(rVal)
                    ? (object)DBNull.Value
                    : Convert.ToDecimal(rVal);

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tblDriver SET Rating = @r WHERE DriverID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@r",  ratingParam);
                    cmd.Parameters.AddWithValue("@id", driverID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Rating column not yet in schema — silently skip */ }

            // Save profile fields: Gender, Specialty, Bio, PhotoUrl (added by script 25)
            try
            {
                string gender    = ddlGender.SelectedValue;
                string specialty = txtSpecialty.Text.Trim();
                string bio       = txtBio.Text.Trim();
                string photo     = txtPhotoUrl.Text.Trim();

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tblDriver SET Gender=@g, Specialty=@sp, Bio=@b, PhotoUrl=@ph WHERE DriverID=@id", conn))
                {
                    // Pass DBNull for any empty optional field — blank string would look odd in the UI
                    cmd.Parameters.AddWithValue("@g",  string.IsNullOrEmpty(gender)    ? (object)DBNull.Value : gender);
                    cmd.Parameters.AddWithValue("@sp", string.IsNullOrEmpty(specialty) ? (object)DBNull.Value : specialty);
                    cmd.Parameters.AddWithValue("@b",  string.IsNullOrEmpty(bio)       ? (object)DBNull.Value : bio);
                    cmd.Parameters.AddWithValue("@ph", string.IsNullOrEmpty(photo)     ? (object)DBNull.Value : photo);
                    cmd.Parameters.AddWithValue("@id", driverID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Profile columns not yet in schema — silently skip */ }

            // Save licence issue and expiry dates — new columns added by later DB migration
            try
            {
                DateTime issueDate, expiryDate;
                bool hasIssue  = DateTime.TryParse(txtLicenceIssueDate.Text.Trim(),  out issueDate);
                bool hasExpiry = DateTime.TryParse(txtLicenceExpiryDate.Text.Trim(), out expiryDate);

                // Only update if at least one date was provided
                if (hasIssue || hasExpiry)
                {
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE tblDriver SET LicenceIssueDate=@li, LicenceExpiryDate=@le WHERE DriverID=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@li", hasIssue  ? (object)issueDate  : DBNull.Value);
                        cmd.Parameters.AddWithValue("@le", hasExpiry ? (object)expiryDate : DBNull.Value);
                        cmd.Parameters.AddWithValue("@id", driverID);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { /* LicenceIssueDate / LicenceExpiryDate columns not yet in schema */ }
        }

        // Back button — returns to the driver list without saving
        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("DriverList.aspx");
        }

        // Helper: safely reads a string column from a DataRow — returns "" if the column doesn't exist or is null
        private static string SafeStr(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return r[col].ToString();
        }

        // Helper: safely pre-fills a date TextBox — skips gracefully if the column doesn't exist or has an invalid value
        private static void SafeDateBox(DataRow r, string col, System.Web.UI.WebControls.TextBox box)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return;
            try { box.Text = Convert.ToDateTime(r[col]).ToString("yyyy-MM-dd"); }
            catch { }
        }

        // Helper: shows an error message label with the given text
        private void ShowError(string msg)
        {
            lblError.Text    = msg;
            lblError.Visible = true;
        }
    }
}
