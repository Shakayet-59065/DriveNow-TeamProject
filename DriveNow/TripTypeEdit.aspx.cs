using System;

namespace DriveNow
{
    public partial class TripTypeEdit : System.Web.UI.Page
    {
        TripManager manager = new TripManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
                LoadTripType();
        }

        private void LoadTripType()
        {
            if (Request.QueryString["id"] == null)
            {
                Response.Redirect("TripTypeList.aspx");
                return;
            }

            int id = int.Parse(Request.QueryString["id"]);
            TripType tripType = manager.FindTripType(id);

            if (tripType == null)
            {
                lblError.Text = "Trip type not found.";
                lblError.Visible = true;
                return;
            }

            hdnTripTypeID.Value = tripType.TripTypeID.ToString();
            txtTypeName.Text = tripType.TypeName;
            txtDescription.Text = tripType.Description;
            txtBaseRate.Text = tripType.BaseRate.ToString("F2");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            TripType tripType = new TripType
            {
                TripTypeID = int.Parse(hdnTripTypeID.Value),
                TypeName = txtTypeName.Text.Trim(),
                Description = txtDescription.Text.Trim(),
                BaseRate = 0
            };

            decimal baseRate;
            if (!decimal.TryParse(txtBaseRate.Text.Trim(), out baseRate))
            {
                lblError.Text = "Base Rate must be a valid number e.g. 5.99";
                lblError.Visible = true;
                return;
            }
            tripType.BaseRate = baseRate;

            string error = manager.ValidateTripType(tripType);
            if (!string.IsNullOrEmpty(error))
            {
                lblError.Text = error;
                lblError.Visible = true;
                return;
            }

            try
            {
                manager.EditTripType(tripType);
                // Redirect to list after successful save
                Response.Redirect("TripTypeList.aspx");
            }
            catch (Exception ex)
            {
                lblError.Text = "Error updating trip type: " + ex.Message;
                lblError.Visible = true;
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("TripTypeList.aspx");
        }
    }
}
