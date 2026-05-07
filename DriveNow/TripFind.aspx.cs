using System;

// DriveNow — Find Trip Code-Behind
// Searches for a single trip record by TripID
// Shows full trip details in a result panel
// Module: CTEC2713N | Developer: Musanna

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

        /// <summary>
        /// Find button — searches for a trip by ID and displays the result
        /// Calls spFindTrip via TripManager.FindTrip()
        /// Shows an error if ID is invalid or trip not found
        /// </summary>
        protected void btnFind_Click(object sender, EventArgs e)
        {
            // Validate that the entered ID is a valid positive integer
            int tripID;
            if (!int.TryParse(txtTripID.Text.Trim(), out tripID) || tripID <= 0)
            {
                lblError.Text = "Please enter a valid Trip ID (a positive number).";
                lblError.Visible = true;
                pnlResult.Visible = false;
                return;
            }

            try
            {
                // Search for the trip via spFindTrip stored procedure
                Trip trip = manager.FindTrip(tripID);

                if (trip == null)
                {
                    // Trip not found in the database
                    lblError.Text = "No trip found with ID: " + tripID;
                    lblError.Visible = true;
                    pnlResult.Visible = false;
                    return;
                }

                // Populate result panel with trip details
                lblTripID.Text = "#TRP-00" + trip.TripID.ToString();
                lblUserId.Text = trip.UserId.ToString();
                lblVehicleID.Text = trip.VehicleID.ToString();
                lblDriverID.Text = trip.DriverID.HasValue
                    ? trip.DriverID.Value.ToString()
                    : "None (Self-Drive)";
                lblTypeName.Text = trip.TypeName;
                lblTripDate.Text = trip.TripDate.ToString("dd MMM yyyy");
                lblStatus.Text = trip.IsActive ? "Active" : "Inactive";

                // Show the result panel and hide any previous error
                pnlResult.Visible = true;
                lblError.Visible = false;
            }
            catch (Exception ex)
            {
                lblError.Text = "Error finding trip: " + ex.Message;
                lblError.Visible = true;
                pnlResult.Visible = false;
            }
        }
    }
}
