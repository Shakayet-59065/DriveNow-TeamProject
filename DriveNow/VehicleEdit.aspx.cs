// ============================================================
// VehicleEdit.aspx.cs
// Component:   Vehicle Inventory — Presentation Layer
// Author:      Prodip
// Module:      CTEC2713N — DriveNow Agile Team Project
//
// WHY this page exists:
//   Vehicle details change over time — daily rates are updated,
//   registration plates may be corrected after data entry errors,
//   or a vehicle may be reassigned to a different date range.
//   Edit provides a safe, validated way to update any editable
//   field without touching IsAvailable (soft-delete is separate).
//
// WHY read the ID from the query string (not Session):
//   The Edit link on VehicleList passes ?id=3 in the URL.
//   Query string is the standard pattern for passing a record
//   identifier to an edit page — it is bookmarkable and allows
//   staff to share the URL for a specific vehicle.
//   Session would persist across navigation and could cause
//   the wrong vehicle to be edited if a second tab is open.
// ============================================================

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace DriveNow
{
    public partial class VehicleEdit : Page
    {
        // ------------------------------------------------
        // Page_Load
        // ------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            // Master prompt rule 5: session check on every Page_Load
            if (Session["LoggedIn"] == null || !(bool)Session["LoggedIn"])
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Read VehicleID from URL query string e.g. ?id=3
                string idParam = Request.QueryString["id"];

                // WHY redirect if no ID: the page cannot function
                // without knowing which vehicle to load. Redirecting
                // to the list is safer than showing an empty form.
                if (string.IsNullOrEmpty(idParam))
                {
                    Response.Redirect("VehicleList.aspx");
                    return;
                }

                int vehicleID;
                if (!int.TryParse(idParam, out vehicleID))
                {
                    // Malformed ID — redirect safely
                    Response.Redirect("VehicleList.aspx");
                    return;
                }

                // WHY store ID in HiddenField:
                //   On postback (Save button), the query string is
                //   still available but the HiddenField is more
                //   explicit and survives form submissions cleanly.
                hdnVehicleID.Value = vehicleID.ToString();
                LoadVehicle(vehicleID);
            }
        }

        // ------------------------------------------------
        // LoadVehicle
        //
        // WHY include soft-deleted vehicles here:
        //   A staff member might navigate to VehicleEdit directly
        //   (e.g. from a bookmark) for a vehicle that was removed.
        //   Showing a clear "not found" message is better than
        //   a crash. FindVehicle includes IsAvailable = 0 records
        //   so we can show the appropriate message.
        // ------------------------------------------------
        private void LoadVehicle(int vehicleID)
        {
            VehicleManager manager = new VehicleManager();
            Vehicle v = manager.FindVehicle(vehicleID);

            if (v == null)
            {
                lblNotFound.Text = "Vehicle #VEH-" + vehicleID.ToString("D3") +
                                      " was not found.";
                lblNotFound.Visible = true;
                btnSave.Visible = false;
                return;
            }

            // Populate form with current values from the database
            txtRegistrationNo.Text = v.RegistrationNo;
            txtMake.Text           = v.Make;
            txtModel.Text          = v.Model;
            txtDailyRate.Text      = v.DailyRate.ToString("N2");
            txtDateAdded.Text      = v.DateAdded.ToString("yyyy-MM-dd");
            ddlSeats.SelectedValue = v.Seats.ToString();

            // ── Photo preview ──────────────────────────────────────────────
            // Always show the current display image so staff know what
            // customers see on BrowseFleet before uploading a replacement.
            //
            // Priority: 1) uploaded PhotoUrl stored in tblVehicle
            //           2) auto-generated stock image from CarImages (CDN)
            string photoUrl = GetCurrentPhotoUrl(vehicleID);
            pnlCurrentPhoto.Visible = true;
            if (!string.IsNullOrEmpty(photoUrl))
            {
                // Uploaded custom photo — show it with Remove option
                hfCurrentPhotoUrl.Value = photoUrl;
                imgCurrentPhoto.Src     = ResolveUrl("~/" + photoUrl.TrimStart('/'));
                chkRemovePhoto.Visible  = true;
                lblCurrentPhotoCaption.Text = "Current uploaded photo:";
            }
            else
            {
                // No custom photo — show the stock image currently displayed to customers
                string stockUrl = CarImages.GetUrl(v.Make, v.Model);
                imgCurrentPhoto.Src     = stockUrl;
                chkRemovePhoto.Visible  = false;  // nothing to remove
                lblCurrentPhotoCaption.Text = "Currently showing (stock image — upload your own below):";
            }
        }

        // Gets the current PhotoUrl from tblVehicle via direct SQL.
        // Returns null if column doesn't exist or no photo set.
        private string GetCurrentPhotoUrl(int vehicleID)
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT PhotoUrl FROM tblVehicle WHERE VehicleID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", vehicleID);
                    object val = cmd.ExecuteScalar();
                    return (val != null && val != DBNull.Value) ? val.ToString() : null;
                }
            }
            catch { return null; }
        }

        // ------------------------------------------------
        // btnSave_Click
        // ------------------------------------------------
        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblError.Visible = false;
            lblSuccess.Visible = false;

            int vehicleID = Convert.ToInt32(hdnVehicleID.Value);

            Vehicle v = new Vehicle();
            v.VehicleID = vehicleID;
            v.RegistrationNo = txtRegistrationNo.Text.Trim().ToUpper();
            v.Make = txtMake.Text.Trim();
            v.Model = txtModel.Text.Trim();

            decimal dailyRate;
            if (!decimal.TryParse(txtDailyRate.Text.Trim(), out dailyRate))
            {
                lblError.Text = "Daily rate must be a valid number e.g. 45.00";
                lblError.Visible = true;
                return;
            }
            v.DailyRate = dailyRate;

            DateTime dateAdded;
            if (!DateTime.TryParse(txtDateAdded.Text.Trim(), out dateAdded))
            {
                lblError.Text = "Please enter a valid date for Date Added.";
                lblError.Visible = true;
                return;
            }
            v.DateAdded = dateAdded;
            v.Seats     = int.Parse(ddlSeats.SelectedValue);

            VehicleManager manager = new VehicleManager();
            List<string> errors = manager.ValidateVehicle(v);

            if (errors.Count > 0)
            {
                lblError.Text = string.Join("<br />", errors);
                lblError.Visible = true;
                return;
            }

            // Pre-save duplicate registration check (uses spCheckDuplicateVehicleReg if available)
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand chk = new SqlCommand("spCheckDuplicateVehicleReg", conn))
                {
                    chk.CommandType = CommandType.StoredProcedure;
                    chk.Parameters.AddWithValue("@RegistrationNo",  v.RegistrationNo);
                    chk.Parameters.AddWithValue("@ExcludeVehicleID", v.VehicleID);
                    object result = chk.ExecuteScalar();
                    if (result != null && Convert.ToInt32(result) > 0)
                    {
                        lblError.Text    = "Registration number '" + v.RegistrationNo + "' is already used by another vehicle. Please use a unique plate.";
                        lblError.Visible = true;
                        return;
                    }
                }
            }
            catch { /* Script 30 not yet run — fall through to UNIQUE constraint catch below */ }

            try
            {
                manager.EditVehicle(v);

                // Handle photo: remove, replace, or leave as-is
                if (chkRemovePhoto.Checked)
                    TrySavePhotoUrl(vehicleID, null);           // null = clear
                else if (fuVehiclePhoto.HasFile)
                    TrySaveVehiclePhoto(vehicleID, v.Make, v.Model); // upload new

                lblSuccess.Text = "Vehicle #VEH-" + vehicleID.ToString("D3") +
                                     " updated successfully.";
                lblSuccess.Visible = true;

                // Reload photo panel to reflect any change
                string photoUrl = GetCurrentPhotoUrl(vehicleID);
                pnlCurrentPhoto.Visible = true;
                if (!string.IsNullOrEmpty(photoUrl))
                {
                    hfCurrentPhotoUrl.Value = photoUrl;
                    imgCurrentPhoto.Src     = ResolveUrl("~/" + photoUrl.TrimStart('/'));
                    chkRemovePhoto.Visible  = true;
                    lblCurrentPhotoCaption.Text = "Current uploaded photo:";
                }
                else
                {
                    // Revert to stock image preview after removal
                    imgCurrentPhoto.Src     = CarImages.GetUrl(v.Make, v.Model);
                    chkRemovePhoto.Visible  = false;
                    lblCurrentPhotoCaption.Text = "Currently showing (stock image — upload your own below):";
                }
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("UNIQUE") || ex.Message.Contains("duplicate"))
                    lblError.Text = "That registration number is already used by another vehicle.";
                else
                    lblError.Text = "An error occurred while saving. Please try again.";

                lblError.Visible = true;
            }
        }

        // Saves a new photo upload to Content/cars/ and updates PhotoUrl in tblVehicle.
        private void TrySaveVehiclePhoto(int vehicleID, string make, string model)
        {
            try
            {
                string dir = Server.MapPath("~/Content/cars/");
                Directory.CreateDirectory(dir);
                string ext      = Path.GetExtension(fuVehiclePhoto.FileName).ToLower();
                string fileName = (make + " " + model).Trim() + ext;
                fuVehiclePhoto.SaveAs(Path.Combine(dir, fileName));
                TrySavePhotoUrl(vehicleID, "Content/cars/" + fileName);
            }
            catch { }
        }

        // Writes (or clears) the PhotoUrl column in tblVehicle.
        // Pass null to remove the photo.
        private void TrySavePhotoUrl(int vehicleID, string relUrl)
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tblVehicle SET PhotoUrl=@url WHERE VehicleID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@url", relUrl != null ? (object)relUrl : DBNull.Value);
                    cmd.Parameters.AddWithValue("@id",  vehicleID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* PhotoUrl column requires Script 27 */ }
        }
    }
}