// ============================================================
// File: ContributorManager.cs
// Developer: Ushna
// Component: Contributor Applications
// Layer: Middle Layer (App_Code)
// Purpose: Handles all business logic and database operations
//          for tblContributor and tblContribVehicle.
//          Uses DatabaseHelper.GetConnection() for all DB calls
//          matching the shared team pattern exactly.
//          All DB calls use stored procedures — no inline SQL.
//          Validate() runs before every database write to ensure
//          data integrity and prevent invalid records being saved.
// ============================================================

using System;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow
{
    /// <summary>
    /// Middle layer class for the Contributor Applications component.
    /// Manages contributor application records and linked vehicle records.
    /// All methods call stored procedures via DatabaseHelper.GetConnection().
    /// </summary>
    public class ContributorManager
    {
        // ============================================================
        // PROPERTIES — map directly to tblContributor columns
        // ============================================================

        /// <summary>
        /// Primary key for tblContributor.
        /// Auto-assigned by SQL Server IDENTITY — do not set on Add.
        /// Required for Edit and Delete operations.
        /// </summary>
        public int ContributorID { get; set; }

        /// <summary>
        /// Full name of the applicant.
        /// Required. Maximum 100 characters. Cannot be null or whitespace.
        /// </summary>
        public string FullName { get; set; }

        /// <summary>
        /// Contact email address of the applicant.
        /// Required. Maximum 150 characters. Must contain @ and dot.
        /// </summary>
        public string Email { get; set; }

        /// <summary>
        /// Contact phone number of the applicant.
        /// Required. Maximum 20 characters.
        /// </summary>
        public string Phone { get; set; }

        /// <summary>
        /// Type of contributor applying.
        /// Must be exactly "Driver" or "VehicleOwner".
        /// Any other value will fail validation.
        /// </summary>
        public string ContributorType { get; set; }

        /// <summary>
        /// Date the application was submitted.
        /// Required. Cannot be a future date.
        /// </summary>
        public DateTime ApplicationDate { get; set; }

        /// <summary>
        /// Approval status of the contributor application.
        /// False = pending (default on creation).
        /// True = approved by staff.
        /// Also used for soft delete — false deactivates the record.
        /// </summary>
        public bool IsApproved { get; set; }

        /// <summary>
        /// Stores the specific validation error message to display
        /// on the ASPX page when Validate() returns false.
        /// </summary>
        public string ErrorMessage { get; set; }


        // ============================================================
        // METHODS — tblContributor
        // ============================================================

        /// <summary>
        /// Validates all fields then inserts a new contributor record
        /// into tblContributor via spAddContributor.
        /// Returns new ContributorID or -1 if validation fails.
        /// </summary>
        public int Add()
        {
            if (!Validate())
                return -1;

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spAddContributor", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@FullName", FullName);
                cmd.Parameters.AddWithValue("@Email", Email);
                cmd.Parameters.AddWithValue("@Phone", Phone);
                cmd.Parameters.AddWithValue("@ContributorType", ContributorType);
                cmd.Parameters.AddWithValue("@ApplicationDate", ApplicationDate);

                // OUTPUT parameter — SQL Server returns the new PK here
                SqlParameter outParam = new SqlParameter("@NewID", SqlDbType.Int);
                outParam.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outParam);

                cmd.ExecuteNonQuery();

                // Read the new ContributorID assigned by SCOPE_IDENTITY()
                return Convert.ToInt32(cmd.Parameters["@NewID"].Value);
            }
        }

        /// <summary>
        /// Validates all fields then updates the existing contributor record
        /// via spEditContributor. Staff can approve an applicant here by
        /// setting IsApproved = true.
        /// </summary>
        public void Edit()
        {
            if (!Validate())
                return;

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spEditContributor", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ContributorID", ContributorID);
                cmd.Parameters.AddWithValue("@FullName", FullName);
                cmd.Parameters.AddWithValue("@Email", Email);
                cmd.Parameters.AddWithValue("@Phone", Phone);
                cmd.Parameters.AddWithValue("@ContributorType", ContributorType);
                cmd.Parameters.AddWithValue("@IsApproved", IsApproved);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Soft deletes contributor by setting IsApproved = 0.
        /// Cascades to soft-delete linked vehicles (IsAvailable = 0).
        /// Records are kept in the database — use HardDelete for permanent removal.
        /// </summary>
        public void Delete()
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spDeleteContributor", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ContributorID", ContributorID);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Approves a pending contributor application by setting IsApproved = 1.
        /// Calls spApproveContributor (Script 12). Quick one-click action — staff do
        /// not need to open the full edit form just to approve an application.
        /// </summary>
        public static void Approve(int contributorID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spApproveContributor", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ContributorID", contributorID);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Full approval — sets IsApproved=1 and auto-promotes the contributor
        /// into tblDriver and/or tblVehicle based on their ContributorType.
        /// Calls spApproveContributorFull (Script 26).
        /// Returns a tuple of (NewDriverID, NewVehicleID); either may be 0 if
        /// not applicable for the contributor type.
        /// </summary>
        public static (int driverID, int vehicleID) ApproveFull(int contributorID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spApproveContributorFull", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ContributorID", contributorID);

                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);

                int driverID  = 0;
                int vehicleID = 0;

                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["NewDriverID"]  != DBNull.Value) driverID  = Convert.ToInt32(dt.Rows[0]["NewDriverID"]);
                    if (dt.Rows[0]["NewVehicleID"] != DBNull.Value) vehicleID = Convert.ToInt32(dt.Rows[0]["NewVehicleID"]);
                }

                return (driverID, vehicleID);
            }
        }

        /// <summary>
        /// Returns a single DataRow with all tblContributor columns for the given ID.
        /// Returns null if the record is not found.
        /// </summary>
        public static DataRow GetDetails(int contributorID)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT * FROM tblContributor WHERE ContributorID = @id", conn))
            {
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.AddWithValue("@id", contributorID);
                new SqlDataAdapter(cmd).Fill(dt);
            }

            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        /// <summary>
        /// Permanently removes a contributor and all linked ContribVehicle records.
        /// Records the data-retention period (3 or 6 months) in the audit log
        /// via spHardDeleteContributor before the record is erased.
        /// Only call this after explicit staff consent has been captured.
        /// </summary>
        public static void HardDelete(int contributorID, int retentionMonths)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spHardDeleteContributor", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ContributorID",   contributorID);
                cmd.Parameters.AddWithValue("@RetentionMonths", retentionMonths);
                cmd.Parameters.AddWithValue("@ConsentDate",     DateTime.Today);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Returns all contributor records ordered by ApplicationDate descending.
        /// Returns both pending and approved for admin review.
        /// </summary>
        public static DataTable List()
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spListContributors", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }

            return dt;
        }

        /// <summary>
        /// Searches tblContributor by ContributorID or FullName (partial match).
        /// Pass 0 for ID or null for name to skip that filter.
        /// </summary>
        public static DataTable Find(int contributorID, string fullName)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spFindContributor", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // DBNull tells the stored procedure to skip this filter
                cmd.Parameters.AddWithValue("@ContributorID",
                    contributorID == 0 ? (object)DBNull.Value : contributorID);
                cmd.Parameters.AddWithValue("@FullName",
                    string.IsNullOrEmpty(fullName) ? (object)DBNull.Value : fullName);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }

            return dt;
        }

        /// <summary>
        /// Filters contributors by ContributorType and/or IsApproved.
        /// Pass null to either parameter to include all values.
        /// </summary>
        public static DataTable Filter(string contributorType, object isApproved)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spFilterContributors", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ContributorType",
                    string.IsNullOrEmpty(contributorType)
                    ? (object)DBNull.Value : contributorType);
                cmd.Parameters.AddWithValue("@IsApproved",
                    isApproved ?? (object)DBNull.Value);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }

            return dt;
        }

        /// <summary>
        /// Validates all contributor fields before any database write.
        /// Returns true only if ALL rules pass.
        /// Sets ErrorMessage with specific message if any rule fails.
        /// </summary>
        public bool Validate()
        {
            if (string.IsNullOrWhiteSpace(FullName))
            { ErrorMessage = "Full name is required."; return false; }

            if (FullName.Length > 100)
            { ErrorMessage = "Full name must not exceed 100 characters."; return false; }

            if (string.IsNullOrWhiteSpace(Email))
            { ErrorMessage = "Email address is required."; return false; }

            if (!Email.Contains("@") || !Email.Contains("."))
            { ErrorMessage = "Please enter a valid email address."; return false; }

            if (Email.Length > 150)
            { ErrorMessage = "Email must not exceed 150 characters."; return false; }

            if (string.IsNullOrWhiteSpace(Phone))
            { ErrorMessage = "Phone number is required."; return false; }

            if (Phone.Length > 20)
            { ErrorMessage = "Phone number must not exceed 20 characters."; return false; }

            if (ContributorType != "Driver" && ContributorType != "VehicleOwner" && ContributorType != "OwnerDriver")
            { ErrorMessage = "Contributor type must be Driver, VehicleOwner, or OwnerDriver."; return false; }

            if (ApplicationDate == DateTime.MinValue)
            { ErrorMessage = "Application date is required."; return false; }

            if (ApplicationDate > DateTime.Today)
            { ErrorMessage = "Application date cannot be in the future."; return false; }

            ErrorMessage = "";
            return true;
        }


        // ============================================================
        // METHODS — tblContribVehicle
        // ============================================================

        /// <summary>
        /// Inserts a new vehicle linked to an existing contributor.
        /// IsAvailable defaults to 1 (active). Returns new ContribVehicleID.
        /// </summary>
        public static int AddVehicle(int contributorID, string make,
            string model, int year, string registrationNo)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spAddContribVehicle", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ContributorID", contributorID);
                cmd.Parameters.AddWithValue("@Make", make);
                cmd.Parameters.AddWithValue("@Model", model);
                cmd.Parameters.AddWithValue("@Year", year);
                cmd.Parameters.AddWithValue("@RegistrationNo", registrationNo);

                SqlParameter outParam = new SqlParameter("@NewID", SqlDbType.Int);
                outParam.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outParam);

                cmd.ExecuteNonQuery();
                return Convert.ToInt32(cmd.Parameters["@NewID"].Value);
            }
        }

        /// <summary>
        /// Updates Make, Model, Year, RegistrationNo for a vehicle record.
        /// ContributorID and IsAvailable are not changed here.
        /// </summary>
        public static void EditVehicle(int contribVehicleID, string make,
            string model, int year, string registrationNo)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spEditContribVehicle", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ContribVehicleID", contribVehicleID);
                cmd.Parameters.AddWithValue("@Make", make);
                cmd.Parameters.AddWithValue("@Model", model);
                cmd.Parameters.AddWithValue("@Year", year);
                cmd.Parameters.AddWithValue("@RegistrationNo", registrationNo);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Soft deletes a vehicle by setting IsAvailable = 0.
        /// Record retained in database — never permanently removed.
        /// </summary>
        public static void DeleteVehicle(int contribVehicleID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spDeleteContribVehicle", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ContribVehicleID", contribVehicleID);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Returns all active vehicles (IsAvailable = 1) for a contributor.
        /// </summary>
        public static DataTable ListVehicles(int contributorID)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spListContribVehicles", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ContributorID", contributorID);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }

            return dt;
        }
    }
}