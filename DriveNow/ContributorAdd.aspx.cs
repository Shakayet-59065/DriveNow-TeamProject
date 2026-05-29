// ============================================================
// File: ContributorAdd.aspx.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Presentation Layer
// Purpose: Handles the submission of a new contributor application.
//          ASP.NET validators run client-side first to catch empty
//          fields before the form is submitted to the server.
//          Server-side validation then runs via ContributorManager.Validate()
//          to enforce business rules before any database write.
//          On success, redirects to ListContributors with the new ID
//          in the query string so a confirmation can be shown.
//          IsApproved defaults to 0 (pending) on every new record —
//          staff must approve applications separately via Edit page.
// ============================================================

using System;


namespace DriveNow
{
    public partial class AddContributor : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session check — redirect to login if not authenticated
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");

            // Nothing else needed on load — form starts empty
        }

        /// <summary>
        /// Fires when the Save Contributor button is clicked.
        /// Runs two levels of validation:
        /// 1. ASP.NET RequiredFieldValidators and RegularExpressionValidators
        /// 2. Server-side ContributorManager.Validate() for business rules
        /// Only writes to the database if both levels pass.
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Stop if ASP.NET validators caught any empty or invalid fields
            // Page.IsValid checks all validators on the page simultaneously
            if (!Page.IsValid)
                return;

            try
            {
                // Build ContributorManager object with values from the form
                // .Trim() removes accidental leading/trailing whitespace
                ContributorManager cm = new ContributorManager();
                cm.FullName = txtFullName.Text.Trim();
                cm.Email = txtEmail.Text.Trim();
                cm.Phone = txtPhone.Text.Trim();
                cm.ContributorType = ddlContributorType.SelectedValue;
                cm.ApplicationDate = Convert.ToDateTime(txtApplicationDate.Text);

                // Run server-side business rule validation before database write
                // Validate() sets cm.ErrorMessage if any rule fails
                if (!cm.Validate())
                {
                    lblMessage.Text = cm.ErrorMessage;
                    lblMessage.CssClass = "dn-alert-error";
                    lblMessage.Visible = true;
                    return;
                }

                // Insert the record — Add() returns the new ContributorID
                int newID = cm.Add();

                // Redirect to list page — query string carries the new ID
                // so ListContributors can show a success confirmation if needed
                Response.Redirect("ContributorList.aspx?added=" + newID);
            }
            catch (Exception ex)
            {
                // Show database or conversion errors on the page
                lblMessage.Text = "Error saving contributor: " + ex.Message;
                lblMessage.CssClass = "dn-alert-error";
                lblMessage.Visible = true;
            }
        }
    }
}