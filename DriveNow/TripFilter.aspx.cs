using System;
using System.Web.UI.WebControls;

namespace DriveNow
{
    public partial class TripFilter : System.Web.UI.Page
    {
        TripManager manager = new TripManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
                LoadTripTypes();
        }

        private void LoadTripTypes()
        {
            try
            {
                ddlTripType.DataSource = manager.ListTripTypes();
                ddlTripType.DataTextField = "TypeName";
                ddlTripType.DataValueField = "TripTypeID";
                ddlTripType.DataBind();
                ddlTripType.Items.Insert(0, new ListItem("-- All Trip Types --", "0"));
            }
            catch (Exception ex)
            {
                lblError.Text = "Error loading trip types: " + ex.Message;
                lblError.Visible = true;
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            try
            {
                int? tripTypeID = null;
                int parsed;
                if (int.TryParse(ddlTripType.SelectedValue, out parsed) && parsed > 0)
                    tripTypeID = parsed;

                DateTime? tripDate = null;
                DateTime parsedDate;
                if (!string.IsNullOrWhiteSpace(txtTripDate.Text))
                {
                    if (!DateTime.TryParseExact(txtTripDate.Text.Trim(), "dd/MM/yyyy",
                        System.Globalization.CultureInfo.InvariantCulture,
                        System.Globalization.DateTimeStyles.None, out parsedDate))
                    {
                        lblError.Text = "Please enter date in format dd/MM/yyyy";
                        lblError.Visible = true;
                        return;
                    }
                    tripDate = parsedDate;
                }

                gvTrips.DataSource = manager.FilterTrips(tripTypeID, tripDate);
                gvTrips.DataBind();
                lblError.Visible = false;
            }
            catch (Exception ex)
            {
                lblError.Text = "Error filtering trips: " + ex.Message;
                lblError.Visible = true;
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlTripType.SelectedIndex = 0;
            txtTripDate.Text = "";
            gvTrips.DataSource = null;
            gvTrips.DataBind();
            lblError.Visible = false;
        }
    }
}
