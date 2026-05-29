namespace DriveNow
{
    public partial class ContributorApply
    {
        protected global::System.Web.UI.WebControls.Label                      lblSuccess;
        protected global::System.Web.UI.WebControls.Label                      lblError;
        protected global::System.Web.UI.WebControls.Panel                      pnlForm;
        // Type selection
        protected global::System.Web.UI.WebControls.RadioButton                rbOwner;
        protected global::System.Web.UI.WebControls.RadioButton                rbDriver;
        protected global::System.Web.UI.WebControls.RadioButton                rbOwnerDriver;
        protected global::System.Web.UI.WebControls.HiddenField                hfContribType;
        protected global::System.Web.UI.WebControls.Label                      lblTypeError;
        // Personal details
        protected global::System.Web.UI.WebControls.TextBox                    txtFullName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvName;
        protected global::System.Web.UI.WebControls.TextBox                    txtEmail;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEmail;
        protected global::System.Web.UI.WebControls.TextBox                    txtPhone;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator     rfvPhone;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revPhone;
        // Vehicle details
        protected global::System.Web.UI.WebControls.TextBox                    txtVehicleMake;
        protected global::System.Web.UI.WebControls.TextBox                    txtVehicleModel;
        protected global::System.Web.UI.WebControls.TextBox                    txtVehicleYear;
        protected global::System.Web.UI.WebControls.TextBox                    txtVehicleReg;
        protected global::System.Web.UI.WebControls.TextBox                    txtVehicleColour;
        protected global::System.Web.UI.WebControls.DropDownList               ddlVehicleSeats;
        protected global::System.Web.UI.WebControls.TextBox                    txtVehicleDailyRate;
        protected global::System.Web.UI.WebControls.FileUpload                 fuVehiclePhoto;
        // Driver credentials
        protected global::System.Web.UI.WebControls.TextBox                    txtLicenceNumber;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revLicenceNumber;
        protected global::System.Web.UI.WebControls.Label                      lblLicenceError;
        protected global::System.Web.UI.WebControls.TextBox                    txtLicenceIssueDate;
        protected global::System.Web.UI.WebControls.TextBox                    txtLicenceExpiryDate;
        protected global::System.Web.UI.WebControls.TextBox                    txtDateOfBirth;
        protected global::System.Web.UI.WebControls.TextBox                    txtDrivingYears;
        protected global::System.Web.UI.WebControls.FileUpload                 fuProfilePhoto;
        // Message
        protected global::System.Web.UI.WebControls.TextBox                    txtMessage;
        // Consent
        protected global::System.Web.UI.WebControls.CheckBox                   chkAccuracy;
        protected global::System.Web.UI.WebControls.CheckBox                   chkConsent;
        protected global::System.Web.UI.WebControls.Label                      lblConsentError;
        // Submit
        protected global::System.Web.UI.WebControls.Button                     btnSubmit;
    }
}
