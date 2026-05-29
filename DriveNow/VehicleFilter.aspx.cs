// ============================================================
// VehicleFilter.aspx.cs
// Component:   Vehicle Inventory — Presentation Layer
// Author:      Prodip
// Module:      CTEC2713N — DriveNow Agile Team Project
//
// WHY this page exists:
//   The list page shows all active vehicles. Staff sometimes
//   need a subset — e.g. vehicles added this year, or all
//   removed vehicles for a fleet audit. Filter provides
//   flexible querying without needing a custom stored procedure
//   for each combination.
//
// WHY two optional filters rather than one mandatory one:
//   Forcing staff to always fill in both filters would be
//   frustrating when they only care about one dimension.
//   Optional filters (both can be blank = show all) give
//   maximum flexibility with minimum friction.
// ============================================================

using System;
using System.Collections.Generic;
using System.Web.UI;

namespace DriveNow
{
    public partial class VehicleFilter : Page
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
        // btnFilter_Click
        //
        // WHY convert dropdown value to bool? not string:
        //   VehicleManager.FilterVehicles expects bool? so the
        //   middle layer handles the SQL NULL logic correctly.
        //   Converting here keeps the ASPX page responsible only
        //   for reading form controls — the manager handles data.
        //
        // WHY show result count above the table:
        //   If 47 vehicles match, staff know immediately without
        //   scrolling through the whole table. If 0 match, the
        //   count message explains this before the table appears.
        // ------------------------------------------------
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            lblResultCount.Visible = false;
            lblNoResults.Visible = false;
            pnlResults.Visible = false;

            // Convert dropdown selection to nullable bool
            // Empty string = no filter, "1" = active, "0" = removed
            bool? availabilityFilter = null;
            if (ddlAvailability.SelectedValue == "1") availabilityFilter = true;
            else if (ddlAvailability.SelectedValue == "0") availabilityFilter = false;

            // Convert date text box to nullable DateTime
            // Empty = no date filter applied
            DateTime? dateFrom = null;
            if (!string.IsNullOrWhiteSpace(txtDateFrom.Text))
            {
                DateTime parsedDate;
                if (DateTime.TryParse(txtDateFrom.Text.Trim(), out parsedDate))
                    dateFrom = parsedDate;
            }

            // Call the middle layer — it calls spFilterVehicles
            VehicleManager manager = new VehicleManager();
            List<Vehicle> results = manager.FilterVehicles(availabilityFilter, dateFrom);

            if (results.Count == 0)
            {
                lblNoResults.Text = "No vehicles found matching the selected filter. " +
                                       "Try adjusting your criteria or clearing the filter.";
                lblNoResults.Visible = true;
                return;
            }

            gvResults.DataSource = results;
            gvResults.DataBind();

            lblResultCount.Text = results.Count + " vehicle(s) found matching your filter.";
            lblResultCount.Visible = true;
            pnlResults.Visible = true;
        }

        // ------------------------------------------------
        // btnClear_Click
        //
        // WHY reset SelectedIndex to 0 not SelectedValue to "":
        //   DropDownList.SelectedValue setter does not always
        //   trigger a re-render. Setting SelectedIndex = 0
        //   always selects the first item reliably.
        // ------------------------------------------------
        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlAvailability.SelectedIndex = 0;
            txtDateFrom.Text = "";
            lblResultCount.Visible = false;
            lblNoResults.Visible = false;
            pnlResults.Visible = false;
        }
    }
}