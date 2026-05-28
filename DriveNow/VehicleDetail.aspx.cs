using System;
using System.Web;

namespace DriveNow
{
    public partial class VehicleDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            bool loggedIn = Session["CustomerLoggedIn"] != null && (bool)Session["CustomerLoggedIn"];
            phGuest.Visible    = !loggedIn;
            phLoggedIn.Visible =  loggedIn;

            int vehicleID;
            if (!int.TryParse(Request.QueryString["vid"], out vehicleID) || vehicleID <= 0)
            {
                ShowNotFound();
                return;
            }

            var mgr = new VehicleManager();
            Vehicle v = mgr.FindVehicle(vehicleID);
            if (v == null) { ShowNotFound(); return; }

            string fullName = v.Make + " " + v.Model;
            string mk = v.Make.ToLower().Trim();
            string mo = v.Model.ToLower().Trim();

            litPageTitle.Text   = fullName;
            litBreadcrumb.Text  = fullName;
            litVehicleName.Text = fullName;
            litReg.Text         = v.RegistrationNo;
            litRate.Text        = v.DailyRate.ToString("N2");
            imgVehicle.ImageUrl = GetCarImage(v.Make, v.Model);
            imgVehicle.Attributes["class"] = "vehicle-img-wrap img";
            imgVehicle.AlternateText       = fullName;

            // Use REAL seat count from database — not a hardcoded guess
            litSeats.Text    = v.Seats.ToString() + " Seats";
            litCategory.Text = GetCategory(mk, mo, v.DailyRate, v.Seats);
            litDoors.Text    = GetDoors(mk, mo, v.Seats);
            litMileage.Text  = GetMileage(v.VehicleID);

            if (loggedIn)
            {
                phBookBtn.Visible  = true;
                phLoginBtn.Visible = false;
                bookLink.HRef = "BookTrip.aspx?vid=" + vehicleID;
            }
            else
            {
                phBookBtn.Visible  = false;
                phLoginBtn.Visible = true;
                // Store return URL in session so Default.aspx login handler can redirect back after login
                Session["LoginReturnUrl"] = "BookTrip.aspx?vid=" + vehicleID;
                loginLink.HRef = "Default.aspx?openlogin=1";
            }
        }

        private void ShowNotFound()
        {
            pnlNotFound.Visible = true;
            pnlDetail.Visible   = false;
        }

        // ── GetCarImage ────────────────────────────────────────────────────────
        private string GetCarImage(string make, string model)
        {
            return CarImages.GetUrl(make, model);
        }

        // ── GetCategory ────────────────────────────────────────────────────────
        // Derives a display category from make + model + price band + seat count
        private string GetCategory(string mk, string mo, decimal dailyRate, int seats)
        {
            // Segment by model name first for accuracy
            if (mk == "ferrari" || mk == "mclaren" ||
                (mk == "porsche" && (mo.Contains("911") || mo.Contains("718") || mo.Contains("boxster"))) ||
                (mk == "mercedes" && mo.Contains("amg gt")) ||
                mk == "aston martin")
                return "Sports Car";

            if (mk == "smart" || (mk == "fiat" && mo.Contains("500")) ||
                (mk == "mini" && mo.Contains("convert")))
                return "City Car";

            if (mk == "mini")
                return "Premium Hatchback";

            if (mk == "rolls royce")  return "Ultra Luxury Limousine";
            if (mk == "bentley")      return "Luxury Grand Tourer";
            if (mk == "maserati")     return "Luxury Sports Sedan";
            if (mk == "lamborghini")  return "Supercar SUV";
            if (mk == "range rover")  return "Luxury SUV";
            if (mk == "jaguar")       return "Luxury SUV";

            if (seats >= 7) return "7-Seat MPV / People Carrier";

            if (mk == "tesla")  return "Electric " + (dailyRate > 100 ? "Luxury" : "Mid-Range") + " Sedan";
            if (mk == "volvo" || mk == "subaru" || mk == "mazda")
                return "Premium Crossover";

            if (dailyRate > 150) return "Luxury Sedan";
            if (dailyRate > 100) return "Premium SUV / Saloon";
            if (dailyRate > 60)  return "Executive Sedan";

            // Budget hatchbacks / compacts
            if (mo.Contains("suv") || mo.Contains("crossover") ||
                mo.Contains("rav") || mo.Contains("qashqai") || mo.Contains("tucson") ||
                mo.Contains("kuga") || mo.Contains("duster") || mo.Contains("cr-v"))
                return "Compact SUV";

            return "Compact Hatchback";
        }

        // ── GetDoors ───────────────────────────────────────────────────────────
        private string GetDoors(string mk, string mo, int seats)
        {
            // Convertibles and pure sports are 2-door
            if (mk == "ferrari" || mk == "mclaren" || mk == "aston martin")
                return "2 Doors";
            if (mo.Contains("convert") || mo.Contains("cabriolet") || mo.Contains("roadster"))
                return "2 Doors";
            if (mk == "porsche" && (mo.Contains("911") || mo.Contains("718") || mo.Contains("boxster")))
                return "2 Doors";
            if (mk == "smart")
                return "2 Doors";
            if (mk == "mercedes" && mo.Contains("amg gt"))
                return "2 Doors";
            // Everything else 4/5-door
            return "4 Doors";
        }

        // ── GetMileage ─────────────────────────────────────────────────────────
        private string GetMileage(int vehicleID)
        {
            int[] miles = { 4200, 8100, 6300, 3900, 9500, 5700, 7200, 2800, 11400, 6800 };
            int idx = (vehicleID - 1) % miles.Length;
            return miles[idx < 0 ? 0 : idx].ToString("N0") + " miles";
        }
    }
}
