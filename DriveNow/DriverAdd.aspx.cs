// DriveNow — DriverAdd.aspx Code-Behind
// Allows staff to add a new driver record to the system.
// Validates all required fields (name, phone, licence, DOB, join date) and optional fields
// (photo URL, bio, rating, gender, specialty, licence dates) before saving.
// Module: CTEC2713N

using System;
using System.Data.SqlClient;
namespace DriveNow
{
    public partial class DriverAdd : System.Web.UI.Page
    {
        // DriverManager handles all driver database operations
        DriverManager dm = new DriverManager();

        // Security check — redirect to login if not authenticated
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
        }

        // Handles the Add Driver button click — validates fields and saves the new driver
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            // Read the required fields from the form
            string fullName = txtFullName.Text.Trim();
            string phone    = txtPhone.Text.Trim();
            string licence  = txtLicenceNumber.Text.Trim();

            // Parse date of birth — must be a valid date
            DateTime dob, join;
            if (!DateTime.TryParse(txtDateOfBirth.Text.Trim(), out dob))
            { lblError.Text = "Invalid date of birth."; lblError.Visible = true; return; }
            // Parse join date — must be a valid date
            if (!DateTime.TryParse(txtJoinDate.Text.Trim(), out join))
            { lblError.Text = "Invalid join date."; lblError.Visible = true; return; }

            // Run core validation (name format, phone format, age check, etc.) via DriverManager
            string err = dm.ValidateDriver(fullName, phone, licence, dob, join);
            if (!string.IsNullOrEmpty(err))
            { lblError.Text = err; lblError.Visible = true; lblMessage.Visible = false; return; }

            // Read the optional fields — these can be left blank
            string photoUrl  = txtPhotoUrl.Text.Trim();
            string bio       = txtBio.Text.Trim();
            string specialty = txtSpecialty.Text.Trim();
            string gender    = ddlGender.SelectedValue;

            // Rating is optional but must be between 0.0 and 5.0 if provided
            decimal? rating = null;
            string ratingStr = txtRating.Text.Trim();
            if (!string.IsNullOrEmpty(ratingStr))
            {
                decimal r;
                if (!decimal.TryParse(ratingStr, out r) || r < 0m || r > 5m)
                { lblError.Text = "Rating must be a number between 0.0 and 5.0."; lblError.Visible = true; return; }
                rating = r;
            }

            // Save the driver to the database — null is passed for any empty optional fields
            int newID = dm.AddDriver(fullName, phone, licence, dob, join,
                                     string.IsNullOrEmpty(photoUrl)  ? null : photoUrl,
                                     string.IsNullOrEmpty(bio)       ? null : bio,
                                     rating,
                                     string.IsNullOrEmpty(gender)    ? null : gender,
                                     string.IsNullOrEmpty(specialty) ? null : specialty);
            if (newID > 0)
            {
                // Also save the licence issue/expiry dates if provided (separate method — added later to schema)
                TrySaveLicenceDates(newID);
                // Show success message with the new driver's assigned ID
                lblMessage.Text    = "Driver added! ID: #DRV-" + newID.ToString("D3");
                lblMessage.Visible = true; lblError.Visible = false;
                // Clear all form fields so staff can add another driver immediately
                txtFullName.Text = txtPhone.Text = txtLicenceNumber.Text =
                    txtDateOfBirth.Text = txtJoinDate.Text = txtPhotoUrl.Text = txtBio.Text =
                    txtRating.Text = txtSpecialty.Text =
                    txtLicenceIssueDate.Text = txtLicenceExpiryDate.Text = "";
                ddlGender.SelectedIndex = 0;
            }
            else { lblError.Text = "Failed to add driver."; lblError.Visible = true; }
        }

        // Saves the licence issue and expiry dates — these columns were added to the schema later,
        // so this is in a separate try/catch to avoid breaking the main save if the columns don't exist
        private void TrySaveLicenceDates(int driverID)
        {
            try
            {
                DateTime issueDate, expiryDate;
                bool hasIssue  = DateTime.TryParse(txtLicenceIssueDate.Text.Trim(),  out issueDate);
                bool hasExpiry = DateTime.TryParse(txtLicenceExpiryDate.Text.Trim(), out expiryDate);
                // If neither date was provided, nothing to save
                if (!hasIssue && !hasExpiry) return;

                // Update the driver's licence dates directly in the database
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
            catch { /* LicenceIssueDate / LicenceExpiryDate columns not yet in schema — silently skip */ }
        }

        // Back button — returns to the driver list without saving
        protected void btnBack_Click(object sender, EventArgs e) { Response.Redirect("DriverList.aspx"); }
    }
}
