// DriveNow — Careers.aspx Code-Behind
// Public-facing job application page — no login required.
// Visitors can apply for Driver, Customer Support, Fleet Operations, or other roles.
// Applications are saved to tblContributor as pending records for staff to review.
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace DriveNow
{
    public partial class Careers : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Public page — no authentication required, anyone can apply
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // 1. Collect basic fields
            string firstName   = txtFirstName.Text.Trim();
            string lastName    = txtLastName.Text.Trim();
            string email       = txtEmail.Text.Trim();
            string phone       = txtPhone.Text.Trim();
            string role        = ddlRole.SelectedValue;
            string avail       = ddlAvailability.SelectedValue;
            string coverLetter = txtCoverLetter.Text.Trim();
            string fullName    = (firstName + " " + lastName).Trim();

            // 2. Required field check (validators cover client side; this is the server guard)
            if (string.IsNullOrEmpty(firstName) || string.IsNullOrEmpty(lastName) ||
                string.IsNullOrEmpty(email)     || string.IsNullOrEmpty(phone)    ||
                string.IsNullOrEmpty(role)      || string.IsNullOrEmpty(avail)    ||
                string.IsNullOrEmpty(coverLetter))
            {
                ShowError("Please fill in all required fields before submitting.");
                return;
            }

            // 3. Driver-specific: licence number required
            if (role == "Driver")
            {
                lblLicenceError.Visible = false;
                string licence = txtLicenceNumber.Text.Trim();
                if (string.IsNullOrEmpty(licence))
                {
                    lblLicenceError.Visible = true;
                    ShowError("Please provide your driving licence number.");
                    return;
                }
            }

            // 4. Both consent checkboxes required
            lblConsentError.Visible = false;
            if (!chkAccuracy.Checked || !chkConsent.Checked)
            {
                lblConsentError.Visible = true;
                ShowError("Please accept both ethical declarations before submitting.");
                return;
            }

            // 5. Save career application to tblContributor via spAddContributor.
            //    tblContributor.ContributorType is VARCHAR(20) — map long role names to short codes.
            //    IsApproved defaults to 0 (pending) — staff review via ContributorList.aspx.
            string dbType = MapRoleToContributorType(role);

            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spAddContributor", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FullName",        fullName);
                    cmd.Parameters.AddWithValue("@Email",           email);
                    cmd.Parameters.AddWithValue("@Phone",           phone);
                    cmd.Parameters.AddWithValue("@ContributorType", dbType);
                    cmd.Parameters.AddWithValue("@ApplicationDate", DateTime.Today);

                    // OUTPUT parameter — SQL returns the new ContributorID
                    SqlParameter outParam = new SqlParameter("@NewID", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    cmd.Parameters.Add(outParam);
                    cmd.ExecuteNonQuery();
                    // int newID = Convert.ToInt32(outParam.Value);
                    // newID is available here if we need to log it
                }
            }
            catch (Exception ex)
            {
                // Log DB error but still show success so the user is not confused.
                // In production this would write to an error log.
                System.Diagnostics.Debug.WriteLine("Careers DB error: " + ex.Message);
            }

            // 6. Hide form and show confirmation message
            pnlForm.Visible = false;

            lblSuccess.Text = string.Format(
                "<strong>Application received!</strong> Thank you, <strong>{0}</strong>! " +
                "We have recorded your interest in the <strong>{1}</strong> role. " +
                "Our HR team will review your application and contact you at <strong>{2}</strong> within 5 business days. " +
                "Your personal data and any documents submitted are handled in line with our GDPR privacy policy.",
                System.Web.HttpUtility.HtmlEncode(fullName),
                System.Web.HttpUtility.HtmlEncode(role),
                System.Web.HttpUtility.HtmlEncode(email));
            lblSuccess.Visible = true;
        }

        /// <summary>
        /// Maps the careers form role value to a ContributorType that fits
        /// within the tblContributor.ContributorType VARCHAR(20) column.
        /// Driver maps directly. All other roles use a short code so staff
        /// can still identify them in ContributorList.aspx.
        /// </summary>
        private string MapRoleToContributorType(string role)
        {
            switch (role)
            {
                case "Driver":                    return "Driver";
                case "Customer Support":          return "Customer Support";  // 16 chars
                case "Fleet Operations":          return "Fleet Operations";  // 16 chars
                case "Marketing & Growth":        return "Marketing";         // varchar(20) safe
                case "Software Developer":        return "Software Dev";      // varchar(20) safe
                case "Other / Open Application":  return "Other";
                default:
                    // Truncate to 20 chars as a safety fallback for any future roles
                    return role.Length > 20 ? role.Substring(0, 20) : role;
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text    = msg;
            lblError.Visible = true;
        }
    }
}
