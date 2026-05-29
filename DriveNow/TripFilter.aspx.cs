using System;
using System.Web.UI.WebControls;

// DriveNow — Filter Trips Code-Behind
// Filters trips by optional TripTypeID and/or date
// Both filters are optional — blank = return all
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripFilter : System.Web.UI.Page
    {
        TripManager manager = new TripManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Load trip types into filter dropdown on first page load
            if (!IsPostBack)
                LoadTripTypes();
        }

        /// <summary>
        /// Populates the Trip Type filter dropdown from tblTripType
        /// First option is "All Trip Types" which passes null to the filter
        /// </summary>
        private void LoadTripTypes()
        {
            try
            {
                ddlTripType.DataSource = manager.ListTripTypes();
                ddlTripType.DataTextField = "TypeName";
                ddlTripType.DataValueField = "TripTypeID";
                ddlTripType.DataBind();

                // Add "all types" option at the top — passes null to the stored procedure
                ddlTripType.Items.Insert(0, new ListItem("-- All Trip Types --", "0"));
            }
            catch (Exception ex)
            {
                lblError.Text = "Error loading trip types: " + ex.Message;
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Filter button — runs the filter query and binds results to GridView
        /// Both parameters are optional — passing null shows all trips
        /// Calls spFilterTrips via TripManager.FilterTrips()
        /// </summary>
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            try
            {
                // Parse optional TripTypeID filter
                int? tripTypeID = null;
                int parsedType;
                if (int.TryParse(ddlTripType.SelectedValue, out parsedType) && parsedType > 0)
                    tripTypeID = parsedType;

                // Parse optional date filter — blank means no date filter
                DateTime? tripDate = null;
                DateTime parsedDate;
                if (!string.IsNullOrWhiteSpace(txtTripDate.Text))
                {
                    if (!DateTime.TryParseExact(txtTripDate.Text.Trim(), "dd/MM/yyyy",
                        System.Globalization.CultureInfo.InvariantCulture,
                        System.Globalization.DateTimeStyles.None, out parsedDate))
                    {
                        lblError.Text = "Please enter the date in format dd/MM/yyyy e.g. 21/04/2026";
                        lblError.Visible = true;
                        return;
                    }
                    tripDate = parsedDate;
                }

                // Run filter via spFilterTrips stored procedure
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

        /// <summary>
        /// Clear button — resets all filter controls and clears the results grid
        /// </summary>
        protected void btnClear_Click(object sender, EventArgs e)
        {
            // Reset filter controls to defaults
            ddlTripType.SelectedIndex = 0;
            txtTripDate.Text = "";

            // Clear the results grid
            gvTrips.DataSource = null;
            gvTrips.DataBind();
            lblError.Visible = false;
        }
    }
}
