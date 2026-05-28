// ============================================================
// File:    PasswordResetManager.cs
// Layer:   Middle Layer (App_Code)
// Purpose: Handles the customer forgot-password / temporary-password
//          workflow end-to-end.
//
//  Flow:
//   1. Customer submits email on ForgotPassword.aspx
//      → SubmitRequest() creates a row in tblPasswordResetRequest.
//   2. Admin sees the request on TempPasswords.aspx
//      → ListRequests() returns all requests with customer details.
//   3. Admin clicks "Issue Temp Password"
//      → IssueTempPassword() generates a random password, stores the
//        BCrypt hash for authentication and the plain text for admin display.
//   4. Customer enters temp password on Default.aspx customer login
//      → GetActiveRequest() looks up the request.
//      → PasswordHelper.VerifyPassword() checks the hash.
//      → MarkResolved() clears the plain-text display and flags the request.
//
//  Security notes:
//   - Only BCrypt-hashed passwords are used for authentication.
//   - Plain-text display value is stored only for admin communication and
//     is NULLed out the moment the customer uses the temp password.
//   - SubmitRequest() returns 0 (not an exception) if email is not found,
//     so ForgotPassword.aspx can show the same message to all users
//     (prevents account-existence enumeration).
// ============================================================

using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace DriveNow
{
    /// <summary>
    /// Middle layer for the customer password-reset system.
    /// All DB calls use stored procedures via DatabaseHelper.GetConnection().
    /// </summary>
    public class PasswordResetManager
    {
        // ============================================================
        // INNER CLASS — returned by GetActiveRequest()
        // ============================================================

        /// <summary>
        /// Lightweight DTO returned when a valid active reset request is found
        /// for a customer e-mail during the login flow.
        /// </summary>
        public class ActiveRequest
        {
            /// <summary>Primary key of tblPasswordResetRequest.</summary>
            public int    RequestID        { get; set; }

            /// <summary>FK to tblCustomer — used to build the session.</summary>
            public int    CustomerID       { get; set; }

            /// <summary>BCrypt hash of the temp password — compared with
            /// PasswordHelper.VerifyPassword() during login.</summary>
            public string TempPasswordHash { get; set; }

            /// <summary>Customer's full name — copied into Session after login.</summary>
            public string FullName         { get; set; }

            /// <summary>Customer's e-mail — copied into Session after login.</summary>
            public string Email            { get; set; }
        }


        // ============================================================
        // METHODS
        // ============================================================

        /// <summary>
        /// Called when a customer submits ForgotPassword.aspx.
        /// Inserts a pending request row for the customer whose e-mail matches.
        /// Returns the new RequestID, or 0 if no active customer has that e-mail
        /// (caller should show the same success message either way to prevent
        /// account-existence enumeration).
        /// </summary>
        public static int SubmitRequest(string email)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd  = new SqlCommand("spSubmitPasswordResetRequest", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Email", email);

                SqlParameter outParam = new SqlParameter("@RequestID", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outParam);
                cmd.ExecuteNonQuery();

                return Convert.ToInt32(outParam.Value);
            }
        }

        /// <summary>
        /// Returns all password reset requests with joined customer details,
        /// ordered by unresolved first then newest first.
        /// Used by TempPasswords.aspx (admin view).
        /// </summary>
        public static DataTable ListRequests()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd  = new SqlCommand("spListPasswordResetRequests", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt;
        }

        /// <summary>
        /// Admin action: generates a cryptographically random 8-character
        /// temporary password, stores its BCrypt hash and plain-text display
        /// in tblPasswordResetRequest, and marks the request as issued.
        /// Returns the plain-text password so the admin can communicate it
        /// to the customer (e.g. by phone or e-mail).
        /// </summary>
        public static string IssueTempPassword(int requestID)
        {
            string plain = GenerateTempPassword();
            string hash  = PasswordHelper.HashPassword(plain);

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd  = new SqlCommand("spIssueTempPassword", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RequestID",           requestID);
                cmd.Parameters.AddWithValue("@TempPasswordHash",    hash);
                cmd.Parameters.AddWithValue("@TempPasswordDisplay", plain);
                cmd.ExecuteNonQuery();
            }

            return plain;   // returned to admin UI for display
        }

        /// <summary>
        /// Called during customer login when the regular password fails.
        /// Looks up the most recent issued-but-unresolved reset request for
        /// the supplied e-mail.  Returns null when none exists.
        /// </summary>
        public static ActiveRequest GetActiveRequest(string email)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd  = new SqlCommand("spGetActiveResetRequest", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Email", email);

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        return new ActiveRequest
                        {
                            RequestID        = Convert.ToInt32(dr["RequestID"]),
                            CustomerID       = Convert.ToInt32(dr["CustomerID"]),
                            TempPasswordHash = dr["TempPasswordHash"].ToString(),
                            FullName         = dr["FullName"].ToString(),
                            Email            = dr["Email"].ToString()
                        };
                    }
                }
            }
            return null;
        }

        /// <summary>
        /// Called immediately after a customer successfully logs in using a
        /// temporary password.  Marks the request resolved and NULLs out the
        /// plain-text display value so it no longer appears in the admin grid.
        /// </summary>
        public static void MarkResolved(int requestID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd  = new SqlCommand("spResolvePasswordRequest", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RequestID", requestID);
                cmd.ExecuteNonQuery();
            }
        }

        // ============================================================
        // PRIVATE HELPERS
        // ============================================================

        /// <summary>
        /// Generates a cryptographically random 8-character temporary password
        /// using RNGCryptoServiceProvider.  Uses an unambiguous character set
        /// (no I, O, 0, 1 etc.) so passwords are easy to read and type.
        /// </summary>
        private static string GenerateTempPassword()
        {
            // Unambiguous chars: no I/l/1, no O/0
            const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";
            var bytes = new byte[8];
            using (var rng = new RNGCryptoServiceProvider())
                rng.GetBytes(bytes);

            var sb = new StringBuilder(8);
            foreach (byte b in bytes)
                sb.Append(chars[b % chars.Length]);
            return sb.ToString();
        }
    }
}
