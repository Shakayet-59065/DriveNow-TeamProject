using System;
using System.Web.UI.WebControls;

// DriveNow — Trip Type List Code-Behind
// Lists active or inactive trip types depending on the tab query-string.
// Supports soft-delete (Deactivate), Restore (reactivate), and Hard Delete.
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripTypeList : System.Web.UI.Page
    {
        // Middle-layer instance — all DB calls go through TripManager
        TripManager manager = new TripManager();

        /// <summary>
        /// Helper used in markup to apply the active CSS class to the correct tab.
        /// Reads the "tab" query-string parameter; defaults to "active" if absent.
        /// </summary>
        protected string TabCss(string tabName)
        {
            string current = Request.QueryString["tab"] ?? "active";
            return current == tabName ? "dn-pill active" : "dn-pill";
        }

        /// <summary>
        /// Page load — enforces session authentication and loads the trip type list.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Only load data on the initial request, not on postbacks
            if (!IsPostBack)
                LoadTripTypes();
        }

        /// <summary>
        /// Loads the trip type grid depending on the active/inactive tab.
        /// Active tab calls spListTripTypes (WHERE IsActive = 1).
        /// Inactive tab calls spListInactiveTripTypes (WHERE IsActive = 0).
        /// </summary>
        private void LoadTripTypes()
        {
            try
            {
                bool showInactive = Request.QueryString["tab"] == "inactive";

                // Choose the appropriate stored procedure via TripManager
                gvTripTypes.DataSource    = showInactive
                    ? manager.ListInactiveTripTypes()
                    : manager.ListTripTypes();
                gvTripTypes.DataBind();
                gvTripTypes.EmptyDataText = showInactive
                    ? "No inactive trip types found."
                    : "No active trip types found.";
            }
            catch (Exception ex)
            {
                lblError.Text    = "Error loading trip types: " + ex.Message;
                lblError.Visible = true;
            }
        }

        /// <summary>
        /// GridView row command handler — handles Edit, Delete (soft), Restore, and Hard Delete.
        /// Edit    → redirects to TripTypeEdit.aspx with the TripTypeID in the query string.
        /// Delete  → soft delete via spDeleteTripType (sets IsActive = 0, never SQL DELETE).
        /// Restore → reactivates via spRestoreTripType (sets IsActive = 1).
        /// HardDelete → permanent removal via spHardDeleteTripType (only if no FK references).
        /// </summary>
        protected void gvTripTypes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int tripTypeID = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "EditType")
            {
                // Navigate to edit page, passing the TripTypeID in the query string
                Response.Redirect("TripTypeEdit.aspx?id=" + tripTypeID);
            }
            else if (e.CommandName == "DeleteType")
            {
                try
                {
                    // Soft delete — sets IsActive = 0 via spDeleteTripType
                    manager.DeleteTripType(tripTypeID);
                    lblError.Text     = "Trip type deactivated. Record retained for audit.";
                    lblError.CssClass = "dn-alert-success";
                    lblError.Visible  = true;
                    LoadTripTypes();
                }
                catch (Exception ex)
                {
                    lblError.Text     = "Error deactivating trip type: " + ex.Message;
                    lblError.CssClass = "dn-alert-error";
                    lblError.Visible  = true;
                }
            }
            else if (e.CommandName == "RestoreType")
            {
                try
                {
                    // Restore — sets IsActive = 1 via spRestoreTripType
                    manager.RestoreTripType(tripTypeID);
                    lblError.Text     = "Trip type restored to active status.";
                    lblError.CssClass = "dn-alert-success";
                    lblError.Visible  = true;
                    LoadTripTypes();
                }
                catch (Exception ex)
                {
                    lblError.Text     = "Error restoring trip type: " + ex.Message;
                    lblError.CssClass = "dn-alert-error";
                    lblError.Visible  = true;
                }
            }
            else if (e.CommandName == "HardDeleteType")
            {
                try
                {
                    // Permanent delete via spHardDeleteTripType — raises error if FK refs exist
                    manager.HardDeleteTripType(tripTypeID);
                    lblError.Text     = "Trip type permanently deleted.";
                    lblError.CssClass = "dn-alert-success";
                    lblError.Visible  = true;
                    LoadTripTypes();
                }
                catch (Exception ex)
                {
                    lblError.Text     = "Error: " + ex.Message;
                    lblError.CssClass = "dn-alert-error";
                    lblError.Visible  = true;
                }
            }
        }
    }
}
