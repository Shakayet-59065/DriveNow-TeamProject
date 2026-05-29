// ============================================================
// VehicleFind.aspx.cs
// Component:   Vehicle Inventory — Presentation Layer
// Author:      Prodip
// Module:      CTEC2713N — DriveNow Agile Team Project
//
// WHY this page exists:
//   The list page shows active vehicles only. Staff sometimes
//   need to look up a specific vehicle by ID — including
//   soft-deleted ones — for audit, dispute resolution, or
//   to reactivate a previously removed vehicle. Find by ID
//   is the fastest way to locate a single known record.
//
// WHY Find shows soft-deleted vehicles but List does not:
//   List is for browsing the active fleet — retired vehicles
//   would clutter it. Find is for targeted lookup of a known
//   record — hiding it would be misleading and unhelpful.
//   The status dot (green/red) clearly shows if it is active.
// ============================================================

using System;
using System.Web.UI;

namespace DriveNow
{
    public partial class VehicleFind : Page
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
        }

        // ------------------------------------------------
        // btnFind_Click
        //
        // WHY validate ID > 0 as well as TryParse:
        //   TryParse accepts 0 and negative numbers.
        //   VehicleIDs start at 1 (IDENTITY(1,1)) so 0 or
        //   negative can never be a valid vehicle — catching
        //   this gives a more specific error message.
        // ------------------------------------------------
        protected void btnFind_Click(object sender, EventArgs e)
        {
            lblError.Visible = false;
            pnlResult.Visible = false;

            if (string.IsNullOrWhiteSpace(txtVehicleID.Text))
            {
                lblError.Text = "Please enter a Vehicle ID to search for.";
                lblError.Visible = true;
                return;
            }

            int vehicleID;
            if (!int.TryParse(txtVehicleID.Text.Trim(), out vehicleID) || vehicleID <= 0)
            {
                lblError.Text = "Vehicle ID must be a positive whole number e.g. 3";
                lblError.Visible = true;
                return;
            }

            VehicleManager manager = new VehicleManager();
            Vehicle v = manager.FindVehicle(vehicleID);

            if (v == null)
            {
                lblError.Text = "No vehicle found with ID " + vehicleID +
                                   ". Please check the number and try again.";
                lblError.Visible = true;
                return;
            }

            // Populate result card with vehicle data
            lblVehicleID.Text = "#VEH-" + v.VehicleID.ToString("D3");
            lblRegistrationNo.Text = v.RegistrationNo;
            lblMake.Text = v.Make;
            lblModel.Text = v.Model;
            lblDailyRate.Text = "&pound;" + v.DailyRate.ToString("N2");
            lblDateAdded.Text = v.DateAdded.ToString("dd MMM yyyy");

            // WHY use HTML for status dots not an image:
            //   CSS dots defined in Site.css are consistent across
            //   the whole system. They scale with font size and
            //   require no image files or additional HTTP requests.
            if (v.IsAvailable)
                lblStatus.Text = "<span class=\"dn-status\"><span class=\"dn-dot-green\"></span> Active</span>";
            else
                lblStatus.Text = "<span class=\"dn-status\"><span class=\"dn-dot-red\"></span> Removed from service</span>";

            // Set Edit link URL to pass VehicleID as query string
            lnkEdit.NavigateUrl = "VehicleEdit.aspx?id=" + v.VehicleID;

            pnlResult.Visible = true;
        }

        // ------------------------------------------------
        // btnClear_Click
        //
        // WHY clear hides the result panel:
        //   If the user searches again immediately after a result,
        //   the old result card would flicker before the new one
        //   appears. Hiding on clear gives a clean starting state.
        // ------------------------------------------------
        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtVehicleID.Text = "";
            lblError.Visible = false;
            pnlResult.Visible = false;
        }
    }
}