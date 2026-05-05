using System;

// DriveNow — Edit Trip Type Code-Behind
// Loads an existing trip type by ID and saves updated values
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripTypeEdit : System.Web.UI.Page
    {
        TripManager manager = new TripManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Load existing data only on first page load
            if (!IsPostBack)
                LoadTripType();
        }

        /// <summary>
        /// Loads the trip type record from the database using the ID from the query string
        /// Populates form fields with existing values for editing
        /// </summary>
        private void LoadTripType()
        {
            // Check that an ID was passed in the query string
            if (Request.QueryString["id"] == null)
            {
                Response.Redirect("TripTypeList.aspx");
                return;
            }

            int id = int.Parse(Request.QueryString["id"]);

            // Find the trip type via spFindTripType stored procedure
            TripType tripType = manager.FindTripType(id);

            if (tripType == null)
            {
                lblError.Text = "Trip type not found.";
                lblError.Visible = true;
                return;
            }

            // Populate form fields with existing values
            hdnTripTypeID.Value = tripType.TripTypeID.ToString();
            txtTypeName.Text = tripType.TypeName;
            txtDescription.Text = tripType.Description;
            txtBaseRate.Text = tripType.BaseRate.ToString("F2");
        }

        /// <summary>
        /// Save button — validates updated values and saves to database
        /// Calls ValidateTripType then EditTripType via TripManager
        /// Redirects to TripTypeList on success
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            TripType tripType = new TripType
            {
                TripTypeID = int.Parse(hdnTripTypeID.Value),
                TypeName = txtTypeName.Text.Trim(),
                Description = txtDescription.Text.Trim(),
                BaseRate = 0
            };

            // Parse BaseRate field
            decimal baseRate;
            if (!decimal.TryParse(txtBaseRate.Text.Trim(), out baseRate))
            {
                lblError.Text = "Base Rate must be a valid number e.g. 5.99";
                lblError.Visible = true;
                return;
            }
            tripType.BaseRate = baseRate;

            // Run validation before saving
            string error = manager.ValidateTripType(tripType);
            if (!string.IsNullOrEmpty(error))
            {
                lblError.Text = error;
                lblError.Visible = true;
                return;
            }

            try
            {
                // Update the record via spEditTripType stored procedure
                manager.EditTripType(tripType);

                // Redirect to list after successful update
                Response.Redirect("TripTypeList.aspx");
            }
            catch (Exception ex)
            {
                lblError.Text = "Error updating trip type: " + ex.Message;
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Cancel — returns to list without saving changes
        /// </summary>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("TripTypeList.aspx");
        }
    }
}
