using System;

namespace DriveNow
{
    public partial class TripTypeAdd : System.Web.UI.Page
    {
        TripManager manager = new TripManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Build TripType object from form inputs
            TripType tripType = new TripType
            {
                TypeName = txtTypeName.Text.Trim(),
                Description = txtDescription.Text.Trim(),
                BaseRate = 0
            };

            // Parse BaseRate
            decimal baseRate;
            if (!decimal.TryParse(txtBaseRate.Text.Trim(), out baseRate))
            {
                lblError.Text = "Base Rate must be a valid number e.g. 5.99";
                lblError.Visible = true;
                return;
            }
            tripType.BaseRate = baseRate;

            // Validate before saving
            string error = manager.ValidateTripType(tripType);
            if (!string.IsNullOrEmpty(error))
            {
                lblError.Text = error;
                lblError.Visible = true;
                return;
            }

            try
            {
                int newID = manager.AddTripType(tripType);
                lblSuccess.Text = "Trip type added successfully. ID: " + newID;
                lblSuccess.Visible = true;
                lblError.Visible = false;

                // Clear form
                txtTypeName.Text = "";
                txtDescription.Text = "";
                txtBaseRate.Text = "";
            }
            catch (Exception ex)
            {
                lblError.Text = "Error saving trip type: " + ex.Message;
                lblError.Visible = true;
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("TripTypeList.aspx");
        }
    }
}
