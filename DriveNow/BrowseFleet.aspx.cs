// DriveNow — BrowseFleet.aspx Code-Behind
// Controls the public fleet browsing page where customers can see all available vehicles.
// Handles: showing vehicle cards, pre-booking banners, search pre-fill, and Book/Login button visibility.
// Module: CTEC2713N

using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DriveNow
{
    public partial class BrowseFleet : Page
    {
        // Runs when the Browse Fleet page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if the customer is logged in — determines whether to show Book or Login buttons
            bool loggedIn = Session["CustomerLoggedIn"] != null && (bool)Session["CustomerLoggedIn"];
            // Show the correct navigation links depending on login state
            phGuest.Visible    = !loggedIn;
            phLoggedIn.Visible =  loggedIn;

            // Only load the vehicle list on first visit — not every time a form is submitted
            if (!IsPostBack)
            {
                LoadVehicles(loggedIn);
                // Show a pre-booking banner when the customer arrived here from the homepage booking form
                if (Request.QueryString["from"] == "booking" && pnlBookingBanner != null)
                {
                    pnlBookingBanner.Visible = true;
                    // Read the pickup/drop-off locations saved from the homepage form
                    string pickup = Session["PreBookPickup"] as string;
                    string dropoff = Session["PreBookDropoff"] as string;
                    // Build the banner detail text showing their chosen route
                    if (!string.IsNullOrEmpty(pickup) || !string.IsNullOrEmpty(dropoff))
                    {
                        string detail = "";
                        if (!string.IsNullOrEmpty(pickup))  detail += " from <strong>" + Server.HtmlEncode(pickup) + "</strong>";
                        if (!string.IsNullOrEmpty(dropoff)) detail += " to <strong>" + Server.HtmlEncode(dropoff) + "</strong>";
                        lblBannerDetail.Text = detail;
                    }
                }
            }

            // If a search term was passed in the URL (e.g. from Default.aspx hero search), pre-fill it
            string searchTerm = (Request.QueryString["search"] ?? "").Replace("'", "");
            if (!string.IsNullOrEmpty(searchTerm))
            {
                // Inject JavaScript to set the search box value and trigger the filter on page load
                Page.ClientScript.RegisterStartupScript(GetType(), "search",
                    "window.addEventListener('load',function(){" +
                    "var i=document.getElementById('fleetSearch');if(i){i.value='" + searchTerm + "';filterBySearch('" + searchTerm + "');}" +
                    "});", true);
            }
        }

        // Fetches all available vehicles from the database and displays them as cards on the page
        private void LoadVehicles(bool loggedIn)
        {
            var manager  = new VehicleManager();
            var vehicles = manager.ListVehicles();

            // If no vehicles are found in the database, show an empty state message instead
            if (vehicles.Count == 0)
            {
                lblEmpty.Visible    = true;
                rptVehicles.Visible = false;
                return;
            }

            // Bind the vehicle list to the repeater — this generates one card per vehicle
            rptVehicles.DataSource = vehicles;
            rptVehicles.DataBind();

            // After binding, set the correct button visibility on each card
            foreach (RepeaterItem item in rptVehicles.Items)
            {
                var phBook  = (PlaceHolder)item.FindControl("phBookBtn");  // "Book Now" button
                var phLogin = (PlaceHolder)item.FindControl("phLoginBtn"); // "Login to Book" button
                // Logged-in customers see the Book button; guests see the Login button
                if (phBook != null)  phBook.Visible  =  loggedIn;
                if (phLogin != null) phLogin.Visible  = !loggedIn;
            }
        }

        // Builds the URL for a guest clicking "Login to Book" — sends to login, then back to book the vehicle
        protected string GetBookingLoginUrl(object vehicleID)
        {
            string returnUrl = "BookTrip.aspx?vid=" + vehicleID;
            return "Login.aspx?type=Customer&returnUrl=" + HttpUtility.UrlEncode(returnUrl);
        }

        // Returns the image URL for a vehicle card.
        // Prefers the vehicle's own uploaded photo (PhotoUrl) if available;
        // falls back to the stock image from CarImages.GetUrl().
        protected string GetCarImage(string make, string model, object photoUrl)
        {
            if (photoUrl != null && photoUrl != DBNull.Value)
            {
                string url = photoUrl.ToString();
                if (!string.IsNullOrEmpty(url)) return url;
            }
            return CarImages.GetUrl(make, model);
        }
    }
}
