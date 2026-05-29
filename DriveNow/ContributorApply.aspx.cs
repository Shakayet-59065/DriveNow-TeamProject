using System;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace DriveNow
{
    public partial class ContributorApply : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Public page — no auth check required
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // 1. Validate contributor type (set via JS hidden field)
            string contribType = hfContribType.Value.Trim();
            if (contribType != "VehicleOwner" && contribType != "Driver" && contribType != "OwnerDriver")
            {
                lblTypeError.Visible = true;
                return;
            }
            lblTypeError.Visible = false;

            // 2. Ethical consent — both checkboxes required
            lblConsentError.Visible = false;
            if (!chkAccuracy.Checked || !chkConsent.Checked)
            {
                lblConsentError.Visible = true;
                return;
            }

            // 3. Driver-specific field validation
            if (contribType == "Driver" || contribType == "OwnerDriver")
            {
                lblLicenceError.Visible = false;
                string licence = txtLicenceNumber.Text.Trim().ToUpper();

                // 3a. Licence number required
                if (string.IsNullOrEmpty(licence))
                {
                    lblLicenceError.Text    = "Driving licence number is required for Driver / Owner &amp; Driver applications.";
                    lblLicenceError.Visible = true;
                    return;
                }

                // 3b. Licence number format: 5–20 chars, ≥2 letters, ≥2 digits
                if (!System.Text.RegularExpressions.Regex.IsMatch(
                        licence, @"^(?=(?:.*[A-Za-z]){2})(?=(?:.*[0-9]){2})[A-Za-z0-9\-]{5,20}$"))
                {
                    lblLicenceError.Text    = "Licence number must be 5–20 characters and contain at least 2 letters and 2 digits (e.g. SMIT9701157JS9AB).";
                    lblLicenceError.Visible = true;
                    return;
                }

                // 3c. Duplicate licence number check across tblContributor
                try
                {
                    using (var conn = DatabaseHelper.GetConnection())
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(1) FROM tblContributor WHERE UPPER(LicenceNumber)=@lic", conn))
                    {
                        cmd.Parameters.AddWithValue("@lic", licence);
                        int cnt = (int)cmd.ExecuteScalar();
                        if (cnt > 0)
                        {
                            lblLicenceError.Text    = "An application with that driving licence number already exists.";
                            lblLicenceError.Visible = true;
                            return;
                        }
                    }
                }
                catch { /* column may not yet exist — skip duplicate check */ }

                // 3d. Date of Birth: ≥ 1970-01-01, ≤ today minus 18 years
                string dobText = txtDateOfBirth.Text.Trim();
                if (!string.IsNullOrEmpty(dobText))
                {
                    DateTime dob;
                    if (!DateTime.TryParse(dobText, out dob))
                    {
                        lblError.Text    = "Please enter a valid date of birth.";
                        lblError.Visible = true;
                        return;
                    }
                    DateTime minDob = new DateTime(1970, 1, 1);
                    DateTime maxDob = DateTime.Today.AddYears(-18);
                    if (dob < minDob || dob > maxDob)
                    {
                        lblError.Text    = "Date of birth must be on or after 01/01/1970 and at least 18 years before today.";
                        lblError.Visible = true;
                        return;
                    }
                }

                // 3e. Licence issue date: ≤ today minus 1 year
                string issueTxt = txtLicenceIssueDate.Text.Trim();
                if (!string.IsNullOrEmpty(issueTxt))
                {
                    DateTime issueDate;
                    if (!DateTime.TryParse(issueTxt, out issueDate))
                    {
                        lblError.Text    = "Please enter a valid licence issue date.";
                        lblError.Visible = true;
                        return;
                    }
                    if (issueDate > DateTime.Today.AddYears(-1))
                    {
                        lblError.Text    = "Driving licence must have been issued at least 1 year ago.";
                        lblError.Visible = true;
                        return;
                    }
                }
            }

            // 3f. Phone: must start with + and total digits 7–15
            {
                string phoneVal = txtPhone.Text.Trim();
                string digitsOnly = System.Text.RegularExpressions.Regex.Replace(phoneVal, @"[^\d]", "");
                if (!phoneVal.StartsWith("+") || digitsOnly.Length < 7 || digitsOnly.Length > 15)
                {
                    lblError.Text    = "Phone number must start with a country code (e.g. +44) and contain 7–15 digits in total.";
                    lblError.Visible = true;
                    return;
                }
            }

            // 3g. Vehicle registration duplicate check (Owner / OwnerDriver)
            if (contribType == "VehicleOwner" || contribType == "OwnerDriver")
            {
                string regNo = txtVehicleReg.Text.Trim().ToUpper();
                if (!string.IsNullOrEmpty(regNo) && regNo != "N/A")
                {
                    try
                    {
                        using (var conn = DatabaseHelper.GetConnection())
                        using (var cmd = new SqlCommand(
                            "SELECT COUNT(1) FROM tblVehicle WHERE UPPER(RegistrationNo)=@reg", conn))
                        {
                            cmd.Parameters.AddWithValue("@reg", regNo);
                            int cnt = (int)cmd.ExecuteScalar();
                            if (cnt > 0)
                            {
                                lblError.Text    = "Registration number '" + regNo + "' is already registered in the fleet. Please verify the plate.";
                                lblError.Visible = true;
                                return;
                            }
                        }
                    }
                    catch { /* tblVehicle may not be accessible — skip */ }
                }
            }

            // 4. Collect personal details
            string fullName = txtFullName.Text.Trim();
            string email    = txtEmail.Text.Trim();
            string phone    = txtPhone.Text.Trim();

            // 5. Use ContributorManager to insert via spAddContributor
            var mgr = new ContributorManager
            {
                FullName        = fullName,
                Email           = email,
                Phone           = phone,
                ContributorType = contribType,
                ApplicationDate = DateTime.Today,
                IsApproved      = false
            };

            int newID = -1;
            try
            {
                newID = mgr.Add();
            }
            catch (Exception)
            {
                lblError.Text    = "An error occurred while submitting your application. Please try again later.";
                lblError.Visible = true;
                return;
            }

            if (newID == -1)
            {
                lblError.Text    = mgr.ErrorMessage;
                lblError.Visible = true;
                return;
            }

            // 6. If Driver or OwnerDriver — save licence dates (best-effort)
            if (contribType == "Driver" || contribType == "OwnerDriver")
            {
                TrySaveLicenceDates(newID);
            }

            // 7. Save extended fields (photos, DOB, daily rate, colour, seats)
            TrySaveExtendedFields(newID, contribType);

            // 8. If Vehicle Owner or OwnerDriver — save vehicle details to tblContribVehicle
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
                        int contribVehicleID = ContributorManager.AddVehicle(newID, make, model, year,
                            string.IsNullOrEmpty(reg) ? "N/A" : reg);

                        // Update tblContribVehicle with the extra fields
                        TrySaveContribVehicleExtras(contribVehicleID, newID);
                    }
                    catch { /* vehicle details are optional — silently continue */ }
                }
            }

            // 9. Success — hide form and show confirmation
            pnlForm.Visible  = false;
            lblError.Visible = false;

            string typeLabel = contribType == "VehicleOwner" ? "Vehicle Owner"
                             : contribType == "OwnerDriver"  ? "Owner &amp; Driver"
                             : "Driver";
            lblSuccess.Text = string.Format(
                "Thank you, <strong>{0}</strong>! Your application as a <strong>{1}</strong> has been received. " +
                "Our team reviews applications within 3 business days and will contact you at <strong>{2}</strong>. " +
                "Any documents you attached will be reviewed securely in line with our privacy policy.",
                System.Web.HttpUtility.HtmlEncode(fullName),
                typeLabel,
                System.Web.HttpUtility.HtmlEncode(email));
            lblSuccess.Visible = true;
        }
        private void TrySaveLicenceDates(int contributorID)
        {
            try
            {
                DateTime issueDate, expiryDate;
                bool hasIssue  = DateTime.TryParse(txtLicenceIssueDate.Text.Trim(),  out issueDate);
                bool hasExpiry = DateTime.TryParse(txtLicenceExpiryDate.Text.Trim(), out expiryDate);
                if (!hasIssue && !hasExpiry) return;

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tblContributor SET LicenceIssueDate=@li, LicenceExpiryDate=@le WHERE ContributorID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@li", hasIssue  ? (object)issueDate  : DBNull.Value);
                    cmd.Parameters.AddWithValue("@le", hasExpiry ? (object)expiryDate : DBNull.Value);
                    cmd.Parameters.AddWithValue("@id", contributorID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* LicenceIssueDate / LicenceExpiryDate columns may not yet exist in tblContributor */ }
        }

        // Saves extended optional fields to tblContributor: DOB, LicenceNumber, DailyRate,
        // Colour, Seats and any uploaded photo files. Best-effort — swallows exceptions if
        // columns do not yet exist (Script 26 not yet run).
        private void TrySaveExtendedFields(int contributorID, string contribType)
        {
            try
            {
                // --- Resolve upload directory ---
                string uploadDir = Server.MapPath("~/Uploads/Contributors/");
                Directory.CreateDirectory(uploadDir);  // no-op if already exists

                string profilePhotoRelUrl = null;
                string vehiclePhotoRelUrl = null;

                bool isDriver = contribType == "Driver" || contribType == "OwnerDriver";
                bool isOwner  = contribType == "VehicleOwner" || contribType == "OwnerDriver";

                // --- Save profile photo ---
                if (isDriver && fuProfilePhoto.HasFile)
                {
                    string ext      = Path.GetExtension(fuProfilePhoto.FileName).ToLower();
                    string fileName = contributorID + "_profile" + ext;
                    fuProfilePhoto.SaveAs(Path.Combine(uploadDir, fileName));
                    profilePhotoRelUrl = "Uploads/Contributors/" + fileName;
                }

                // --- Save vehicle photo ---
                if (isOwner && fuVehiclePhoto.HasFile)
                {
                    string ext      = Path.GetExtension(fuVehiclePhoto.FileName).ToLower();
                    string fileName = contributorID + "_vehicle" + ext;
                    fuVehiclePhoto.SaveAs(Path.Combine(uploadDir, fileName));
                    vehiclePhotoRelUrl = "Uploads/Contributors/" + fileName;
                }

                // --- Build UPDATE for tblContributor ---
                // Initialise to defaults so the compiler knows they're assigned even
                // when the short-circuit (isDriver / isOwner == false) skips TryParse.
                DateTime dob      = DateTime.MinValue;
                decimal dailyRate = 0m;
                int     seats     = 0;

                bool hasDOB      = isDriver && DateTime.TryParse(txtDateOfBirth.Text.Trim(),      out dob)       && dob != DateTime.MinValue;
                bool hasDailyRate = isOwner && decimal.TryParse(txtVehicleDailyRate.Text.Trim(),   out dailyRate) && dailyRate > 0;
                bool hasSeats     = isOwner && int.TryParse(ddlVehicleSeats.SelectedValue,         out seats)     && seats > 0;

                string colour = isOwner ? txtVehicleColour.Text.Trim() : null;
                string licence = isDriver ? txtLicenceNumber.Text.Trim() : null;

                // Read the optional "why join" message and save it to the Notes column
                string notes = txtMessage.Text.Trim();

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"UPDATE tblContributor SET
                        LicenceNumber    = CASE WHEN @licence    IS NOT NULL THEN @licence    ELSE LicenceNumber    END,
                        DateOfBirth      = CASE WHEN @dob        IS NOT NULL THEN @dob        ELSE DateOfBirth      END,
                        DailyRate        = CASE WHEN @dailyRate  IS NOT NULL THEN @dailyRate  ELSE DailyRate        END,
                        Colour           = CASE WHEN @colour     IS NOT NULL THEN @colour     ELSE Colour           END,
                        Seats            = CASE WHEN @seats      IS NOT NULL THEN @seats      ELSE Seats            END,
                        Notes            = CASE WHEN @notes      IS NOT NULL THEN @notes      ELSE Notes            END,
                        ProfilePhotoUrl  = CASE WHEN @profileUrl IS NOT NULL THEN @profileUrl ELSE ProfilePhotoUrl  END,
                        VehiclePhotoUrl  = CASE WHEN @vehicleUrl IS NOT NULL THEN @vehicleUrl ELSE VehiclePhotoUrl  END
                      WHERE ContributorID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@licence",    string.IsNullOrEmpty(licence) ? (object)DBNull.Value : licence);
                    cmd.Parameters.AddWithValue("@dob",        hasDOB        ? (object)dob       : DBNull.Value);
                    cmd.Parameters.AddWithValue("@dailyRate",  hasDailyRate  ? (object)dailyRate  : DBNull.Value);
                    cmd.Parameters.AddWithValue("@colour",     string.IsNullOrEmpty(colour) ? (object)DBNull.Value : colour);
                    cmd.Parameters.AddWithValue("@seats",      hasSeats      ? (object)seats      : DBNull.Value);
                    cmd.Parameters.AddWithValue("@notes",      string.IsNullOrEmpty(notes)  ? (object)DBNull.Value : notes);
                    cmd.Parameters.AddWithValue("@profileUrl", profilePhotoRelUrl != null ? (object)profilePhotoRelUrl : DBNull.Value);
                    cmd.Parameters.AddWithValue("@vehicleUrl", vehiclePhotoRelUrl != null ? (object)vehiclePhotoRelUrl : DBNull.Value);
                    cmd.Parameters.AddWithValue("@id",         contributorID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Extended columns may not yet exist — Script 26 must be run first */ }
        }

        // Updates the tblContribVehicle record with extra fields (DailyRate, Colour, Seats, VehiclePhotoUrl).
        // Called after AddVehicle() so the contribVehicleID is known.
        private void TrySaveContribVehicleExtras(int contribVehicleID, int contributorID)
        {
            try
            {
                decimal dailyRate = 0m;
                bool hasDailyRate = decimal.TryParse(txtVehicleDailyRate.Text.Trim(), out dailyRate) && dailyRate > 0;

                int seats = 0;
                bool hasSeats = int.TryParse(ddlVehicleSeats.SelectedValue, out seats) && seats > 0;

                string colour = txtVehicleColour.Text.Trim();

                // The vehicle photo URL was already saved in TrySaveExtendedFields — re-derive the path
                string uploadDir       = Server.MapPath("~/Uploads/Contributors/");
                string vehiclePhotoUrl = null;
                if (fuVehiclePhoto.HasFile)
                {
                    string ext      = Path.GetExtension(fuVehiclePhoto.FileName).ToLower();
                    string fileName = contributorID + "_vehicle" + ext;
                    vehiclePhotoUrl = "Uploads/Contributors/" + fileName;
                }

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"UPDATE tblContribVehicle SET
                        DailyRate       = CASE WHEN @dailyRate  IS NOT NULL THEN @dailyRate  ELSE DailyRate       END,
                        Colour          = CASE WHEN @colour     IS NOT NULL THEN @colour     ELSE Colour          END,
                        Seats           = CASE WHEN @seats      IS NOT NULL THEN @seats      ELSE Seats           END,
                        VehiclePhotoUrl = CASE WHEN @photoUrl   IS NOT NULL THEN @photoUrl   ELSE VehiclePhotoUrl END
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
            catch { /* Extended columns may not yet exist — Script 26 must be run first */ }
        }
    }
}
