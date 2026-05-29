// DriveNow — CustomerPortal.aspx Code-Behind
// This is the logged-in customer's personal dashboard — their "My Account" page.
// Shows: welcome flash message, booking history, trip stats, loyalty tier, profile edit, password change.
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace DriveNow
{
    public partial class CustomerPortal : Page
    {
        // Runs when the portal page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // If not logged in as a customer, send them to the homepage (which has the login modal)
            if (Session["CustomerLoggedIn"] == null || !(bool)Session["CustomerLoggedIn"])
            {
                Response.Redirect("Default.aspx?openlogin=1");
                return;
            }

            // Customer logged in with a temporary password and has not yet
            // set a new permanent password — send them there first.
            if (Session["TempPwLogin"] != null && (bool)Session["TempPwLogin"])
            {
                Response.Redirect("SetNewPassword.aspx");
                return;
            }

            // Only load data on the first visit (not on every button click)
            if (!IsPostBack)
            {
                // Display the customer's name at the top of the page
                string name = Convert.ToString(Session["CustomerName"]);
                litName.Text    = System.Web.HttpUtility.HtmlEncode(name);
                litNavName.Text = System.Web.HttpUtility.HtmlEncode(name);

                ShowFlashMessage(); // Show welcome or booking confirmation banner if set
                LoadTrips();        // Load this customer's trip bookings
                LoadProfile();      // Pre-fill the profile edit form with current contact details
            }
        }

        // ── Flash message ────────────────────────────────────────────

        // Shows a one-time notification banner based on what just happened (sign-up, login, booking)
        private void ShowFlashMessage()
        {
            // Read and immediately clear the flash message from session — it should only show once
            string flash = Convert.ToString(Session["FlashMessage"]);
            Session.Remove("FlashMessage");

            if (string.IsNullOrEmpty(flash)) return;

            // The flash value is formatted as "type:name" e.g. "new_signup:Jane"
            string name = flash.Contains(":") ? flash.Substring(flash.IndexOf(':') + 1) : "";
            name = System.Web.HttpUtility.HtmlEncode(name);

            // Show different messages depending on the type of flash event
            if (flash.StartsWith("new_signup:"))
            {
                // First-time registration welcome message
                litFlash.Text     = "Welcome to DriveNow, " + name + "! Your account has been created successfully.";
                pnlFlash.CssClass = "flash flash-success";
            }
            else if (flash.StartsWith("welcome_back:"))
            {
                // Returning customer login message
                litFlash.Text     = "Welcome back, " + name + "! Great to see you again.";
                pnlFlash.CssClass = "flash flash-info";
            }
            else if (flash.StartsWith("booking_confirmed:"))
            {
                // Booking confirmed after payment
                litFlash.Text     = "&#10003; Payment accepted &amp; booking confirmed for <strong>" + name + "</strong>! Your trip has been added below.";
                pnlFlash.CssClass = "flash flash-success";
            }

            pnlFlash.Visible = true;
        }

        // ── Load trips ───────────────────────────────────────────────

        // Loads all of this customer's trip bookings from the database and calculates stats
        private void LoadTrips()
        {
            int customerID = Convert.ToInt32(Session["CustomerID"]);
            DataTable dt   = new DataTable();

            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand("spListCustomerTrips", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CustomerID", customerID);
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch
            {
                pnlTrips.Visible  = false;
                pnlEmpty.Visible  = true;
                litTotal.Text     = "0";
                litUpcoming.Text  = "0";
                litCompleted.Text = "0";
                litSpend.Text     = "0.00";
                return;
            }

            // Ensure InsuranceTier/Addons columns exist — added by script 31.
            if (!dt.Columns.Contains("InsuranceTier"))
                dt.Columns.Add("InsuranceTier", typeof(string)).DefaultValue = "Basic";
            if (!dt.Columns.Contains("Addons"))
                dt.Columns.Add("Addons", typeof(string)).DefaultValue = "";

            // Ensure CarReturned column exists — returned by spListCustomerTrips (script 31).
            if (!dt.Columns.Contains("CarReturned"))
            {
                var col = dt.Columns.Add("CarReturned", typeof(bool));
                col.DefaultValue = false;
                foreach (DataRow r in dt.Rows) r["CarReturned"] = false;
            }

            // Ensure DriverID column always exists — added by script 24.
            if (!dt.Columns.Contains("DriverID"))
                dt.Columns.Add("DriverID", typeof(object)).DefaultValue = DBNull.Value;

            // Ensure TripIsActive column always exists — added by script 23.
            // If the script hasn't been run yet, default to true (trip is active) so
            // the portal still renders correctly and no Eval() call throws.
            if (!dt.Columns.Contains("TripIsActive"))
            {
                var col = dt.Columns.Add("TripIsActive", typeof(bool));
                col.DefaultValue = true;
                foreach (DataRow r in dt.Rows)
                    r["TripIsActive"] = true;
            }

            if (dt.Rows.Count == 0)
            {
                pnlTrips.Visible      = false;
                pnlEmpty.Visible      = true;
                pnlReceipts.Visible   = false;
                pnlNoReceipts.Visible = true;
                litTotal.Text     = "0";
                litUpcoming.Text  = "0";
                litCompleted.Text = "0";
                litSpend.Text     = "0.00";
                SetLoyaltyTier(0);
                return;
            }

            int upcoming = 0, completed = 0, adminCancelled = 0;
            decimal spend = 0;
            var receiptRows = new System.Collections.Generic.List<DataRow>();
            foreach (DataRow row in dt.Rows)
            {
                // TripIsActive = 0 means staff deactivated this trip — don't count it in stats
                bool tripActive = true;
                try { tripActive = Convert.ToBoolean(row["TripIsActive"]); } catch { }

                if (!tripActive) { adminCancelled++; continue; }

                DateTime pickup = Convert.ToDateTime(row["PickupDate"]);
                if (pickup.Date >= DateTime.Today) upcoming++;
                else completed++;
                // Receipt = payment proof; show for all active (non-admin-cancelled) bookings
                receiptRows.Add(row);

                // Use VehicleDailyRate × TripDays for accurate spend (Script 21 adds these columns)
                try
                {
                    decimal dailyRate = Convert.ToDecimal(row["VehicleDailyRate"]);
                    int     tripDays  = Convert.ToInt32(row["TripDays"]);
                    spend += dailyRate * Math.Max(1, tripDays);
                }
                catch
                {
                    spend += Convert.ToDecimal(row["BaseRate"]);
                }
            }

            litTotal.Text     = (dt.Rows.Count - adminCancelled).ToString();
            litUpcoming.Text  = upcoming.ToString();
            litCompleted.Text = completed.ToString();
            litSpend.Text     = spend.ToString("N2");

            // Loyalty tier — calculated from completed trips count
            SetLoyaltyTier(completed);

            rptTrips.DataSource = dt;
            rptTrips.DataBind();

            // Receipts — only show completed (past) trips that were not admin-cancelled
            if (receiptRows.Count > 0)
            {
                DataTable receiptDt = dt.Clone();
                foreach (DataRow r in receiptRows) receiptDt.ImportRow(r);
                rptReceipts.DataSource = receiptDt;
                rptReceipts.DataBind();
                pnlReceipts.Visible   = true;
                pnlNoReceipts.Visible = false;
            }
            else
            {
                pnlReceipts.Visible   = false;
                pnlNoReceipts.Visible = true;
            }
        }

        // ── Load current email/phone into edit fields ─────────────────
        private void LoadProfile()
        {
            int customerID = Convert.ToInt32(Session["CustomerID"]);
            try
            {
                // Uses spGetCustomerProfile via CustomerManager — no inline SQL
                CustomerManager cm  = new CustomerManager();
                DataRow         row = cm.GetCustomerProfile(customerID);
                if (row != null)
                {
                    txtEditEmail.Text = row["Email"] != DBNull.Value ? row["Email"].ToString() : "";
                    txtEditPhone.Text = row["Phone"] != DBNull.Value ? row["Phone"].ToString() : "";
                }
            }
            catch { /* silently skip if DB unavailable */ }
        }

        // ── Save profile changes ──────────────────────────────────────
        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            // Consent required
            if (!chkProfileConsent.Checked)
            {
                lblProfileConsentError.Visible = true;
                lblProfileMsg.Visible          = false;
                return;
            }
            lblProfileConsentError.Visible = false;

            string email = txtEditEmail.Text.Trim();
            string phone = txtEditPhone.Text.Trim();

            if (string.IsNullOrEmpty(email))
            {
                lblProfileMsg.CssClass = "ep-msg-err";
                lblProfileMsg.Text     = "Email address cannot be empty.";
                lblProfileMsg.Visible  = true;
                return;
            }
            if (!email.Contains("@") || !email.Contains("."))
            {
                lblProfileMsg.CssClass = "ep-msg-err";
                lblProfileMsg.Text     = "Please enter a valid email address.";
                lblProfileMsg.Visible  = true;
                return;
            }

            int customerID = Convert.ToInt32(Session["CustomerID"]);

            try
            {
                // Uses spUpdateCustomerProfile via CustomerManager — no inline SQL
                CustomerManager cm = new CustomerManager();
                cm.UpdateCustomerProfile(customerID, email, phone);

                chkProfileConsent.Checked = false;
                lblProfileMsg.CssClass    = "ep-msg-ok";
                lblProfileMsg.Text        = "&#10003; Your contact details have been updated successfully.";
                lblProfileMsg.Visible     = true;
            }
            catch (Exception ex)
            {
                lblProfileMsg.CssClass = "ep-msg-err";
                lblProfileMsg.Text     = "Could not save changes: " + ex.Message;
                lblProfileMsg.Visible  = true;
            }
        }

        // ── Loyalty tier ─────────────────────────────────────────────

        // Calculates and displays the customer's loyalty tier badge based on how many trips they've completed
        private void SetLoyaltyTier(int completedTrips)
        {
            if (litLoyaltyTier == null) return;
            string tier, colour, next;
            // Assign a tier and progress message based on number of completed trips
            if      (completedTrips >= 20) { tier = "Platinum"; colour = "#e2e8f0"; next = "Maximum tier reached!"; }
            else if (completedTrips >= 10) { tier = "Gold";     colour = "#fbbf24"; next = (20 - completedTrips) + " more trip(s) to Platinum"; }
            else if (completedTrips >= 5)  { tier = "Silver";   colour = "#94a3b8"; next = (10 - completedTrips) + " more trip(s) to Gold"; }
            else if (completedTrips >= 1)  { tier = "Bronze";   colour = "#f97316"; next = (5  - completedTrips) + " more trip(s) to Silver"; }
            else                           { tier = "Guest";    colour = "#64748b"; next = "Complete your first trip to earn Bronze status"; }

            litLoyaltyTier.Text = "<div class=\"loyalty-badge\" style=\"border-color:" + colour + ";\">"
                + "<span style=\"color:" + colour + ";font-weight:800;font-size:.9rem;\">" + tier + " Member</span>"
                + "<span style=\"color:#64748b;font-size:.75rem;margin-left:.5rem;\">&mdash; " + completedTrips + " trip" + (completedTrips != 1 ? "s" : "") + " completed &mdash; " + next + "</span>"
                + "</div>";
        }

        // ── Helper methods ────────────────────────────────────────────
        protected string GetStatusBadge(object pickupDateObj, object tripIsActiveObj, object carReturnedObj = null)
        {
            bool tripActive = true;
            try { tripActive = Convert.ToBoolean(tripIsActiveObj); } catch { }

            bool carReturned = false;
            if (carReturnedObj != null && carReturnedObj != DBNull.Value)
                try { carReturned = Convert.ToBoolean(carReturnedObj); } catch { }

            // CarReturned takes priority — the vehicle was physically handed back.
            // Admin marked it returned; show a positive "Returned" status, not "Cancelled".
            if (carReturned)
                return "<span class=\"badge\" style=\"background:rgba(20,184,166,.18);color:#14b8a6;\">&#10003; Returned by Staff</span>";

            // Trip was deactivated by admin without being marked returned — truly cancelled.
            if (!tripActive)
                return "<span class=\"badge badge-cancelled\">Cancelled by Admin</span>";

            DateTime d = Convert.ToDateTime(pickupDateObj).Date;
            if (d > DateTime.Today)  return "<span class=\"badge badge-upcoming\">Upcoming</span>";
            if (d == DateTime.Today) return "<span class=\"badge badge-today\">Today</span>";
            return "<span class=\"badge badge-completed\">Completed</span>";
        }

        protected string FormatDriver(object val)
        {
            return (val == DBNull.Value || string.IsNullOrEmpty(val.ToString()))
                ? "Self-Drive" : val.ToString();
        }

        // Formats a date from a Repeater Eval() — returns "—" when the value is null/DBNull
        protected string FormatDate(object val)
        {
            if (val == null || val == DBNull.Value) return "&mdash;";
            DateTime d;
            return DateTime.TryParse(val.ToString(), out d) ? d.ToString("dd MMM yyyy HH:mm") : "&mdash;";
        }

        // Same but date-only (no time) — used in e-receipt display
        protected string FormatDateShort(object val)
        {
            if (val == null || val == DBNull.Value) return "&mdash;";
            DateTime d;
            return DateTime.TryParse(val.ToString(), out d) ? d.ToString("dd MMM yyyy") : "&mdash;";
        }

        protected string FormatInsurance(object val)
        {
            if (val == null || val == DBNull.Value) return "Basic";
            string ins = val.ToString().Trim();
            return string.IsNullOrEmpty(ins) ? "Basic" : System.Web.HttpUtility.HtmlEncode(ins);
        }

        protected string FormatAddons(object val)
        {
            if (val == null || val == DBNull.Value) return "&mdash;";
            string a = val.ToString().Trim();
            if (string.IsNullOrEmpty(a)) return "&mdash;";
            // Truncate for display; full list shown in title tooltip
            return a.Length > 30
                ? System.Web.HttpUtility.HtmlEncode(a.Substring(0, 30)) + "&hellip;"
                : System.Web.HttpUtility.HtmlEncode(a);
        }

        protected string FormatDriverLink(object nameVal, object idVal)
        {
            if (nameVal == DBNull.Value || string.IsNullOrEmpty(nameVal.ToString()))
                return "Self-Drive";
            string name = System.Web.HttpUtility.HtmlEncode(nameVal.ToString());
            if (idVal == DBNull.Value || idVal == null) return name;
            int driverID;
            if (!int.TryParse(idVal.ToString(), out driverID) || driverID <= 0) return name;
            return name + "<br/><a href=\"DriverPublicProfile.aspx?id=" + driverID + "\" style=\"font-size:.72rem;color:#0d9488;\">View Profile</a>";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Default.aspx");
        }

        // ── Cancel booking ────────────────────────────────────────────
        /// <summary>
        /// Handles Cancel button clicks from the trip repeater.
        /// Soft-cancels the booking by setting IsActive = 0 via spCancelCustomerTrip.
        /// Only upcoming trips can be cancelled (past trips show a dash instead).
        /// </summary>
        protected void rptTrips_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "CancelTrip")
            {
                int customerTripID = Convert.ToInt32(e.CommandArgument);
                int customerID     = Convert.ToInt32(Session["CustomerID"]);
                try
                {
                    // Cancel booking via spCancelCustomerTrip — soft delete only
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand("spCancelCustomerTrip", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@CustomerTripID", customerTripID);
                        cmd.Parameters.AddWithValue("@CustomerID",     customerID); // security: verify ownership
                        cmd.ExecuteNonQuery();
                    }
                    // Reload to show updated list
                    LoadTrips();
                    LoadProfile();
                }
                catch (Exception ex)
                {
                    litFlash.Text     = "&#9888; Could not cancel booking: " + System.Web.HttpUtility.HtmlEncode(ex.Message);
                    pnlFlash.CssClass = "flash flash-info";
                    pnlFlash.Visible  = true;
                }
            }
        }

        // ── Change password ───────────────────────────────────────────
        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string newPw     = txtNewPw.Text.Trim();
            string confirmPw = txtConfirmPw.Text.Trim();

            if (string.IsNullOrEmpty(newPw) || string.IsNullOrEmpty(confirmPw))
            {
                lblChangePwMsg.CssClass = "ep-msg-err";
                lblChangePwMsg.Text     = "Both password fields are required.";
                lblChangePwMsg.Visible  = true;
                return;
            }
            if (newPw.Length < 8)
            {
                lblChangePwMsg.CssClass = "ep-msg-err";
                lblChangePwMsg.Text     = "Password must be at least 8 characters.";
                lblChangePwMsg.Visible  = true;
                return;
            }
            if (newPw != confirmPw)
            {
                lblChangePwMsg.CssClass = "ep-msg-err";
                lblChangePwMsg.Text     = "Passwords do not match.";
                lblChangePwMsg.Visible  = true;
                return;
            }

            int customerID = Convert.ToInt32(Session["CustomerID"]);
            try
            {
                string newHash = PasswordHelper.HashPassword(newPw);
                CustomerManager.UpdatePassword(customerID, newHash);
                txtNewPw.Text           = "";
                txtConfirmPw.Text       = "";
                lblChangePwMsg.CssClass = "ep-msg-ok";
                lblChangePwMsg.Text     = "&#10003; Password updated successfully.";
                lblChangePwMsg.Visible  = true;
            }
            catch (Exception ex)
            {
                lblChangePwMsg.CssClass = "ep-msg-err";
                lblChangePwMsg.Text     = "Could not update password: " + ex.Message;
                lblChangePwMsg.Visible  = true;
            }
        }
    }
}
