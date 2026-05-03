using System;
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
                LoadTripTypes();
                LoadTrip();
            }
        }

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

            hdnTripID.Value = trip.TripID.ToString();
            txtCustomerID.Text = trip.CustomerID.ToString();
            txtVehicleID.Text = trip.VehicleID.ToString();
            txtDriverID.Text = trip.DriverID.HasValue ? trip.DriverID.Value.ToString() : "";
            txtTripDate.Text = trip.TripDate.ToString("dd/MM/yyyy");

            ListItem item = ddlTripType.Items.FindByValue(trip.TripTypeID.ToString());
            if (item != null) item.Selected = true;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Trip trip = new Trip();
            trip.TripID = int.Parse(hdnTripID.Value);

            int customerID;
            if (!int.TryParse(txtCustomerID.Text.Trim(), out customerID) || customerID <= 0)
            {
                lblError.Text = "Please enter a valid Customer ID.";
                lblError.Visible = true;
                return;
            }
            trip.CustomerID = customerID;

            int vehicleID;
            if (!int.TryParse(txtVehicleID.Text.Trim(), out vehicleID) || vehicleID <= 0)
            {
                lblError.Text = "Please enter a valid Vehicle ID.";
                lblError.Visible = true;
                return;
            }
            trip.VehicleID = vehicleID;

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
                manager.EditTrip(trip);
                // Redirect to list after successful save
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
