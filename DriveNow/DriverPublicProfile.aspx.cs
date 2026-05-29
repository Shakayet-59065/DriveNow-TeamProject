using System;
using System.Data;
using System.Web;

namespace DriveNow
{
    public partial class DriverPublicProfile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["CustomerLoggedIn"] == null || !(bool)Session["CustomerLoggedIn"])
            {
                Response.Redirect("Default.aspx?openlogin=1");
                return;
            }

            if (!IsPostBack)
                LoadProfile();
        }

        private void LoadProfile()
        {
            int driverID;
            if (!int.TryParse(Request.QueryString["id"], out driverID) || driverID <= 0)
            {
                pnlNotFound.Visible = true;
                return;
            }

            try
            {
                var dm  = new DriverManager();
                DataRow row = dm.GetDriverPublicProfile(driverID);
                if (row == null) { pnlNotFound.Visible = true; return; }

                string name      = SafeStr(row, "FullName");
                string photoUrl  = SafeStr(row, "PhotoUrl");
                string bio       = SafeStr(row, "Bio");
                string gender    = SafeStr(row, "Gender");
                string specialty = SafeStr(row, "Specialty");
                decimal? rating  = SafeDecimal(row, "Rating");
                DateTime join    = SafeDate(row, "JoinDate");

                if (!string.IsNullOrWhiteSpace(photoUrl))
                    litAvatarContent.Text = "<img src=\"" + HttpUtility.HtmlAttributeEncode(photoUrl) + "\" alt=\"" + HttpUtility.HtmlAttributeEncode(name) + "\" />";
                else
                    litAvatarContent.Text = HttpUtility.HtmlEncode(GetInitials(name));

                litName.Text           = HttpUtility.HtmlEncode(name);
                litExp.Text            = GetExperienceText(join);
                litStars.Text          = RenderStars(rating);
                litGenderBadge.Text    = RenderGenderBadge(gender);
                litSpecialtyBadge.Text = RenderSpecialtyBadge(specialty);
                litBio.Text            = string.IsNullOrWhiteSpace(bio)
                                       ? "<em class=\"bio-empty\">No bio available.</em>"
                                       : HttpUtility.HtmlEncode(bio);
                litJoinDate.Text = join != DateTime.MinValue ? join.ToString("MMMM yyyy") : "—";

                pnlProfile.Visible = true;
            }
            catch
            {
                pnlNotFound.Visible = true;
            }
        }

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

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }

        private static string GetExperienceText(DateTime joinDate)
        {
            if (joinDate == DateTime.MinValue) return "Experienced driver";
            int years = DateTime.Today.Year - joinDate.Year;
            if (joinDate > DateTime.Today.AddYears(-years)) years--;
            if (years < 1) return "Less than 1 year experience";
            return years + (years == 1 ? " year" : " years") + " experience";
        }
    }
}
