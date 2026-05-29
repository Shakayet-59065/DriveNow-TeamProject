namespace DriveNow
{
    public partial class StaffEdit
    {
        protected global::System.Web.UI.HtmlControls.HtmlForm   form1;
        protected global::System.Web.UI.WebControls.Label        lblMessage;
        protected global::System.Web.UI.WebControls.Label        lblError;
        protected global::System.Web.UI.WebControls.HiddenField  hdnStaffID;
        protected global::System.Web.UI.WebControls.TextBox      txtFullName;
        protected global::System.Web.UI.WebControls.TextBox      txtUsername;
        protected global::System.Web.UI.WebControls.TextBox      txtEmail;
        protected global::System.Web.UI.WebControls.TextBox      txtPhone;
        protected global::System.Web.UI.WebControls.DropDownList ddlRole;
        protected global::System.Web.UI.WebControls.TextBox      txtNewPassword;
        protected global::System.Web.UI.WebControls.TextBox      txtConfirmPassword;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revPassword;
        protected global::System.Web.UI.WebControls.CompareValidator          cvPasswordMatch;
        protected global::System.Web.UI.WebControls.Button                    btnSave;
        protected global::System.Web.UI.WebControls.Button                    btnToggleActive;
        protected global::System.Web.UI.WebControls.Button                    btnHardDelete;
    }
}
