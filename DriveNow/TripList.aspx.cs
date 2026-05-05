using System;
using System.Web.UI.WebControls;

// DriveNow — Trip List Code-Behind
// Lists all active trips from tblTrip with Edit and Delete actions
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripList : System.Web.UI.Page
    {
        TripManager manager = new TripManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
                LoadTrips();
        }

        /// <summary>
        /// Loads all active trips into the GridView
        /// Calls spListTrips via TripManager.ListTrips()
        /// </summary>
        private void LoadTrips()
        {
            try
            {
                gvTrips.DataSource = manager.ListTrips();
                gvTrips.DataBind();
            }
            catch (Exception ex)
            {
                lblError.Text = "Error loading trips: " + ex.Message;
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// Handles Edit and Delete row commands from the GridView
        /// Edit redirects to TripEdit.aspx with ID in query string
        /// Delete performs soft delete via spDeleteTrip
        /// </summary>
        protected void gvTrips_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int tripID = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "EditTrip")
            {
                Response.Redirect("TripEdit.aspx?id=" + tripID);
            }
            else if (e.CommandName == "DeleteTrip")
            {
                try
                {
                    // Soft delete — sets IsActive = 0, never hard deletes
                    // Preserves record for audit trail and GDPR compliance
                    manager.DeleteTrip(tripID);
                    LoadTrips();
                }
                catch (Exception ex)
                {
                    lblError.Text = "Error deleting trip: " + ex.Message;
                    lblError.Visible = true;
                }
            }
        }
    }
}
