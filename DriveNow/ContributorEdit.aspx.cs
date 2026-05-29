// ============================================================
// File: ContributorEdit.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Presentation Layer
// Purpose: Loads an existing contributor record by ContributorID
//          passed in the query string (?id=) and pre-populates
//          all form fields with the current values from the database.
//          Staff can update any field including IsApproved status —
//          this is how pending applications are approved.
//          Validates all inputs before calling ContributorManager.Edit().
//          ContributorID is stored in ViewState so it persists across
//          postbacks without being visible in the URL or form.
//          Redirects to ListContributors after successful save.
// ============================================================

using System;
using System.Data;


namespace DriveNow
{
    public partial class EditContributor : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session check — redirect to login if not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                // Read ContributorID from query string on first load only
                // IsPostBack check prevents overwriting form values on Save click
                if (Request.QueryString["id"] != null)
                {
                    int id = Convert.ToInt32(Request.QueryString["id"]);
                    LoadContributor(id);
                }
                else
                {
                    // No ID in query string — cannot edit without knowing which record
                    Response.Redirect("ContributorList.aspx");
                }
            }
        }

        /// <summary>
        /// Fetches the contributor record by ID from the database and
        /// pre-populates all form fields with the existing values.
        /// Stores ContributorID in ViewState so Save can use it on postback.
        /// If no record found for the given ID, redirects back to the list.
        /// </summary>
        /// <param name="id">ContributorID from the query string.</param>
        private void LoadContributor(int id)
        {
            try
            {
                // Find record by exact ID — returns DataTable with one row
                DataTable dt = ContributorManager.Find(id, null);

                if (dt.Rows.Count == 0)
                {
                    // Record not found — redirect rather than showing empty form
                    Response.Redirect("ContributorList.aspx");
                    return;
                }

                DataRow row = dt.Rows[0];

                // Display formatted ID in the page subtitle
                lblContributorID.Text = "#CON-" + id.ToString("D3");

                // Pre-populate form fields with current database values
                txtFullName.Text = row["FullName"].ToString();
                txtEmail.Text = row["Email"].ToString();
                txtPhone.Text = row["Phone"].ToString();
                ddlContributorType.SelectedValue = row["ContributorType"].ToString();

                // Format date as yyyy-MM-dd for HTML date input compatibility
                txtApplicationDate.Text = Convert.ToDateTime(row["ApplicationDate"])
                                            .ToString("yyyy-MM-dd");

                // Set approval dropdown — converts BIT to lowercase string
                bool isApproved = Convert.ToBoolean(row["IsApproved"]);
                ddlIsApproved.SelectedValue = isApproved.ToString().ToLower();

                // Store ID in ViewState — survives postback without URL exposure
                ViewState["ContributorID"] = id;
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error loading contributor: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }

        /// <summary>
        /// Fires when Save Changes button is clicked.
        /// Reads ContributorID from ViewState — not from the URL —
        /// to prevent ID tampering via the address bar.
        /// Runs two levels of validation before updating the database.
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Stop if ASP.NET validators caught empty or invalid fields
            if (!Page.IsValid)
                return;

            try
            {
                // Build ContributorManager with updated form values
                ContributorManager cm = new ContributorManager();

                // Read ID from ViewState — set during LoadContributor on first load
                cm.ContributorID = Convert.ToInt32(ViewState["ContributorID"]);
                cm.FullName = txtFullName.Text.Trim();
                cm.Email = txtEmail.Text.Trim();
                cm.Phone = txtPhone.Text.Trim();
                cm.ContributorType = ddlContributorType.SelectedValue;
                cm.ApplicationDate = Convert.ToDateTime(txtApplicationDate.Text);

                // Convert dropdown string value to boolean for IsApproved
                cm.IsApproved = ddlIsApproved.SelectedValue == "true";

                // Server-side validation before database write
                if (!cm.Validate())
                {
                    lblMessage.Text = cm.ErrorMessage;
                    lblMessage.CssClass = "dn-alert-error";
                    lblMessage.Visible = true;
                    return;
                }

                cm.Edit();

                // Redirect back to list — query string carries edited ID
                Response.Redirect("ContributorList.aspx?edited=" + cm.ContributorID);
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error saving changes: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }
    }
}