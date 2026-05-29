// ============================================================
// VehicleAdd.aspx.cs
// Component:   Vehicle Inventory — Presentation Layer
// Author:      Prodip
// Module:      CTEC2713N — DriveNow Agile Team Project
//
// WHY this page exists:
//   Staff add new vehicles when a contributor's vehicle is
//   approved, when DriveNow purchases a new vehicle, or when
//   correcting a missing record. This is an admin-only action —
//   customers never add vehicles directly.
//
// WHY validation happens here AND in VehicleManager:
//   This page validates before calling the manager so the user
//   gets a helpful error message if input is wrong. The manager
//   validates again as a safety net — if a future page calls
//   AddVehicle() without validating, the rules still apply.
//   Defence in depth: never trust input from any layer above.
// ============================================================

using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace DriveNow
{
    public partial class VehicleAdd : Page
    {
        // ------------------------------------------------
        // Page_Load
        //
        // WHY set today's date as default for DateAdded:
        //   Most vehicles are added on the day they join the fleet.
        //   Pre-filling today's date reduces keystrokes and data
        //   entry errors. Staff can still change it if needed.
        //
        // WHY only set the default on !IsPostBack:
        //   On postback (after clicking Save), the TextBox values
        //   are already populated from the user's input. Setting
        //   the default again would overwrite what they typed.
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
                // Pre-fill today's date — most vehicles added same day
                txtDateAdded.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }

        // ------------------------------------------------
        // btnSave_Click
        //
        // WHY TryParse for DailyRate and DateAdded:
        //   TextBox.Text is always a string. If the user types
        //   "abc" in the rate field, decimal.Parse would throw
        //   an unhandled exception and crash the page with a
        //   yellow error screen. TryParse returns false safely
        //   so we can show a user-friendly message instead.
        //
        // WHY ToUpper() for RegistrationNo:
        //   UK registration plates are uppercase by convention.
        //   Storing them consistently prevents duplicates like
        //   "AB21 HKL" and "ab21 hkl" being treated as different.
        //   The UNIQUE constraint is case-insensitive in SQL Server
        //   by default, but consistent casing prevents confusion.
        // ------------------------------------------------
        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblError.Visible = false;
            lblSuccess.Visible = false;

            // Build Vehicle object from form inputs
            Vehicle v = new Vehicle();
            v.RegistrationNo = txtRegistrationNo.Text.Trim().ToUpper();
            v.Make = txtMake.Text.Trim();
            v.Model = txtModel.Text.Trim();

            // Parse DailyRate — show user-friendly error if not numeric
            decimal dailyRate;
            if (!decimal.TryParse(txtDailyRate.Text.Trim(), out dailyRate))
            {
                lblError.Text = "Daily rate must be a valid number e.g. 45.00";
                lblError.Visible = true;
                return;
            }
            v.DailyRate = dailyRate;

            // Parse DateAdded — show user-friendly error if invalid
            DateTime dateAdded;
            if (!DateTime.TryParse(txtDateAdded.Text.Trim(), out dateAdded))
            {
                lblError.Text = "Please enter a valid date for Date Added.";
                lblError.Visible = true;
                return;
            }
            v.DateAdded = dateAdded;
            v.Seats     = int.Parse(ddlSeats.SelectedValue);

            // Validate using middle layer business rules
            VehicleManager manager = new VehicleManager();
            List<string> errors = manager.ValidateVehicle(v);

            if (errors.Count > 0)
            {
                // Show all errors at once — better UX than one at a time
                lblError.Text = string.Join("<br />", errors);
                lblError.Visible = true;
                return;
            }

            try
            {
                // All validation passed — call the data layer
                int newID = manager.AddVehicle(v);

                // Save uploaded photo (if provided) to Content/cars/ and record path in DB
                if (fuVehiclePhoto.HasFile)
                    TrySaveVehiclePhoto(newID, v.Make, v.Model);

                lblSuccess.Text = "Vehicle added successfully. " +
                                     "Assigned ID: #VEH-" + newID.ToString("D3");
                lblSuccess.Visible = true;

                // Clear form so staff can add another vehicle straight away
                txtRegistrationNo.Text = "";
                txtMake.Text           = "";
                txtModel.Text          = "";
                txtDailyRate.Text      = "";
                ddlSeats.SelectedValue = "5";
                txtDateAdded.Text      = DateTime.Today.ToString("yyyy-MM-dd");
            }
            catch (Exception ex)
            {
                // WHY check for UNIQUE keyword in exception message:
                //   SQL Server raises error 2627 for UNIQUE constraint
                //   violations. The exception message contains "UNIQUE"
                //   or "duplicate key". Checking for this gives a
                //   specific, helpful message instead of a generic one.
                if (ex.Message.Contains("UNIQUE") || ex.Message.Contains("duplicate"))
                {
                    lblError.Text = "That registration number already exists. " +
                                    "Each vehicle must have a unique registration plate.";
                }
                else
                {
                    lblError.Text = "An error occurred while saving. Please try again.";
                }
                lblError.Visible = true;
            }
        }

        // Saves the uploaded vehicle photo and writes the relative path to tblVehicle.PhotoUrl.
        // Uses the vehicle's make+model to name the file so CarImages.GetUrl can also use it.
        // Best-effort — swallows exceptions if PhotoUrl column not yet added by Script 27.
        private void TrySaveVehiclePhoto(int vehicleID, string make, string model)
        {
            try
            {
                string dir = Server.MapPath("~/Content/cars/");
                Directory.CreateDirectory(dir);
                string ext      = Path.GetExtension(fuVehiclePhoto.FileName).ToLower();
                string fileName = (make + " " + model).Trim() + ext;
                string fullPath = Path.Combine(dir, fileName);
                fuVehiclePhoto.SaveAs(fullPath);
                string relUrl = "Content/cars/" + fileName;

                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE tblVehicle SET PhotoUrl=@url WHERE VehicleID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@url", relUrl);
                    cmd.Parameters.AddWithValue("@id",  vehicleID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* PhotoUrl column requires Script 27 to be run first */ }
        }
    }
}
