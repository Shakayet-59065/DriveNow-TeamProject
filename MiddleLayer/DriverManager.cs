// DriveNow — Driver Manager (Middle Layer Reference Copy)
// Full implementation matching App_Code/DriverManager.cs
// Module: CTEC2713N | Developer: Redoy | Niels Brock Copenhagen

using System;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow.MiddleLayer
{
    public class DriverManager
    {
        public string ValidateDriver(string fullName, string phone,
                                     string licenceNumber, DateTime dob, DateTime joinDate)
        {
            if (string.IsNullOrWhiteSpace(fullName))      return "Full name is required.";
            if (fullName.Trim().Length > 100)             return "Full name must be 100 characters or fewer.";
            if (string.IsNullOrWhiteSpace(phone))         return "Phone is required.";
            if (string.IsNullOrWhiteSpace(licenceNumber)) return "Licence number is required.";
            if (licenceNumber.Trim().Length > 30)         return "Licence number must be 30 characters or fewer.";

            int age = DateTime.Today.Year - dob.Year;
            if (dob > DateTime.Today.AddYears(-age)) age--;
            if (age < 18) return "Driver must be at least 18 years old.";
            if (joinDate > DateTime.Today) return "Join date cannot be in the future.";
            if (joinDate < dob)            return "Join date cannot be before date of birth.";
            return string.Empty;
        }

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
                    cmd.Parameters.AddWithValue("@LicenceNumber", licenceNumber);
                    cmd.Parameters.AddWithValue("@DateOfBirth",   dateOfBirth);
                    cmd.Parameters.AddWithValue("@JoinDate",      joinDate);
                    cmd.Parameters.AddWithValue("@PhotoUrl",      (object)photoUrl  ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Bio",           (object)bio       ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Rating",        (object)rating    ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Gender",        (object)gender    ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Specialty",     (object)specialty ?? DBNull.Value);
                    newID = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch (Exception ex) { Console.WriteLine("AddDriver: " + ex.Message); }
            return newID;
        }

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
                    ok = true;
                }
            }
            catch (Exception ex) { Console.WriteLine("EditDriver: " + ex.Message); }
            return ok;
        }

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

        public DataTable FindDriver(int? driverID = null, string fullName = null)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand("spFindDriver", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DriverID", (object)driverID ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@FullName", (object)fullName ?? DBNull.Value);
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex) { Console.WriteLine("FindDriver: " + ex.Message); }
            return dt;
        }

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

        public void RestoreDriver(int driverID)
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spRestoreDriver", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DriverID", driverID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex) { Console.WriteLine("RestoreDriver: " + ex.Message); }
        }

        public void HardDeleteDriver(int driverID)
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spHardDeleteDriver", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DriverID", driverID);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex) { Console.WriteLine("HardDeleteDriver: " + ex.Message); }
        }
    }
}
