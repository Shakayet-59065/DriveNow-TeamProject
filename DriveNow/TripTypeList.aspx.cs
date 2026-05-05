using System;
using System.Web.UI.WebControls;

// DriveNow — Trip Type List Code-Behind
// Lists all active trip types from tblTripType
// Allows editing and soft-deleting trip types
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripTypeList : System.Web.UI.Page
    {
        // Create instance of TripManager to call middle layer methods
        TripManager manager = new TripManager();

        /// <summary>
        /// Page load — check session and load trip types
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to login if not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Only load data on first load — not on postback (button clicks)
            if (!IsPostBack)
                LoadTripTypes();
        }

        /// <summary>
        /// Loads all active trip types into the GridView
        /// Calls spListTripTypes via TripManager.ListTripTypes()
        /// </summary>
        private void LoadTripTypes()
        {
            try
            {
                // Bind the list of trip types to the GridView
                gvTripTypes.DataSource = manager.ListTripTypes();
                gvTripTypes.DataBind();
            }
            catch (Exception ex)
            {
                // Show error message if database call fails
                lblError.Text = "Error loading trip types: " + ex.Message;
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Handles Edit and Delete button clicks from the GridView
        /// Edit redirects to TripTypeEdit.aspx with the ID in the query string
        /// Delete calls soft delete — sets IsActive to 0, never hard deletes
        /// </summary>
        protected void gvTripTypes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Parse the TripTypeID from the button's CommandArgument
            int tripTypeID = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "EditType")
            {
                // Redirect to edit page with ID in query string
                Response.Redirect("TripTypeEdit.aspx?id=" + tripTypeID);
            }
            else if (e.CommandName == "DeleteType")
            {
                try
                {
                    // Soft delete — sets IsActive = 0 via spDeleteTripType
                    // Record is kept in the database for audit purposes (GDPR)
                    manager.DeleteTripType(tripTypeID);

                    // Reload the list to reflect the deletion
                    LoadTripTypes();
                }
                catch (Exception ex)
                {
                    lblError.Text = "Error deleting trip type: " + ex.Message;
                    lblError.Visible = true;
                }
            }
        }
    }
}
