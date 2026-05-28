// ============================================================
// File:    TempPasswords.aspx.cs
// Module:  Admin — Customer Password Resets
// Purpose: Code-behind for the admin temporary-password management
//          page.  Staff can see all customer forgot-password requests
//          and issue (or re-issue) a system-generated temporary password.
//          The plain-text password is displayed once on-screen after issue
//          so the admin can communicate it to the customer.
// ============================================================

using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DriveNow
{
    public partial class TempPasswords : Page
    {
        // ── Page lifecycle ────────────────────────────────────────

        protected void Page_Load(object sender, EventArgs e)
        {
            // Admin-only page — temporary passwords are sensitive
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
            {
                Response.Redirect("Login.aspx");
                return;
            }
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("MainMenu.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadRequests();
                // Restore the customer issued-password panel if it was set this session
                RestoreIssuedPanel();
                RestoreStaffIssuedPanel();
            }
        }

        // ── Data loading ──────────────────────────────────────────

        /// <summary>
        /// Loads all password reset requests and updates the stat cards.
        /// </summary>
        private void LoadRequests()
        {
            LoadStaffRequests();
            try
            {
                DataTable dt = PasswordResetManager.ListRequests();

                // Stat counters
                int total = dt.Rows.Count, pending = 0, issued = 0, resolved = 0;
                foreach (DataRow row in dt.Rows)
                {
                    if      (Convert.ToBoolean(row["IsResolved"])) resolved++;
                    else if (Convert.ToBoolean(row["IsIssued"]))   issued++;
                    else                                            pending++;
                }

                lblTotal.Text    = total.ToString();
                lblPending.Text  = pending.ToString();
                lblIssued.Text   = issued.ToString();
                lblResolved.Text = resolved.ToString();

                gvRequests.DataSource = dt;
                gvRequests.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading requests: " + ex.Message, "dn-alert-error");
            }
        }

        // ── Staff reset requests ──────────────────────────────────

        private void LoadStaffRequests()
        {
            try
            {
                gvStaffRequests.DataSource = StaffPasswordResetManager.ListRequests();
                gvStaffRequests.DataBind();
            }
            catch { /* table may not exist if Script 20 not run — silently hide */ }
        }

        protected void gvStaffRequests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "IssueStaffTempPw") return;
            int resetID = Convert.ToInt32(e.CommandArgument);
            try
            {
                string plain = StaffPasswordResetManager.IssueTempPassword(resetID);

                // Find staff name/username to show in confirmation panel
                var dt = StaffPasswordResetManager.ListRequests();
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    if (Convert.ToInt32(row["ResetID"]) == resetID)
                    {
                        lblStaffIssuedName.Text     = row["FullName"].ToString();
                        lblStaffIssuedUsername.Text = row["Username"].ToString();
                        break;
                    }
                }

                lblStaffIssuedPw.Text          = plain;
                pnlStaffIssuedPassword.Visible = true;
                Session["TmpPwStaff_Pw"]       = plain;
                Session["TmpPwStaff_Name"]     = lblStaffIssuedName.Text;
                Session["TmpPwStaff_Username"] = lblStaffIssuedUsername.Text;
                LoadRequests();
            }
            catch (Exception ex)
            {
                ShowMessage("Error issuing staff temporary password: " + ex.Message, "dn-alert-error");
            }
        }

        // ── Customer GridView row command ─────────────────────────

        protected void gvRequests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "IssueTempPw") return;

            int requestID = Convert.ToInt32(e.CommandArgument);

            try
            {
                // Generate and store temp password; retrieve plain text for display
                string plain = PasswordResetManager.IssueTempPassword(requestID);

                // Retrieve customer details to show alongside the password
                DataTable dt       = PasswordResetManager.ListRequests();
                string custName    = "";
                string custEmail   = "";
                foreach (DataRow row in dt.Rows)
                {
                    if (Convert.ToInt32(row["RequestID"]) == requestID)
                    {
                        custName  = row["FullName"].ToString();
                        custEmail = row["Email"].ToString();
                        break;
                    }
                }

                // Show the issued-password panel and persist across page reload
                lblIssuedPw.Text    = plain;
                lblIssuedName.Text  = custName;
                lblIssuedEmail.Text = custEmail;
                pnlIssuedPassword.Visible = true;
                Session["TmpPwDisplay_Pw"]    = plain;
                Session["TmpPwDisplay_Name"]  = custName;
                Session["TmpPwDisplay_Email"] = custEmail;

                // Reload grid to reflect updated status
                LoadRequests();
            }
            catch (Exception ex)
            {
                ShowMessage("Error issuing temporary password: " + ex.Message, "dn-alert-error");
            }
        }

        // ── Session-persistence helpers ───────────────────────────

        private void RestoreIssuedPanel()
        {
            string pw = Session["TmpPwDisplay_Pw"] as string;
            if (string.IsNullOrEmpty(pw)) return;
            lblIssuedPw.Text    = pw;
            lblIssuedName.Text  = Session["TmpPwDisplay_Name"]  as string ?? "";
            lblIssuedEmail.Text = Session["TmpPwDisplay_Email"] as string ?? "";
            pnlIssuedPassword.Visible = true;
        }

        private void RestoreStaffIssuedPanel()
        {
            string pw = Session["TmpPwStaff_Pw"] as string;
            if (string.IsNullOrEmpty(pw)) return;
            lblStaffIssuedPw.Text       = pw;
            lblStaffIssuedName.Text     = Session["TmpPwStaff_Name"]     as string ?? "";
            lblStaffIssuedUsername.Text = Session["TmpPwStaff_Username"] as string ?? "";
            pnlStaffIssuedPassword.Visible = true;
        }

        // ── Markup helper ─────────────────────────────────────────

        /// <summary>
        /// Returns an HTML status badge based on the request's resolved/issued flags.
        /// Called from the GridView ItemTemplate via <%# GetStatusBadge(...) %>.
        /// </summary>
        protected string GetStatusBadge(bool isResolved, bool isIssued)
        {
            if (isResolved) return "<span class=\"dn-status-resolved\">&#10003; Resolved</span>";
            if (isIssued)   return "<span class=\"dn-status-issued\">Temp Issued</span>";
            return                  "<span class=\"dn-status-pending\">Pending</span>";
        }

        // ── Helper ───────────────────────────────────────────────

        private void ShowMessage(string text, string cssClass)
        {
            lblMessage.Text     = text;
            lblMessage.CssClass = cssClass;
            lblMessage.Visible  = true;
        }
    }
}
