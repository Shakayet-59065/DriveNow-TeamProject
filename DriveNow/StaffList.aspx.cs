// DriveNow — Staff List Code-Behind
// Displays all staff members (current and former) with tab switching between active and inactive.
// Only Admins can toggle a staff member's active status.
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace DriveNow
{
    public partial class StaffList : System.Web.UI.Page
    {
        // Helper property: returns true if the currently logged-in user has the Admin role
        protected bool IsAdmin
        {
            get { return Session["Role"] != null && Session["Role"].ToString() == "Admin"; }
        }

        // Returns the CSS class to highlight the currently selected tab (Active or Inactive/Former)
        protected string TabCss(string tabName)
        {
            // Read the ?tab= URL parameter; default to "active" if not provided
            string current = Request.QueryString["tab"] ?? "active";
            return current == tabName ? "dn-pill active" : "dn-pill";
        }

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // Block unauthenticated access — redirect to login page
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Only load staff data on the first visit — not after every button click
            if (!IsPostBack)
                LoadStaff();
        }

        // Fetches all staff records from the database, computes stat counts, and fills the grid
        private void LoadStaff()
        {
            // Determine which tab is selected — Active staff or Former (inactive) staff
            string tab = Request.QueryString["tab"] ?? "active";
            bool showActive = tab != "inactive";

            DataTable dt     = new DataTable(); // The filtered table for the current tab
            DataTable dtAll  = new DataTable(); // All staff records (used for stat counts)

            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    // Load counts from all staff (regardless of tab)
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT StaffID, FullName, Username, Email, Phone, Role, IsActive FROM tblStaff", conn))
                    {
                        new SqlDataAdapter(cmd).Fill(dtAll);
                    }
                }
            }
            catch
            {
                // tblStaff may not have IsActive yet — try simpler query without that column
                try
                {
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT StaffID, FullName, Username, Email, Phone, Role FROM tblStaff", conn))
                    {
                        new SqlDataAdapter(cmd).Fill(dtAll);
                    }

                    // If the IsActive column is missing, add it and default everyone to active
                    if (!dtAll.Columns.Contains("IsActive"))
                    {
                        var col = dtAll.Columns.Add("IsActive", typeof(bool));
                        col.DefaultValue = true;
                        foreach (DataRow r in dtAll.Rows) r["IsActive"] = true;
                    }
                }
                catch (Exception ex)
                {
                    // If even the fallback query fails, show an error and stop loading
                    lblMessage.Text    = "Could not load staff records: " + ex.Message;
                    lblMessage.CssClass = "dn-alert-error";
                    lblMessage.Visible  = true;
                    return;
                }
            }

            // Count active vs former staff for the stat cards
            int active = 0, former = 0;
            foreach (DataRow r in dtAll.Rows)
            {
                bool isAct = true;
                try { isAct = Convert.ToBoolean(r["IsActive"]); } catch { }
                if (isAct) active++; else former++;
            }
            // Update the stat labels at the top of the page
            lblTotalStaff.Text  = dtAll.Rows.Count.ToString();
            lblActiveStaff.Text = active.ToString();
            lblFormerStaff.Text = former.ToString();

            // Build a filtered copy of the table that matches the selected tab
            dt = dtAll.Clone(); // Clone creates same columns but no rows
            foreach (DataRow r in dtAll.Rows)
            {
                bool isAct = true;
                try { isAct = Convert.ToBoolean(r["IsActive"]); } catch { }
                if (showActive == isAct) dt.ImportRow(r); // Only import rows matching the tab
            }

            // Bind the filtered staff list to the grid
            gvStaff.DataSource = dt;
            gvStaff.DataBind();
        }

        // Handles the Toggle Active/Inactive button click — only Admins can do this
        protected void gvStaff_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ToggleActive" && IsAdmin)
            {
                int staffID = Convert.ToInt32(e.CommandArgument);
                try
                {
                    // Flip the IsActive flag: 1 → 0 (deactivate) or 0 → 1 (reactivate)
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE tblStaff SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE StaffID = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", staffID);
                        cmd.ExecuteNonQuery();
                    }
                }
                catch
                {
                    // IsActive column may not exist yet in older database versions — silently skip
                }
                LoadStaff(); // Refresh to reflect the status change
            }
        }

        // ── Helpers called from ASPX ──────────────────────────────────

        // Returns the first letter of a staff member's name in uppercase — used for the avatar circle
        protected string GetInitial(object nameObj)
        {
            string name = nameObj?.ToString() ?? "";
            return name.Length > 0 ? name[0].ToString().ToUpper() : "?";
        }

        // Returns an HTML badge showing the staff member's role (Admin or Staff) with appropriate styling
        protected string RenderRolePill(object roleObj)
        {
            string role = roleObj == DBNull.Value ? "Staff" : (roleObj?.ToString() ?? "Staff");
            string css  = role.ToLower().Contains("admin") ? "role-pill role-admin" : "role-pill role-staff";
            return string.Format("<span class=\"{0}\">{1}</span>", css, System.Web.HttpUtility.HtmlEncode(role));
        }

        // Returns an HTML status badge — green dot for Active staff, red dot for Former staff
        protected string GetStatusBadge(object isActiveObj)
        {
            bool active = true;
            try { active = Convert.ToBoolean(isActiveObj); } catch { }
            return active
                ? "<span class=\"dn-status\"><span class=\"dn-dot dn-dot-green\"></span> Active</span>"
                : "<span class=\"dn-status\"><span class=\"dn-dot dn-dot-red\"></span> Former</span>";
        }
    }
}
