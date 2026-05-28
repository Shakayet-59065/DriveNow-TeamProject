// DriverFind.aspx.cs - Developer: Redoy (59065) - Finds driver by ID or name
using System;
using System.Data;
namespace DriveNow
{
    public partial class DriverFind : System.Web.UI.Page
    {
        DriverManager dm = new DriverManager();
        protected void Page_Load(object sender, EventArgs e) { if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"]) Response.Redirect("Login.aspx"); }
        protected void btnFind_Click(object sender, EventArgs e)
        {
            string idText = txtDriverID.Text.Trim(), name = txtFullName.Text.Trim();
            if (string.IsNullOrEmpty(idText) && string.IsNullOrEmpty(name)) { lblError.Text = "Enter a Driver ID or Full Name."; lblError.Visible = true; gvResults.Visible = false; return; }
            int? driverID = null;
            if (!string.IsNullOrEmpty(idText)) { int p; if (!int.TryParse(idText, out p)) { lblError.Text = "Driver ID must be a number."; lblError.Visible = true; return; } driverID = p; }
            DataTable dt = dm.FindDriver(driverID, string.IsNullOrEmpty(name) ? null : name);
            lblError.Visible = false; gvResults.DataSource = dt; gvResults.DataBind(); gvResults.Visible = true;
        }
    }
}