// DriveNow — Password Helper
// Handles all password security in the system.
// Passwords are never stored as plain text — they are converted to a scrambled "hash" using
// the PBKDF2 algorithm (a secure, industry-standard method).
// Even if someone stole the database, they could not read the original passwords.
// Module: CTEC2713N

using System;
using System.Security.Cryptography;

namespace DriveNow
{
    public static class PasswordHelper
    {
        // Security settings — these control how strong the password hashing is
        private const int SaltSize  = 16;      // Random salt size in bytes — adds uniqueness to each hash
        private const int HashSize  = 32;      // Output hash size in bytes
        private const int Iterations = 100000; // Number of hashing rounds — higher = harder to crack
        private const string Prefix = "PBKDF2";// Marker at the start of stored hashes so we can identify them

        // Converts a plain-text password into a secure scrambled hash that can be stored in the database
        public static string HashPassword(string password)
        {
            // Generate a random "salt" — a unique random value mixed into the hash
            // This ensures two users with the same password get completely different hashes
            byte[] salt = new byte[SaltSize];
            using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt); // Fill the salt array with random bytes
            }

            // Create the hash by mixing the password + salt using 100,000 rounds of PBKDF2
            byte[] hash = CreateHash(password, salt, Iterations);

            // Store everything needed to verify later: algorithm prefix, iteration count, salt, hash
            return Prefix + "$" + Iterations + "$" + Convert.ToBase64String(salt) + "$" + Convert.ToBase64String(hash);
        }

        // Checks whether a password entered at login matches the stored hash — returns true if correct
        public static bool VerifyPassword(string password, string storedPassword)
        {
            // Reject immediately if there is no stored password
            if (String.IsNullOrEmpty(storedPassword))
            {
                return false;
            }

            // If the stored value is not a hash (e.g. legacy plain-text password), compare directly
            if (!IsHashedPassword(storedPassword))
            {
                return String.Equals(password, storedPassword, StringComparison.Ordinal);
            }

            // Split the stored hash into its four parts: prefix, iterations, salt, hash
            string[] parts = storedPassword.Split('$');
            if (parts.Length != 4)
            {
                return false; // Malformed hash — reject
            }

            // Read the iteration count from the stored hash
            int iterations;
            if (!Int32.TryParse(parts[1], out iterations))
            {
                return false; // Could not read iteration count — reject
            }

            // Re-create the hash using the stored salt and the password the user just typed
            byte[] salt         = Convert.FromBase64String(parts[2]);
            byte[] expectedHash = Convert.FromBase64String(parts[3]);
            byte[] actualHash   = CreateHash(password, salt, iterations);

            // Compare the two hashes in constant time (prevents timing attacks)
            return ConstantTimeEquals(actualHash, expectedHash);
        }

        // Returns true if the stored password string looks like a PBKDF2 hash (not plain text)
        public static bool IsHashedPassword(string storedPassword)
        {
            return !String.IsNullOrEmpty(storedPassword)
                && storedPassword.StartsWith(Prefix + "$", StringComparison.Ordinal);
        }

        // Creates a PBKDF2 hash from a password + salt using the given number of iterations
        private static byte[] CreateHash(string password, byte[] salt, int iterations)
        {
            using (Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations))
            {
                return pbkdf2.GetBytes(HashSize); // Return HashSize bytes of derived key material
            }
        }

        // Compares two byte arrays in constant time — prevents timing-based attacks where an attacker
        // measures how long the comparison takes to guess which bytes are correct
        private static bool ConstantTimeEquals(byte[] a, byte[] b)
        {
            if (a == null || b == null)
            {
                return false;
            }

            // XOR the lengths — if they differ, difference will be non-zero (i.e. not equal)
            int difference = a.Length ^ b.Length;
            int length = Math.Min(a.Length, b.Length);

            // Compare every byte — accumulating differences without short-circuiting
            for (int i = 0; i < length; i++)
            {
                difference |= a[i] ^ b[i]; // OR in any byte differences
            }

            return difference == 0; // Zero means all bytes matched
        }
    }
}
