// ============================================================
// File: ContributorView.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Purpose: Full application detail view for staff.
//          Loads all contributor fields from tblContributor
//          and the linked tblContribVehicle record (if any).
//          Approve & Promote calls spApproveContributorFull,
//          which auto-inserts into tblDriver and/or tblVehicle.
// ============================================================

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace DriveNow
{
    public partial class ContributorView : Page
    {
        // Stores the ContributorID from the query string across postbacks
        private int ContributorID
        {
            get
            {
                int id;
                if (int.TryParse(Request.QueryString["id"], out id)) return id;
                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth check — staff only
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            lblDate.Text = DateTime.Today.ToString("dd MMM yyyy");

            if (!IsPostBack)
            {
                int id = ContributorID;
                if (id <= 0)
                {
                    ShowError("No contributor ID supplied. Please return to the list and select a record.");
                    return;
                }
                LoadContributor(id);
            }
        }

        // Loads all contributor and linked vehicle data, populates labels, shows/hides sections
        private void LoadContributor(int id)
        {
            try
            {
                DataRow row = null;

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT ContributorID, FullName, Email, Phone, ContributorType,
                             ApplicationDate, IsApproved,
                             LicenceNumber, DateOfBirth,
                             DailyRate, VehiclePhotoUrl, ProfilePhotoUrl,
                             Notes, Colour, Seats,
                             PromotedDriverID, PromotedVehicleID
                      FROM tblContributor
                      WHERE ContributorID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);
                    if (dt.Rows.Count == 0)
                    {
                        ShowError("Contributor #" + id + " was not found.");
                        return;
                    }
                    row = dt.Rows[0];
                }

                // ---- Summary ----
                string contribType = row["ContributorType"].ToString();
                bool isApproved    = Convert.ToBoolean(row["IsApproved"]);

                lblPageID.Text         = id.ToString();
                lblID.Text             = id.ToString();
                lblApplicationDate.Text= Convert.ToDateTime(row["ApplicationDate"]).ToString("dd MMM yyyy");
                lblTypeBadge.Text      = BuildTypeBadge(contribType);
                lblStatus.Text         = isApproved
                    ? "<span class='cv-status-approved'><span class='cv-dot cv-dot-green'></span> Approved</span>"
                    : "<span class='cv-status-pending'><span class='cv-dot cv-dot-amber'></span> Pending</span>";

                string notes = row["Notes"] == DBNull.Value ? "" : row["Notes"].ToString().Trim();
                lblNotes.Text = string.IsNullOrEmpty(notes) ? "—" : System.Web.HttpUtility.HtmlEncode(notes);

                // ---- Personal details ----
                lblFullName.Text = System.Web.HttpUtility.HtmlEncode(row["FullName"].ToString());
                lblEmail.Text    = System.Web.HttpUtility.HtmlEncode(row["Email"].ToString());
                lblPhone.Text    = System.Web.HttpUtility.HtmlEncode(row["Phone"].ToString());

                // ---- Driver credentials section ----
                bool isDriver = contribType == "Driver" || contribType == "OwnerDriver";
                if (isDriver)
                {
                    pnlDriverCreds.Visible = true;

                    lblLicenceNumber.Text = row["LicenceNumber"] == DBNull.Value ? "—"
                        : System.Web.HttpUtility.HtmlEncode(row["LicenceNumber"].ToString());

                    lblDateOfBirth.Text = row["DateOfBirth"] == DBNull.Value ? "—"
                        : Convert.ToDateTime(row["DateOfBirth"]).ToString("dd MMM yyyy");

                    // LicenceIssueDate / LicenceExpiryDate added by Script 28 — load defensively
                    lblLicenceIssue.Text  = "—";
                    lblLicenceExpiry.Text = "—";
                    try
                    {
                        using (SqlConnection conn3 = DatabaseHelper.GetConnection())
                        using (SqlCommand cd = new SqlCommand(
                            "SELECT LicenceIssueDate, LicenceExpiryDate FROM tblContributor WHERE ContributorID=@id", conn3))
                        {
                            cd.Parameters.AddWithValue("@id", id);
                            using (System.Data.SqlClient.SqlDataReader rdr = cd.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    if (!rdr.IsDBNull(0)) lblLicenceIssue.Text  = rdr.GetDateTime(0).ToString("dd MMM yyyy");
                                    if (!rdr.IsDBNull(1)) lblLicenceExpiry.Text = rdr.GetDateTime(1).ToString("dd MMM yyyy");
                                }
                            }
                        }
                    }
                    catch { /* columns not yet in schema — show dashes */ }

                    string profileUrl = row["ProfilePhotoUrl"] == DBNull.Value ? "" : row["ProfilePhotoUrl"].ToString().Trim();
                    if (!string.IsNullOrEmpty(profileUrl))
                    {
                        pnlProfilePhoto.Visible  = true;
                        imgProfilePhoto.ImageUrl = ResolveUrl("~/" + profileUrl.TrimStart('/'));
                    }
                }

                // ---- Vehicle details section ----
                bool isOwner = contribType == "VehicleOwner" || contribType == "OwnerDriver";
                if (isOwner)
                {
                    pnlVehicleDetails.Visible = true;

                    // Load from tblContribVehicle (first record for this contributor)
                    using (SqlConnection conn2 = DatabaseHelper.GetConnection())
                    using (SqlCommand cv = new SqlCommand(
                        @"SELECT TOP 1 Make, Model, Year, RegistrationNo, Colour, Seats, DailyRate, VehiclePhotoUrl
                          FROM tblContribVehicle
                          WHERE ContributorID = @id
                          ORDER BY ContribVehicleID DESC", conn2))
                    {
                        cv.Parameters.AddWithValue("@id", id);
                        DataTable dvt = new DataTable();
                        new SqlDataAdapter(cv).Fill(dvt);

                        if (dvt.Rows.Count > 0)
                        {
                            DataRow vr = dvt.Rows[0];
                            lblVehicleMake.Text      = vr["Make"] == DBNull.Value ? "—" : System.Web.HttpUtility.HtmlEncode(vr["Make"].ToString());
                            lblVehicleModel.Text     = vr["Model"] == DBNull.Value ? "—" : System.Web.HttpUtility.HtmlEncode(vr["Model"].ToString());
                            lblVehicleYear.Text      = vr["Year"] == DBNull.Value ? "—" : vr["Year"].ToString();
                            lblVehicleReg.Text       = vr["RegistrationNo"] == DBNull.Value ? "—" : System.Web.HttpUtility.HtmlEncode(vr["RegistrationNo"].ToString());

                            string colour = vr["Colour"] == DBNull.Value ? "" : vr["Colour"].ToString().Trim();
                            lblVehicleColour.Text    = string.IsNullOrEmpty(colour) ? "—" : System.Web.HttpUtility.HtmlEncode(colour);

                            lblVehicleSeats.Text     = vr["Seats"] == DBNull.Value ? "—" : vr["Seats"].ToString();

                            // Daily rate: prefer ContribVehicle row, fallback to tblContributor column
                            decimal displayRate = 0;
                            bool hasVehicleRate = vr["DailyRate"] != DBNull.Value && decimal.TryParse(vr["DailyRate"].ToString(), out displayRate);
                            if (!hasVehicleRate && row["DailyRate"] != DBNull.Value)
                                decimal.TryParse(row["DailyRate"].ToString(), out displayRate);
                            lblVehicleDailyRate.Text = displayRate > 0 ? displayRate.ToString("0.00") : "—";

                            string vehiclePhotoUrl = vr["VehiclePhotoUrl"] == DBNull.Value ? "" : vr["VehiclePhotoUrl"].ToString().Trim();
                            if (!string.IsNullOrEmpty(vehiclePhotoUrl))
                            {
                                pnlVehiclePhoto.Visible          = true;
                                pnlNoVehiclePhotoView.Visible    = false;
                                imgVehiclePhoto.ImageUrl         = ResolveUrl("~/" + vehiclePhotoUrl.TrimStart('/'));
                            }
                            else
                            {
                                pnlVehiclePhoto.Visible       = false;
                                pnlNoVehiclePhotoView.Visible = true;
                            }
                        }
                        else
                        {
                            // Fall back to contributor-level vehicle fields if no tblContribVehicle row
                            lblVehicleColour.Text    = row["Colour"] == DBNull.Value ? "—" : System.Web.HttpUtility.HtmlEncode(row["Colour"].ToString());
                            lblVehicleSeats.Text     = row["Seats"] == DBNull.Value ? "—" : row["Seats"].ToString();
                            if (row["DailyRate"] != DBNull.Value)
                                lblVehicleDailyRate.Text = Convert.ToDecimal(row["DailyRate"]).ToString("0.00");

                            string vUrl = row["VehiclePhotoUrl"] == DBNull.Value ? "" : row["VehiclePhotoUrl"].ToString().Trim();
                            if (!string.IsNullOrEmpty(vUrl))
                            {
                                pnlVehiclePhoto.Visible       = true;
                                pnlNoVehiclePhotoView.Visible = false;
                                imgVehiclePhoto.ImageUrl      = ResolveUrl("~/" + vUrl.TrimStart('/'));
                            }
                            else
                            {
                                pnlVehiclePhoto.Visible       = false;
                                pnlNoVehiclePhotoView.Visible = true;
                            }
                        }
                    }
                }

                // ---- Action bar ----
                if (!isApproved)
                {
                    pnlApprove.Visible = true;

                    // Warn if DOB missing for driver type
                    if (isDriver && row["DateOfBirth"] == DBNull.Value)
                        pnlWarnDOB.Visible = true;

                    // Warn if daily rate missing for vehicle type
                    if (isOwner)
                    {
                        bool hasDailyRate = row["DailyRate"] != DBNull.Value;
                        if (!hasDailyRate)
                        {
                            // also check tblContribVehicle
                            pnlWarnRate.Visible = true;
                        }
                    }
                }
                else
                {
                    pnlApprovedBanner.Visible = true;

                    int driverID  = row["PromotedDriverID"]  == DBNull.Value ? 0 : Convert.ToInt32(row["PromotedDriverID"]);
                    int vehicleID = row["PromotedVehicleID"] == DBNull.Value ? 0 : Convert.ToInt32(row["PromotedVehicleID"]);

                    if (driverID > 0)
                    {
                        lnkDriver.Visible    = true;
                        lnkDriver.Text       = "View Driver #" + driverID;
                        lnkDriver.NavigateUrl= "DriverView.aspx?id=" + driverID;
                    }
                    if (vehicleID > 0)
                    {
                        lnkVehicle.Visible    = true;
                        lnkVehicle.Text       = "View Vehicle #" + vehicleID;
                        lnkVehicle.NavigateUrl= "VehicleView.aspx?id=" + vehicleID;
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Error loading contributor: " + ex.Message);
            }
        }

        // Handles the Approve & Promote button click
        protected void btnApproveFull_Click(object sender, EventArgs e)
        {
            int id = ContributorID;
            if (id <= 0) return;

            try
            {
                // Read optional override values from the warning fields
                decimal? overrideRate = null;
                decimal rateVal;
                if (!string.IsNullOrWhiteSpace(txtOverrideRate.Text) &&
                    decimal.TryParse(txtOverrideRate.Text.Trim(), out rateVal) && rateVal > 0)
                {
                    overrideRate = rateVal;

                    // Persist override rate to tblContributor so the SP can use it
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE tblContributor SET DailyRate=@r WHERE ContributorID=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@r",  overrideRate.Value);
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                }

                DateTime? overrideDOB = null;
                DateTime dobVal;
                if (!string.IsNullOrWhiteSpace(txtOverrideDOB.Text) &&
                    DateTime.TryParse(txtOverrideDOB.Text.Trim(), out dobVal))
                {
                    overrideDOB = dobVal;

                    // Persist override DOB to tblContributor so the SP can use it
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE tblContributor SET DateOfBirth=@d WHERE ContributorID=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@d",  overrideDOB.Value);
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                }

                // Call the full approval stored procedure
                var result = ContributorManager.ApproveFull(id);

                // Build success message
                string msg = "Application approved successfully.";
                if (result.driverID > 0)  msg += " Driver #" + result.driverID + " created.";
                if (result.vehicleID > 0) msg += " Vehicle #" + result.vehicleID + " added to fleet.";

                lblMessage.Text     = msg;
                lblMessage.CssClass = "dn-alert-success";
                lblMessage.Visible  = true;

                // Reload the page to show the approved state
                LoadContributor(id);
            }
            catch (Exception ex)
            {
                ShowError("Error approving contributor: " + ex.Message);
            }
        }

        // Helper: returns coloured HTML badge for the contributor type
        private string BuildTypeBadge(string type)
        {
            switch (type)
            {
                case "Driver":
                    return "<span class='cv-type-badge cv-badge-driver'>Driver</span>";
                case "VehicleOwner":
                    return "<span class='cv-type-badge cv-badge-owner'>Vehicle Owner</span>";
                case "OwnerDriver":
                    return "<span class='cv-type-badge cv-badge-ownerdrv'>Owner &amp; Driver</span>";
                default:
                    return System.Web.HttpUtility.HtmlEncode(type);
            }
        }

        private void ShowError(string msg)
        {
            lblMessage.Text     = msg;
            lblMessage.CssClass = "dn-alert-error";
            lblMessage.Visible  = true;
        }
    }
}
