using System;
using System.Collections.Generic;

// DriveNow — Find Trip Type Code-Behind
// Searches the trip type catalogue by ID or by name keyword.
// All database access goes through TripManager — no inline SQL.
// Module: CTEC2713N | Developer: Musanna

namespace DriveNow
{
    public partial class TripTypeFind : System.Web.UI.Page
    {
        // Middle-layer instance — all DB calls go through here
        TripManager manager = new TripManager();

        /// <summary>
        /// Page load — enforces session authentication.
        /// Unauthenticated users are redirected to Login.aspx.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
        }

        /// <summary>
        /// Search button — finds trip types by ID or by name keyword.
        /// If ID is provided, calls TripManager.FindTripType() via spFindTripType.
        /// If name is provided, calls TripManager.FilterTripTypes() via spFilterTripTypes (LIKE match).
        /// Both fields blank shows a validation error.
        /// Results are bound to gvResults GridView.
        /// </summary>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string idText = txtID.Text.Trim();
            string name   = txtName.Text.Trim();

            // At least one search field must be filled
            if (string.IsNullOrEmpty(idText) && string.IsNullOrEmpty(name))
            {
                lblMessage.Text    = "Please enter an ID or type name to search.";
                lblMessage.Visible = true;
                gvResults.Visible  = false;
                return;
            }

            try
            {
                List<TripType> results = new List<TripType>();

                if (!string.IsNullOrEmpty(idText))
                {
                    // Search by TripTypeID — must be a valid positive integer
                    int id;
                    if (!int.TryParse(idText, out id) || id <= 0)
                    {
                        lblMessage.Text    = "Trip Type ID must be a valid positive number.";
                        lblMessage.Visible = true;
                        gvResults.Visible  = false;
                        return;
                    }

                    // Find single record via spFindTripType stored procedure
                    TripType found = manager.FindTripType(id);
                    if (found != null)
                        results.Add(found);
                }
                else
                {
                    // Search by name keyword via spFilterTripTypes (LIKE match)
                    results = manager.FilterTripTypes(name);
                }

                if (results.Count == 0)
                {
                    // No matching records found
                    lblMessage.Text    = "No trip types found matching your search.";
                    lblMessage.Visible = true;
                    gvResults.Visible  = false;
                    return;
                }

                // Bind results to the GridView and hide any previous error
                gvResults.DataSource = results;
                gvResults.DataBind();
                gvResults.Visible  = true;
                lblMessage.Visible = false;
            }
            catch (Exception ex)
            {
                // Database or middle-layer error — show message, hide grid
                lblMessage.Text    = "Search error: " + ex.Message;
                lblMessage.Visible = true;
                gvResults.Visible  = false;
            }
        }
    }
}
