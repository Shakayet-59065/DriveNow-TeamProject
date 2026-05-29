//------------------------------------------------------------------------------
// ContributorView.aspx.designer.cs
// Hand-maintained partial-class declarations for all runat="server" controls
// in ContributorView.aspx so the code-behind can compile.
//------------------------------------------------------------------------------

namespace DriveNow
{
    public partial class ContributorView
    {
        protected global::System.Web.UI.HtmlControls.HtmlForm form1;

        // ── Topbar ──────────────────────────────────────────────────────────
        protected global::System.Web.UI.WebControls.Label lblPageID;
        protected global::System.Web.UI.WebControls.Label lblDate;

        // ── Alert / message banner ───────────────────────────────────────────
        protected global::System.Web.UI.WebControls.Label lblMessage;

        // ── Application summary card ─────────────────────────────────────────
        protected global::System.Web.UI.WebControls.Label lblID;
        protected global::System.Web.UI.WebControls.Label lblTypeBadge;
        protected global::System.Web.UI.WebControls.Label lblApplicationDate;
        protected global::System.Web.UI.WebControls.Label lblStatus;
        protected global::System.Web.UI.WebControls.Label lblNotes;

        // ── Personal details card ────────────────────────────────────────────
        protected global::System.Web.UI.WebControls.Label lblFullName;
        protected global::System.Web.UI.WebControls.Label lblEmail;
        protected global::System.Web.UI.WebControls.Label lblPhone;

        // ── Driver credentials panel (shown for Driver / OwnerDriver) ────────
        protected global::System.Web.UI.WebControls.Panel pnlDriverCreds;
        protected global::System.Web.UI.WebControls.Label lblLicenceNumber;
        protected global::System.Web.UI.WebControls.Label lblDateOfBirth;
        protected global::System.Web.UI.WebControls.Label lblLicenceIssue;
        protected global::System.Web.UI.WebControls.Label lblLicenceExpiry;
        protected global::System.Web.UI.WebControls.Panel pnlProfilePhoto;
        protected global::System.Web.UI.WebControls.Image imgProfilePhoto;

        // ── Vehicle details panel (shown for VehicleOwner / OwnerDriver) ─────
        protected global::System.Web.UI.WebControls.Panel pnlVehicleDetails;
        protected global::System.Web.UI.WebControls.Label lblVehicleMake;
        protected global::System.Web.UI.WebControls.Label lblVehicleModel;
        protected global::System.Web.UI.WebControls.Label lblVehicleYear;
        protected global::System.Web.UI.WebControls.Label lblVehicleReg;
        protected global::System.Web.UI.WebControls.Label lblVehicleColour;
        protected global::System.Web.UI.WebControls.Label lblVehicleSeats;
        protected global::System.Web.UI.WebControls.Label lblVehicleDailyRate;
        protected global::System.Web.UI.WebControls.Panel pnlVehiclePhoto;
        protected global::System.Web.UI.WebControls.Image imgVehiclePhoto;
        protected global::System.Web.UI.WebControls.Panel pnlNoVehiclePhotoView;

        // ── Approval action panel (pending contributors) ──────────────────────
        protected global::System.Web.UI.WebControls.Panel   pnlApprove;
        protected global::System.Web.UI.WebControls.Panel   pnlWarnDOB;
        protected global::System.Web.UI.WebControls.TextBox txtOverrideDOB;
        protected global::System.Web.UI.WebControls.Panel   pnlWarnRate;
        protected global::System.Web.UI.WebControls.TextBox txtOverrideRate;
        protected global::System.Web.UI.WebControls.Button  btnApproveFull;

        // ── Already-approved banner ───────────────────────────────────────────
        protected global::System.Web.UI.WebControls.Panel     pnlApprovedBanner;
        protected global::System.Web.UI.WebControls.HyperLink lnkDriver;
        protected global::System.Web.UI.WebControls.HyperLink lnkVehicle;
    }
}
