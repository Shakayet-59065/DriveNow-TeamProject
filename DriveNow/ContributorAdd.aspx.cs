// DriveNow — ContributorAdd.aspx.cs
// Staff form to register a new contributor application.
// Supports Driver, VehicleOwner, and OwnerDriver types with the same fields
// as the public ContributorApply.aspx form.
// On OwnerDriver/VehicleOwner: vehicle record inserted into tblContribVehicle
// Extended fields (DOB, licence dates, colour, seats, rate, photos) saved via
// direct SQL UPDATE — tolerant if Script 26 columns have not yet been applied.
// Module: CTEC2713N

using System;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace DriveNow
{
    public partial class AddContributor : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                txtApplicationDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                if (Session["Username"] != null)
                    lblUsername.Text = Session["Username"].ToString();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // 1. Validate contributor type
            string contribType = hfContribType.Value.Trim();
            if (contribType != "VehicleOwner" && contribType != "Driver" && contribType != "OwnerDriver")
            {
                lblTypeError.Visible = true;
                lblMessage.Text      = "Please select a contributor type before saving.";
                lblMessage.CssClass  = "dn-alert-error";
                lblMessage.Visible   = true;
                return;
            }
            lblTypeError.Visible = false;

            // 2. ASP.NET validators (name, email, phone, date)
            if (!Page.IsValid) return;

            // 3. Driver-specific: licence number required
            if (contribType == "Driver" || contribType == "OwnerDriver")
            {
                lblLicenceError.Visible = false;
                if (string.IsNullOrWhiteSpace(txtLicenceNumber.Text.Trim()))
                {
                    lblLicenceError.Visible = true;
                    return;
                }
            }

            try
            {
                // 4. Build ContributorManager and insert base record
                var cm = new ContributorManager
                {
                    FullName        = txtFullName.Text.Trim(),
                    Email           = txtEmail.Text.Trim(),
                    Phone           = txtPhone.Text.Trim(),
                    ContributorType = contribType,
                    ApplicationDate = Convert.ToDateTime(txtApplicationDate.Text),
                    IsApproved      = false
                };

                if (!cm.Validate())
                {
                    lblMessage.Text    = cm.ErrorMessage;
                    lblMessage.CssClass = "dn-alert-error";
                    lblMessage.Visible = true;
                    return;
                }

                int newID = cm.Add();
                if (newID == -1)
                {
                    lblMessage.Text    = cm.ErrorMessage;
                    lblMessage.CssClass = "dn-alert-error";
                    lblMessage.Visible = true;
                    return;
                }

                // 5. Save licence dates + extended fields (best-effort)
                if (contribType == "Driver" || contribType == "OwnerDriver")
                    TrySaveLicenceDates(newID);

                TrySaveExtendedFields(newID, contribType);

                // 6. Save vehicle record to tblContribVehicle
                if (contribType == "VehicleOwner" || contribType == "OwnerDriver")
                {
                    string make  = txtVehicleMake.Text.Trim();
                    string model = txtVehicleModel.Text.Trim();
                    string reg   = txtVehicleReg.Text.Trim();
                    int    year  = 0;
                    int.TryParse(txtVehicleYear.Text.Trim(), out year);

                    if (!string.IsNullOrEmpty(make) && !string.IsNullOrEmpty(model) && year > 1900)
                    {
                        try
                        {
                            int cvID = ContributorManager.AddVehicle(newID, make, model, year,
                                string.IsNullOrEmpty(reg) ? "N/A" : reg);
                            TrySaveContribVehicleExtras(cvID, newID);
                        }
                        catch { /* vehicle details are optional */ }
                    }
                }

                // 7. Redirect with success confirmation
                Response.Redirect("ContributorList.aspx?added=" + newID);
            }
            catch (Exception ex)
            {
                lblMessage.Text    = "Error saving contributor: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }

        // Saves LicenceNumber, LicenceIssueDate, LicenceExpiryDate to tblContributor.
        // Tolerant — catches exception if columns have not yet been added by Script 26.
        private void TrySaveLicenceDates(int contributorID)
        {
            try
            {
                string licNum = txtLicenceNumber.Text.Trim();
                DateTime issueDate, expiryDate;
                bool hasIssue  = DateTime.TryParse(txtLicenceIssueDate.Text.Trim(),  out issueDate);
                bool hasExpiry = DateTime.TryParse(txtLicenceExpiryDate.Text.Trim(), out expiryDate);

                if (string.IsNullOrEmpty(licNum) && !hasIssue && !hasExpiry) return;

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tblContributor SET LicenceNumber=@ln, LicenceIssueDate=@li, LicenceExpiryDate=@le WHERE ContributorID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@ln", string.IsNullOrEmpty(licNum) ? (object)DBNull.Value : licNum);
                    cmd.Parameters.AddWithValue("@li", hasIssue  ? (object)issueDate  : DBNull.Value);
                    cmd.Parameters.AddWithValue("@le", hasExpiry ? (object)expiryDate : DBNull.Value);
                    cmd.Parameters.AddWithValue("@id", contributorID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* columns may not yet exist */ }
        }

        // Saves DOB, DailyRate, Colour, Seats, ProfilePhotoUrl, VehiclePhotoUrl to tblContributor.
        // Best-effort — swallows exceptions if Script 26 has not been run.
        private void TrySaveExtendedFields(int contributorID, string contribType)
        {
            try
            {
                string uploadDir = Server.MapPath("~/Uploads/Contributors/");
                Directory.CreateDirectory(uploadDir);

                bool isDriver = contribType == "Driver"        || contribType == "OwnerDriver";
                bool isOwner  = contribType == "VehicleOwner"  || contribType == "OwnerDriver";

                string profilePhotoUrl = null;
                string vehiclePhotoUrl = null;

                // --- Save profile photo ---
                if (isDriver && fuProfilePhoto.HasFile)
                {
                    string ext  = Path.GetExtension(fuProfilePhoto.FileName).ToLower();
                    string fn   = contributorID + "_profile" + ext;
                    fuProfilePhoto.SaveAs(Path.Combine(uploadDir, fn));
                    profilePhotoUrl = "Uploads/Contributors/" + fn;
                }

                // --- Save vehicle photo ---
                if (isOwner && fuVehiclePhoto.HasFile)
                {
                    string ext  = Path.GetExtension(fuVehiclePhoto.FileName).ToLower();
                    string fn   = contributorID + "_vehicle" + ext;
                    fuVehiclePhoto.SaveAs(Path.Combine(uploadDir, fn));
                    vehiclePhotoUrl = "Uploads/Contributors/" + fn;
                }

                DateTime dob      = DateTime.MinValue;
                decimal dailyRate = 0m;
                int     seats     = 0;

                bool hasDOB      = isDriver && DateTime.TryParse(txtDateOfBirth.Text.Trim(),      out dob)       && dob != DateTime.MinValue;
                bool hasDailyRate = isOwner && decimal.TryParse(txtVehicleDailyRate.Text.Trim(),   out dailyRate) && dailyRate > 0;
                bool hasSeats     = isOwner && int.TryParse(ddlVehicleSeats.SelectedValue,         out seats)     && seats > 0;

                string colour  = isOwner  ? txtVehicleColour.Text.Trim()  : null;
                string licence = isDriver ? txtLicenceNumber.Text.Trim()  : null;

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"UPDATE tblContributor SET
                        LicenceNumber   = CASE WHEN @licence    IS NOT NULL THEN @licence    ELSE LicenceNumber    END,
                        DateOfBirth     = CASE WHEN @dob        IS NOT NULL THEN @dob        ELSE DateOfBirth      END,
                        DailyRate       = CASE WHEN @dailyRate  IS NOT NULL THEN @dailyRate  ELSE DailyRate        END,
                        Colour          = CASE WHEN @colour     IS NOT NULL THEN @colour     ELSE Colour           END,
                        Seats           = CASE WHEN @seats      IS NOT NULL THEN @seats      ELSE Seats            END,
                        ProfilePhotoUrl = CASE WHEN @profileUrl IS NOT NULL THEN @profileUrl ELSE ProfilePhotoUrl  END,
                        VehiclePhotoUrl = CASE WHEN @vehicleUrl IS NOT NULL THEN @vehicleUrl ELSE VehiclePhotoUrl  END
                      WHERE ContributorID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@licence",    string.IsNullOrEmpty(licence)    ? (object)DBNull.Value : licence);
                    cmd.Parameters.AddWithValue("@dob",        hasDOB       ? (object)dob       : DBNull.Value);
                    cmd.Parameters.AddWithValue("@dailyRate",  hasDailyRate ? (object)dailyRate  : DBNull.Value);
                    cmd.Parameters.AddWithValue("@colour",     string.IsNullOrEmpty(colour)     ? (object)DBNull.Value : colour);
                    cmd.Parameters.AddWithValue("@seats",      hasSeats     ? (object)seats      : DBNull.Value);
                    cmd.Parameters.AddWithValue("@profileUrl", profilePhotoUrl != null ? (object)profilePhotoUrl : DBNull.Value);
                    cmd.Parameters.AddWithValue("@vehicleUrl", vehiclePhotoUrl != null ? (object)vehiclePhotoUrl : DBNull.Value);
                    cmd.Parameters.AddWithValue("@id",         contributorID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Extended columns require Script 26 */ }
        }

        // Updates tblContribVehicle with DailyRate, Colour, Seats, VehiclePhotoUrl.
        private void TrySaveContribVehicleExtras(int contribVehicleID, int contributorID)
        {
            try
            {
                decimal dailyRate = 0m;
                bool hasDailyRate = decimal.TryParse(txtVehicleDailyRate.Text.Trim(), out dailyRate) && dailyRate > 0;
                int seats = 0;
                bool hasSeats = int.TryParse(ddlVehicleSeats.SelectedValue, out seats) && seats > 0;
                string colour = txtVehicleColour.Text.Trim();

                string vehiclePhotoUrl = null;
                if (fuVehiclePhoto.HasFile)
                {
                    string ext = Path.GetExtension(fuVehiclePhoto.FileName).ToLower();
                    vehiclePhotoUrl = "Uploads/Contributors/" + contributorID + "_vehicle" + ext;
                }

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"UPDATE tblContribVehicle SET
                        DailyRate       = CASE WHEN @dailyRate IS NOT NULL THEN @dailyRate ELSE DailyRate       END,
                        Colour          = CASE WHEN @colour    IS NOT NULL THEN @colour    ELSE Colour          END,
                        Seats           = CASE WHEN @seats     IS NOT NULL THEN @seats     ELSE Seats           END,
                        VehiclePhotoUrl = CASE WHEN @photoUrl  IS NOT NULL THEN @photoUrl  ELSE VehiclePhotoUrl END
                      WHERE ContribVehicleID = @cvid", conn))
                {
                    cmd.Parameters.AddWithValue("@dailyRate", hasDailyRate ? (object)dailyRate : DBNull.Value);
                    cmd.Parameters.AddWithValue("@colour",    string.IsNullOrEmpty(colour) ? (object)DBNull.Value : colour);
                    cmd.Parameters.AddWithValue("@seats",     hasSeats ? (object)seats : DBNull.Value);
                    cmd.Parameters.AddWithValue("@photoUrl",  vehiclePhotoUrl != null ? (object)vehiclePhotoUrl : DBNull.Value);
                    cmd.Parameters.AddWithValue("@cvid",      contribVehicleID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Extended columns require Script 26 */ }
        }
    }
}
