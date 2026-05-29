// ============================================================
// File: ContributorEdit.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Presentation Layer
// Purpose: Loads an existing contributor record by ContributorID
//          passed in the query string (?id=) and pre-populates
//          ALL form fields — including driver credentials and
//          vehicle details — with the current values from the DB.
//          Staff can update any field including IsApproved status.
//          On Save the upgraded spEditContributor syncs tblContributor,
//          tblContribVehicle, and (if already approved) tblVehicle /
//          tblDriver so the vehicles tab and drivers tab stay in sync.
//          ContributorID is stored in ViewState so it persists across
//          postbacks without being visible in the URL or form.
//          Redirects to ContributorList after successful save.
// ============================================================

using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;

namespace DriveNow
{
    public partial class EditContributor : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session check — redirect to login if not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                if (Request.QueryString["id"] != null)
                {
                    int id;
                    if (int.TryParse(Request.QueryString["id"], out id) && id > 0)
                        LoadContributor(id);
                    else
                        Response.Redirect("ContributorList.aspx");
                }
                else
                {
                    Response.Redirect("ContributorList.aspx");
                }
            }
        }

        // ── Load ─────────────────────────────────────────────────────────────

        /// <summary>
        /// Fetches the contributor record and linked vehicle record by ID,
        /// then pre-populates all form fields.
        /// </summary>
        private void LoadContributor(int id)
        {
            try
            {
                // Direct SQL — only selects columns guaranteed to exist from Script 26.
                // Notes, Colour, Seats, DailyRate etc. are Script-26 columns.
                // LicenceIssueDate / LicenceExpiryDate are Script-28 — loaded separately.
                DataTable dt = new DataTable();
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT ContributorID, FullName, Email, Phone, ContributorType,
                             ApplicationDate, IsApproved,
                             LicenceNumber, DateOfBirth,
                             DailyRate, VehiclePhotoUrl, ProfilePhotoUrl,
                             Notes, Colour, Seats,
                             PromotedDriverID, PromotedVehicleID
                      FROM tblContributor WHERE ContributorID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    new SqlDataAdapter(cmd).Fill(dt);
                }

                if (dt.Rows.Count == 0)
                {
                    Response.Redirect("ContributorList.aspx");
                    return;
                }

                DataRow row = dt.Rows[0];

                lblContributorID.Text = "#CON-" + id.ToString("D3");

                // ── Core fields ───────────────────────────────────────────────
                txtFullName.Text            = row["FullName"].ToString();
                txtEmail.Text               = row["Email"].ToString();
                txtPhone.Text               = row["Phone"].ToString();
                ddlContributorType.SelectedValue = row["ContributorType"].ToString();
                txtApplicationDate.Text     = Convert.ToDateTime(row["ApplicationDate"]).ToString("yyyy-MM-dd");
                bool isApproved             = Convert.ToBoolean(row["IsApproved"]);
                ddlIsApproved.SelectedValue = isApproved.ToString().ToLower();

                // Notes (Script-26 column — exists if Script 26 was run)
                txtNotes.Text = dt.Columns.Contains("Notes") && row["Notes"] != DBNull.Value
                    ? row["Notes"].ToString() : "";

                // ── Driver credential fields ──────────────────────────────────
                string contribType = row["ContributorType"].ToString();
                bool isDriver = contribType == "Driver" || contribType == "OwnerDriver";

                if (isDriver)
                {
                    txtLicenceNumber.Text = dt.Columns.Contains("LicenceNumber") && row["LicenceNumber"] != DBNull.Value
                        ? row["LicenceNumber"].ToString() : "";

                    if (dt.Columns.Contains("DateOfBirth") && row["DateOfBirth"] != DBNull.Value)
                        txtDateOfBirth.Text = Convert.ToDateTime(row["DateOfBirth"]).ToString("yyyy-MM-dd");

                    // LicenceIssueDate / LicenceExpiryDate — Script-28 columns, load defensively
                    try
                    {
                        using (SqlConnection conn2 = DatabaseHelper.GetConnection())
                        using (SqlCommand cd = new SqlCommand(
                            "SELECT LicenceIssueDate, LicenceExpiryDate FROM tblContributor WHERE ContributorID=@id", conn2))
                        {
                            cd.Parameters.AddWithValue("@id", id);
                            using (System.Data.SqlClient.SqlDataReader rdr = cd.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    if (!rdr.IsDBNull(0)) txtLicenceIssueDate.Text  = rdr.GetDateTime(0).ToString("yyyy-MM-dd");
                                    if (!rdr.IsDBNull(1)) txtLicenceExpiryDate.Text = rdr.GetDateTime(1).ToString("yyyy-MM-dd");
                                }
                            }
                        }
                    }
                    catch { /* Script 28 not yet run — fields remain empty */ }
                }

                // ── Vehicle fields — load from tblContribVehicle ──────────────
                bool isOwner = contribType == "VehicleOwner" || contribType == "OwnerDriver";

                if (isOwner)
                {
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 1 Make, Model, Year, RegistrationNo, Colour, Seats, DailyRate, VehiclePhotoUrl
                          FROM tblContribVehicle
                          WHERE ContributorID = @id
                          ORDER BY ContribVehicleID DESC", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        DataTable vdt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(vdt);

                        if (vdt.Rows.Count > 0)
                        {
                            DataRow vr = vdt.Rows[0];
                            txtVehicleMake.Text      = vr["Make"]          == DBNull.Value ? "" : vr["Make"].ToString();
                            txtVehicleModel.Text     = vr["Model"]         == DBNull.Value ? "" : vr["Model"].ToString();
                            txtVehicleYear.Text      = vr["Year"]          == DBNull.Value ? "" : vr["Year"].ToString();
                            txtVehicleReg.Text       = vr["RegistrationNo"]== DBNull.Value ? "" : vr["RegistrationNo"].ToString();
                            txtVehicleColour.Text    = vr["Colour"]        == DBNull.Value ? "" : vr["Colour"].ToString();
                            txtVehicleSeats.Text     = vr["Seats"]         == DBNull.Value ? "" : vr["Seats"].ToString();

                            if (vr["DailyRate"] != DBNull.Value)
                                txtVehicleDailyRate.Text = Convert.ToDecimal(vr["DailyRate"]).ToString("0.00");

                            // Load vehicle photo
                            string existingPhoto = vdt.Columns.Contains("VehiclePhotoUrl") && vr["VehiclePhotoUrl"] != DBNull.Value
                                ? vr["VehiclePhotoUrl"].ToString().Trim() : "";
                            if (!string.IsNullOrEmpty(existingPhoto))
                            {
                                hfCurrentVehiclePhotoUrl.Value       = existingPhoto;
                                imgCurrentContribVehicle.ImageUrl    = ResolveUrl("~/" + existingPhoto);
                                pnlCurrentVehiclePhoto.Visible       = true;
                                pnlNoVehiclePhoto.Visible            = false;
                            }
                            else
                            {
                                pnlCurrentVehiclePhoto.Visible = false;
                                pnlNoVehiclePhoto.Visible      = true;
                            }
                        }
                        else
                        {
                            // Fall back to contributor-level vehicle fields
                            txtVehicleColour.Text = row["Colour"] == DBNull.Value ? "" : row["Colour"].ToString();
                            txtVehicleSeats.Text  = row["Seats"]  == DBNull.Value ? "" : row["Seats"].ToString();
                            if (row["DailyRate"] != DBNull.Value)
                                txtVehicleDailyRate.Text = Convert.ToDecimal(row["DailyRate"]).ToString("0.00");
                            pnlCurrentVehiclePhoto.Visible = false;
                            pnlNoVehiclePhoto.Visible      = true;
                        }
                    }
                }

                // Store ID in ViewState — survives postback without URL exposure
                ViewState["ContributorID"] = id;
            }
            catch (Exception ex)
            {
                lblMessage.Text    = "Error loading contributor: " + ex.Message;
                lblMessage.CssClass= "dn-alert-error";
                lblMessage.Visible = true;
            }
        }

        // ── Photo helpers ─────────────────────────────────────────────────────

        /// <summary>
        /// Saves an uploaded vehicle photo to Content/contributors/ and updates
        /// VehiclePhotoUrl in both tblContribVehicle and tblContributor.
        /// </summary>
        private void TrySaveContribVehiclePhoto(int contributorID, System.Web.UI.WebControls.FileUpload fu)
        {
            try
            {
                string dir = Server.MapPath("~/Content/contributors/");
                Directory.CreateDirectory(dir);
                string ext      = Path.GetExtension(fu.FileName).ToLower();
                string fileName = "contrib_" + contributorID + "_vehicle" + ext;
                fu.SaveAs(Path.Combine(dir, fileName));
                SaveVehiclePhotoUrl(contributorID, "Content/contributors/" + fileName);
            }
            catch { /* photo upload failed — non-critical */ }
        }

        /// <summary>Writes the VehiclePhotoUrl to tblContribVehicle (most recent row) and tblContributor.</summary>
        private void SaveVehiclePhotoUrl(int contributorID, string relUrl)
        {
            try
            {
                object val = relUrl != null ? (object)relUrl : DBNull.Value;
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    // Update the most recent tblContribVehicle row
                    using (SqlCommand cmd = new SqlCommand(
                        @"UPDATE tblContribVehicle SET VehiclePhotoUrl=@url
                          WHERE ContribVehicleID=(
                              SELECT TOP 1 ContribVehicleID FROM tblContribVehicle
                              WHERE ContributorID=@id ORDER BY ContribVehicleID DESC)", conn))
                    {
                        cmd.Parameters.AddWithValue("@url", val);
                        cmd.Parameters.AddWithValue("@id",  contributorID);
                        cmd.ExecuteNonQuery();
                    }
                    // Also update tblContributor (used by ContributorView display)
                    try
                    {
                        using (SqlCommand cmd2 = new SqlCommand(
                            "UPDATE tblContributor SET VehiclePhotoUrl=@url WHERE ContributorID=@id", conn))
                        {
                            cmd2.Parameters.AddWithValue("@url", val);
                            cmd2.Parameters.AddWithValue("@id",  contributorID);
                            cmd2.ExecuteNonQuery();
                        }
                    }
                    catch { }
                }
            }
            catch { }
        }

        // ── Save ─────────────────────────────────────────────────────────────

        /// <summary>
        /// Fires when Save Changes is clicked.
        /// Calls the upgraded spEditContributor which:
        ///   — saves all extended contributor columns
        ///   — upserts the tblContribVehicle record
        ///   — syncs tblVehicle / tblDriver if the contributor is already approved
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            // ── Server-side validation ───────────────────────────────────────
            int id             = Convert.ToInt32(ViewState["ContributorID"]);
            string contribType = ddlContributorType.SelectedValue;
            bool isDriver      = contribType == "Driver"       || contribType == "OwnerDriver";
            bool isOwner       = contribType == "VehicleOwner" || contribType == "OwnerDriver";

            // Phone: must start with +, digits 7–15
            string phoneVal   = txtPhone.Text.Trim();
            string digitsOnly = Regex.Replace(phoneVal, @"[^\d]", "");
            if (!phoneVal.StartsWith("+") || digitsOnly.Length < 7 || digitsOnly.Length > 15)
            {
                lblMessage.Text    = "Phone number must start with a country code (e.g. +44) and contain 7–15 digits.";
                lblMessage.CssClass= "dn-alert-error";
                lblMessage.Visible = true;
                return;
            }

            if (isDriver)
            {
                // Licence number format
                string lic = txtLicenceNumber.Text.Trim().ToUpper();
                if (!string.IsNullOrEmpty(lic) &&
                    !Regex.IsMatch(lic, @"^(?=(?:.*[A-Za-z]){2})(?=(?:.*[0-9]){2})[A-Za-z0-9\-]{5,20}$"))
                {
                    lblMessage.Text    = "Licence number must be 5–20 characters with at least 2 letters and 2 digits.";
                    lblMessage.CssClass= "dn-alert-error";
                    lblMessage.Visible = true;
                    return;
                }

                // Duplicate licence number (exclude current contributor)
                if (!string.IsNullOrEmpty(lic))
                {
                    try
                    {
                        using (SqlConnection conn = DatabaseHelper.GetConnection())
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT COUNT(1) FROM tblContributor WHERE UPPER(LicenceNumber)=@lic AND ContributorID<>@id", conn))
                        {
                            cmd.Parameters.AddWithValue("@lic", lic);
                            cmd.Parameters.AddWithValue("@id",  id);
                            if ((int)cmd.ExecuteScalar() > 0)
                            {
                                lblMessage.Text    = "Another contributor already uses that driving licence number.";
                                lblMessage.CssClass= "dn-alert-error";
                                lblMessage.Visible = true;
                                return;
                            }
                        }
                    }
                    catch { /* column may not exist yet */ }
                }

                // Date of birth: ≥ 1970-01-01, ≤ today minus 18 years
                if (!string.IsNullOrWhiteSpace(txtDateOfBirth.Text))
                {
                    DateTime dob;
                    if (DateTime.TryParse(txtDateOfBirth.Text, out dob))
                    {
                        if (dob < new DateTime(1970, 1, 1) || dob > DateTime.Today.AddYears(-18))
                        {
                            lblMessage.Text    = "Date of birth must be on or after 01/01/1970 and at least 18 years before today.";
                            lblMessage.CssClass= "dn-alert-error";
                            lblMessage.Visible = true;
                            return;
                        }
                    }
                }

                // Licence issue date: ≤ today minus 1 year
                if (!string.IsNullOrWhiteSpace(txtLicenceIssueDate.Text))
                {
                    DateTime issueDate;
                    if (DateTime.TryParse(txtLicenceIssueDate.Text, out issueDate))
                    {
                        if (issueDate > DateTime.Today.AddYears(-1))
                        {
                            lblMessage.Text    = "Driving licence must have been issued at least 1 year ago.";
                            lblMessage.CssClass= "dn-alert-error";
                            lblMessage.Visible = true;
                            return;
                        }
                    }
                }
            }

            // Vehicle registration duplicate check (exclude current contributor's existing reg)
            if (isOwner && !string.IsNullOrWhiteSpace(txtVehicleReg.Text))
            {
                string newReg = txtVehicleReg.Text.Trim().ToUpper();
                try
                {
                    // Check if another vehicle (not belonging to this contributor) already has this reg
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT COUNT(1) FROM tblVehicle v
                          WHERE UPPER(v.RegistrationNo)=@reg
                            AND NOT EXISTS (
                                SELECT 1 FROM tblContributor c
                                WHERE c.PromotedVehicleID = v.VehicleID
                                  AND c.ContributorID = @id)", conn))
                    {
                        cmd.Parameters.AddWithValue("@reg", newReg);
                        cmd.Parameters.AddWithValue("@id",  id);
                        if ((int)cmd.ExecuteScalar() > 0)
                        {
                            lblMessage.Text    = "Registration number '" + newReg + "' is already in the fleet. Please verify the plate.";
                            lblMessage.CssClass= "dn-alert-error";
                            lblMessage.Visible = true;
                            return;
                        }
                    }
                }
                catch { /* tblVehicle / PromotedVehicleID may not be accessible */ }
            }

            try
            {

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spEditContributor", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Core fields
                    cmd.Parameters.AddWithValue("@ContributorID",   id);
                    cmd.Parameters.AddWithValue("@FullName",         txtFullName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Email",            txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@Phone",            txtPhone.Text.Trim());
                    cmd.Parameters.AddWithValue("@ContributorType",  contribType);
                    cmd.Parameters.AddWithValue("@IsApproved",       ddlIsApproved.SelectedValue == "true");
                    cmd.Parameters.AddWithValue("@Notes",            string.IsNullOrWhiteSpace(txtNotes.Text)
                                                                        ? (object)DBNull.Value
                                                                        : txtNotes.Text.Trim());

                    // Driver credential fields
                    cmd.Parameters.AddWithValue("@LicenceNumber",
                        isDriver && !string.IsNullOrWhiteSpace(txtLicenceNumber.Text)
                            ? (object)txtLicenceNumber.Text.Trim() : DBNull.Value);

                    DateTime dob;
                    cmd.Parameters.AddWithValue("@DateOfBirth",
                        isDriver && DateTime.TryParse(txtDateOfBirth.Text, out dob)
                            ? (object)dob : DBNull.Value);

                    DateTime licIssue;
                    cmd.Parameters.AddWithValue("@LicenceIssueDate",
                        isDriver && DateTime.TryParse(txtLicenceIssueDate.Text, out licIssue)
                            ? (object)licIssue : DBNull.Value);

                    DateTime licExpiry;
                    cmd.Parameters.AddWithValue("@LicenceExpiryDate",
                        isDriver && DateTime.TryParse(txtLicenceExpiryDate.Text, out licExpiry)
                            ? (object)licExpiry : DBNull.Value);

                    cmd.Parameters.AddWithValue("@ProfilePhotoUrl", (object)DBNull.Value); // unchanged — photo upload is a separate flow

                    // Vehicle fields
                    cmd.Parameters.AddWithValue("@VehicleMake",
                        isOwner && !string.IsNullOrWhiteSpace(txtVehicleMake.Text)
                            ? (object)txtVehicleMake.Text.Trim() : DBNull.Value);

                    cmd.Parameters.AddWithValue("@VehicleModel",
                        isOwner && !string.IsNullOrWhiteSpace(txtVehicleModel.Text)
                            ? (object)txtVehicleModel.Text.Trim() : DBNull.Value);

                    int vehicleYear;
                    cmd.Parameters.AddWithValue("@VehicleYear",
                        isOwner && int.TryParse(txtVehicleYear.Text, out vehicleYear)
                            ? (object)vehicleYear : DBNull.Value);

                    cmd.Parameters.AddWithValue("@VehicleReg",
                        isOwner && !string.IsNullOrWhiteSpace(txtVehicleReg.Text)
                            ? (object)txtVehicleReg.Text.Trim().ToUpper() : DBNull.Value);

                    cmd.Parameters.AddWithValue("@VehicleColour",
                        isOwner && !string.IsNullOrWhiteSpace(txtVehicleColour.Text)
                            ? (object)txtVehicleColour.Text.Trim() : DBNull.Value);

                    int vehicleSeats;
                    cmd.Parameters.AddWithValue("@VehicleSeats",
                        isOwner && int.TryParse(txtVehicleSeats.Text, out vehicleSeats)
                            ? (object)vehicleSeats : DBNull.Value);

                    decimal vehicleRate;
                    cmd.Parameters.AddWithValue("@VehicleDailyRate",
                        isOwner && decimal.TryParse(txtVehicleDailyRate.Text, out vehicleRate) && vehicleRate > 0
                            ? (object)vehicleRate : DBNull.Value);

                    cmd.Parameters.AddWithValue("@VehiclePhotoUrl", (object)DBNull.Value); // unchanged — photo upload is a separate flow

                    cmd.ExecuteNonQuery();
                }

                // ── Handle vehicle photo upload ───────────────────────────────
                if (isOwner)
                {
                    if (chkRemoveVehiclePhoto.Checked)
                    {
                        SaveVehiclePhotoUrl(id, null);
                    }
                    else if (fuContribVehiclePhoto.HasFile)
                    {
                        TrySaveContribVehiclePhoto(id, fuContribVehiclePhoto);
                    }
                }

                Response.Redirect("ContributorList.aspx?edited=" + id);
            }
            catch (Exception ex)
            {
                lblMessage.Text    = "Error saving changes: " + ex.Message;
                lblMessage.CssClass= "dn-alert-error";
                lblMessage.Visible = true;
            }
        }
    }
}
