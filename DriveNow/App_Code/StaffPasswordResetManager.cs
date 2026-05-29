// DriveNow — Staff Password Reset Manager
// Handles the forgotten-password workflow specifically for staff (admin) accounts.
// Works the same way as the customer password reset, but uses the staff login table (tblStaff).
//
// Flow:
//  1. Staff member enters username on the Forgot Password page → SubmitRequest() logs the request
//  2. Super-admin sees the pending request on TempPasswords.aspx → IssueTempPassword() generates a temp password
//  3. Staff member logs in with the temp password → GetActiveRequest() checks it, MarkResolved() clears it
//
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace DriveNow
{
    public class StaffPasswordResetManager
    {
        // Represents a found reset request — contains the information needed to authenticate the staff member
        public class ActiveRequest
        {
            public int    ResetID         { get; set; }  // Primary key of the reset request row
            public int    StaffID         { get; set; }  // Which staff member this reset is for
            public string TempPasswordHash { get; set; } // The hashed temp password for secure comparison
            public string FullName        { get; set; }  // Staff member's name (used in session)
            public string Username        { get; set; }  // Staff member's username (used in session)
        }

        // Called when a staff member clicks "Forgot Password" — logs the request in the database
        // Returns the new ResetID (used to track the request on the admin panel)
        public static int SubmitRequest(string username)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spSubmitStaffPasswordResetRequest", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Username", username);
                // OUTPUT parameter — the stored procedure returns the new ResetID
                SqlParameter outParam = new SqlParameter("@ResetID", SqlDbType.Int)
                    { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outParam);
                cmd.ExecuteNonQuery();
                return Convert.ToInt32(outParam.Value); // 0 if the username was not found
            }
        }

        // Returns all pending and issued staff password reset requests — shown on the admin TempPasswords page
        public static DataTable ListRequests()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spListStaffPasswordResetRequests", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt;
        }

        // Admin action: generates a random temporary password for a staff reset request
        // The plain-text password is returned so the admin can share it with the staff member
        public static string IssueTempPassword(int resetID)
        {
            string plain = GenerateTempPassword(); // Create random 8-character password
            string hash  = PasswordHelper.HashPassword(plain); // Hash it for secure storage

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spIssueStaffTempPassword", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ResetID",             resetID);
                cmd.Parameters.AddWithValue("@TempPasswordHash",    hash);  // Stored securely as hash
                cmd.Parameters.AddWithValue("@TempPasswordDisplay", plain); // Shown to admin only
                cmd.ExecuteNonQuery();
            }
            return plain; // Admin uses this to tell the staff member their temp password
        }

        // Called during staff login when the regular password check fails
        // Returns the active reset request if one exists, so the temp password can be checked
        public static ActiveRequest GetActiveRequest(string username)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spGetActiveStaffResetRequest", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Username", username);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                        return new ActiveRequest
                        {
                            ResetID          = Convert.ToInt32(dr["ResetID"]),
                            StaffID          = Convert.ToInt32(dr["StaffID"]),
                            TempPasswordHash = dr["TempPasswordHash"].ToString(),
                            FullName         = dr["FullName"].ToString(),
                            Username         = dr["Username"].ToString()
                        };
                }
            }
            return null; // No active reset request found for this username
        }

        // Marks the reset request as resolved and clears the plain-text display value
        // Called immediately after a staff member successfully logs in with their temp password
        public static void MarkResolved(int resetID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spResolveStaffPasswordRequest", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ResetID", resetID);
                cmd.ExecuteNonQuery();
            }
        }

        // Generates a secure random 8-character temporary password
        // Uses only unambiguous characters (no letters/numbers that look alike, e.g. O and 0)
        private static string GenerateTempPassword()
        {
            const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";
            var bytes = new byte[8];
            using (var rng = new RNGCryptoServiceProvider())
                rng.GetBytes(bytes); // Fill with cryptographically random bytes
            var sb = new StringBuilder(8);
            foreach (byte b in bytes)
                sb.Append(chars[b % chars.Length]); // Map each byte to a character
            return sb.ToString();
        }
    }
}
