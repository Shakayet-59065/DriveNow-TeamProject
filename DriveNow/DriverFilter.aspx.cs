// DriverFilter.aspx.cs - Developer: Redoy (59065) - Filters drivers
using System;
using System.Data;
namespace DriveNow
{
    public partial class DriverFilter : System.Web.UI.Page
    {
        DriverManager dm = new DriverManager();
        protected void Page_Load(object sender, EventArgs e) { if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"]) Response.Redirect("Login.aspx"); }
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            DateTime? from = null, to = null; bool? isActive = null;
            if (!string.IsNullOrEmpty(txtDateFrom.Text.Trim())) { DateTime d; if (!DateTime.TryParse(txtDateFrom.Text.Trim(), out d)) { lblError.Text = "Invalid From date."; lblError.Visible = true; return; } from = d; }
            if (!string.IsNullOrEmpty(txtDateTo.Text.Trim())) { DateTime d; if (!DateTime.TryParse(txtDateTo.Text.Trim(), out d)) { lblError.Text = "Invalid To date."; lblError.Visible = true; return; } to = d; }
            if (!string.IsNullOrEmpty(ddlStatus.SelectedValue)) isActive = ddlStatus.SelectedValue == "1";
            DataTable dt = dm.FilterDrivers(from, to, isActive);
            lblError.Visible = false; gvResults.DataSource = dt; gvResults.DataBind(); gvResults.Visible = true;
        }
    }
}