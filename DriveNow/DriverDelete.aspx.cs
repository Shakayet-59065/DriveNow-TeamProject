// DriverDelete.aspx.cs - Developer: Redoy (59065) - Soft deletes driver
using System;
using System.Data;
namespace DriveNow
{
    public partial class DriverDelete : System.Web.UI.Page
    {
        DriverManager dm = new DriverManager();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"]) Response.Redirect("Login.aspx");
            if (!IsPostBack) { string id = Request.QueryString["id"]; if (!string.IsNullOrEmpty(id)) { hdnDriverID.Value = id; DataTable dt = dm.FindDriver(Convert.ToInt32(id), null); if (dt.Rows.Count > 0) { DataRow r = dt.Rows[0]; lblDriverInfo.Text = string.Format("ID: #DRV-{0} | Name: {1} | Licence: {2}", r["DriverID"], r["FullName"], r["LicenceNumber"]); } } }
        }
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            // Soft delete - sets IsActive=0 - GDPR compliance
            bool ok = dm.DeleteDriver(Convert.ToInt32(hdnDriverID.Value));
            if (ok) { lblMessage.Text = "Driver deactivated!"; lblMessage.Visible = true; btnDelete.Enabled = false; Response.AddHeader("Refresh", "2;url=DriverList.aspx"); }
            else { lblError.Text = "Failed to deactivate."; lblError.Visible = true; }
        }
        protected void btnBack_Click(object sender, EventArgs e) { Response.Redirect("DriverList.aspx"); }
    }
}