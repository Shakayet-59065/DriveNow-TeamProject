// DriveNow — Car Images Helper
// Returns relative URLs for local car photos stored in Content/cars/.
// Images were sourced from the project's img folder and matched by make/model.
// GetUrl() selects the most specific image available, falling back to a class default.
// Module: CTEC2713N

using System;

namespace DriveNow
{
    public static class CarImages
    {
        // Base path for all local car images — relative to site root
        private const string BASE = "Content/cars/";

        public static string GetUrl(string make, string model)
        {
            string mk = (make  ?? "").ToLower().Trim();
            string mo = (model ?? "").ToLower().Trim();

            // ── SUPERCARS ────────────────────────────────────────────────────────
            if (mk == "ferrari")
                return BASE + "ferrari 488 GTB.jpg";

            if (mk == "lamborghini")
                return BASE + "lamborgini urus.jpg";

            if (mk == "mclaren")
                return BASE + "Mclaren GT.jpg";

            if (mk == "aston martin" || mk == "astonmartin" || mk.Contains("aston"))
                return BASE + "Aston Martin DB11.jpg";

            // ── PORSCHE ─────────────────────────────────────────────────────────
            if (mk == "porsche")
            {
                if (mo.Contains("cayenne") || mo.Contains("macan"))
                    return BASE + "porsche cayenne.jpg";
                if (mo.Contains("gt3"))
                    return BASE + "porsche 911 gt3.jpg";
                return BASE + "Porsche 911 turbo s.jpg"; // default 911 Turbo S
            }

            // ── ULTRA LUXURY ────────────────────────────────────────────────────
            if (mk == "rolls royce" || mk == "rolls-royce")
                return BASE + "Rolls Royce Ghost.jpg";

            if (mk == "bentley")
                return BASE + "bentley bentayaga.jpg";

            if (mk == "maserati")
                return BASE + "maserati ghibli.jpg";

            // ── BMW ─────────────────────────────────────────────────────────────
            if (mk == "bmw")
            {
                if (mo.Contains("x7"))
                    return BASE + "bmw x7.jpg";
                if (mo.Contains("7 series") || mo.Contains("7series") || mo.Contains("series 7"))
                    return BASE + "bmw 7 series.jpg";
                if (mo.Contains("m5"))
                    return BASE + "bmw m5.jpg";
                if (mo.Contains("3 series") || mo.Contains("3series") || mo.Contains("series 3"))
                    return BASE + "bmw 3 series.jpg";
                return BASE + "bmw 5 series.jpg"; // default BMW
            }

            // ── MERCEDES ────────────────────────────────────────────────────────
            if (mk == "mercedes" || mk == "mercedes-benz" || mk == "mercedes benz")
            {
                if (mo.Contains("g-class") || mo.Contains("g class") || mo.Contains("g63") || mo.Contains("g500"))
                    return BASE + "Mercedes G class.jpg";
                if (mo.Contains("v-class") || mo.Contains("v class") || mo.Contains("vito"))
                    return BASE + "mercedes v class.jpg";
                if (mo.Contains("amg gt") || mo.Contains("amg-gt"))
                    return BASE + "mercedes amg gt.jpg";
                if (mo.Contains("s-class") || mo.Contains("s class") || mo.Contains("s500") || mo.Contains("s600"))
                    return BASE + "mercedes s class.jpg";
                if (mo.Contains("e-class") || mo.Contains("e class") || mo.Contains("e200") || mo.Contains("e300"))
                    return BASE + "mercedes e class.jpg";
                if (mo.Contains("c-class") || mo.Contains("c class") || mo.Contains("c200") || mo.Contains("c300"))
                    return BASE + "mercedes c class.jpg";
                return BASE + "mercedes e class.jpg"; // default Mercedes
            }

            // ── AUDI ────────────────────────────────────────────────────────────
            if (mk == "audi")
            {
                if (mo.Contains("q8"))
                    return BASE + "Audi Q8.jpg";
                if (mo.Contains("rs6") || mo.Contains("rs 6"))
                    return BASE + "audi rs6 avant.jpg";
                if (mo.Contains("a8"))
                    return BASE + "audi a8.jpg";
                return BASE + "audi a4.jpg"; // default Audi
            }

            // ── TESLA ───────────────────────────────────────────────────────────
            if (mk == "tesla")
            {
                if (mo.Contains("cybertruck"))
                    return BASE + "cybertruck.jpg";
                if (mo.Contains("model s") || mo.Contains("models"))
                    return BASE + "tesla model s.jpg";
                return BASE + "tesla model 3.jpg"; // default Tesla
            }

            // ── RANGE ROVER ─────────────────────────────────────────────────────
            if (mk == "range rover" || mk == "land rover")
            {
                if (mo.Contains("sport"))
                    return BASE + "rangerover sport.jpg";
                return BASE + "rangerover autobiography.jpg";
            }

            // ── JAGUAR ──────────────────────────────────────────────────────────
            if (mk == "jaguar")
                return BASE + "jaguar f pace.jpg";

            // ── TOYOTA ──────────────────────────────────────────────────────────
            if (mk == "toyota")
            {
                if (mo.Contains("land cruiser") || mo.Contains("landcruiser"))
                    return BASE + "Toyota land cruiser.jpg";
                if (mo.Contains("rav") || mo.Contains("rav4") || mo.Contains("rav 4"))
                    return BASE + "Toyota rav 4.jpg";
                if (mo.Contains("c-hr") || mo.Contains("chr"))
                    return BASE + "Toyota chr.jpg";
                return BASE + "Toyota corolla.jpg"; // default Toyota
            }

            // ── FORD ────────────────────────────────────────────────────────────
            if (mk == "ford")
            {
                if (mo.Contains("kuga"))
                    return BASE + "Ford kuga.jpg";
                if (mo.Contains("s-max") || mo.Contains("s max") || mo.Contains("smax"))
                    return BASE + "Ford s max.jpg";
                return BASE + "Ford focus.jpg"; // default Ford
            }

            // ── HONDA ───────────────────────────────────────────────────────────
            if (mk == "honda")
            {
                if (mo.Contains("cr-v") || mo.Contains("crv") || mo.Contains("cr v"))
                    return BASE + "Honda crv.jpg";
                return BASE + "Honda civic.jpg"; // default Honda
            }

            // ── HYUNDAI ─────────────────────────────────────────────────────────
            if (mk == "hyundai")
            {
                if (mo.Contains("tucson"))
                    return BASE + "Hyundai tucson.jpg";
                return BASE + "Hyundai i 30.jpg"; // default Hyundai
            }

            // ── KIA ─────────────────────────────────────────────────────────────
            if (mk == "kia")
            {
                if (mo.Contains("sorento"))
                    return BASE + "Kia sorento.jpg";
                if (mo.Contains("ev6"))
                    return BASE + "Kia ev6.jpg";
                return BASE + "Kia ceed.jpg"; // default Kia
            }

            // ── VOLKSWAGEN ──────────────────────────────────────────────────────
            if (mk == "volkswagen" || mk == "vw")
            {
                if (mo.Contains("touran"))
                    return BASE + "Volkwagen touran.jpg";
                if (mo.Contains("polo"))
                    return BASE + "Volkwagen polo.jpg";
                return BASE + "volkswagen golf.jpg"; // default VW
            }

            // ── RENAULT ─────────────────────────────────────────────────────────
            if (mk == "renault")
            {
                if (mo.Contains("espace") || mo.Contains("espeace"))
                    return BASE + "renault espeace.jpg";
                return BASE + "renault cilo.jpg"; // default Renault (Clio)
            }

            // ── PEUGEOT ─────────────────────────────────────────────────────────
            if (mk == "peugeot")
            {
                if (mo.Contains("508"))
                    return BASE + "peugeot 508.jpg";
                return BASE + "peugeot 208.jpg"; // default Peugeot
            }

            // ── SKODA ───────────────────────────────────────────────────────────
            if (mk == "skoda")
            {
                if (mo.Contains("kodiaq") || mo.Contains("codiaq"))
                    return BASE + "skoda codiaq.jpg";
                return BASE + "skoda fabia.jpg"; // default Skoda
            }

            // ── NISSAN ──────────────────────────────────────────────────────────
            if (mk == "nissan")
            {
                if (mo.Contains("micra"))
                    return BASE + "nissan micra.jpg";
                return BASE + "nissan qashqai.jpg"; // default Nissan
            }

            // ── VOLVO ───────────────────────────────────────────────────────────
            if (mk == "volvo")
            {
                if (mo.Contains("v90"))
                    return BASE + "Volvo v90.jpg";
                return BASE + "volvo xc60.jpg"; // default Volvo
            }

            // ── MAZDA ───────────────────────────────────────────────────────────
            if (mk == "mazda")
                return BASE + "Mazda cx5.jpg";

            // ── SUBARU ──────────────────────────────────────────────────────────
            if (mk == "subaru")
                return BASE + "Subaru Outback.jpg";

            // ── DACIA ───────────────────────────────────────────────────────────
            if (mk == "dacia")
                return BASE + "dacia dustar.jpg";

            // ── OPEL ────────────────────────────────────────────────────────────
            if (mk == "opel")
            {
                if (mo.Contains("zafira"))
                    return BASE + "opel zafira.jpg";
                return BASE + "opel corsa.jpg"; // default Opel
            }

            // ── SEAT ────────────────────────────────────────────────────────────
            if (mk == "seat")
                return BASE + "Seat Alhamra.jpg";

            // ── FIAT ────────────────────────────────────────────────────────────
            if (mk == "fiat")
                return BASE + "fiat 500.jpg";

            // ── SMART ───────────────────────────────────────────────────────────
            if (mk == "smart")
                return BASE + "Smart for Two.jpg";

            // ── MINI ────────────────────────────────────────────────────────────
            if (mk == "mini")
            {
                if (mo.Contains("convertible") || mo.Contains("cabrio"))
                    return BASE + "mini convertible.jpg";
                return BASE + "Mini Cooper 5.jpg"; // default Mini
            }

            // ── MITSUBISHI ──────────────────────────────────────────────────────
            if (mk == "mitsubishi")
                return BASE + "mitsubishi space star.jpg";

            // ── DEFAULT — generic fallback ───────────────────────────────────────
            return BASE + "mercedes e class.jpg";
        }
    }
}
