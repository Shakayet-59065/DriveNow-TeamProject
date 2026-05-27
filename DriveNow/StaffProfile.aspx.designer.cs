namespace DriveNow
{
    public partial class StaffProfile
    {
        protected global::System.Web.UI.HtmlControls.HtmlForm frmStaffProfile;
        // Sidebar / overview labels
        protected global::System.Web.UI.WebControls.Label     lblSidebarName;
        protected global::System.Web.UI.WebControls.Label     lblAvatarLetter;
        protected global::System.Web.UI.WebControls.Label     lblFullName;
        protected global::System.Web.UI.WebControls.Label     lblUsername;
        protected global::System.Web.UI.WebControls.Label     lblRole;
        protected global::System.Web.UI.WebControls.Label     lblRoleDisplay;
        protected global::System.Web.UI.WebControls.Label     lblCurrentEmail;
        protected global::System.Web.UI.WebControls.Label     lblCurrentPhone;
        protected global::System.Web.UI.WebControls.Label     lblSessionDate;
        // Edit form controls
        protected global::System.Web.UI.WebControls.Label     lblProfileMsg;
        protected global::System.Web.UI.WebControls.TextBox   txtEditFullName;
        protected global::System.Web.UI.WebControls.TextBox   txtEditUsername;
        protected global::System.Web.UI.WebControls.TextBox   txtEditEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEditEmail;
        protected global::System.Web.UI.WebControls.TextBox   txtEditPhone;
        protected global::System.Web.UI.WebControls.TextBox   txtNewPassword;
        protected global::System.Web.UI.WebControls.TextBox   txtConfirmPassword;
        protected global::System.Web.UI.WebControls.CheckBox  chkProfileConsent;
        protected global::System.Web.UI.WebControls.Label     lblConsentError;
        protected global::System.Web.UI.WebControls.Button    btnSaveProfile;
        // Stats
        protected global::System.Web.UI.WebControls.Label     lblTripCount;
        protected global::System.Web.UI.WebControls.Label     lblTripTypeCount;
        protected global::System.Web.UI.WebControls.Label     lblCustomerCount;
        protected global::System.Web.UI.WebControls.Label     lblDriverCount;
        protected global::System.Web.UI.WebControls.Label     lblContributorCount;
    }
}
