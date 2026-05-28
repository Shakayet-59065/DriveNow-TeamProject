using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace DriveNow
{
    public partial class DriverDetail : System.Web.UI.Page
    {
        private int _driverID;
        private bool _isAdmin;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
            if (!IsPostBack)
                LoadProfile();
        }

        private void LoadProfile()
        {
            if (!int.TryParse(Request.QueryString["id"], out _driverID) || _driverID <= 0)
            {
                pnlNotFound.Visible = true;
                return;
            }

            _isAdmin = Request.QueryString["admin"] == "1"
                    && Session["LoggedIn"] != null
                    && (bool)Session["LoggedIn"];

            var dm = new DriverManager();

            try
            {
                if (_isAdmin)
                    LoadAdminView(dm, _driverID);
                else
                    LoadCustomerView(dm, _driverID);
            }
            catch
            {
                // Fallback: SP may be missing columns — try public view
                try { LoadCustomerView(dm, _driverID); }
                catch { pnlNotFound.Visible = true; }
            }
        }

        private void LoadCustomerView(DriverManager dm, int driverID)
        {
            DataRow row = dm.GetDriverPublicProfile(driverID);
            if (row == null) { pnlNotFound.Visible = true; return; }

            string name     = SafeStr(row, "FullName");
            string photoUrl = SafeStr(row, "PhotoUrl");
            string bio      = SafeStr(row, "Bio");
            string gender   = SafeStr(row, "Gender");
            string specialty= SafeStr(row, "Specialty");
            decimal? rating = SafeDecimal(row, "Rating");
            DateTime join   = SafeDate(row, "JoinDate");

            RenderAvatar(name, photoUrl);
            litName.Text           = HttpUtility.HtmlEncode(name);
            litExp.Text            = GetExperienceText(join);
            litStars.Text          = RenderStars(rating);
            litGenderBadge.Text    = RenderGenderBadge(gender);
            litSpecialtyBadge.Text = RenderSpecialtyBadge(specialty);
            litBio.Text            = string.IsNullOrWhiteSpace(bio)
                                   ? "<em class=\"bio-empty\">No bio available.</em>"
                                   : HttpUtility.HtmlEncode(bio);
            litJoinDate.Text = join != DateTime.MinValue ? join.ToString("MMMM yyyy") : "—";

            lnkBack.Text        = "&#8592; Back to Booking";
            lnkBack.NavigateUrl = "javascript:history.back()";
            lnkNavBack.Text        = "Back";
            lnkNavBack.NavigateUrl = "javascript:history.back()";

            pnlProfile.Visible   = true;
            pnlAdminInfo.Visible = false;
        }

        private void LoadAdminView(DriverManager dm, int driverID)
        {
            DataRow row = dm.GetDriverAdminProfile(driverID);
            if (row == null)
            {
                // Admin profile SP may not exist yet — fall back to public view
                LoadCustomerView(dm, driverID);
                return;
            }

            string name     = SafeStr(row, "FullName");
            string photoUrl = SafeStr(row, "PhotoUrl");
            string bio      = SafeStr(row, "Bio");
            string gender   = SafeStr(row, "Gender");
            string specialty= SafeStr(row, "Specialty");
            decimal? rating = SafeDecimal(row, "Rating");
            DateTime join   = SafeDate(row, "JoinDate");
            bool active     = SafeBool(row, "IsActive", true);

            RenderAvatar(name, photoUrl);
            litName.Text           = HttpUtility.HtmlEncode(name);
            litExp.Text            = GetExperienceText(join);
            litStars.Text          = RenderStars(rating);
            litGenderBadge.Text    = RenderGenderBadge(gender);
            litSpecialtyBadge.Text = RenderSpecialtyBadge(specialty);
            litBio.Text            = string.IsNullOrWhiteSpace(bio)
                                   ? "<em class=\"bio-empty\">No bio set.</em>"
                                   : HttpUtility.HtmlEncode(bio);
            litJoinDate.Text = join != DateTime.MinValue ? join.ToString("MMMM yyyy") : "—";

            litAdminID.Text      = "#DRV-" + driverID.ToString("D3");
            litAdminPhone.Text   = HttpUtility.HtmlEncode(SafeStr(row, "Phone") ?? "—");
            litAdminLicence.Text = HttpUtility.HtmlEncode(SafeStr(row, "LicenceNumber") ?? "—");
            litAdminDOB.Text     = SafeDate(row, "DateOfBirth") != DateTime.MinValue
                                 ? SafeDate(row, "DateOfBirth").ToString("dd MMM yyyy") : "—";
            litAdminJoin.Text    = join != DateTime.MinValue ? join.ToString("dd MMM yyyy") : "—";
            litAdminStatus.Text  = active
                ? "<span style=\"color:#4ade80;\">Active</span>"
                : "<span style=\"color:#fca5a5;\">Inactive</span>";

            // Pre-select current rating in the dropdown
            if (rating.HasValue)
            {
                string rVal = rating.Value.ToString("F1");
                if (ddlRating.Items.FindByValue(rVal) != null)
                    ddlRating.SelectedValue = rVal;
            }

            lnkEdit.NavigateUrl = "DriverEdit.aspx?id=" + driverID;

            lnkBack.Text        = "&#8592; Back to Driver List";
            lnkBack.NavigateUrl = "DriverList.aspx";
            lnkNavBack.Text        = "Driver List";
            lnkNavBack.NavigateUrl = "DriverList.aspx";

            pnlProfile.Visible    = true;
            pnlAdminInfo.Visible  = true;
            pnlPublicInfo.Visible = false;

            // Store driver ID for postback
            ViewState["DriverID"] = driverID;
        }

        protected void btnUpdateRating_Click(object sender, EventArgs e)
        {
            int driverID = ViewState["DriverID"] != null
                ? (int)ViewState["DriverID"]
                : 0;

            if (!int.TryParse(Request.QueryString["id"], out driverID) || driverID <= 0)
            {
                ShowRatingMsg("Could not determine driver ID.", false);
                return;
            }

            string ratingVal = ddlRating.SelectedValue;
            if (string.IsNullOrEmpty(ratingVal))
            {
                ShowRatingMsg("Please select a rating first.", false);
                return;
            }

            decimal rating;
            if (!decimal.TryParse(ratingVal, System.Globalization.NumberStyles.Any,
                System.Globalization.CultureInfo.InvariantCulture, out rating))
            {
                ShowRatingMsg("Invalid rating value.", false);
                return;
            }

            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tblDriver SET Rating = @r WHERE DriverID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@r",  rating);
                    cmd.Parameters.AddWithValue("@id", driverID);
                    cmd.ExecuteNonQuery();
                }

                // Refresh the stars display
                litStars.Text = RenderStars(rating);
                ShowRatingMsg("&#10003; Rating updated to " + rating.ToString("N1") + " / 5.0", true);
            }
            catch (Exception ex)
            {
                ShowRatingMsg("Could not save rating: " + ex.Message, false);
            }
        }

        private void ShowRatingMsg(string msg, bool ok)
        {
            lblRatingMsg.Text     = msg;
            lblRatingMsg.CssClass = ok ? "rating-msg rating-msg-ok" : "rating-msg rating-msg-err";
            lblRatingMsg.Visible  = true;
        }

        // ── Rendering helpers ────────────────────────────────────────

        private static string RenderStars(decimal? rating)
        {
            if (rating == null)
                return "<div class=\"stars\"><span class=\"no-rating\">No ratings yet</span></div>";
            decimal r = Math.Max(0m, Math.Min(5m, rating.Value));
            var sb = new System.Text.StringBuilder("<div class=\"stars\" title=\"" + r.ToString("N1") + " out of 5\">");
            for (int i = 1; i <= 5; i++)
                sb.Append(r >= i ? "<span class=\"star-full\">&#9733;</span>" : "<span class=\"star-empty\">&#9733;</span>");
            sb.Append("<span class=\"rating-num\">" + r.ToString("N1") + " / 5.0</span></div>");
            return sb.ToString();
        }

        private static string RenderGenderBadge(string gender)
        {
            switch ((gender ?? "").Trim().ToUpper())
            {
                case "M": return "<span class=\"gender-badge gender-m\">&#9794; Male</span>";
                case "F": return "<span class=\"gender-badge gender-f\">&#9792; Female</span>";
                case "X": return "<span class=\"gender-badge gender-x\">&#9954; Non-binary</span>";
                default:  return "";
            }
        }

        private static string RenderSpecialtyBadge(string specialty)
        {
            if (string.IsNullOrWhiteSpace(specialty)) return "";
            return "<span class=\"specialty-badge\">&#9733; " + HttpUtility.HtmlEncode(specialty.Trim()) + "</span>";
        }

        private void RenderAvatar(string name, string photoUrl)
        {
            if (!string.IsNullOrWhiteSpace(photoUrl))
                litAvatarContent.Text = "<img src=\"" + HttpUtility.HtmlAttributeEncode(photoUrl) + "\" alt=\"" + HttpUtility.HtmlAttributeEncode(name) + "\" />";
            else
                litAvatarContent.Text = HttpUtility.HtmlEncode(GetInitials(name));
        }

        // ── Defensive row accessors ───────────────────────────────────

        private static string SafeStr(DataRow row, string col)
        {
            if (!row.Table.Columns.Contains(col)) return "";
            return row[col] == DBNull.Value ? "" : row[col].ToString();
        }

        private static decimal? SafeDecimal(DataRow row, string col)
        {
            if (!row.Table.Columns.Contains(col) || row[col] == DBNull.Value) return null;
            try { return Convert.ToDecimal(row[col]); } catch { return null; }
        }

        private static DateTime SafeDate(DataRow row, string col)
        {
            if (!row.Table.Columns.Contains(col) || row[col] == DBNull.Value) return DateTime.MinValue;
            try { return Convert.ToDateTime(row[col]); } catch { return DateTime.MinValue; }
        }

        private static bool SafeBool(DataRow row, string col, bool defaultVal = false)
        {
            if (!row.Table.Columns.Contains(col) || row[col] == DBNull.Value) return defaultVal;
            try { return Convert.ToBoolean(row[col]); } catch { return defaultVal; }
        }

        // ── Utility helpers ───────────────────────────────────────────

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }

        private static string GetExperienceText(DateTime joinDate)
        {
            if (joinDate == DateTime.MinValue) return "Experience unknown";
            int years = DateTime.Today.Year - joinDate.Year;
            if (joinDate > DateTime.Today.AddYears(-years)) years--;
            if (years < 1) return "Less than 1 year experience";
            return years + (years == 1 ? " year" : " years") + " experience";
        }
    }
}
