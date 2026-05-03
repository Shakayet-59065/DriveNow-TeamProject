using System;
using System.Web.UI.WebControls;

namespace DriveNow
{
    public partial class TripTypeList : System.Web.UI.Page
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
                gvTripTypes.DataSource = manager.ListTripTypes();
                gvTripTypes.DataBind();
            }
            catch (Exception ex)
            {
                lblError.Text = "Error loading trip types: " + ex.Message;
                lblError.Visible = true;
            }
        }

        protected void gvTripTypes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int tripTypeID = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "EditType")
            {
                Response.Redirect("TripTypeEdit.aspx?id=" + tripTypeID);
            }
            else if (e.CommandName == "DeleteType")
            {
                try
                {
                    manager.DeleteTripType(tripTypeID);
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