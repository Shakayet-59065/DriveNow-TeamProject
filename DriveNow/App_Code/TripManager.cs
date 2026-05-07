using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

// DriveNow — TripManager Middle Layer
// Handles all business logic and database operations for
// Trip Records and Trip Type Catalogue components.
// Developer: Musanna | CTEC2713N | Niels Brock Copenhagen

namespace DriveNow
{
    /// <summary>
    /// Represents a single trip record in the DriveNow system.
    /// Maps directly to tblTrip in the database.
    /// </summary>
    public class Trip
    {
        /// <summary>Unique identifier for the trip. Primary key.</summary>
        public int TripID { get; set; }

        /// <summary>Foreign key referencing tblCustomer.</summary>
        public int CustomerId { get; set; }

        /// <summary>Foreign key referencing tblVehicle.</summary>
        public int VehicleID { get; set; }

        /// <summary>Foreign key referencing tblDriver. Nullable for self-drive rentals.</summary>
        public int? DriverID { get; set; }

        /// <summary>Foreign key referencing tblTripType.</summary>
        public int TripTypeID { get; set; }

        /// <summary>Trip type name populated from JOIN with tblTripType.</summary>
        public string TypeName { get; set; }

        /// <summary>The date on which the trip takes place.</summary>
        public DateTime TripDate { get; set; }

        /// <summary>Soft delete flag. 1 = active, 0 = deleted.</summary>
        public bool IsActive { get; set; }
    }

    /// <summary>
    /// Represents a trip type in the DriveNow catalogue.
    /// Maps directly to tblTripType in the database.
    /// </summary>
    public class TripType
    {
        /// <summary>Unique identifier for the trip type. Primary key.</summary>
        public int TripTypeID { get; set; }

        /// <summary>Name of the service type e.g. Short Ride.</summary>
        public string TypeName { get; set; }

        /// <summary>Brief description of the service type. Optional.</summary>
        public string Description { get; set; }

        /// <summary>Base price in GBP for this service type.</summary>
        public decimal BaseRate { get; set; }

        /// <summary>Date the trip type record was created.</summary>
        public DateTime CreatedDate { get; set; }

        /// <summary>Soft delete flag. 1 = active, 0 = discontinued.</summary>
        public bool IsActive { get; set; }
    }

    /// <summary>
    /// Handles all business logic and database operations for
    /// Trip Records and Trip Type Catalogue components.
    /// Developer: Musanna | CTEC2713N | Niels Brock Copenhagen
    /// </summary>
    public class TripManager
    {
        // =============================================
        // TRIP TYPE METHODS
        // =============================================

        /// <summary>
        /// Returns all active trip types. Calls spListTripTypes.
        /// </summary>
        public List<TripType> ListTripTypes()
        {
            List<TripType> tripTypes = new List<TripType>();

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spListTripTypes", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        tripTypes.Add(new TripType
                        {
                            TripTypeID = (int)reader["TripTypeID"],
                            TypeName = reader["TypeName"].ToString(),
                            Description = reader["Description"] == DBNull.Value ? "" : reader["Description"].ToString(),
                            BaseRate = (decimal)reader["BaseRate"],
                            CreatedDate = (DateTime)reader["CreatedDate"],
                            IsActive = (bool)reader["IsActive"]
                        });
                    }
                }
            }
            return tripTypes;
        }

        /// <summary>
        /// Finds a single trip type by ID. Calls spFindTripType.
        /// </summary>
        public TripType FindTripType(int tripTypeID)
        {
            TripType tripType = null;

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spFindTripType", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TripTypeID", tripTypeID);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        tripType = new TripType
                        {
                            TripTypeID = (int)reader["TripTypeID"],
                            TypeName = reader["TypeName"].ToString(),
                            Description = reader["Description"] == DBNull.Value ? "" : reader["Description"].ToString(),
                            BaseRate = (decimal)reader["BaseRate"],
                            CreatedDate = (DateTime)reader["CreatedDate"],
                            IsActive = (bool)reader["IsActive"]
                        };
                    }
                }
            }
            return tripType;
        }

        /// <summary>
        /// Adds a new trip type. Calls spAddTripType.
        /// Returns the new TripTypeID.
        /// </summary>
        public int AddTripType(TripType tripType)
        {
            int newID = 0;

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spAddTripType", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TypeName", tripType.TypeName);
                cmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(tripType.Description) ? (object)DBNull.Value : tripType.Description);
                cmd.Parameters.AddWithValue("@BaseRate", tripType.BaseRate);

                SqlParameter output = new SqlParameter("@NewID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(output);
                cmd.ExecuteNonQuery();
                newID = (int)output.Value;
            }
            return newID;
        }

        /// <summary>
        /// Updates an existing trip type. Calls spEditTripType.
        /// </summary>
        public void EditTripType(TripType tripType)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spEditTripType", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TripTypeID", tripType.TripTypeID);
                cmd.Parameters.AddWithValue("@TypeName", tripType.TypeName);
                cmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(tripType.Description) ? (object)DBNull.Value : tripType.Description);
                cmd.Parameters.AddWithValue("@BaseRate", tripType.BaseRate);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Soft deletes a trip type. Calls spDeleteTripType.
        /// Sets IsActive = 0 — never uses SQL DELETE.
        /// Record preserved for audit trail and FK integrity.
        /// </summary>
        public void DeleteTripType(int tripTypeID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spDeleteTripType", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TripTypeID", tripTypeID);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Filters trip types by name keyword. Calls spFilterTripTypes.
        /// </summary>
        public List<TripType> FilterTripTypes(string typeName)
        {
            List<TripType> tripTypes = new List<TripType>();

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spFilterTripTypes", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TypeName", string.IsNullOrEmpty(typeName) ? (object)DBNull.Value : typeName);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        tripTypes.Add(new TripType
                        {
                            TripTypeID = (int)reader["TripTypeID"],
                            TypeName = reader["TypeName"].ToString(),
                            Description = reader["Description"] == DBNull.Value ? "" : reader["Description"].ToString(),
                            BaseRate = (decimal)reader["BaseRate"],
                            CreatedDate = (DateTime)reader["CreatedDate"],
                            IsActive = (bool)reader["IsActive"]
                        });
                    }
                }
            }
            return tripTypes;
        }

        /// <summary>
        /// Validates a TripType before database write.
        /// Returns error message string, or empty string if valid.
        /// </summary>
        public string ValidateTripType(TripType tripType)
        {
            if (string.IsNullOrWhiteSpace(tripType.TypeName))
                return "Type Name is required.";
            if (tripType.TypeName.Length > 50)
                return "Type Name must be 50 characters or fewer.";
            if (!string.IsNullOrEmpty(tripType.Description) && tripType.Description.Length > 200)
                return "Description must be 200 characters or fewer.";
            if (tripType.BaseRate <= 0)
                return "Base Rate must be greater than zero.";
            return string.Empty;
        }

        // =============================================
        // TRIP METHODS
        // =============================================

        /// <summary>
        /// Returns all active trips. Calls spListTrips.
        /// </summary>
        public List<Trip> ListTrips()
        {
            List<Trip> trips = new List<Trip>();

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spListTrips", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        trips.Add(new Trip
                        {
                            TripID = (int)reader["TripID"],
                            CustomerId = (int)reader["CustomerId"],
                            VehicleID = (int)reader["VehicleID"],
                            DriverID = reader["DriverID"] == DBNull.Value ? (int?)null : (int)reader["DriverID"],
                            TripTypeID = (int)reader["TripTypeID"],
                            TypeName = reader["TypeName"].ToString(),
                            TripDate = (DateTime)reader["TripDate"],
                            IsActive = (bool)reader["IsActive"]
                        });
                    }
                }
            }
            return trips;
        }

        /// <summary>
        /// Finds a single trip by ID. Calls spFindTrip.
        /// </summary>
        public Trip FindTrip(int tripID)
        {
            Trip trip = null;

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spFindTrip", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TripID", tripID);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        trip = new Trip
                        {
                            TripID = (int)reader["TripID"],
                            CustomerId = (int)reader["CustomerId"],
                            VehicleID = (int)reader["VehicleID"],
                            DriverID = reader["DriverID"] == DBNull.Value ? (int?)null : (int)reader["DriverID"],
                            TripTypeID = (int)reader["TripTypeID"],
                            TypeName = reader["TypeName"].ToString(),
                            TripDate = (DateTime)reader["TripDate"],
                            IsActive = (bool)reader["IsActive"]
                        };
                    }
                }
            }
            return trip;
        }

        /// <summary>
        /// Adds a new trip. Calls spAddTrip.
        /// Returns the new TripID.
        /// </summary>
        public int AddTrip(Trip trip)
        {
            int newID = 0;

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spAddTrip", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerId", trip.CustomerId);
                cmd.Parameters.AddWithValue("@VehicleID", trip.VehicleID);
                cmd.Parameters.AddWithValue("@DriverID", trip.DriverID.HasValue ? (object)trip.DriverID.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@TripTypeID", trip.TripTypeID);
                cmd.Parameters.AddWithValue("@TripDate", trip.TripDate);

                SqlParameter output = new SqlParameter("@NewTripID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(output);
                cmd.ExecuteNonQuery();
                newID = (int)output.Value;
            }
            return newID;
        }

        /// <summary>
        /// Updates an existing trip. Calls spEditTrip.
        /// </summary>
        public void EditTrip(Trip trip)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spEditTrip", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TripID", trip.TripID);
                cmd.Parameters.AddWithValue("@CustomerId", trip.CustomerId);
                cmd.Parameters.AddWithValue("@VehicleID", trip.VehicleID);
                cmd.Parameters.AddWithValue("@DriverID", trip.DriverID.HasValue ? (object)trip.DriverID.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@TripTypeID", trip.TripTypeID);
                cmd.Parameters.AddWithValue("@TripDate", trip.TripDate);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Soft deletes a trip. Calls spDeleteTrip.
        /// Sets IsActive = 0 — never uses SQL DELETE.
        /// Preserves record for audit trail and GDPR compliance.
        /// </summary>
        public void DeleteTrip(int tripID)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spDeleteTrip", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TripID", tripID);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Filters trips by optional trip type and/or date. Calls spFilterTrips.
        /// Passing null for either parameter returns all active trips.
        /// </summary>
        public List<Trip> FilterTrips(int? tripTypeID, DateTime? tripDate)
        {
            List<Trip> trips = new List<Trip>();

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spFilterTrips", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TripTypeID", tripTypeID.HasValue ? (object)tripTypeID.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@TripDate", tripDate.HasValue ? (object)tripDate.Value : DBNull.Value);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        trips.Add(new Trip
                        {
                            TripID = (int)reader["TripID"],
                            CustomerId = (int)reader["CustomerId"],
                            VehicleID = (int)reader["VehicleID"],
                            DriverID = reader["DriverID"] == DBNull.Value ? (int?)null : (int)reader["DriverID"],
                            TripTypeID = (int)reader["TripTypeID"],
                            TypeName = reader["TypeName"].ToString(),
                            TripDate = (DateTime)reader["TripDate"],
                            IsActive = (bool)reader["IsActive"]
                        });
                    }
                }
            }
            return trips;
        }

        /// <summary>
        /// Returns all active trips for a specific customer.
        /// Used by the customer portal — filters by CustomerId so Customers
        /// never see each other's data. GDPR data isolation requirement.
        /// Calls spListTripsByCustomer.
        /// </summary>
        public List<Trip> ListTripsByCustomer(int CustomerId)
        {
            List<Trip> trips = new List<Trip>();

            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand("spListTripsByCustomer", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CustomerId", CustomerId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            trips.Add(new Trip
                            {
                                TripID = (int)reader["TripID"],
                                CustomerId = (int)reader["CustomerId"],
                                VehicleID = (int)reader["VehicleID"],
                                DriverID = reader["DriverID"] == DBNull.Value ? (int?)null : (int)reader["DriverID"],
                                TripTypeID = (int)reader["TripTypeID"],
                                TypeName = reader["TypeName"].ToString(),
                                TripDate = (DateTime)reader["TripDate"],
                                IsActive = (bool)reader["IsActive"]
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error listing trips by customer: " + ex.Message);
            }

            return trips;
        }

        /// <summary>
        /// Validates a Trip before database write.
        /// Returns error message string, or empty string if valid.
        /// </summary>
        public string ValidateTrip(Trip trip)
        {
            if (trip.CustomerId <= 0)
                return "A valid Customer must be selected.";
            if (trip.VehicleID <= 0)
                return "A valid Vehicle must be selected.";
            if (trip.TripTypeID <= 0)
                return "A valid Trip Type must be selected.";
            if (trip.TripDate < DateTime.Today)
                return "Trip Date cannot be in the past.";
            return string.Empty;
        }

    } // ← TripManager class closes here
}     // ← DriveNow namespace closes here