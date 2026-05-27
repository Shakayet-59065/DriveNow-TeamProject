// DriveNow — Trip Add Code-Behind
// This page lets staff create a new trip booking by selecting a customer, vehicle, driver, and dates.
// After saving, the page redirects back to the Trip List.
// Module: CTEC2713N | Developer: Musanna

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
// TripAdd — books a trip on behalf of a customer including
// core trip (tblTrip) + full booking details (tblCustomerTrip).

namespace DriveNow
{
    public partial class TripAdd : System.Web.UI.Page
    {
        // Creates a TripManager to handle saving the new trip to the database
        TripManager manager = new TripManager();

        // Runs when the page first loads — populates all the dropdown menus
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to login if the user does not have an active staff session
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Only populate the dropdowns on the first load — not after each form submission
            if (!IsPostBack)
            {
                LoadCustomers();   // Fill the "Select Customer" dropdown
                LoadVehicles();    // Fill the "Select Vehicle" dropdown
                LoadTripTypes();   // Fill the "Select Trip Type" dropdown
                LoadDrivers();     // Fill the "Select Driver" dropdown
            }
        }

        // Fills the Customer dropdown with all registered customers from the database
        private void LoadCustomers()
        {
            try
            {
                var dt = new CustomerManager().ListCustomers();
                ddlCustomer.Items.Clear();
                ddlCustomer.Items.Add(new ListItem("-- Select Customer --", "0")); // Default empty option
                foreach (DataRow row in dt.Rows)
                    ddlCustomer.Items.Add(new ListItem(row["FullName"].ToString(), row["CustomerID"].ToString()));
            }
            catch (Exception ex)
            {
                ShowError("Error loading customers: " + ex.Message);
            }
        }

        // Fills the Vehicle dropdown showing make, model, registration, and daily rate for each vehicle
        private void LoadVehicles()
        {
            try
            {
                ddlVehicle.Items.Clear();
                ddlVehicle.Items.Add(new ListItem("-- Select Vehicle --", "0")); // Default empty option
                foreach (Vehicle v in new VehicleManager().ListVehicles())
                {
                    // Display as "Toyota Corolla (AB12CDE) — £45.00/day" so staff can identify the vehicle
                    string label = string.Format("{0} {1} ({2}) — £{3:F2}/day", v.Make, v.Model, v.RegistrationNo, v.DailyRate);
                    ddlVehicle.Items.Add(new ListItem(label, v.VehicleID.ToString()));
                }
            }
            catch (Exception ex)
            {
                ShowError("Error loading vehicles: " + ex.Message);
            }
        }

        // Fills the Trip Type dropdown (e.g. Short Ride, Airport Transfer) from the database
        private void LoadTripTypes()
        {
            try
            {
                ddlTripType.DataSource     = manager.ListTripTypes();
                ddlTripType.DataTextField  = "TypeName";   // What the user sees
                ddlTripType.DataValueField = "TripTypeID"; // What gets saved to the database
                ddlTripType.DataBind();
                ddlTripType.Items.Insert(0, new ListItem("-- Select Trip Type --", "0")); // Add blank option at top
            }
            catch (Exception ex)
            {
                ShowError("Error loading trip types: " + ex.Message);
            }
        }

        // Fills the Driver dropdown — shows rating and specialty if available, or "Self-Drive" option
        private void LoadDrivers()
        {
            try
            {
                var dt = new DriverManager().ListActiveDriversPublic();
                ddlDriver.Items.Clear();
                ddlDriver.Items.Add(new ListItem("Self-Drive (no driver assigned)", "0")); // Optional driver

                // Defensive column guard — Rating/Gender added by script 25 — not in every database version
                bool hasRating    = dt.Columns.Contains("Rating");
                bool hasSpecialty = dt.Columns.Contains("Specialty");

                foreach (DataRow row in dt.Rows)
                {
                    string name  = row["FullName"].ToString();
                    string label = name;

                    // Append rating score to the dropdown label if it exists
                    if (hasRating && row["Rating"] != DBNull.Value)
                    {
                        decimal r = Convert.ToDecimal(row["Rating"]);
                        label += string.Format(" — {0:N1}/5", r);
                    }
                    // Append the driver's specialty (e.g. Airport Transfers) if it exists
                    if (hasSpecialty && row["Specialty"] != DBNull.Value && !string.IsNullOrEmpty(row["Specialty"].ToString()))
                        label += " (" + row["Specialty"] + ")";

                    ddlDriver.Items.Add(new ListItem(label, row["DriverID"].ToString()));
                }
            }
            catch
            {
                // If loading drivers fails, fall back to Self-Drive only so the form still works
                ddlDriver.Items.Clear();
                ddlDriver.Items.Add(new ListItem("Self-Drive (no driver assigned)", "0"));
            }
        }

        // Runs when the admin clicks "Save Trip" — validates all fields and saves to the database
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Clear any previous messages before re-validating
            lblError.Visible   = false;
            lblSuccess.Visible = false;

            // Validate: a customer must be selected (not the blank default)
            int customerID;
            if (!int.TryParse(ddlCustomer.SelectedValue, out customerID) || customerID <= 0)
            { ShowError("Please select a customer."); return; }

            // Validate: a vehicle must be selected
            int vehicleID;
            if (!int.TryParse(ddlVehicle.SelectedValue, out vehicleID) || vehicleID <= 0)
            { ShowError("Please select a vehicle."); return; }

            // Validate: a trip type must be selected
            int tripTypeID;
            if (!int.TryParse(ddlTripType.SelectedValue, out tripTypeID) || tripTypeID <= 0)
            { ShowError("Please select a trip type."); return; }

            // Validate: pickup and drop-off addresses are required text fields
            string pickupLoc  = txtPickupLocation.Text.Trim();
            string dropoffLoc = txtDropoffLocation.Text.Trim();
            if (string.IsNullOrEmpty(pickupLoc))
            { ShowError("Pickup location is required."); return; }
            if (string.IsNullOrEmpty(dropoffLoc))
            { ShowError("Drop-off location is required."); return; }

            // Validate and parse the pickup date — must be in yyyy-MM-dd format from the date picker
            DateTime pickupDate;
            if (!DateTime.TryParseExact(txtPickupDate.Text.Trim(), "yyyy-MM-dd",
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out pickupDate))
            { ShowError("Please select a valid pickup date."); return; }

            // If a pickup time was entered, combine it with the pickup date
            if (!string.IsNullOrEmpty(txtPickupTime.Text.Trim()))
            {
                TimeSpan ts;
                if (TimeSpan.TryParse(txtPickupTime.Text.Trim(), out ts))
                    pickupDate = pickupDate.Date + ts;
            }

            // Drop-off date is required — a vehicle rental must have a return date
            if (string.IsNullOrWhiteSpace(txtDropoffDate.Text))
            { ShowError("Drop-off date is required. Please enter the date the vehicle will be returned."); return; }

            DateTime? dropoffDate = null;
            {
                DateTime dd;
                if (!DateTime.TryParseExact(txtDropoffDate.Text.Trim(), "yyyy-MM-dd",
                    System.Globalization.CultureInfo.InvariantCulture,
                    System.Globalization.DateTimeStyles.None, out dd))
                { ShowError("Drop-off date is not a valid date."); return; }

                // If a drop-off time was entered, add it to the drop-off date
                if (!string.IsNullOrEmpty(txtDropoffTime.Text.Trim()))
                {
                    TimeSpan ts;
                    if (TimeSpan.TryParse(txtDropoffTime.Text.Trim(), out ts))
                        dd = dd.Date + ts;
                }
                if (dd < pickupDate)
                { ShowError("Drop-off date cannot be before the pickup date."); return; }

                dropoffDate = dd;
            }

            // Driver is optional — value 0 means the customer will drive themselves
            int? driverID = null;
            int did;
            if (int.TryParse(ddlDriver.SelectedValue, out did) && did > 0)
                driverID = did;

            // Build the Trip object that will be passed to the database
            var trip = new Trip
            {
                CustomerId = customerID,
                VehicleID  = vehicleID,
                TripTypeID = tripTypeID,
                DriverID   = driverID,
                TripDate   = pickupDate
            };

            // Run business-rule validation before attempting to save
            string validationError = manager.ValidateTrip(trip);
            if (!string.IsNullOrEmpty(validationError))
            { ShowError(validationError); return; }

            // Build add-ons string from checkboxes
            var addonParts = new System.Collections.Generic.List<string>();
            if (chkGPS.Checked)          addonParts.Add("GPS Navigation");
            if (chkMobileMount.Checked)  addonParts.Add("Mobile Mount & Charger");
            if (chkBabySeat.Checked)     addonParts.Add("Baby/Child Seat");
            if (chkBoosterSeat.Checked)  addonParts.Add("Booster Seat");
            if (chkCycleCarrier.Checked) addonParts.Add("Cycle Carrier");
            if (chkRoofBox.Checked)      addonParts.Add("Roof Box");
            if (chkWifiHotspot.Checked)  addonParts.Add("WiFi Hotspot");
            if (chkDashcam.Checked)      addonParts.Add("Dashcam");
            string addonsStr  = string.Join(", ", addonParts);
            string insurance  = hdnInsurance.Value;
            if (string.IsNullOrWhiteSpace(insurance)) insurance = "Basic";

            try
            {
                // Save the core trip record — spAddTrip returns the new TripID
                int newTripID = manager.AddTrip(trip);

                // Save booking details (pickup/dropoff/notes/insurance/addons) to tblCustomerTrip
                if (newTripID > 0 && dropoffDate.HasValue)
                {
                    try
                    {
                        using (SqlConnection conn = DatabaseHelper.GetConnection())
                        using (SqlCommand cmd = new SqlCommand("spAddCustomerTripFull", conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@TripID",          newTripID);
                            cmd.Parameters.AddWithValue("@CustomerID",      customerID);
                            cmd.Parameters.AddWithValue("@PickupLocation",  pickupLoc);
                            cmd.Parameters.AddWithValue("@PickupDate",      pickupDate);
                            cmd.Parameters.AddWithValue("@DropoffLocation", dropoffLoc);
                            cmd.Parameters.AddWithValue("@DropoffDate",     dropoffDate.Value);
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
                    catch { /* Script 31 not yet run — booking details skipped gracefully */ }
                }

                // Redirect back to the trip list after successful save
                Response.Redirect("TripList.aspx");
            }
            catch (Exception ex)
            {
                ShowError("Error saving trip: " + ex.Message);
            }
        }

        // Cancels the add operation and returns to the trip list without saving
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("TripList.aspx");
        }

        // Helper method: shows an error message banner at the top of the form
        private void ShowError(string msg)
        {
            lblError.Text    = msg;
            lblError.Visible = true;
        }
    }
}
