namespace DriveNow
{
    public partial class Careers
    {
        protected global::System.Web.UI.WebControls.Label                      lblSuccess;
        protected global::System.Web.UI.WebControls.Label                      lblError;
        protected global::System.Web.UI.WebControls.Panel                      pnlForm;
        // Personal details
        protected global::System.Web.UI.WebControls.TextBox                    txtFirstName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvFirst;
        protected global::System.Web.UI.WebControls.TextBox                    txtLastName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvLast;
        protected global::System.Web.UI.WebControls.TextBox                    txtEmail;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEmail;
        protected global::System.Web.UI.WebControls.TextBox                    txtPhone;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvPhone;
        // Role / availability
        protected global::System.Web.UI.WebControls.DropDownList               ddlRole;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvRole;
        protected global::System.Web.UI.WebControls.Label                      lblRoleError;
        protected global::System.Web.UI.WebControls.DropDownList               ddlAvailability;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvAvail;
        // Driver credentials
        protected global::System.Web.UI.WebControls.TextBox                    txtLicenceNumber;
        protected global::System.Web.UI.WebControls.Label                      lblLicenceError;
        protected global::System.Web.UI.WebControls.TextBox                    txtDrivingYears;
        protected global::System.Web.UI.WebControls.TextBox                    txtLicenceCountry;
        // Cover letter / LinkedIn
        protected global::System.Web.UI.WebControls.TextBox                    txtCoverLetter;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvCover;
        protected global::System.Web.UI.WebControls.TextBox                    txtLinkedIn;
        // Consent
        protected global::System.Web.UI.WebControls.CheckBox                   chkAccuracy;
        protected global::System.Web.UI.WebControls.CheckBox                   chkConsent;
        protected global::System.Web.UI.WebControls.Label                      lblConsentError;
        // Submit
        protected global::System.Web.UI.WebControls.Button                     btnSubmit;
    }
}
