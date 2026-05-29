// DriveNow — Driver Manager
// Handles all Create, Read, Update, Delete (CRUD) operations for driver records.
// Drivers can be assigned to trips; sensitive fields like licence number and DOB are
// only visible to admin staff — public-facing pages use a separate "public profile" method.
// Module: CTEC2713N | Developer: Redoy

using System;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow
{
    public class DriverManager
    {
        // Saves a new driver to the database — optional fields (photo, bio, rating, specialty) can be left null
        // Returns the new DriverID, or -1 if the save failed
        public int AddDriver(string fullName, string phone,
                             string licenceNumber, DateTime dateOfBirth, DateTime joinDate,
                             string photoUrl = null, string bio = null,
                             decimal? rating = null, string gender = null, string specialty = null)
        {
            int newID = -1;
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand("spAddDriver", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FullName",      fullName);
                    cmd.Parameters.AddWithValue("@Phone",         phone);
                    cmd.Parameters.AddWithValue("@LicenceNumber", licenceNumber); // Sensitive — admin only
                    cmd.Parameters.AddWithValue("@DateOfBirth",   dateOfBirth);   // Sensitive — admin only
                    cmd.Parameters.AddWithValue("@JoinDate",      joinDate);
                    cmd.Parameters.AddWithValue("@PhotoUrl",      (object)photoUrl  ?? DBNull.Value); // Optional profile photo
                    cmd.Parameters.AddWithValue("@Bio",           (object)bio       ?? DBNull.Value); // Optional description
                    cmd.Parameters.AddWithValue("@Rating",        (object)rating    ?? DBNull.Value); // Star rating 0-5
                    cmd.Parameters.AddWithValue("@Gender",        (object)gender    ?? DBNull.Value); // Optional
                    cmd.Parameters.AddWithValue("@Specialty",     (object)specialty ?? DBNull.Value); // e.g. Airport Transfers
                    newID = Convert.ToInt32(cmd.ExecuteScalar()); // Returns the new auto-generated DriverID
                }
            }
            catch (Exception ex) { Console.WriteLine("AddDriver: " + ex.Message); }
            return newID;
        }

        // Updates a driver's core details — returns true if the update succeeded
        public bool EditDriver(int driverID, string fullName, string phone,
                               string licenceNumber, DateTime dateOfBirth, DateTime joinDate)
        {
            bool ok = false;
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand("spEditDriver", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DriverID",      driverID);
                    cmd.Parameters.AddWithValue("@FullName",      fullName);
                    cmd.Parameters.AddWithValue("@Phone",         phone);
                    cmd.Parameters.AddWithValue("@LicenceNumber", licenceNumber);
                    cmd.Parameters.AddWithValue("@DateOfBirth",   dateOfBirth);
                    cmd.Parameters.AddWithValue("@JoinDate",      joinDate);
                    cmd.ExecuteNonQuery();
                    ok = true; // Mark success only if no exception was thrown
                }
            }
            catch (Exception ex) { Console.WriteLine("EditDriver: " + ex.Message); }
            return ok;
        }

        // Soft-delete: marks the driver as inactive (IsActive = 0) without removing the record
        // Returns true if the deactivation succeeded
        public bool DeleteDriver(int driverID)
        {
            bool ok = false;
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand("spDeleteDriver", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DriverID", driverID);
                    cmd.ExecuteNonQuery();
                    ok = true;
                }
            }
            catch (Exception ex) { Console.WriteLine("DeleteDriver: " + ex.Message); }
            return ok;
        }

        // Returns all active drivers from the database (including sensitive admin fields)
        public DataTable ListDrivers()
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand("spListDrivers", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex) { Console.WriteLine("ListDrivers: " + ex.Message); }
            return dt;
        }

        // Searches for a driver by ID or name — either parameter can be null to skip that filter
        public DataTable FindDriver(int? driverID = null, string fullName = null)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand("spFindDriver", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    // DBNull tells the stored procedure to ignore that filter
                    cmd.Parameters.AddWithValue("@DriverID",  (object)driverID  ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@FullName",  (object)fullName  ?? DBNull.Value);
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex) { Console.WriteLine("FindDriver: " + ex.Message); }
            return dt;
        }

        // Returns drivers filtered by join date range and/or active status
        // Any null parameter is ignored — so passing all nulls returns every driver
        public DataTable FilterDrivers(DateTime? from = null, DateTime? to = null, bool? isActive = null)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand("spFilterDrivers", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@JoinDateFrom", (object)from     ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@JoinDateTo",   (object)to       ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@IsActive",     (object)isActive ?? DBNull.Value);
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex) { Console.WriteLine("FilterDrivers: " + ex.Message); }
            return dt;
        }

        // Validates driver details before saving — returns an error message string or empty string if valid
        public string ValidateDriver(string fullName, string phone,
                                     string licenceNumber, DateTime dob, DateTime joinDate)
        {
            if (string.IsNullOrWhiteSpace(fullName))      return "Full name is required.";
            if (string.IsNullOrWhiteSpace(phone))         return "Phone is required.";
            if (string.IsNullOrWhiteSpace(licenceNumber)) return "Licence number is required.";

            // Calculate the driver's age — they must be at least 18 to legally drive
            int age = DateTime.Today.Year - dob.Year;
            if (dob > DateTime.Today.AddYears(-age)) age--;
            if (age < 18) return "Driver must be at least 18 years old.";

            if (joinDate > DateTime.Today) return "Join date cannot be in the future.";
            return string.Empty; // No errors — all fields are valid
        }

        /// <summary>
        /// Returns all active drivers with public-safe fields (no licence / DOB).
        /// Calls spListActiveDriversPublic — used by BookTrip.aspx driver selection panel.
        /// </summary>
        public DataTable ListActiveDriversPublic()
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spListActiveDriversPublic", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex) { Console.WriteLine("ListActiveDriversPublic: " + ex.Message); }
            return dt;
        }

        /// <summary>
        /// Returns public profile for a single active driver (no licence / DOB).
        /// Calls spGetDriverPublicProfile — used by DriverDetail.aspx customer view.
        /// Returns null if not found or inactive.
        /// </summary>
        public DataRow GetDriverPublicProfile(int driverID)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spGetDriverPublicProfile", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DriverID", driverID);
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex) { Console.WriteLine("GetDriverPublicProfile: " + ex.Message); }
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        /// <summary>
        /// Returns full profile for a single driver including sensitive fields.
        /// Calls spGetDriverAdminProfile — used by DriverDetail.aspx admin view.
        /// Returns null if not found.
        /// </summary>
        public DataRow GetDriverAdminProfile(int driverID)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spGetDriverAdminProfile", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DriverID", driverID);
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex) { Console.WriteLine("GetDriverAdminProfile: " + ex.Message); }
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        /// <summary>
        /// Reactivates a soft-deleted driver. Calls spRestoreDriver.
        /// Sets IsActive = 1 so the driver reappears on the active list.
        /// </summary>
        public void RestoreDriver(int driverID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spRestoreDriver", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@DriverID", driverID);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Permanently removes a driver record from the database. Calls spHardDeleteDriver.
        /// NULLs out DriverID in tblTrip (nullable FK) before deleting — preserves trip records.
        /// Only use after soft-delete when the record is no longer needed.
        /// </summary>
        public void HardDeleteDriver(int driverID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spHardDeleteDriver", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@DriverID", driverID);
                cmd.ExecuteNonQuery();
            }
        }
    }
}
