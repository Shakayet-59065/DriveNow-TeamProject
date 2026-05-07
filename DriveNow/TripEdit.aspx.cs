using System;
using System.Web.UI.WebControls;

// DriveNow — Edit Trip Code-Behind
// Loads an existing trip by ID and saves updated values
// Module: CTEC2713N | Developer: Musanna

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
                LoadTripTypes();
                LoadTrip();
            }
        }

        /// <summary>
        /// Populates the Trip Type dropdown from tblTripType
        /// </summary>
        private void LoadTripTypes()
        {
            try
            {
                ddlTripType.DataSource = manager.ListTripTypes();
                ddlTripType.DataTextField = "TypeName";
                ddlTripType.DataValueField = "TripTypeID";
                ddlTripType.DataBind();
            }
            catch (Exception ex)
            {
                lblError.Text = "Error loading trip types: " + ex.Message;
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Loads the trip record by ID from the query string
        /// Pre-fills form fields with existing values
        /// </summary>
        private void LoadTrip()
        {
            if (Request.QueryString["id"] == null)
            {
                Response.Redirect("TripList.aspx");
                return;
            }

            int id = int.Parse(Request.QueryString["id"]);
            Trip trip = manager.FindTrip(id);

            if (trip == null)
            {
                lblError.Text = "Trip not found.";
                lblError.Visible = true;
                return;
            }

            // Pre-fill form with existing values
            hdnTripID.Value = trip.TripID.ToString();
            txtCustomerId.Text = trip.CustomerId.ToString();
            txtVehicleID.Text = trip.VehicleID.ToString();
            txtDriverID.Text = trip.DriverID.HasValue ? trip.DriverID.Value.ToString() : "";
            txtTripDate.Text = trip.TripDate.ToString("dd/MM/yyyy");

            // Set the current trip type as selected in the dropdown
            ListItem item = ddlTripType.Items.FindByValue(trip.TripTypeID.ToString());
            if (item != null) item.Selected = true;
        }

        /// <summary>
        /// Save button — validates updated values and saves to database
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            Trip trip = new Trip();
            trip.TripID = int.Parse(hdnTripID.Value);

            int CustomerId;
            if (!int.TryParse(txtCustomerId.Text.Trim(), out CustomerId) || CustomerId <= 0)
            {
                lblError.Text = "Please enter a valid Customer ID.";
                lblError.Visible = true;
                return;
            }
            trip.CustomerId = CustomerId;

            int vehicleID;
            if (!int.TryParse(txtVehicleID.Text.Trim(), out vehicleID) || vehicleID <= 0)
            {
                lblError.Text = "Please enter a valid Vehicle ID.";
                lblError.Visible = true;
                return;
            }
            trip.VehicleID = vehicleID;

            // DriverID optional — null is valid for self-drive
            if (!string.IsNullOrWhiteSpace(txtDriverID.Text))
            {
                int driverID;
                if (!int.TryParse(txtDriverID.Text.Trim(), out driverID) || driverID <= 0)
                {
                    lblError.Text = "Driver ID must be a valid number or left blank.";
                    lblError.Visible = true;
                    return;
                }
                trip.DriverID = driverID;
            }
            else
            {
                trip.DriverID = null;
            }

            int tripTypeID;
            if (!int.TryParse(ddlTripType.SelectedValue, out tripTypeID) || tripTypeID <= 0)
            {
                lblError.Text = "Please select a Trip Type.";
                lblError.Visible = true;
                return;
            }
            trip.TripTypeID = tripTypeID;

            DateTime tripDate;
            if (!DateTime.TryParseExact(txtTripDate.Text.Trim(), "dd/MM/yyyy",
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out tripDate))
            {
                lblError.Text = "Please enter Trip Date in format dd/MM/yyyy";
                lblError.Visible = true;
                return;
            }
            trip.TripDate = tripDate;

            string error = manager.ValidateTrip(trip);
            if (!string.IsNullOrEmpty(error))
            {
                lblError.Text = error;
                lblError.Visible = true;
                return;
            }

            try
            {
                // Update record via spEditTrip stored procedure
                manager.EditTrip(trip);
                Response.Redirect("TripList.aspx");
            }
            catch (Exception ex)
            {
                lblError.Text = "Error updating trip: " + ex.Message;
                lblError.Visible = true;
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("TripList.aspx");
        }
    }
}
