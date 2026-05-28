// DriveNow — Customer Manager
// Handles all Create, Read, Update, Delete (CRUD) operations for customer accounts.
// All database calls use stored procedures for security and consistency.
// Module: CTEC2713N | Developer: Tahmid

using System;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow
{
    public class CustomerManager
    {
        // Saves a new customer account to the database — returns the new CustomerID
        // The password is stored as a secure hash (never plain text)
        public int AddCustomer(string fullName, string email, string phone, string passwordHash)
        {
            int newID = 0;
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            {
                SqlCommand cmd = new SqlCommand("spAddCustomer", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@FullName",     fullName);
                cmd.Parameters.AddWithValue("@Email",        email);
                cmd.Parameters.AddWithValue("@Phone",        phone);
                cmd.Parameters.AddWithValue("@PasswordHash", passwordHash); // Always a hashed value
                object result = cmd.ExecuteScalar();
                if (result != null) newID = Convert.ToInt32(result); // The new auto-generated ID
            }
            return newID;
        }

        // Updates an existing customer's details — can also activate or deactivate their account
        public void EditCustomer(int customerID, string fullName, string email, string phone, bool isActive)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            {
                SqlCommand cmd = new SqlCommand("spEditCustomer", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", customerID);
                cmd.Parameters.AddWithValue("@FullName",   fullName);
                cmd.Parameters.AddWithValue("@Email",      email);
                cmd.Parameters.AddWithValue("@Phone",      phone);
                cmd.Parameters.AddWithValue("@IsActive",   isActive); // True = active, False = deactivated
                cmd.ExecuteNonQuery();
            }
        }

        // Soft-delete: marks the customer as inactive (IsActive = 0) without removing the record
        public void DeleteCustomer(int customerID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            {
                SqlCommand cmd = new SqlCommand("spDeleteCustomer", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", customerID);
                cmd.ExecuteNonQuery();
            }
        }

        // Returns all customer records from the database (both active and inactive)
        public DataTable ListCustomers()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            {
                SqlCommand cmd = new SqlCommand("spListCustomers", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                new SqlDataAdapter(cmd).Fill(dt); // Fill the DataTable with results
            }
            return dt;
        }

        // Searches for a customer by ID or name — either parameter can be left null to skip that filter
        public DataTable FindCustomer(int? customerID = null, string fullName = null)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            {
                SqlCommand cmd = new SqlCommand("spFindCustomer", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                // Pass DBNull when no value is provided so the stored procedure skips that filter
                cmd.Parameters.AddWithValue("@CustomerID", (object)customerID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@FullName",   (object)fullName   ?? DBNull.Value);
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt;
        }

        // Returns customers filtered by registration date and/or active status
        // Passing null for either parameter returns all customers without that filter
        public DataTable FilterCustomers(DateTime? registerDateFrom = null, bool? isActive = null)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            {
                SqlCommand cmd = new SqlCommand("spFilterCustomers", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RegisterDateFrom", (object)registerDateFrom ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@IsActive",         (object)isActive         ?? DBNull.Value);
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt;
        }

        // Checks all customer fields for errors before saving — returns an error message string or empty if valid
        public string ValidateCustomer(string fullName, string email, string phone)
        {
            // ── Name — must be a real full name (first + last), no numbers or special chars ─────
            if (string.IsNullOrWhiteSpace(fullName))
                return "Full name is required.";
            fullName = fullName.Trim();
            if (fullName.Length < 3)
                return "Full name must be at least 3 characters.";
            if (fullName.Length > 100)
                return "Full name must not exceed 100 characters.";
            if (!fullName.Contains(" "))
                return "Please enter your first and last name.";
            if (System.Text.RegularExpressions.Regex.IsMatch(fullName, @"\d"))
                return "Full name must not contain numbers.";
            if (System.Text.RegularExpressions.Regex.IsMatch(fullName, @"[^\p{L}\s'\-\.]"))
                return "Full name contains invalid characters.";

            // ── Email — must be in a standard format like name@domain.com ─────────────────────
            if (string.IsNullOrWhiteSpace(email))
                return "Email address is required.";
            email = email.Trim();
            if (!System.Text.RegularExpressions.Regex.IsMatch(email,
                    @"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$"))
                return "Enter a valid email address (e.g. name@example.com).";
            if (email.Length > 150)
                return "Email must not exceed 150 characters.";

            // ── Phone — must have 6–15 digits; allows spaces, brackets, + and dashes ──────────
            if (string.IsNullOrWhiteSpace(phone))
                return "Phone number is required.";
            phone = phone.Trim();
            if (phone.Length > 30)
                return "Phone number must not exceed 30 characters.";
            string digitsOnly = System.Text.RegularExpressions.Regex.Replace(phone, @"[+\-\s\(\)]", "");
            if (!System.Text.RegularExpressions.Regex.IsMatch(digitsOnly, @"^\d{6,15}$"))
                return "Phone number must contain 6-15 digits (digits, spaces, +, - and brackets allowed).";

            return string.Empty; // Empty string = no errors = valid
        }

        /// <summary>
        /// Checks whether an email address is already registered in tblCustomer.
        /// Called before AddCustomer to prevent duplicate accounts.
        /// Returns true if email already exists (case-insensitive).
        /// Calls spEmailExists stored procedure.
        /// </summary>
        public bool EmailExists(string email)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spEmailExists", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Email", email);
                object result = cmd.ExecuteScalar();
                return result != null && Convert.ToInt32(result) > 0;
            }
        }

        /// <summary>
        /// Reads the email and phone for a single customer from tblCustomer.
        /// Calls spGetCustomerProfile — no inline SQL in the presentation layer.
        /// Used by CustomerPortal.aspx.cs to pre-fill the profile edit form.
        /// Returns null if customer not found or inactive.
        /// </summary>
        public DataRow GetCustomerProfile(int customerID)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spGetCustomerProfile", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", customerID);
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        /// <summary>
        /// Replaces the password hash for an active customer record.
        /// Calls spUpdateCustomerPassword.
        /// Used by SetNewPassword.aspx.cs after a customer has logged in
        /// with an admin-issued temporary password and chooses a new one.
        /// </summary>
        public static void UpdatePassword(int customerID, string newPasswordHash)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd  = new SqlCommand("spUpdateCustomerPassword", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID",   customerID);
                cmd.Parameters.AddWithValue("@PasswordHash", newPasswordHash);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Updates the email and phone for an active customer record.
        /// Calls spUpdateCustomerProfile — no inline SQL in the presentation layer.
        /// Used by CustomerPortal.aspx.cs when the customer saves profile changes.
        /// Phone is nullable — pass null or empty string to clear it.
        /// </summary>
        public void UpdateCustomerProfile(int customerID, string email, string phone)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spUpdateCustomerProfile", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", customerID);
                cmd.Parameters.AddWithValue("@Email",      email);
                cmd.Parameters.AddWithValue("@Phone",
                    string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Reactivates a soft-deleted customer. Calls spRestoreCustomer.
        /// Sets IsActive = 1 so the customer reappears on the active list.
        /// </summary>
        public void RestoreCustomer(int customerID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spRestoreCustomer", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", customerID);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Permanently removes a customer record from the database. Calls spHardDeleteCustomer.
        /// Deletes CustomerTrip bookings first; raises an error if tblTrip still references
        /// this customer — soft-delete those trips first, then retry.
        /// </summary>
        public void HardDeleteCustomer(int customerID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spHardDeleteCustomer", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", customerID);
                cmd.ExecuteNonQuery();
            }
        }
    }
}
