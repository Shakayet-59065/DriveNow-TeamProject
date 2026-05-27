using System;
using System.Web;

namespace DriveNow
{
    public partial class BookingConfirmed : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth guard
            if (Session["CustomerLoggedIn"] == null || !(bool)Session["CustomerLoggedIn"])
            {
                Response.Redirect("Login.aspx?type=Customer");
                return;
            }

            // Refresh / direct-navigation guard
            string bookingRef = Session["BookingRef"] as string;
            if (string.IsNullOrEmpty(bookingRef))
            {
                Response.Redirect("CustomerPortal.aspx");
                return;
            }

            // Populate display fields
            string vehicle      = Session["BookingVehicle"]     as string ?? "";
            string pickup       = Session["BookingPickup"]      as string ?? "";
            string dropoff      = Session["BookingDropoff"]     as string ?? "";
            string insurance    = Session["BookingInsurance"]   as string ?? "";
            string addons       = Session["BookingAddons"]      as string ?? "";
            string total        = Session["BookingTotal"]       as string ?? "";
            string days         = Session["BookingDays"]        as string ?? "";
            string tripTypeName = Session["BookingTripType"]    as string ?? "";
            bool   needsDriver  = (Session["BookingNeedsDriver"] as string) == "1";

            litBookingRef.Text = HttpUtility.HtmlEncode(bookingRef);
            litVehicle.Text    = HttpUtility.HtmlEncode(vehicle);
            litPickup.Text     = HttpUtility.HtmlEncode(pickup);
            litDropoff.Text    = HttpUtility.HtmlEncode(dropoff);
            litDays.Text       = HttpUtility.HtmlEncode(days) + (days == "1" ? " day" : " days");
            litInsurance.Text  = HttpUtility.HtmlEncode(insurance);
            litAddons.Text     = string.IsNullOrWhiteSpace(addons)
                                 ? "<span style='color:#94A3B8;'>None selected</span>"
                                 : HttpUtility.HtmlEncode(addons);
            litTotal.Text      = HttpUtility.HtmlEncode(total);

            // Contextual instruction box — driver trips vs self-drive
            string safeRef      = HttpUtility.HtmlEncode(bookingRef);
            string safeTripType = HttpUtility.HtmlEncode(tripTypeName);
            if (needsDriver)
            {
                litInstructions.Text =
                    "<div class=\"info-box\">"
                    + "<strong>Your Driver Will Meet You</strong><br />"
                    + "Your assigned driver will be waiting for you at your <strong>pickup location</strong> "
                    + "at the confirmed time. Look for the <strong>DriveNow sign</strong>.<br /><br />"
                    + "Please bring your <strong>booking reference</strong> (" + safeRef + ") "
                    + "and a valid <strong>photo ID</strong>. "
                    + "If you need to contact your driver, our support team is available 24/7."
                    + "</div>";
            }
            else
            {
                litInstructions.Text =
                    "<div class=\"info-box\">"
                    + "<strong>Key Collection Instructions</strong><br />"
                    + "Your keys will be ready at the <strong>DriveNow desk</strong> at your pickup location. "
                    + "Please bring your <strong>booking reference</strong> (" + safeRef + ") "
                    + "and a valid <strong>photo ID</strong>. "
                    + "The vehicle will be parked and ready for you."
                    + "</div>";
            }

            // Clear session booking keys so refresh doesn't re-show stale data
            Session.Remove("BookingRef");
            Session.Remove("BookingVehicle");
            Session.Remove("BookingPickup");
            Session.Remove("BookingDropoff");
            Session.Remove("BookingInsurance");
            Session.Remove("BookingAddons");
            Session.Remove("BookingTotal");
            Session.Remove("BookingDays");
            Session.Remove("BookingTripType");
            Session.Remove("BookingNeedsDriver");
        }
    }
}
