using System;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow
{
    public partial class StaffEdit : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
                Response.Redirect("Login.aspx");
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
                Response.Redirect("StaffList.aspx");

            if (!IsPostBack)
            {
                string id = Request.QueryString["id"];
                if (string.IsNullOrEmpty(id)) { Response.Redirect("StaffList.aspx"); return; }
                hdnStaffID.Value = id;
                LoadStaff(Convert.ToInt32(id));
            }
        }

        private void LoadStaff(int staffID)
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT FullName, Username, Email, Phone, Role, IsActive FROM tblStaff WHERE StaffID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", staffID);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) { Response.Redirect("StaffList.aspx"); return; }
                        txtFullName.Text = dr["FullName"] != DBNull.Value ? dr["FullName"].ToString() : "";
                        txtUsername.Text = dr["Username"] != DBNull.Value ? dr["Username"].ToString() : "";
                        txtEmail.Text    = dr["Email"]    != DBNull.Value ? dr["Email"].ToString()    : "";
                        txtPhone.Text    = dr["Phone"]    != DBNull.Value ? dr["Phone"].ToString()    : "";

                        string role = dr["Role"] != DBNull.Value ? dr["Role"].ToString() : "Staff";
                        if (ddlRole.Items.FindByValue(role) != null)
                            ddlRole.SelectedValue = role;

                        bool isActive = dr["IsActive"] != DBNull.Value && Convert.ToBoolean(dr["IsActive"]);
                        btnToggleActive.Text = isActive ? "Deactivate Account" : "Reactivate Account";
                        btnToggleActive.CssClass = isActive ? "dn-action-del" : "dn-btn dn-btn-secondary";
                    }
                }
            }
            catch
            {
                ShowError("Could not load the staff record. Please go back and try again.");
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblError.Visible   = false;
            lblMessage.Visible = false;

            string fullName = txtFullName.Text.Trim();
            string email    = txtEmail.Text.Trim();
            string phone    = txtPhone.Text.Trim();
            string role     = ddlRole.SelectedValue;
            string newPwd   = txtNewPassword.Text;
            string confPwd  = txtConfirmPassword.Text;

            if (string.IsNullOrEmpty(fullName)) { ShowError("Full name is required."); return; }

            bool changePwd = !string.IsNullOrEmpty(newPwd);
            if (changePwd)
            {
                if (newPwd.Length < 8)
                { ShowError("Password must be at least 8 characters."); return; }
                if (!System.Text.RegularExpressions.Regex.IsMatch(newPwd, @"[A-Z]") ||
                    !System.Text.RegularExpressions.Regex.IsMatch(newPwd, @"\d"))
                { ShowError("Password must contain at least 1 uppercase letter and 1 number."); return; }
                if (newPwd != confPwd)
                { ShowError("Passwords do not match."); return; }
            }

            int staffID = Convert.ToInt32(hdnStaffID.Value);
            try
            {
                string sql = changePwd
                    ? "UPDATE tblStaff SET FullName=@fn, Email=@em, Phone=@ph, Role=@role, PasswordHash=@pw WHERE StaffID=@id"
                    : "UPDATE tblStaff SET FullName=@fn, Email=@em, Phone=@ph, Role=@role               WHERE StaffID=@id";

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@fn",   fullName);
                    cmd.Parameters.AddWithValue("@em",   string.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
                    cmd.Parameters.AddWithValue("@ph",   string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                    cmd.Parameters.AddWithValue("@role", role);
                    cmd.Parameters.AddWithValue("@id",   staffID);
                    if (changePwd)
                        cmd.Parameters.AddWithValue("@pw", PasswordHelper.HashPassword(newPwd));
                    cmd.ExecuteNonQuery();
                }

                txtNewPassword.Text     = "";
                txtConfirmPassword.Text = "";

                lblMessage.Text    = "&#10003; Staff record updated successfully.";
                lblMessage.Visible = true;

                // Reload to refresh button text
                LoadStaff(staffID);
            }
            catch
            {
                ShowError("Could not save changes. Please check your input and try again.");
            }
        }

        protected void btnToggleActive_Click(object sender, EventArgs e)
        {
            int staffID = Convert.ToInt32(hdnStaffID.Value);
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tblStaff SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE StaffID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", staffID);
                    cmd.ExecuteNonQuery();
                }
                lblMessage.Text    = "&#10003; Staff account status updated.";
                lblMessage.Visible = true;
                lblError.Visible   = false;
                LoadStaff(staffID);
            }
            catch
            {
                ShowError("Could not update account status. Please try again.");
            }
        }

        protected void btnHardDelete_Click(object sender, EventArgs e)
        {
            int staffID = Convert.ToInt32(hdnStaffID.Value);
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("DELETE FROM tblStaff WHERE StaffID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", staffID);
                    cmd.ExecuteNonQuery();
                }
                Response.Redirect("StaffList.aspx?deleted=1");
            }
            catch
            {
                ShowError("Could not delete this staff member. The account may be referenced by existing records.");
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text    = msg;
            lblError.Visible = true;
        }
    }
}
