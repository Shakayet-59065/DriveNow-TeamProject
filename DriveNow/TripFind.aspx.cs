using System;

namespace DriveNow
{
    public partial class TripFind : System.Web.UI.Page
    {
        TripManager manager = new TripManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
        }

        protected void btnFind_Click(object sender, EventArgs e)
        {
            int tripID;
            if (!int.TryParse(txtTripID.Text.Trim(), out tripID) || tripID <= 0)
            {
                lblError.Text = "Please enter a valid Trip ID.";
                lblError.Visible = true;
                pnlResult.Visible = false;
                return;
            }

            try
            {
                Trip trip = manager.FindTrip(tripID);

                if (trip == null)
                {
                    lblError.Text = "No trip found with ID: " + tripID;
                    lblError.Visible = true;
                    pnlResult.Visible = false;
                    return;
                }

                lblTripID.Text = trip.TripID.ToString();
                lblCustomerID.Text = trip.CustomerID.ToString();
                lblVehicleID.Text = trip.VehicleID.ToString();
                lblDriverID.Text = trip.DriverID.HasValue ? trip.DriverID.Value.ToString() : "None (Self-Drive)";
                lblTypeName.Text = trip.TypeName;
                lblTripDate.Text = trip.TripDate.ToString("dd/MM/yyyy");
                lblStatus.Text = trip.IsActive ? "Active" : "Inactive";

                pnlResult.Visible = true;
                lblError.Visible = false;
            }
            catch (Exception ex)
            {
                lblError.Text = "Error finding trip: " + ex.Message;
                lblError.Visible = true;
            }
        }
    }
}
