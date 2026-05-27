// DriveNow — Default.aspx Code-Behind (Customer-Facing Homepage)
// This file controls what happens when a customer visits the DriveNow website.
// It handles: showing the fleet, customer login, customer registration, and the Rent a Car form.
// Module: CTEC2713N

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace DriveNow
{
    public partial class Default : System.Web.UI.Page
    {
        // Runs every time the homepage loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // If arrived via login redirect (e.g. from BookTrip.aspx without being logged in),
            // store the returnUrl in session so we can redirect there after successful login.
            if (!IsPostBack && Request.QueryString["openlogin"] == "1")
            {
                // Keep any returnUrl already set (BookTrip.aspx.cs sets Session["LoginReturnUrl"])
                // The client-side tryReopenModal IIFE will open the login modal automatically.
            }

            // Check if the customer is already logged in — used to show/hide nav buttons
            bool loggedIn = Session["CustomerLoggedIn"] != null && (bool)Session["CustomerLoggedIn"];
            // Show guest nav (Login / Register) or logged-in nav (My Account / Logout) accordingly
            pnlNavGuest.Visible    = !loggedIn;
            pnlNavLoggedIn.Visible =  loggedIn;

            // Expose login state + customer name to client-side JavaScript for dynamic UI updates
            hfCustLoggedIn.Value = loggedIn ? "1" : "0";
            hfCustName.Value     = loggedIn && Session["CustomerName"] != null
                                   ? Session["CustomerName"].ToString() : "";

            // Only load the featured cars and trip type dropdown on first page visit (not on form submit)
            if (!IsPostBack)
            {
                LoadFeaturedFleet();
                LoadTripTypes();
            }
        }

        // Exposes the real trip-type count to the stats strip via <%= TripTypeCount %>
        protected int TripTypeCount { get; private set; } = 5; // fallback if DB unavailable

        // Loads trip types from the database into the "Service Type" dropdown in the booking form
        private void LoadTripTypes()
        {
            try
            {
                var types = new TripManager().ListTripTypes();
                // Update the stats strip count with how many trip types exist in the database
                TripTypeCount = types.Count > 0 ? types.Count : 1;

                // Clear and re-populate the service type dropdown with live data
                ServiceTypeDropDownList.Items.Clear();
                ServiceTypeDropDownList.Items.Add(
                    new System.Web.UI.WebControls.ListItem("Select service type", ""));
                foreach (var t in types)
                    ServiceTypeDropDownList.Items.Add(
                        new System.Web.UI.WebControls.ListItem(t.TypeName, t.TripTypeID.ToString()));
            }
            catch { } // Keep static fallback items already in markup if DB unavailable
        }

        // Loads the first 3 vehicles from the database to show in the "Featured Fleet" section
        private void LoadFeaturedFleet()
        {
            try
            {
                var mgr      = new VehicleManager();
                var vehicles = mgr.ListVehicles();
                // Take only up to 3 vehicles for the featured section — don't show the full fleet here
                var featured = vehicles.Count > 3 ? vehicles.GetRange(0, 3) : vehicles;
                rptFeaturedFleet.DataSource = featured;
                rptFeaturedFleet.DataBind();
            }
            catch
            {
                // DB not available — fall back to empty repeater (section stays hidden via no items)
            }
        }

        // Returns the Unsplash photo URL for a given car make and model
        protected string GetFleetImage(string make, string model)
        {
            return CarImages.GetUrl(make, model);
        }

        // Returns formatted spec labels (type, seats, doors) for a car based on its brand
        protected string GetFleetSpecs(string make)
        {
            string type, seats, doors;
            // Match each well-known brand to its typical body type and seating configuration
            switch (make.ToLower().Trim())
            {
                case "porsche":
                    type = "Sports Car"; seats = "4 Seater"; doors = "2 Door"; break;
                case "bmw":
                    type = "Executive Sedan"; seats = "5 Seater"; doors = "4 Door"; break;
                case "mercedes":
                    type = "Luxury Sedan"; seats = "5 Seater"; doors = "4 Door"; break;
                case "tesla":
                    type = "Electric Sedan"; seats = "5 Seater"; doors = "4 Door"; break;
                case "audi":
                    type = "Executive Sedan"; seats = "5 Seater"; doors = "4 Door"; break;
                default:
                    // Generic fallback for any brand not specifically listed above
                    type = "Sedan"; seats = "5 Seater"; doors = "4 Door"; break;
            }
            // Build the HTML spec pill labels shown on each fleet card
            return string.Format(
                "<span class=\"spec\">{0}</span><span class=\"spec\">{1}</span><span class=\"spec\">{2}</span><span class=\"spec\">Automatic</span>",
                type, seats, doors);
        }

        // Handles the Login button click from the login modal on the homepage
        protected void LoginButton_Click(object sender, EventArgs e)
        {
            // Read the email and password the customer typed into the login form
            string email    = LoginEmailTextBox.Text.Trim();
            string password = LoginPasswordTextBox.Text.Trim();

            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    // Look up the customer record by email address
                    SqlCommand cmd = new SqlCommand("spCustomerLogin", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Email", email);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            // Read the stored account details from the database
                            int    custID     = Convert.ToInt32(dr["CustomerID"]);
                            string storedHash = dr["PasswordHash"].ToString();
                            string fullName   = dr["FullName"].ToString();
                            string custEmail  = dr["Email"].ToString();

                            // PasswordHelper.VerifyPassword handles both PBKDF2 hashes and plain-text
                            bool pwOk = PasswordHelper.VerifyPassword(password, storedHash);

                            // Silently upgrade plain-text password to PBKDF2 on first successful login
                            if (pwOk && !PasswordHelper.IsHashedPassword(storedHash))
                            {
                                dr.Close();
                                CustomerManager.UpdatePassword(custID, PasswordHelper.HashPassword(password));
                            }

                            if (pwOk)
                            {
                                // Check email verification — customer must verify before they can sign in
                                bool isVerified = true;
                                try { isVerified = dr.IsClosed ? true : Convert.ToBoolean(dr["IsEmailVerified"]); }
                                catch { isVerified = true; } // column may not exist if Script 20 not run

                                // If email not yet verified, show a message with a resend link instead of logging in
                                if (!isVerified)
                                {
                                    LoginMessageLabel.Text = "Please verify your email address before signing in. "
                                        + "Check your inbox for the verification link, or <a href=\"ResendVerification.aspx?email="
                                        + Server.UrlEncode(custEmail) + "\" style=\"color:#14b8a6\">click here to resend it</a>.";
                                    return;
                                }

                                // Password correct and email verified — create the session and log the customer in
                                Session["CustomerLoggedIn"] = true;
                                Session["CustomerID"]       = custID;
                                Session["CustomerName"]     = fullName;
                                Session["CustomerEmail"]    = custEmail;
                                Session["FlashMessage"]     = "welcome_back:" + fullName;
                                // If they were trying to visit another page before logging in, redirect there
                                string returnUrl = Session["LoginReturnUrl"] as string;
                                Session.Remove("LoginReturnUrl");
                                Response.Redirect(!string.IsNullOrEmpty(returnUrl) ? returnUrl : "CustomerPortal.aspx");
                                return;
                            }
                        }

                        // Regular password failed — check whether an admin-issued
                        // temporary password is active for this e-mail.
                        PasswordResetManager.ActiveRequest activeReq =
                            PasswordResetManager.GetActiveRequest(email);

                        // If a temp password was issued by admin and the customer typed it correctly, log them in
                        if (activeReq != null &&
                            PasswordHelper.VerifyPassword(password, activeReq.TempPasswordHash))
                        {
                            // Temp-password login succeeded — set session but force them to set a new password
                            Session["CustomerLoggedIn"] = true;
                            Session["CustomerID"]       = activeReq.CustomerID;
                            Session["CustomerName"]     = activeReq.FullName;
                            Session["CustomerEmail"]    = activeReq.Email;
                            Session["TempPwLogin"]      = true; // forces SetNewPassword before portal
                            // Mark the reset request as resolved so the temp password cannot be reused
                            PasswordResetManager.MarkResolved(activeReq.RequestID);
                            Response.Redirect("SetNewPassword.aspx");
                            return;
                        }

                        // Neither regular nor temp password matched — show an error
                        LoginMessageLabel.Text = "Invalid email or password. Please try again.";
                        // Note: the modal is re-opened client-side by the
                        // tryReopenModal() IIFE in Default.aspx — it detects
                        // that .form-message has text after the postback.
                    }
                }
            }
            catch (Exception)
            {
                // Database connection failed — show a friendly error to the customer
                LoginMessageLabel.Text = "Unable to connect. Please try again later.";
            }
        }

        // Handles the Register button click from the registration modal
        protected void RegisterButton_Click(object sender, EventArgs e)
        {
            // The customer must tick the privacy policy checkbox before registering
            if (PrivacyConsentHiddenField.Value != "true")
            {
                RegisterMessageLabel.Text = "You must accept the privacy policy to create an account.";
                Page.ClientScript.RegisterStartupScript(GetType(), "openReg",
                    "openModal('m-register');", true);
                return;
            }

            // Read all the registration form fields
            string name    = RegisterNameTextBox.Text.Trim();
            string email   = RegisterEmailTextBox.Text.Trim();
            string phone   = RegisterPhoneTextBox.Text.Trim();
            string pass    = RegisterPasswordTextBox.Text;
            string confirm = RegisterConfirmPwTextBox.Text;

            // Server-side password strength check (mirrors client-side regex) — must be 8+ chars with uppercase + number
            if (string.IsNullOrWhiteSpace(pass) || pass.Length < 8 ||
                !System.Text.RegularExpressions.Regex.IsMatch(pass, @"[A-Z]") ||
                !System.Text.RegularExpressions.Regex.IsMatch(pass, @"\d"))
            {
                RegisterMessageLabel.Text = "Password must be at least 8 characters and include at least 1 uppercase letter and 1 number.";
                Page.ClientScript.RegisterStartupScript(GetType(), "openReg", "openModal('m-register');", true);
                return;
            }
            // Make sure the password and confirm password fields match
            if (pass != confirm)
            {
                RegisterMessageLabel.Text = "Passwords do not match.";
                Page.ClientScript.RegisterStartupScript(GetType(), "openReg", "openModal('m-register');", true);
                return;
            }

            // Run the full validation check (name format, email format, phone format)
            var mgr = new CustomerManager();
            string err = mgr.ValidateCustomer(name, email, phone);
            if (!string.IsNullOrEmpty(err))
            {
                RegisterMessageLabel.Text = err;
                Page.ClientScript.RegisterStartupScript(GetType(), "openReg",
                    "openModal('m-register');", true);
                return;
            }

            // Check email uniqueness before attempting insert — prevents same-email duplicate accounts
            if (mgr.EmailExists(email))
            {
                RegisterMessageLabel.Text    = "An account with this email already exists. Please log in instead.";
                RegisterMessageLabel.Visible = true;
                return;
            }

            try
            {
                // Hash the password securely before saving — never store plain text
                string hash  = PasswordHelper.HashPassword(pass);
                int    newID = mgr.AddCustomer(name, email, phone, hash);

                // Generate email verification token — best-effort (login still works if Script 20 not run)
                string verifyToken = null;
                try { verifyToken = EmailVerificationManager.GenerateToken(newID); } catch { }

                // Show verification notice instead of auto-logging in — forces email confirmation
                string verifyMsg;
                if (!string.IsNullOrEmpty(verifyToken))
                {
                    // Build the verification URL — in production this would be emailed to the customer
                    string verifyUrl = ResolveUrl("~/VerifyEmail.aspx?token=" + Uri.EscapeDataString(verifyToken));
                    verifyMsg = "Account created! To activate your account, verify your email address. "
                              + "In a real deployment this link is emailed to you — for this demo: "
                              + "<a href=\"" + verifyUrl + "\" style=\"color:#0d9488;font-weight:700;\">Click here to verify your email</a>.";
                }
                else
                {
                    // Email verification not set up yet — log straight in (backward-compatible)
                    Session["CustomerLoggedIn"] = true;
                    Session["CustomerID"]       = newID;
                    Session["CustomerName"]     = name;
                    Session["CustomerEmail"]    = email;
                    Session["FlashMessage"]     = "new_signup:" + name;
                    Response.Redirect("CustomerPortal.aspx");
                    return;
                }

                // Display the verification message on the page (modal stays closed)
                RegisterMessageLabel.Text    = verifyMsg;
                RegisterMessageLabel.Visible = true;
                // Keep modal closed — verification message is shown in the main page area
            }
            catch (Exception ex)
            {
                // Handle duplicate email errors gracefully, or show a generic error for other failures
                if (ex.Message.IndexOf("duplicate", StringComparison.OrdinalIgnoreCase) >= 0 ||
                    ex.Message.IndexOf("UNIQUE",    StringComparison.OrdinalIgnoreCase) >= 0)
                    RegisterMessageLabel.Text = "An account with this email already exists.";
                else
                    RegisterMessageLabel.Text = "Registration failed. Please try again.";

                Page.ClientScript.RegisterStartupScript(GetType(), "openReg",
                    "openModal('m-register');", true);
            }
        }

        // Handles the Logout button in the navigation bar — clears all session data and returns to homepage
        protected void btnNavLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Default.aspx");
        }

        // Handles the "Rent a Car" form submission from the homepage CTA section
        protected void RentButton_Click(object sender, EventArgs e)
        {
            // Save the booking form details to session so BrowseFleet/BookTrip can use them to pre-fill
            Session["PreBookPickup"]     = PickupLocationTextBox.Text.Trim();
            Session["PreBookDropoff"]    = DropLocationTextBox.Text.Trim();
            Session["PreBookPickupDate"] = PickupDateTextBox.Text;
            Session["PreBookDropDate"]   = DropDateTextBox.Text;
            Session["PreBookTripTypeID"] = ServiceTypeDropDownList.SelectedValue;

            if (Session["CustomerLoggedIn"] == null || !(bool)Session["CustomerLoggedIn"])
            {
                // Customer is not logged in — ask them to sign in first, then continue to fleet
                Session["LoginReturnUrl"] = "BrowseFleet.aspx?from=booking";
                RentMessageLabel.Text     = "Please sign in to continue with your booking.";
                RentMessageLabel.CssClass = "rent-message";
                Page.ClientScript.RegisterStartupScript(GetType(), "openLogin",
                    "openModal('m-login');", true);
                return;
            }

            // Logged in — send straight to fleet browser to pick a vehicle
            Response.Redirect("BrowseFleet.aspx?from=booking");
        }

        // Returns the correct URL for booking a specific vehicle — sends to login first if not signed in
        protected string GetBookingUrl(object vehicleID)
        {
            bool loggedIn = Session["CustomerLoggedIn"] != null && (bool)Session["CustomerLoggedIn"];
            if (loggedIn)
                return "BookTrip.aspx?vid=" + vehicleID;
            // If not logged in, redirect to login with the booking URL as a return address
            return "Login.aspx?type=Customer&returnUrl=" + System.Web.HttpUtility.UrlEncode("BookTrip.aspx?vid=" + vehicleID);
        }
    }
}
