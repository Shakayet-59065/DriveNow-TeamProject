// ============================================================
// File: ContribVehicleAdd.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Presentation Layer
// Purpose: Handles submission of a new vehicle record linked to
//          an existing contributor. ContributorID passed via
//          query string (?id=) from the Add Vehicle button on
//          ContribVehicleList.aspx. Stored in ViewState so it
//          persists when the Save button is clicked (postback).
//          ASP.NET validators catch empty fields and invalid year
//          range client-side before form is submitted.
//          On success redirects to ListContribVehicles with the
//          new vehicle ID so a confirmation can be shown.
// ============================================================

using System;


namespace DriveNow
{
    public partial class AddContribVehicle : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session check — redirect to login if not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                // Read ContributorID from query string on first load
                if (Request.QueryString["id"] != null)
                {
                    int contributorID = Convert.ToInt32(Request.QueryString["id"]);

                    // Store in ViewState — survives the Save button postback
                    ViewState["ContributorID"] = contributorID;

                    // Show contributor ID in page subtitle for context
                    lblContributorID.Text = "#CON-" + contributorID.ToString("D3");

                    // Set back and cancel links dynamically with correct ID
                    // so staff return to the right contributor's vehicle list
                    hlBack.NavigateUrl = "ContribVehicleList.aspx?id=" + contributorID;
                    hlCancel.NavigateUrl = "ContribVehicleList.aspx?id=" + contributorID;
                }
                else
                {
                    // No contributor ID — cannot add vehicle without knowing
                    // which contributor it belongs to
                    Response.Redirect("ContributorList.aspx");
                }
            }
        }

        /// <summary>
        /// Fires when Save Vehicle button is clicked.
        /// ASP.NET RangeValidator already checks year is 1990-2100.
        /// Calls ContributorManager.AddVehicle() with form values.
        /// ContributorID read from ViewState — not from URL — to
        /// prevent ID tampering via the address bar.
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Stop if ASP.NET validators caught empty fields or invalid year
            if (!Page.IsValid)
                return;

            try
            {
                // Read ContributorID from ViewState — set on first page load
                int contributorID = Convert.ToInt32(ViewState["ContributorID"]);

                // Insert vehicle record linked to this contributor
                // Returns the new ContribVehicleID assigned by the database
                int newID = ContributorManager.AddVehicle(
                    contributorID,
                    txtMake.Text.Trim(),
                    txtModel.Text.Trim(),
                    Convert.ToInt32(txtYear.Text.Trim()),
                    txtRegistrationNo.Text.Trim()
                );

                // Redirect back to vehicle list with both IDs in query string
                Response.Redirect("ContribVehicleList.aspx?id=" + contributorID
                    + "&added=" + newID);
            }
            catch (Exception ex)
            {
                // Show database errors on page — duplicate registration will
                // cause a SQL unique constraint violation caught here
                lblMessage.Text = "Error saving vehicle: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }
    }
}