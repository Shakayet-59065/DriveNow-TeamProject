using System;
using System.Web.UI.WebControls;

// DriveNow — Add Trip Code-Behind
// Handles creation of new trip records in tblTrip
// DriverID is nullable — null is valid for self-drive rentals
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripAdd : System.Web.UI.Page
    {
        TripManager manager = new TripManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Load trip types into dropdown on first page load only
            if (!IsPostBack)
                LoadTripTypes();
        }

        /// <summary>
        /// Populates the Trip Type dropdown from tblTripType
        /// Calls spListTripTypes via TripManager.ListTripTypes()
        /// </summary>
        private void LoadTripTypes()
        {
            try
            {
                ddlTripType.DataSource = manager.ListTripTypes();
                ddlTripType.DataTextField = "TypeName";
                ddlTripType.DataValueField = "TripTypeID";
                ddlTripType.DataBind();

                // Add a default empty selection at the top
                ddlTripType.Items.Insert(0, new ListItem("-- Select Trip Type --", "0"));
            }
            catch (Exception ex)
            {
                lblError.Text = "Error loading trip types: " + ex.Message;
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Save button — validates form data and creates new trip record
        /// Calls ValidateTrip then AddTrip via TripManager
        /// Redirects to TripList on success
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            Trip trip = new Trip();

            // Validate and parse UserId
            int UserId;
            if (!int.TryParse(txtUserId.Text.Trim(), out UserId) || UserId <= 0)
            {
                lblError.Text = "Please enter a valid Customer ID.";
                lblError.Visible = true;
                return;
            }
            trip.UserId = UserId;

            // Validate and parse VehicleID
            int vehicleID;
            if (!int.TryParse(txtVehicleID.Text.Trim(), out vehicleID) || vehicleID <= 0)
            {
                lblError.Text = "Please enter a valid Vehicle ID.";
                lblError.Visible = true;
                return;
            }
            trip.VehicleID = vehicleID;

            // DriverID is optional — null means self-drive rental (no driver needed)
            if (!string.IsNullOrWhiteSpace(txtDriverID.Text))
            {
                int driverID;
                if (!int.TryParse(txtDriverID.Text.Trim(), out driverID) || driverID <= 0)
                {
                    lblError.Text = "Driver ID must be a valid number or left blank for self-drive.";
                    lblError.Visible = true;
                    return;
                }
                trip.DriverID = driverID;
            }
            else
            {
                // Null DriverID is valid — represents a self-drive rental
                trip.DriverID = null;
            }

            // Validate TripTypeID from dropdown selection
            int tripTypeID;
            if (!int.TryParse(ddlTripType.SelectedValue, out tripTypeID) || tripTypeID <= 0)
            {
                lblError.Text = "Please select a Trip Type.";
                lblError.Visible = true;
                return;
            }
            trip.TripTypeID = tripTypeID;

            // Parse TripDate — expected format dd/MM/yyyy
            DateTime tripDate;
            if (!DateTime.TryParseExact(txtTripDate.Text.Trim(), "dd/MM/yyyy",
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out tripDate))
            {
                lblError.Text = "Please enter Trip Date in format dd/MM/yyyy e.g. 01/06/2026";
                lblError.Visible = true;
                return;
            }
            trip.TripDate = tripDate;

            // Run middle layer validation before saving
            string error = manager.ValidateTrip(trip);
            if (!string.IsNullOrEmpty(error))
            {
                lblError.Text = error;
                lblError.Visible = true;
                return;
            }

            try
            {
                // Save to database via spAddTrip stored procedure
                manager.AddTrip(trip);

                // Redirect to list after successful save
                Response.Redirect("TripList.aspx");
            }
            catch (Exception ex)
            {
                lblError.Text = "Error saving trip: " + ex.Message;
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Cancel — returns to trip list without saving
        /// </summary>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("TripList.aspx");
        }
    }
}
