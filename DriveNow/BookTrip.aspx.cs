// DriveNow — BookTrip.aspx Code-Behind
// Powers the multi-step booking wizard that customers use to reserve a vehicle.
// Step 1: Enter trip details (dates, locations, trip type)
// Step 2: Choose insurance level
// Step 3: Add optional extras (GPS, child seat, etc.)
// Step 4: Review the full quote and confirm payment
// All booking data is held in ViewState between steps so it survives form submissions.
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web;

namespace DriveNow
{
    public partial class BookTrip : System.Web.UI.Page
    {
        // ── ViewState helpers ──────────────────────────────────────────────────
        // ViewState stores values between page requests (button clicks) without round-tripping to the server.
        // Each property below saves and retrieves one piece of the booking data.

        // The vehicle the customer is booking (set from the ?vid= query string)
        private int VehicleID
        {
            get { return ViewState["VehicleID"] as int? ?? 0; }
            set { ViewState["VehicleID"] = value; }
        }
        // Display name of the vehicle — shown in the booking summary
        private string VehicleName
        {
            get { return ViewState["VehicleName"] as string ?? ""; }
            set { ViewState["VehicleName"] = value; }
        }
        // The vehicle's daily hire rate in GBP — used to calculate the total cost
        private decimal DailyRate
        {
            get { return ViewState["DailyRate"] as decimal? ?? 0m; }
            set { ViewState["DailyRate"] = value; }
        }
        // Step-1 data stored for use in steps 2 & 3
        private DateTime PickupDT
        {
            get { return ViewState["PickupDT"] as DateTime? ?? DateTime.MinValue; }
            set { ViewState["PickupDT"] = value; }
        }
        private DateTime DropoffDT
        {
            get { return ViewState["DropoffDT"] as DateTime? ?? DateTime.MinValue; }
            set { ViewState["DropoffDT"] = value; }
        }
        private string PickupLocation
        {
            get { return ViewState["PickupLoc"] as string ?? ""; }
            set { ViewState["PickupLoc"] = value; }
        }
        private string DropoffLocation
        {
            get { return ViewState["DropoffLoc"] as string ?? ""; }
            set { ViewState["DropoffLoc"] = value; }
        }
        private int TripTypeID
        {
            get { return ViewState["TripTypeID"] as int? ?? 0; }
            set { ViewState["TripTypeID"] = value; }
        }
        private string TripTypeName
        {
            get { return ViewState["TripTypeName"] as string ?? ""; }
            set { ViewState["TripTypeName"] = value; }
        }
        private string Notes
        {
            get { return ViewState["Notes"] as string ?? ""; }
            set { ViewState["Notes"] = value; }
        }
        // Step-2 (insurance) data stored for step 3
        private string InsuranceName
        {
            get { return ViewState["InsuranceName"] as string ?? "Basic (Third-Party)"; }
            set { ViewState["InsuranceName"] = value; }
        }
        private decimal InsurancePerDay
        {
            get { return ViewState["InsurancePerDay"] as decimal? ?? 0m; }
            set { ViewState["InsurancePerDay"] = value; }
        }
        // Step-3 (add-ons) data stored for step 4
        private string SelectedAddons
        {
            get { return ViewState["SelectedAddons"] as string ?? ""; }
            set { ViewState["SelectedAddons"] = value; }
        }
        private decimal AddonsCostPerDay
        {
            get { return ViewState["AddonsCostPerDay"] as decimal? ?? 0m; }
            set { ViewState["AddonsCostPerDay"] = value; }
        }
        // Selected driver (0 = auto-assign)
        private int DriverID
        {
            get { return ViewState["DriverID"] as int? ?? 0; }
            set { ViewState["DriverID"] = value; }
        }

        // ── Page_Load ──────────────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["CustomerLoggedIn"] == null || !(bool)Session["CustomerLoggedIn"])
            {
                // Store the vehicle ID so after login we redirect back to booking, not the dashboard
                string vidStr = Request.QueryString["vid"];
                string returnUrl = string.IsNullOrEmpty(vidStr) ? "BrowseFleet.aspx"
                                   : "BookTrip.aspx?vid=" + HttpUtility.UrlEncode(vidStr);
                // Redirect to Default.aspx (customer login modal), not the staff Login.aspx
                Session["LoginReturnUrl"] = returnUrl;
                Response.Redirect("Default.aspx?openlogin=1");
                return;
            }

            int vehicleID;
            if (!int.TryParse(Request.QueryString["vid"], out vehicleID) || vehicleID <= 0)
            {
                Response.Redirect("BrowseFleet.aspx");
                return;
            }

            if (!IsPostBack)
            {
                VehicleID = vehicleID;
                LoadVehicle();
                LoadTripTypes();
                LoadDrivers();
                PopulateExpiryYears();
                PreFillFromSession();
                SetStep(1);
            }
        }

        // ── Data loading ───────────────────────────────────────────────────────
        private void LoadVehicle()
        {
            var mgr = new VehicleManager();
            Vehicle v = mgr.FindVehicle(VehicleID);
            if (v == null) { Response.Redirect("BrowseFleet.aspx"); return; }

            VehicleName         = v.Make + " " + v.Model;
            DailyRate           = v.DailyRate;
            litVehicleName.Text = VehicleName;
            litRate.Text        = v.DailyRate.ToString("N2");
            litReg.Text         = v.RegistrationNo;
            imgVehicle.Src      = GetCarImage(v.Make, v.Model);
        }

        private void LoadTripTypes()
        {
            var mgr   = new TripManager();
            var types = mgr.ListTripTypes();
            ddlTripType.Items.Clear();
            ddlTripType.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select trip type --", ""));
            foreach (var t in types)
                ddlTripType.Items.Add(new System.Web.UI.WebControls.ListItem(
                    t.TypeName + " (£" + t.BaseRate.ToString("N2") + "/day)", t.TripTypeID.ToString()));
        }

        private void LoadDrivers()
        {
            try
            {
                var dm = new DriverManager();
                var dt = dm.ListActiveDriversPublic();

                // Script 25 adds Rating/Gender/Specialty — if only Script 24 was run,
                // the SP returns rows without these columns and Eval() would throw.
                if (!dt.Columns.Contains("Rating"))
                {
                    dt.Columns.Add("Rating", typeof(object)).DefaultValue = DBNull.Value;
                    foreach (System.Data.DataRow r in dt.Rows) r["Rating"] = DBNull.Value;
                }
                if (!dt.Columns.Contains("Gender"))
                {
                    dt.Columns.Add("Gender", typeof(object)).DefaultValue = DBNull.Value;
                    foreach (System.Data.DataRow r in dt.Rows) r["Gender"] = DBNull.Value;
                }
                if (!dt.Columns.Contains("Specialty"))
                {
                    dt.Columns.Add("Specialty", typeof(object)).DefaultValue = DBNull.Value;
                    foreach (System.Data.DataRow r in dt.Rows) r["Specialty"] = DBNull.Value;
                }

                rptDrivers.DataSource = dt;
                rptDrivers.DataBind();
            }
            catch { /* silently skip — panel stays hidden if DB unavailable */ }
        }

        // ── Driver card helpers (called from repeater Eval expressions) ────────
        protected string GetDriverInitials(object nameObj)
        {
            string name = nameObj?.ToString() ?? "";
            if (string.IsNullOrWhiteSpace(name)) return "?";
            var parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }

        protected string GetDriverExp(object joinDateObj)
        {
            try
            {
                DateTime join = Convert.ToDateTime(joinDateObj);
                int years = DateTime.Today.Year - join.Year;
                if (join > DateTime.Today.AddYears(-years)) years--;
                if (years < 1) return "New driver";
                return years + (years == 1 ? " yr experience" : " yrs experience");
            }
            catch { return ""; }
        }

        protected string GetDriverBioHtml(object bioObj)
        {
            string bio = bioObj == DBNull.Value ? "" : (bioObj?.ToString() ?? "");
            if (string.IsNullOrWhiteSpace(bio)) return "";
            return "<div class=\"driver-card-bio\">" + HttpUtility.HtmlEncode(bio) + "</div>";
        }

        protected string GetDriverStarsHtml(object ratingObj)
        {
            if (ratingObj == null || ratingObj == DBNull.Value)
                return "<div class=\"driver-stars\" title=\"No ratings yet\"><span class=\"star-empty\">&#9733;</span><span class=\"star-empty\">&#9733;</span><span class=\"star-empty\">&#9733;</span><span class=\"star-empty\">&#9733;</span><span class=\"star-empty\">&#9733;</span><span style=\"font-size:.68rem;color:var(--grey);margin-left:.2rem;\">No ratings</span></div>";

            decimal rating;
            if (!decimal.TryParse(ratingObj.ToString(), out rating)) return "";
            rating = Math.Max(0m, Math.Min(5m, rating));

            var sb = new System.Text.StringBuilder();
            sb.Append("<div class=\"driver-stars\" title=\"" + rating.ToString("N1") + " out of 5\">");
            for (int i = 1; i <= 5; i++)
            {
                if (rating >= i)
                    sb.Append("<span class=\"star-full\">&#9733;</span>");
                else if (rating >= i - 0.5m)
                    sb.Append("<span class=\"star-half\">&#9733;</span>");
                else
                    sb.Append("<span class=\"star-empty\">&#9733;</span>");
            }
            sb.Append("<span class=\"driver-rating-num\">" + rating.ToString("N1") + "</span>");
            sb.Append("</div>");
            return sb.ToString();
        }

        protected string GetGenderBadgeHtml(object genderObj)
        {
            if (genderObj == null || genderObj == DBNull.Value) return "";
            string g = genderObj.ToString().Trim().ToUpper();
            switch (g)
            {
                case "M": return "<span class=\"driver-gender-badge gender-m\">&#9794; Male</span>";
                case "F": return "<span class=\"driver-gender-badge gender-f\">&#9792; Female</span>";
                case "X": return "<span class=\"driver-gender-badge gender-x\">&#9954; Non-binary</span>";
                default:  return "";
            }
        }

        protected string GetSpecialtyHtml(object specialtyObj)
        {
            if (specialtyObj == null || specialtyObj == DBNull.Value) return "";
            string s = specialtyObj.ToString().Trim();
            if (string.IsNullOrEmpty(s)) return "";
            return "<span class=\"driver-specialty\">" + HttpUtility.HtmlEncode(s) + "</span>";
        }

        // Pre-fills step-1 fields when the customer came via the hero booking form
        private void PreFillFromSession()
        {
            try
            {
                string pickup     = Session["PreBookPickup"]     as string;
                string dropoff    = Session["PreBookDropoff"]    as string;
                string pickupDate = Session["PreBookPickupDate"] as string;
                string dropDate   = Session["PreBookDropDate"]   as string;
                string tripTypeID = Session["PreBookTripTypeID"] as string;

                if (!string.IsNullOrEmpty(pickup))     txtPickupLocation.Text  = pickup;
                if (!string.IsNullOrEmpty(dropoff))    txtDropoffLocation.Text = dropoff;
                if (!string.IsNullOrEmpty(pickupDate)) txtPickupDate.Text      = pickupDate;
                if (!string.IsNullOrEmpty(dropDate))   txtDropoffDate.Text     = dropDate;
                if (!string.IsNullOrEmpty(tripTypeID))
                {
                    var item = ddlTripType.Items.FindByValue(tripTypeID);
                    if (item != null) item.Selected = true;
                }

                // Clear pre-book session keys so they don't persist across future visits
                Session.Remove("PreBookPickup");
                Session.Remove("PreBookDropoff");
                Session.Remove("PreBookPickupDate");
                Session.Remove("PreBookDropDate");
                Session.Remove("PreBookTripTypeID");
            }
            catch { }
        }

        private void PopulateExpiryYears()
        {
            ddlExpiryYear.Items.Clear();
            ddlExpiryYear.Items.Add(new System.Web.UI.WebControls.ListItem("Year", ""));
            int currentYear = DateTime.Now.Year;
            for (int y = currentYear; y <= currentYear + 10; y++)
                ddlExpiryYear.Items.Add(new System.Web.UI.WebControls.ListItem(y.ToString(), y.ToString()));
        }

        // ── Step control ───────────────────────────────────────────────────────
        private void SetStep(int step)
        {
            pnlStep1.Visible = (step == 1);
            pnlStep2.Visible = (step == 2);
            pnlStep3.Visible = (step == 3);
            pnlStep4.Visible = (step == 4);

            progressStep1.Attributes["class"] = step == 1 ? "progress-step active"
                                              : step > 1  ? "progress-step done"
                                                           : "progress-step";
            progressStep2.Attributes["class"] = step == 2 ? "progress-step active"
                                              : step > 2  ? "progress-step done"
                                                           : "progress-step";
            progressStep3.Attributes["class"] = step == 3 ? "progress-step active"
                                              : step > 3  ? "progress-step done"
                                                           : "progress-step";
            progressStep4.Attributes["class"] = step == 4 ? "progress-step active" : "progress-step";
        }

        // ── Step 1 → Step 2 (Insurance) ───────────────────────────────────────
        protected void btnContinue_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;

            // --- Required field checks ---
            if (string.IsNullOrWhiteSpace(ddlTripType.SelectedValue))
                { ShowError("Please select a trip type."); SetStep(1); return; }
            if (string.IsNullOrWhiteSpace(txtPickupLocation.Text))
                { ShowError("Pickup location is required."); SetStep(1); return; }
            if (string.IsNullOrWhiteSpace(txtPickupDate.Text))
                { ShowError("Pickup date is required."); SetStep(1); return; }
            if (string.IsNullOrWhiteSpace(txtPickupTime.Text))
                { ShowError("Pickup time is required."); SetStep(1); return; }
            if (string.IsNullOrWhiteSpace(txtDropoffLocation.Text))
                { ShowError("Drop-off location is required."); SetStep(1); return; }
            if (string.IsNullOrWhiteSpace(txtDropoffDate.Text))
                { ShowError("Drop-off date is required."); SetStep(1); return; }
            if (string.IsNullOrWhiteSpace(txtDropoffTime.Text))
                { ShowError("Drop-off time is required."); SetStep(1); return; }

            // --- Date/time parsing ---
            DateTime pickupDT, dropoffDT;
            if (!DateTime.TryParse(txtPickupDate.Text + " " + txtPickupTime.Text, out pickupDT))
                { ShowError("Invalid pickup date or time. Please check your entries."); SetStep(1); return; }
            if (!DateTime.TryParse(txtDropoffDate.Text + " " + txtDropoffTime.Text, out dropoffDT))
                { ShowError("Invalid drop-off date or time. Please check your entries."); SetStep(1); return; }

            // --- Business rules ---
            if (pickupDT < DateTime.Now.AddMinutes(-5))
                { ShowError("Pickup date and time cannot be in the past."); SetStep(1); return; }
            if (dropoffDT <= pickupDT)
                { ShowError("Drop-off must be after pickup date and time."); SetStep(1); return; }
            if ((dropoffDT - pickupDT).TotalHours < 1)
                { ShowError("Minimum booking duration is 1 hour."); SetStep(1); return; }
            if ((dropoffDT - pickupDT).TotalDays > 365)
                { ShowError("Maximum booking duration is 365 days."); SetStep(1); return; }

            // --- Store step-1 data in ViewState ---
            PickupDT        = pickupDT;
            DropoffDT       = dropoffDT;
            PickupLocation  = txtPickupLocation.Text.Trim();
            DropoffLocation = txtDropoffLocation.Text.Trim();
            TripTypeID      = Convert.ToInt32(ddlTripType.SelectedValue);
            TripTypeName    = ddlTripType.SelectedItem.Text;
            Notes           = txtNotes.Text.Trim();

            int selectedDriverID;
            DriverID = int.TryParse(hdnDriverID.Value, out selectedDriverID) && selectedDriverID > 0
                       ? selectedDriverID : 0;

            // Default insurance selection to Basic (free)
            hdnInsurance.Value = "basic:0";

            SetStep(2);
        }

        // ── Back from Insurance to Step 1 ──────────────────────────────────────
        protected void btnBackInsurance_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;
            SetStep(1);
        }

        // ── Step 2 (Insurance) → Step 3 (Add-Ons) ────────────────────────────
        protected void btnNextInsurance_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;

            // Parse insurance choice from hidden field: "code:perDay"
            string insValue = hdnInsurance.Value ?? "basic:0";
            string[] insParts = insValue.Split(':');
            string insCode = insParts.Length > 0 ? insParts[0] : "basic";
            decimal insPerDay = 0;
            if (insParts.Length > 1) decimal.TryParse(insParts[1], out insPerDay);

            // Map code → display name
            string insDisplayName;
            switch (insCode)
            {
                case "standard": insDisplayName = "Standard — Damage & Theft (+£" + insPerDay.ToString("N2") + "/day)"; break;
                case "premium":  insDisplayName = "Premium — Full Comprehensive (+£" + insPerDay.ToString("N2") + "/day)"; break;
                case "elite":    insDisplayName = "Elite — Ultimate Protection (+£" + insPerDay.ToString("N2") + "/day)"; break;
                default:         insDisplayName = "Basic — Third-Party (FREE)"; break;
            }

            InsuranceName   = insDisplayName;
            InsurancePerDay = insPerDay;

            SetStep(3);
        }

        // ── Back from Add-Ons to Insurance ────────────────────────────────────
        protected void btnBackAddons_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;
            SetStep(2);
        }

        // ── Step 3 (Add-Ons) → Step 4 (Payment) ───────────────────────────────
        protected void btnNextAddons_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;

            // Build addon list and total cost per day
            decimal addonsPerDay = 0m;
            var selectedKeys = new System.Collections.Generic.List<string>();

            if (chkGPS.Checked)          { addonsPerDay += 5m;  selectedKeys.Add("GPS Navigation (+£5/day)");         }
            if (chkMobileMount.Checked)  { addonsPerDay += 3m;  selectedKeys.Add("Mobile Mount & Charger (+£3/day)"); }
            if (chkBabySeat.Checked)     { addonsPerDay += 8m;  selectedKeys.Add("Baby/Child Seat (+£8/day)");        }
            if (chkBoosterSeat.Checked)  { addonsPerDay += 5m;  selectedKeys.Add("Booster Seat (+£5/day)");           }
            if (chkCycleCarrier.Checked) { addonsPerDay += 10m; selectedKeys.Add("Cycle Carrier (+£10/day)");         }
            if (chkRoofBox.Checked)      { addonsPerDay += 12m; selectedKeys.Add("Roof Box (+£12/day)");              }
            if (chkWifiHotspot.Checked)  { addonsPerDay += 6m;  selectedKeys.Add("4G WiFi Hotspot (+£6/day)");        }
            if (chkDashcam.Checked)      { addonsPerDay += 4m;  selectedKeys.Add("Dashcam (+£4/day)");                }

            AddonsCostPerDay = addonsPerDay;
            SelectedAddons   = string.Join(", ", selectedKeys);

            int days          = Math.Max(1, (int)Math.Ceiling((DropoffDT - PickupDT).TotalDays));
            decimal vehicleCost   = days * DailyRate;
            decimal insuranceCost = days * InsurancePerDay;
            decimal addonsCost    = days * addonsPerDay;
            decimal total         = vehicleCost + insuranceCost + addonsCost;

            litSummaryVehicle.Text   = HttpUtility.HtmlEncode(VehicleName)
                + " — £" + DailyRate.ToString("N2") + "/day &times; " + days + " = £" + vehicleCost.ToString("N2");
            litSummaryPickup.Text    = HttpUtility.HtmlEncode(PickupDT.ToString("ddd dd MMM yyyy, HH:mm"))
                                       + " — " + HttpUtility.HtmlEncode(PickupLocation);
            litSummaryDropoff.Text   = HttpUtility.HtmlEncode(DropoffDT.ToString("ddd dd MMM yyyy, HH:mm"))
                                       + " — " + HttpUtility.HtmlEncode(DropoffLocation);
            litSummaryTripType.Text  = HttpUtility.HtmlEncode(TripTypeName);
            litSummaryDays.Text      = days + (days == 1 ? " day" : " days");
            litSummaryInsurance.Text = HttpUtility.HtmlEncode(InsuranceName)
                + (InsurancePerDay > 0 ? " — £" + insuranceCost.ToString("N2") : "");

            // Build add-ons HTML
            if (selectedKeys.Count == 0)
            {
                litSummaryAddons.Text = "<div class='summary-row'><span class='lbl'>Add-Ons</span>"
                    + "<span class='val' style='color:var(--grey);font-size:.82rem;'>None selected</span></div>";
            }
            else
            {
                var sb = new System.Text.StringBuilder();
                sb.Append("<div style='border-top:1px solid rgba(255,255,255,.06);margin:.4rem 0;padding-top:.4rem;'>"
                    + "<div style='font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.09em;color:var(--teal-light);margin-bottom:.3rem;'>Add-Ons</div>");
                if (chkGPS.Checked)          sb.Append(AddonRow("GPS Navigation",         5m,  days));
                if (chkMobileMount.Checked)  sb.Append(AddonRow("Mobile Mount & Charger", 3m,  days));
                if (chkBabySeat.Checked)     sb.Append(AddonRow("Baby/Child Seat",         8m,  days));
                if (chkBoosterSeat.Checked)  sb.Append(AddonRow("Booster Seat",            5m,  days));
                if (chkCycleCarrier.Checked) sb.Append(AddonRow("Cycle Carrier",           10m, days));
                if (chkRoofBox.Checked)      sb.Append(AddonRow("Roof Box",                12m, days));
                if (chkWifiHotspot.Checked)  sb.Append(AddonRow("4G WiFi Hotspot",         6m,  days));
                if (chkDashcam.Checked)      sb.Append(AddonRow("Dashcam",                 4m,  days));
                sb.Append("</div>");
                litSummaryAddons.Text = sb.ToString();
            }

            litSummaryTotal.Text = "£" + total.ToString("N2");

            SetStep(4);
        }

        private string AddonRow(string name, decimal perDay, int days)
        {
            return "<div class='summary-row'><span class='lbl'>" + HttpUtility.HtmlEncode(name) + "</span>"
                 + "<span class='val'>£" + perDay.ToString("N2") + "/day &times; " + days
                 + " = £" + (perDay * days).ToString("N2") + "</span></div>";
        }

        // ── Back from Payment to Add-Ons ───────────────────────────────────────
        protected void btnBack_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;
            SetStep(3);
        }

        // ── Step 4 → Complete booking ──────────────────────────────────────────
        protected void btnPay_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;

            // --- Payment field validation ---
            string cardName = txtCardName.Text.Trim();
            if (string.IsNullOrWhiteSpace(cardName))
                { ShowError("Cardholder name is required."); SetStep(4); return; }
            if (cardName.Length < 3)
                { ShowError("Cardholder name must be at least 3 characters."); SetStep(4); return; }
            if (!cardName.Contains(" "))
                { ShowError("Please enter both your first and last name on the card."); SetStep(4); return; }
            if (Regex.IsMatch(cardName, @"\d"))
                { ShowError("Cardholder name must not contain numbers."); SetStep(4); return; }

            string rawCard = txtCardNumber.Text.Replace(" ", "").Replace("-", "");
            if (string.IsNullOrWhiteSpace(rawCard) || rawCard.Length != 16 || !Regex.IsMatch(rawCard, @"^\d{16}$"))
                { ShowError("Please enter a valid 16-digit card number."); SetStep(4); return; }
            // Reject trivially invalid numbers — all identical digits (e.g. 1111111111111111, 0000000000000000)
            if (Regex.IsMatch(rawCard, @"^(\d)\1{15}$"))
                { ShowError("Please enter a real card number."); SetStep(4); return; }

            if (string.IsNullOrWhiteSpace(ddlExpiryMonth.SelectedValue))
                { ShowError("Please select your card's expiry month."); SetStep(4); return; }
            if (string.IsNullOrWhiteSpace(ddlExpiryYear.SelectedValue))
                { ShowError("Please select your card's expiry year."); SetStep(4); return; }

            int expMonth = int.Parse(ddlExpiryMonth.SelectedValue);
            int expYear  = int.Parse(ddlExpiryYear.SelectedValue);
            var expiry   = new DateTime(expYear, expMonth, 1).AddMonths(1).AddDays(-1);
            if (expiry < DateTime.Today)
                { ShowError("Your card has expired. Please use a valid card."); SetStep(4); return; }

            string cvv = txtCVV.Text.Trim();
            if (string.IsNullOrWhiteSpace(cvv) || !Regex.IsMatch(cvv, @"^\d{3,4}$"))
                { ShowError("CVV must be 3 or 4 digits."); SetStep(4); return; }

            if (!chkTerms.Checked)
                { ShowError("You must accept the Terms & Conditions to complete your booking."); SetStep(4); return; }
            if (!chkDataConsent.Checked)
                { ShowError("GDPR data processing consent is required to complete your booking."); SetStep(4); return; }

            // --- Availability guard: check vehicle isn't already booked for these dates ---
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spCheckVehicleAvailability", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@VehicleID",   VehicleID);
                    cmd.Parameters.AddWithValue("@PickupDate",  PickupDT);
                    cmd.Parameters.AddWithValue("@DropoffDate", DropoffDT);
                    int conflicts = Convert.ToInt32(cmd.ExecuteScalar());
                    if (conflicts > 0)
                    {
                        ShowError("Sorry — this vehicle has just been booked for your selected dates by another customer. Please go back to step 1 and choose different dates, or return to fleet and select another vehicle.");
                        SetStep(1);
                        return;
                    }
                }
            }
            catch { /* SP not yet run — skip check so booking still works */ }

            // --- Perform booking ---
            int customerID = Convert.ToInt32(Session["CustomerID"]);
            string customerEmail = Session["CustomerEmail"] as string ?? "";

            // Assign driver for non-self-drive trip types.
            // If the customer picked a specific driver in step 1 use that; otherwise auto-assign.
            object driverParam = DBNull.Value;
            bool needsDriver = !TripTypeName.ToLower().Contains("self-drive") && !TripTypeName.ToLower().Contains("self drive");
            if (needsDriver)
            {
                if (DriverID > 0)
                {
                    driverParam = DriverID;
                }
                else
                {
                    try
                    {
                        using (SqlConnection dConn = DatabaseHelper.GetConnection())
                        using (SqlCommand dCmd = new SqlCommand("spAutoAssignDriver", dConn))
                        {
                            dCmd.CommandType = CommandType.StoredProcedure;
                            SqlParameter dOut = new SqlParameter("@AssignedDriverID", System.Data.SqlDbType.Int)
                                                { Direction = System.Data.ParameterDirection.Output };
                            dCmd.Parameters.Add(dOut);
                            dCmd.ExecuteNonQuery();
                            if (dOut.Value != DBNull.Value)
                                driverParam = Convert.ToInt32(dOut.Value);
                        }
                    }
                    catch { /* If no drivers available, proceed without one */ }
                }
            }

            try
            {
                int tripID;
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand("spAddTrip", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CustomerId",  customerID);
                    cmd.Parameters.AddWithValue("@VehicleID",   VehicleID);
                    cmd.Parameters.AddWithValue("@DriverID",    driverParam);
                    cmd.Parameters.AddWithValue("@TripTypeID",  TripTypeID);
                    cmd.Parameters.AddWithValue("@TripDate",    PickupDT.Date);
                    SqlParameter outTrip = new SqlParameter("@NewTripID", System.Data.SqlDbType.Int)
                                          { Direction = System.Data.ParameterDirection.Output };
                    cmd.Parameters.Add(outTrip);
                    cmd.ExecuteNonQuery();
                    tripID = Convert.ToInt32(outTrip.Value);
                }

                // Extract insurance code from the stored "code:price" format
                string insCode = "Basic";
                string insVal  = hdnInsurance.Value ?? "basic:0";
                string[] insParts = insVal.Split(':');
                if (insParts.Length > 0)
                {
                    string c = insParts[0];
                    if      (c == "standard") insCode = "Standard";
                    else if (c == "premium")  insCode = "Premium";
                    else if (c == "elite")    insCode = "Elite";
                    else                      insCode = "Basic";
                }

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    // Use spAddCustomerTripFull (Script 31) — includes insurance and addons.
                    // Falls back to spAddCustomerTrip if the new SP is not yet deployed.
                    SqlCommand cmd2;
                    try
                    {
                        cmd2 = new SqlCommand("spAddCustomerTripFull", conn);
                        cmd2.CommandType = CommandType.StoredProcedure;
                        cmd2.Parameters.AddWithValue("@TripID",          tripID);
                        cmd2.Parameters.AddWithValue("@CustomerID",      customerID);
                        cmd2.Parameters.AddWithValue("@PickupLocation",  PickupLocation);
                        cmd2.Parameters.AddWithValue("@PickupDate",      PickupDT);
                        cmd2.Parameters.AddWithValue("@DropoffLocation", DropoffLocation);
                        cmd2.Parameters.AddWithValue("@DropoffDate",     DropoffDT);
                        cmd2.Parameters.AddWithValue("@Notes",
                            string.IsNullOrWhiteSpace(Notes) ? (object)DBNull.Value : Notes);
                        cmd2.Parameters.AddWithValue("@InsuranceTier",   insCode);
                        cmd2.Parameters.AddWithValue("@Addons",
                            string.IsNullOrWhiteSpace(SelectedAddons) ? (object)DBNull.Value : SelectedAddons);
                        SqlParameter outCT = new SqlParameter("@NewID", System.Data.SqlDbType.Int)
                                             { Direction = System.Data.ParameterDirection.Output };
                        cmd2.Parameters.Add(outCT);
                        cmd2.ExecuteNonQuery();
                    }
                    catch
                    {
                        // spAddCustomerTripFull not yet deployed — fall back to original SP
                        cmd2 = new SqlCommand("spAddCustomerTrip", conn);
                        cmd2.CommandType = CommandType.StoredProcedure;
                        cmd2.Parameters.AddWithValue("@TripID",          tripID);
                        cmd2.Parameters.AddWithValue("@CustomerID",      customerID);
                        cmd2.Parameters.AddWithValue("@PickupLocation",  PickupLocation);
                        cmd2.Parameters.AddWithValue("@PickupDate",      PickupDT);
                        cmd2.Parameters.AddWithValue("@DropoffLocation", DropoffLocation);
                        cmd2.Parameters.AddWithValue("@DropoffDate",     DropoffDT);
                        cmd2.Parameters.AddWithValue("@Notes",
                            string.IsNullOrWhiteSpace(Notes) ? (object)DBNull.Value : Notes);
                        SqlParameter outCT = new SqlParameter("@NewID", System.Data.SqlDbType.Int)
                                             { Direction = System.Data.ParameterDirection.Output };
                        cmd2.Parameters.Add(outCT);
                        cmd2.ExecuteNonQuery();
                    }
                }

                // Generate booking reference and store in session
                int days = Math.Max(1, (int)Math.Ceiling((DropoffDT - PickupDT).TotalDays));
                decimal total = days * DailyRate + days * InsurancePerDay + days * AddonsCostPerDay;
                string bookingRef = "DNW-" + DateTime.Now.ToString("yyMMdd") + "-" + tripID.ToString("D4");

                Session["BookingRef"]        = bookingRef;
                Session["BookingVehicle"]    = VehicleName;
                Session["BookingPickup"]     = PickupDT.ToString("ddd dd MMM yyyy, HH:mm") + " — " + PickupLocation;
                Session["BookingDropoff"]    = DropoffDT.ToString("ddd dd MMM yyyy, HH:mm") + " — " + DropoffLocation;
                Session["BookingInsurance"]  = InsuranceName;
                Session["BookingAddons"]     = SelectedAddons;
                Session["BookingTotal"]      = litSummaryTotal.Text;
                Session["BookingDays"]       = days.ToString();
                Session["BookingTripType"]   = TripTypeName;
                Session["BookingNeedsDriver"]= needsDriver ? "1" : "0";
                Session["FlashMessage"]      = "booking_confirmed:" + VehicleName;

                TrySendConfirmationEmail(bookingRef, customerEmail);
                Response.Redirect("BookingConfirmed.aspx");
            }
            catch
            {
                ShowError("Your booking could not be completed at this time. Please try again. If the problem persists, contact us.");
                SetStep(4);
            }
        }

        private void TrySendConfirmationEmail(string bookingRef, string toEmail)
        {
            if (string.IsNullOrWhiteSpace(toEmail)) return;
            try
            {
                string body = "<html><body style='font-family:Arial,sans-serif;background:#0D1520;color:#fff;padding:2rem;'>"
                    + "<h2 style='color:#14B8A6;'>DriveNow — Booking Confirmed!</h2>"
                    + "<p>Thank you for booking with DriveNow. Your booking reference is:</p>"
                    + "<h1 style='color:#14B8A6;letter-spacing:.08em;'>" + HttpUtility.HtmlEncode(bookingRef) + "</h1>"
                    + "<p><strong>Vehicle:</strong> " + HttpUtility.HtmlEncode(VehicleName) + "</p>"
                    + "<p><strong>Pickup:</strong> " + HttpUtility.HtmlEncode(PickupDT.ToString("ddd dd MMM yyyy, HH:mm")) + " — " + HttpUtility.HtmlEncode(PickupLocation) + "</p>"
                    + "<p><strong>Drop-off:</strong> " + HttpUtility.HtmlEncode(DropoffDT.ToString("ddd dd MMM yyyy, HH:mm")) + " — " + HttpUtility.HtmlEncode(DropoffLocation) + "</p>"
                    + "<p><strong>Insurance:</strong> " + HttpUtility.HtmlEncode(InsuranceName) + "</p>"
                    + "<p><strong>Add-Ons:</strong> " + HttpUtility.HtmlEncode(string.IsNullOrEmpty(SelectedAddons) ? "None" : SelectedAddons) + "</p>"
                    + "<p><strong>Total:</strong> " + HttpUtility.HtmlEncode(litSummaryTotal.Text) + "</p>"
                    + "<hr style='border-color:#1A2332;'/>"
                    + "<p style='font-size:.85rem;color:#94A3B8;'>Please bring your booking reference and a valid photo ID to the DriveNow desk at your pickup location.</p>"
                    + "</body></html>";

                using (var msg = new System.Net.Mail.MailMessage())
                {
                    msg.From = new System.Net.Mail.MailAddress("noreply@drivenow.example.com", "DriveNow");
                    msg.To.Add(toEmail);
                    msg.Subject   = "DriveNow Booking Confirmed — " + bookingRef;
                    msg.Body      = body;
                    msg.IsBodyHtml = true;
                    using (var smtp = new System.Net.Mail.SmtpClient())
                    {
                        smtp.Send(msg);
                    }
                }
            }
            catch
            {
                // Never crash the page if email fails
            }
        }

        // ── Helpers ────────────────────────────────────────────────────────────
        private void ShowError(string msg)
        {
            litError.Text    = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
        }

        private string GetCarImage(string make, string model)
        {
            return CarImages.GetUrl(make, model);
        }
    }
}
