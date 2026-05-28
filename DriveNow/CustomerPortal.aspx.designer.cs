namespace DriveNow
{
    public partial class CustomerPortal
    {
        protected global::System.Web.UI.WebControls.Panel    pnlFlash;
        protected global::System.Web.UI.WebControls.Literal  litFlash;
        protected global::System.Web.UI.WebControls.Literal  litLoyaltyTier;
        protected global::System.Web.UI.WebControls.Literal  litNavName;
        protected global::System.Web.UI.WebControls.Literal  litName;
        protected global::System.Web.UI.WebControls.Literal  litTotal;
        protected global::System.Web.UI.WebControls.Literal  litUpcoming;
        protected global::System.Web.UI.WebControls.Literal  litCompleted;
        protected global::System.Web.UI.WebControls.Literal  litSpend;
        protected global::System.Web.UI.WebControls.Panel    pnlTrips;
        protected global::System.Web.UI.WebControls.Panel    pnlEmpty;
        protected global::System.Web.UI.WebControls.Repeater rptTrips;
        protected global::System.Web.UI.WebControls.Repeater rptReceipts;
        protected global::System.Web.UI.WebControls.Panel    pnlReceipts;
        protected global::System.Web.UI.WebControls.Panel    pnlNoReceipts;
        protected global::System.Web.UI.WebControls.Button   btnLogout;
        // Edit profile controls
        protected global::System.Web.UI.WebControls.Label    lblProfileMsg;
        protected global::System.Web.UI.WebControls.TextBox  txtEditEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEditEmail;
        protected global::System.Web.UI.WebControls.TextBox  txtEditPhone;
        protected global::System.Web.UI.WebControls.CheckBox chkProfileConsent;
        protected global::System.Web.UI.WebControls.Label    lblProfileConsentError;
        protected global::System.Web.UI.WebControls.Button   btnSaveProfile;
        // Change password controls
        protected global::System.Web.UI.WebControls.Label    lblChangePwMsg;
        protected global::System.Web.UI.WebControls.TextBox  txtNewPw;
        protected global::System.Web.UI.WebControls.TextBox  txtConfirmPw;
        protected global::System.Web.UI.WebControls.Button   btnChangePassword;
    }
}
