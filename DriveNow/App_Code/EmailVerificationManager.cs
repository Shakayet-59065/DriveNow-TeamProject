// DriveNow — Email Verification Manager
// When a new customer registers, they receive a verification email with a unique token link.
// This class handles generating those tokens, verifying them when clicked, and resending them.
//
// Flow:
//  1. Customer registers → GenerateToken() creates a unique code and stores it in the database
//  2. Customer clicks the email link → VerifyToken() checks the code and marks email as verified
//  3. If the email expires or gets lost → ResendToken() creates a fresh token for the same email
//
// Module: CTEC2713N

using System;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow
{
    public static class EmailVerificationManager
    {
        // Generates a unique verification token for a newly registered customer
        // The token is stored in the database and emailed to the customer as a clickable link
        public static string GenerateToken(int customerID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spGenerateEmailVerificationToken", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", customerID);
                // OUTPUT parameter — the stored procedure returns the generated token here
                SqlParameter outToken = new SqlParameter("@Token", SqlDbType.VarChar, 64)
                    { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outToken);
                cmd.ExecuteNonQuery();
                return outToken.Value?.ToString(); // Return the token to be included in the email link
            }
        }

        // Checks whether a token from a verification email link is valid
        // Returns the CustomerID if the token is correct and not expired, or 0 if invalid
        public static int VerifyToken(string token)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spVerifyEmailToken", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Token", token); // The token from the email link URL
                // OUTPUT parameter — returns the CustomerID the token belongs to
                SqlParameter outID = new SqlParameter("@CustomerID", SqlDbType.Int)
                    { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outID);
                cmd.ExecuteNonQuery();
                return Convert.ToInt32(outID.Value); // 0 means invalid or expired
            }
        }

        // Resends a verification email — regenerates a fresh token for an unverified email address
        // Returns the new token (or null if the email was not found or is already verified)
        public static string ResendToken(string email, out int customerID)
        {
            customerID = 0;
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spResendEmailVerificationToken", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Email", email);
                // Two OUTPUT parameters: the customer's ID and the new token
                SqlParameter outID    = new SqlParameter("@CustomerID", SqlDbType.Int)         { Direction = ParameterDirection.Output };
                SqlParameter outToken = new SqlParameter("@Token",      SqlDbType.VarChar, 64) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outID);
                cmd.Parameters.Add(outToken);
                cmd.ExecuteNonQuery();
                customerID = Convert.ToInt32(outID.Value);
                // Only return a token if a valid unverified customer was found
                return customerID > 0 ? outToken.Value?.ToString() : null;
            }
        }
    }
}
