using System;

// DriveNow — Add Trip Type Code-Behind
// Handles creation of new trip type records in tblTripType
// Validates input before calling the middle layer
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripTypeAdd : System.Web.UI.Page
    {
        // TripManager instance for middle layer calls
        TripManager manager = new TripManager();

        /// <summary>
        /// Page load — check session
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
        }

        /// <summary>
        /// Save button — validates form and adds new trip type
        /// Calls ValidateTripType then AddTripType via TripManager
        /// Redirects to TripTypeList on success
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Build TripType object from form input values
            TripType tripType = new TripType
            {
                TypeName = txtTypeName.Text.Trim(),
                Description = txtDescription.Text.Trim(),
                BaseRate = 0
            };

            // Parse and validate BaseRate as a decimal number
            decimal baseRate;
            if (!decimal.TryParse(txtBaseRate.Text.Trim(), out baseRate))
            {
                lblError.Text = "Base Rate must be a valid number e.g. 5.99";
                lblError.Visible = true;
                return;
            }
            tripType.BaseRate = baseRate;

            // Run validation checks via middle layer ValidateTripType method
            string error = manager.ValidateTripType(tripType);
            if (!string.IsNullOrEmpty(error))
            {
                lblError.Text = error;
                lblError.Visible = true;
                return;
            }

            try
            {
                // Save to database via spAddTripType stored procedure
                manager.AddTripType(tripType);

                // Redirect to list page after successful save
                Response.Redirect("TripTypeList.aspx");
            }
            catch (Exception ex)
            {
                lblError.Text = "Error saving trip type: " + ex.Message;
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Cancel button — returns to trip type list without saving
        /// </summary>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("TripTypeList.aspx");
        }
    }
}
