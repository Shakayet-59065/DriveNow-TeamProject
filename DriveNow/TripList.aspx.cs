using System;
using System.Web.UI.WebControls;

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
