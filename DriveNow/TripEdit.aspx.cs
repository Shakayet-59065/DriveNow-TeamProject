// DriveNow — TripEdit.aspx Code-Behind
// Lets staff edit ALL trip details: core trip, pickup/dropoff, insurance, add-ons.
// Core fields (customer/vehicle/driver/trip type) → tblTrip via spEditTrip.
// Booking details (locations/dates/notes/insurance/addons) → tblCustomerTrip via spEditCustomerTripDetails.
// Module: CTEC2713N | Developer: Musanna

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace DriveNow
{
    public partial class TripEdit : System.Web.UI.Page
    {
        TripManager manager = new TripManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                LoadCustomers();
                LoadVehicles();
                LoadDrivers();
                LoadTripTypes();
                LoadTrip();
            }
        }

        // ── Dropdown loaders ─────────────────────────────────────────────────────

        private void LoadCustomers()
        {
            try
            {
                var dt = new CustomerManager().ListCustomers();
                ddlCustomer.Items.Clear();
                ddlCustomer.Items.Add(new ListItem("-- Select Customer --", "0"));
                foreach (DataRow row in dt.Rows)
                    ddlCustomer.Items.Add(new ListItem(row["FullName"].ToString(), row["CustomerID"].ToString()));
            }
            catch (Exception ex) { ShowError("Error loading customers: " + ex.Message); }
        }

        private void LoadVehicles()
        {
            try
            {
                ddlVehicle.Items.Clear();
                ddlVehicle.Items.Add(new ListItem("-- Select Vehicle --", "0"));
                foreach (Vehicle v in new VehicleManager().ListVehicles())
                    ddlVehicle.Items.Add(new ListItem(
                        string.Format("{0} {1} ({2})", v.Make, v.Model, v.RegistrationNo),
                        v.VehicleID.ToString()));
            }
            catch (Exception ex) { ShowError("Error loading vehicles: " + ex.Message); }
        }

        private void LoadDrivers()
        {
            try
            {
                var dt = new DriverManager().ListActiveDriversPublic();
                ddlDriver.Items.Clear();
                ddlDriver.Items.Add(new ListItem("Self-Drive (no driver)", "0"));

                bool hasRating    = dt.Columns.Contains("Rating");
                bool hasSpecialty = dt.Columns.Contains("Specialty");

                foreach (DataRow row in dt.Rows)
                {
                    string label = row["FullName"].ToString();
                    if (hasRating && row["Rating"] != DBNull.Value)
                        label += string.Format(" — {0:N1}/5", Convert.ToDecimal(row["Rating"]));
                    if (hasSpecialty && row["Specialty"] != DBNull.Value && row["Specialty"].ToString() != "")
                        label += " (" + row["Specialty"] + ")";
                    ddlDriver.Items.Add(new ListItem(label, row["DriverID"].ToString()));
                }
            }
            catch
            {
                ddlDriver.Items.Clear();
                ddlDriver.Items.Add(new ListItem("Self-Drive (no driver)", "0"));
            }
        }

        private void LoadTripTypes()
        {
            try
            {
                ddlTripType.DataSource     = manager.ListTripTypes();
                ddlTripType.DataTextField  = "TypeName";
                ddlTripType.DataValueField = "TripTypeID";
                ddlTripType.DataBind();
            }
            catch (Exception ex) { ShowError("Error loading trip types: " + ex.Message); }
        }

        // ── Load existing trip record ────────────────────────────────────────────

        private void LoadTrip()
        {
            if (Request.QueryString["id"] == null) { Response.Redirect("TripList.aspx"); return; }

            int id = int.Parse(Request.QueryString["id"]);
            Trip trip = manager.FindTrip(id);
            if (trip == null) { ShowError("Trip not found."); return; }

            hdnTripID.Value = trip.TripID.ToString();

            // Pre-select core trip fields
            var custItem = ddlCustomer.Items.FindByValue(trip.CustomerId.ToString());
            if (custItem != null) custItem.Selected = true;

            var vehItem = ddlVehicle.Items.FindByValue(trip.VehicleID.ToString());
            if (vehItem != null) vehItem.Selected = true;

            // Pre-select driver (0 = Self-Drive)
            string driverVal = trip.DriverID.HasValue ? trip.DriverID.Value.ToString() : "0";
            var drvItem = ddlDriver.Items.FindByValue(driverVal);
            if (drvItem != null) drvItem.Selected = true;

            var typeItem = ddlTripType.Items.FindByValue(trip.TripTypeID.ToString());
            if (typeItem != null) typeItem.Selected = true;

            // Load booking details from tblCustomerTrip
            LoadCustomerTripDetails(id);
        }

        private void LoadCustomerTripDetails(int tripID)
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spGetCustomerTripByTripID", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@TripID", tripID);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            hdnCustomerTripID.Value = r["CustomerTripID"].ToString();

                            // Pickup
                            DateTime pickup = r["PickupDate"] == DBNull.Value ? DateTime.Today : (DateTime)r["PickupDate"];
                            txtPickupDate.Text     = pickup.ToString("yyyy-MM-dd");
                            txtPickupTime.Text     = pickup.ToString("HH:mm");
                            txtPickupLocation.Text = r["PickupLocation"] == DBNull.Value ? "" : r["PickupLocation"].ToString();

                            // Drop-off
                            DateTime dropoff = r["DropoffDate"] == DBNull.Value ? DateTime.Today.AddDays(1) : (DateTime)r["DropoffDate"];
                            txtDropoffDate.Text     = dropoff.ToString("yyyy-MM-dd");
                            txtDropoffTime.Text     = dropoff.ToString("HH:mm");
                            txtDropoffLocation.Text = r["DropoffLocation"] == DBNull.Value ? "" : r["DropoffLocation"].ToString();

                            // Notes
                            txtNotes.Text = r["Notes"] == DBNull.Value ? "" : r["Notes"].ToString();

                            // Insurance
                            string ins = r["InsuranceTier"] == DBNull.Value ? "Basic" : r["InsuranceTier"].ToString();
                            hdnInsurance.Value = ins;

                            // Add-ons — stored as comma-separated string
                            string addons = r["Addons"] == DBNull.Value ? "" : r["Addons"].ToString();
                            chkGPS.Checked          = addons.Contains("GPS");
                            chkMobileMount.Checked  = addons.Contains("Mobile");
                            chkBabySeat.Checked     = addons.Contains("Baby");
                            chkBoosterSeat.Checked  = addons.Contains("Booster");
                            chkCycleCarrier.Checked = addons.Contains("Cycle");
                            chkRoofBox.Checked      = addons.Contains("Roof");
                            chkWifiHotspot.Checked  = addons.Contains("WiFi") || addons.Contains("Hotspot");
                            chkDashcam.Checked      = addons.Contains("Dashcam");
                        }
                        // If no CustomerTrip row exists (admin-added trip) the fields stay blank — that's fine
                    }
                }
            }
            catch
            {
                // Script 31 may not have been run yet — gracefully ignore
            }
        }

        // ── Save ──────────────────────────────────────────────────────────────────

        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblError.Visible   = false;
            lblSuccess.Visible = false;

            // ── 1. Validate & build core Trip object ─────────────────────────────
            int customerID;
            if (!int.TryParse(ddlCustomer.SelectedValue, out customerID) || customerID <= 0)
            { ShowError("Please select a customer."); return; }

            int vehicleID;
            if (!int.TryParse(ddlVehicle.SelectedValue, out vehicleID) || vehicleID <= 0)
            { ShowError("Please select a vehicle."); return; }

            int tripTypeID;
            if (!int.TryParse(ddlTripType.SelectedValue, out tripTypeID) || tripTypeID <= 0)
            { ShowError("Please select a Trip Type."); return; }

            // Pickup date is required; use it as TripDate for tblTrip
            if (string.IsNullOrWhiteSpace(txtPickupDate.Text))
            { ShowError("Pickup date is required."); return; }

            DateTime pickupDate;
            if (!DateTime.TryParseExact(txtPickupDate.Text.Trim(), "yyyy-MM-dd",
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out pickupDate))
            { ShowError("Pickup date is not valid."); return; }

            if (!string.IsNullOrWhiteSpace(txtPickupTime.Text))
            {
                TimeSpan ts;
                if (TimeSpan.TryParse(txtPickupTime.Text.Trim(), out ts))
                    pickupDate = pickupDate.Date + ts;
            }

            if (string.IsNullOrWhiteSpace(txtDropoffDate.Text))
            { ShowError("Drop-off date is required."); return; }

            DateTime dropoffDate;
            if (!DateTime.TryParseExact(txtDropoffDate.Text.Trim(), "yyyy-MM-dd",
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out dropoffDate))
            { ShowError("Drop-off date is not valid."); return; }

            if (!string.IsNullOrWhiteSpace(txtDropoffTime.Text))
            {
                TimeSpan ts;
                if (TimeSpan.TryParse(txtDropoffTime.Text.Trim(), out ts))
                    dropoffDate = dropoffDate.Date + ts;
            }

            if (dropoffDate <= pickupDate)
            { ShowError("Drop-off must be after pickup date/time."); return; }

            string pickupLoc  = txtPickupLocation.Text.Trim();
            string dropoffLoc = txtDropoffLocation.Text.Trim();
            if (string.IsNullOrEmpty(pickupLoc))  { ShowError("Pickup location is required."); return; }
            if (string.IsNullOrEmpty(dropoffLoc)) { ShowError("Drop-off location is required."); return; }

            // Optional driver
            int? driverID = null;
            int did;
            if (int.TryParse(ddlDriver.SelectedValue, out did) && did > 0)
                driverID = did;

            var trip = new Trip
            {
                TripID     = int.Parse(hdnTripID.Value),
                CustomerId = customerID,
                VehicleID  = vehicleID,
                DriverID   = driverID,
                TripTypeID = tripTypeID,
                TripDate   = pickupDate.Date   // tblTrip stores date only
            };

            // ── 2. Build add-ons string ──────────────────────────────────────────
            var addonParts = new System.Collections.Generic.List<string>();
            if (chkGPS.Checked)          addonParts.Add("GPS Navigation");
            if (chkMobileMount.Checked)  addonParts.Add("Mobile Mount & Charger");
            if (chkBabySeat.Checked)     addonParts.Add("Baby/Child Seat");
            if (chkBoosterSeat.Checked)  addonParts.Add("Booster Seat");
            if (chkCycleCarrier.Checked) addonParts.Add("Cycle Carrier");
            if (chkRoofBox.Checked)      addonParts.Add("Roof Box");
            if (chkWifiHotspot.Checked)  addonParts.Add("WiFi Hotspot");
            if (chkDashcam.Checked)      addonParts.Add("Dashcam");
            string addonsStr = string.Join(", ", addonParts);

            string insurance = hdnInsurance.Value;
            if (string.IsNullOrWhiteSpace(insurance)) insurance = "Basic";

            // ── 3. Save core trip ────────────────────────────────────────────────
            try { manager.EditTrip(trip); }
            catch (Exception ex) { ShowError("Error saving trip: " + ex.Message); return; }

            // ── 4. Save booking details ──────────────────────────────────────────
            int ctID;
            int.TryParse(hdnCustomerTripID.Value, out ctID);

            if (ctID > 0)
            {
                // CustomerTrip row exists — update it
                try
                {
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand("spEditCustomerTripDetails", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@CustomerTripID",  ctID);
                        cmd.Parameters.AddWithValue("@PickupLocation",  pickupLoc);
                        cmd.Parameters.AddWithValue("@PickupDate",      pickupDate);
                        cmd.Parameters.AddWithValue("@DropoffLocation", dropoffLoc);
                        cmd.Parameters.AddWithValue("@DropoffDate",     dropoffDate);
                        cmd.Parameters.AddWithValue("@Notes",
                            string.IsNullOrWhiteSpace(txtNotes.Text) ? (object)DBNull.Value : txtNotes.Text.Trim());
                        cmd.Parameters.AddWithValue("@InsuranceTier",   insurance);
                        cmd.Parameters.AddWithValue("@Addons",
                            string.IsNullOrWhiteSpace(addonsStr) ? (object)DBNull.Value : addonsStr);
                        cmd.ExecuteNonQuery();
                    }
                }
                catch
                {
                    // Script 31 not yet run — silently continue (core trip already saved)
                }
            }
            else
            {
                // No CustomerTrip row yet — create one so the booking details are stored
                try
                {
                    using (SqlConnection conn = DatabaseHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand("spAddCustomerTripFull", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@TripID",          trip.TripID);
                        cmd.Parameters.AddWithValue("@CustomerID",      trip.CustomerId);
                        cmd.Parameters.AddWithValue("@PickupLocation",  pickupLoc);
                        cmd.Parameters.AddWithValue("@PickupDate",      pickupDate);
                        cmd.Parameters.AddWithValue("@DropoffLocation", dropoffLoc);
                        cmd.Parameters.AddWithValue("@DropoffDate",     dropoffDate);
                        cmd.Parameters.AddWithValue("@Notes",
                            string.IsNullOrWhiteSpace(txtNotes.Text) ? (object)DBNull.Value : txtNotes.Text.Trim());
                        cmd.Parameters.AddWithValue("@InsuranceTier",   insurance);
                        cmd.Parameters.AddWithValue("@Addons",
                            string.IsNullOrWhiteSpace(addonsStr) ? (object)DBNull.Value : addonsStr);
                        SqlParameter outID = new SqlParameter("@NewID", SqlDbType.Int)
                                             { Direction = ParameterDirection.Output };
                        cmd.Parameters.Add(outID);
                        cmd.ExecuteNonQuery();
                    }
                }
                catch { /* SP not yet deployed — skip silently */ }
            }

            string from = Request.QueryString["from"];
            Response.Redirect(from == "dashboard" ? "MainMenu.aspx" : "TripList.aspx");
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            string from = Request.QueryString["from"];
            Response.Redirect(from == "dashboard" ? "MainMenu.aspx" : "TripList.aspx");
        }

        private void ShowError(string msg)
        {
            lblError.Text    = msg;
            lblError.Visible = true;
        }
    }
}
