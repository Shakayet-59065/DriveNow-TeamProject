namespace DriveNow
{
    public partial class BookTrip
    {
        // Progress
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl progressStep1;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl progressStep2;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl progressStep3;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl progressStep4;
        protected global::System.Web.UI.WebControls.Panel pnlProgress;

        // Shared
        protected global::System.Web.UI.WebControls.Panel      pnlError;
        protected global::System.Web.UI.WebControls.Literal    litError;
        protected global::System.Web.UI.HtmlControls.HtmlImage imgVehicle;
        protected global::System.Web.UI.WebControls.Literal    litVehicleName;
        protected global::System.Web.UI.WebControls.Literal    litRate;
        protected global::System.Web.UI.WebControls.Literal    litReg;

        // Step 1
        protected global::System.Web.UI.WebControls.Panel       pnlStep1;
        protected global::System.Web.UI.WebControls.DropDownList ddlTripType;
        protected global::System.Web.UI.WebControls.TextBox     txtPickupLocation;
        protected global::System.Web.UI.WebControls.TextBox     txtPickupDate;
        protected global::System.Web.UI.WebControls.TextBox     txtPickupTime;
        protected global::System.Web.UI.WebControls.TextBox     txtDropoffLocation;
        protected global::System.Web.UI.WebControls.TextBox     txtDropoffDate;
        protected global::System.Web.UI.WebControls.TextBox     txtDropoffTime;
        protected global::System.Web.UI.WebControls.TextBox     txtNotes;
        protected global::System.Web.UI.WebControls.HiddenField hdnDriverID;
        protected global::System.Web.UI.WebControls.Repeater    rptDrivers;
        protected global::System.Web.UI.WebControls.Button      btnContinue;

        // Step 2 — Insurance
        protected global::System.Web.UI.WebControls.Panel          pnlStep2;
        protected global::System.Web.UI.WebControls.HiddenField    hdnInsurance;
        protected global::System.Web.UI.WebControls.Button         btnBackInsurance;
        protected global::System.Web.UI.WebControls.Button         btnNextInsurance;

        // Step 3 — Add-Ons
        protected global::System.Web.UI.WebControls.Panel      pnlStep3;
        protected global::System.Web.UI.WebControls.CheckBox   chkGPS;
        protected global::System.Web.UI.WebControls.CheckBox   chkMobileMount;
        protected global::System.Web.UI.WebControls.CheckBox   chkBabySeat;
        protected global::System.Web.UI.WebControls.CheckBox   chkBoosterSeat;
        protected global::System.Web.UI.WebControls.CheckBox   chkCycleCarrier;
        protected global::System.Web.UI.WebControls.CheckBox   chkRoofBox;
        protected global::System.Web.UI.WebControls.CheckBox   chkWifiHotspot;
        protected global::System.Web.UI.WebControls.CheckBox   chkDashcam;
        protected global::System.Web.UI.WebControls.Button     btnBackAddons;
        protected global::System.Web.UI.WebControls.Button     btnNextAddons;

        // Step 4 — Payment
        protected global::System.Web.UI.WebControls.Panel      pnlStep4;
        protected global::System.Web.UI.WebControls.Literal    litSummaryVehicle;
        protected global::System.Web.UI.WebControls.Literal    litSummaryPickup;
        protected global::System.Web.UI.WebControls.Literal    litSummaryDropoff;
        protected global::System.Web.UI.WebControls.Literal    litSummaryTripType;
        protected global::System.Web.UI.WebControls.Literal    litSummaryDays;
        protected global::System.Web.UI.WebControls.Literal    litSummaryInsurance;
        protected global::System.Web.UI.WebControls.Literal    litSummaryAddons;
        protected global::System.Web.UI.WebControls.Literal    litSummaryTotal;
        protected global::System.Web.UI.WebControls.TextBox    txtCardName;
        protected global::System.Web.UI.WebControls.TextBox    txtCardNumber;
        protected global::System.Web.UI.WebControls.DropDownList ddlExpiryMonth;
        protected global::System.Web.UI.WebControls.DropDownList ddlExpiryYear;
        protected global::System.Web.UI.WebControls.TextBox    txtCVV;
        protected global::System.Web.UI.WebControls.CheckBox   chkTerms;
        protected global::System.Web.UI.WebControls.CheckBox   chkDataConsent;
        protected global::System.Web.UI.WebControls.Button     btnBack;
        protected global::System.Web.UI.WebControls.Button     btnPay;
    }
}
