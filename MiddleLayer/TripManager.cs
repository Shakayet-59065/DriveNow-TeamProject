using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow.MiddleLayer
{
    /// <summary>
    /// Represents a single trip record in the DriveNow system.
    /// Maps directly to tblTrip in the database.
    /// </summary>
    public class Trip
    {
        /// <summary>Unique identifier for the trip. Primary key.</summary>
        public int TripID { get; set; }

        /// <summary>Foreign key referencing tblCustomer. The customer who booked the trip.</summary>
        public int CustomerID { get; set; }

        /// <summary>Foreign key referencing tblVehicle. The vehicle used for the trip.</summary>
        public int VehicleID { get; set; }

        /// <summary>Foreign key referencing tblDriver. Nullable — null for self-drive rentals.</summary>
        public int? DriverID { get; set; }

        /// <summary>Foreign key referencing tblTripType. The service type selected.</summary>
        public int TripTypeID { get; set; }

        /// <summary>The name of the trip type — populated from JOIN with tblTripType.</summary>
        public string TypeName { get; set; }

        /// <summary>The date on which the trip takes place.</summary>
        public DateTime TripDate { get; set; }

        /// <summary>Soft delete flag. 1 = active, 0 = deleted. Never hard delete.</summary>
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

        /// <summary>Name of the service type e.g. Short Ride, Self-Drive Rental.</summary>
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
    /// Calls stored procedures in tblTrip and tblTripType.
    /// Developer: Musanna | CTEC2713N | Niels Brock Copenhagen
    /// </summary>
    public class TripManager
    {
        // =============================================
        // TRIP TYPE METHODS
        // =============================================

        /// <summary>
        /// Returns a list of all active trip types from tblTripType.
        /// Calls stored procedure: spListTripTypes
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
        /// Finds a single trip type by its ID.
        /// Calls stored procedure: spFindTripType
        /// </summary>
        /// <param name="tripTypeID">The ID of the trip type to find.</param>
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
        /// Adds a new trip type to tblTripType.
        /// Calls stored procedure: spAddTripType
        /// </summary>
        /// <param name="tripType">TripType object containing the new record details.</param>
        /// <returns>The newly generated TripTypeID.</returns>
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

                // Output parameter to capture new ID
                SqlParameter outputParam = new SqlParameter("@NewID", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outputParam);

                cmd.ExecuteNonQuery();
                newID = (int)outputParam.Value;
            }

            return newID;
        }

        /// <summary>
        /// Updates an existing trip type in tblTripType.
        /// Calls stored procedure: spEditTripType
        /// </summary>
        /// <param name="tripType">TripType object with updated values.</param>
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
        /// Soft deletes a trip type by setting IsActive to 0.
        /// Calls stored procedure: spDeleteTripType
        /// Never performs a hard delete.
        /// </summary>
        /// <param name="tripTypeID">The ID of the trip type to deactivate.</param>
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
        /// Filters trip types by name keyword.
        /// Calls stored procedure: spFilterTripTypes
        /// </summary>
        /// <param name="typeName">Optional name keyword to filter by. Pass null for all.</param>
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

        // =============================================
        // VALIDATE TRIP TYPE
        // =============================================

        /// <summary>
        /// Validates all fields of a TripType object before any database write.
        /// Returns an error message string, or empty string if valid.
        /// </summary>
        /// <param name="tripType">The TripType object to validate.</param>
        public string ValidateTripType(TripType tripType)
        {
            // TypeName is required
            if (string.IsNullOrWhiteSpace(tripType.TypeName))
                return "Type Name is required.";

            // TypeName max 50 characters
            if (tripType.TypeName.Length > 50)
                return "Type Name must be 50 characters or fewer.";

            // Description max 200 characters if provided
            if (!string.IsNullOrEmpty(tripType.Description) && tripType.Description.Length > 200)
                return "Description must be 200 characters or fewer.";

            // BaseRate must be greater than zero
            if (tripType.BaseRate <= 0)
                return "Base Rate must be greater than zero.";

            // BaseRate max 2 decimal places handled by DECIMAL(8,2) — no further validation needed
            return string.Empty;
        }

        // =============================================
        // TRIP METHODS
        // =============================================

        /// <summary>
        /// Returns a list of all active trips from tblTrip.
        /// Calls stored procedure: spListTrips
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
                            CustomerID = (int)reader["CustomerID"],
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
        /// Finds a single trip by its ID.
        /// Calls stored procedure: spFindTrip
        /// </summary>
        /// <param name="tripID">The ID of the trip to find.</param>
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
                            CustomerID = (int)reader["CustomerID"],
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
        /// Adds a new trip record to tblTrip.
        /// Calls stored procedure: spAddTrip
        /// </summary>
        /// <param name="trip">Trip object containing the new record details.</param>
        /// <returns>The newly generated TripID.</returns>
        public int AddTrip(Trip trip)
        {
            int newID = 0;

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spAddTrip", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", trip.CustomerID);
                cmd.Parameters.AddWithValue("@VehicleID", trip.VehicleID);
                cmd.Parameters.AddWithValue("@DriverID", trip.DriverID.HasValue ? (object)trip.DriverID.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@TripTypeID", trip.TripTypeID);
                cmd.Parameters.AddWithValue("@TripDate", trip.TripDate);

                // Output parameter to capture new ID
                SqlParameter outputParam = new SqlParameter("@NewTripID", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outputParam);

                cmd.ExecuteNonQuery();
                newID = (int)outputParam.Value;
            }

            return newID;
        }

        /// <summary>
        /// Updates an existing trip record in tblTrip.
        /// Calls stored procedure: spEditTrip
        /// </summary>
        /// <param name="trip">Trip object with updated values.</param>
        public void EditTrip(Trip trip)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spEditTrip", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TripID", trip.TripID);
                cmd.Parameters.AddWithValue("@CustomerID", trip.CustomerID);
                cmd.Parameters.AddWithValue("@VehicleID", trip.VehicleID);
                cmd.Parameters.AddWithValue("@DriverID", trip.DriverID.HasValue ? (object)trip.DriverID.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@TripTypeID", trip.TripTypeID);
                cmd.Parameters.AddWithValue("@TripDate", trip.TripDate);

                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Soft deletes a trip by setting IsActive to 0.
        /// Calls stored procedure: spDeleteTrip
        /// Never performs a hard delete.
        /// </summary>
        /// <param name="tripID">The ID of the trip to deactivate.</param>
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
        /// Filters trips by trip type and/or date.
        /// Calls stored procedure: spFilterTrips
        /// </summary>
        /// <param name="tripTypeID">Optional trip type ID to filter by. Pass null for all.</param>
        /// <param name="tripDate">Optional date to filter by. Pass null for all.</param>
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
                            CustomerID = (int)reader["CustomerID"],
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

        // =============================================
        // VALIDATE TRIP
        // =============================================

        /// <summary>
        /// Validates all fields of a Trip object before any database write.
        /// Returns an error message string, or empty string if valid.
        /// </summary>
        /// <param name="trip">The Trip object to validate.</param>
        public string ValidateTrip(Trip trip)
        {
            // CustomerID must be greater than zero
            if (trip.CustomerID <= 0)
                return "A valid Customer must be selected.";

            // VehicleID must be greater than zero
            if (trip.VehicleID <= 0)
                return "A valid Vehicle must be selected.";

            // TripTypeID must be greater than zero
            if (trip.TripTypeID <= 0)
                return "A valid Trip Type must be selected.";

            // TripDate must not be in the past
            if (trip.TripDate < DateTime.Today)
                return "Trip Date cannot be in the past.";

            // DriverID is optional — null is valid for self-drive rentals
            // No validation required for DriverID

            return string.Empty;
        }
    }
}
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace DriveNow.MiddleLayer
{
    /// <summary>
    /// Represents a single trip record in the DriveNow system.
    /// Maps directly to tblTrip in the database.
    /// </summary>
    public class Trip
    {
        /// <summary>Unique identifier for the trip. Primary key.</summary>
        public int TripID { get; set; }

        /// <summary>Foreign key referencing tblCustomer. The customer who booked the trip.</summary>
        public int CustomerID { get; set; }

        /// <summary>Foreign key referencing tblVehicle. The vehicle used for the trip.</summary>
        public int VehicleID { get; set; }

        /// <summary>Foreign key referencing tblDriver. Nullable — null for self-drive rentals.</summary>
        public int? DriverID { get; set; }

        /// <summary>Foreign key referencing tblTripType. The service type selected.</summary>
        public int TripTypeID { get; set; }

        /// <summary>The name of the trip type — populated from JOIN with tblTripType.</summary>
        public string TypeName { get; set; }

        /// <summary>The date on which the trip takes place.</summary>
        public DateTime TripDate { get; set; }

        /// <summary>Soft delete flag. 1 = active, 0 = deleted. Never hard delete.</summary>
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

        /// <summary>Name of the service type e.g. Short Ride, Self-Drive Rental.</summary>
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
    /// Calls stored procedures in tblTrip and tblTripType.
    /// Developer: Musanna | CTEC2713N | Niels Brock Copenhagen
    /// </summary>
    public class TripManager
    {
        // =============================================
        // TRIP TYPE METHODS
        // =============================================

        /// <summary>
        /// Returns a list of all active trip types from tblTripType.
        /// Calls stored procedure: spListTripTypes
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
        /// Finds a single trip type by its ID.
        /// Calls stored procedure: spFindTripType
        /// </summary>
        /// <param name="tripTypeID">The ID of the trip type to find.</param>
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
        /// Adds a new trip type to tblTripType.
        /// Calls stored procedure: spAddTripType
        /// </summary>
        /// <param name="tripType">TripType object containing the new record details.</param>
        /// <returns>The newly generated TripTypeID.</returns>
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

                // Output parameter to capture new ID
                SqlParameter outputParam = new SqlParameter("@NewID", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outputParam);

                cmd.ExecuteNonQuery();
                newID = (int)outputParam.Value;
            }

            return newID;
        }

        /// <summary>
        /// Updates an existing trip type in tblTripType.
        /// Calls stored procedure: spEditTripType
        /// </summary>
        /// <param name="tripType">TripType object with updated values.</param>
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
        /// Soft deletes a trip type by setting IsActive to 0.
        /// Calls stored procedure: spDeleteTripType
        /// Never performs a hard delete.
        /// </summary>
        /// <param name="tripTypeID">The ID of the trip type to deactivate.</param>
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
        /// Filters trip types by name keyword.
        /// Calls stored procedure: spFilterTripTypes
        /// </summary>
        /// <param name="typeName">Optional name keyword to filter by. Pass null for all.</param>
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

        // =============================================
        // VALIDATE TRIP TYPE
        // =============================================

        /// <summary>
        /// Validates all fields of a TripType object before any database write.
        /// Returns an error message string, or empty string if valid.
        /// </summary>
        /// <param name="tripType">The TripType object to validate.</param>
        public string ValidateTripType(TripType tripType)
        {
            // TypeName is required
            if (string.IsNullOrWhiteSpace(tripType.TypeName))
                return "Type Name is required.";

            // TypeName max 50 characters
            if (tripType.TypeName.Length > 50)
                return "Type Name must be 50 characters or fewer.";

            // Description max 200 characters if provided
            if (!string.IsNullOrEmpty(tripType.Description) && tripType.Description.Length > 200)
                return "Description must be 200 characters or fewer.";

            // BaseRate must be greater than zero
            if (tripType.BaseRate <= 0)
                return "Base Rate must be greater than zero.";

            // BaseRate max 2 decimal places handled by DECIMAL(8,2) — no further validation needed
            return string.Empty;
        }

        // =============================================
        // TRIP METHODS
        // =============================================

        /// <summary>
        /// Returns a list of all active trips from tblTrip.
        /// Calls stored procedure: spListTrips
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
                            CustomerID = (int)reader["CustomerID"],
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
        /// Finds a single trip by its ID.
        /// Calls stored procedure: spFindTrip
        /// </summary>
        /// <param name="tripID">The ID of the trip to find.</param>
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
                            CustomerID = (int)reader["CustomerID"],
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
        /// Adds a new trip record to tblTrip.
        /// Calls stored procedure: spAddTrip
        /// </summary>
        /// <param name="trip">Trip object containing the new record details.</param>
        /// <returns>The newly generated TripID.</returns>
        public int AddTrip(Trip trip)
        {
            int newID = 0;

            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spAddTrip", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", trip.CustomerID);
                cmd.Parameters.AddWithValue("@VehicleID", trip.VehicleID);
                cmd.Parameters.AddWithValue("@DriverID", trip.DriverID.HasValue ? (object)trip.DriverID.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@TripTypeID", trip.TripTypeID);
                cmd.Parameters.AddWithValue("@TripDate", trip.TripDate);

                // Output parameter to capture new ID
                SqlParameter outputParam = new SqlParameter("@NewTripID", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outputParam);

                cmd.ExecuteNonQuery();
                newID = (int)outputParam.Value;
            }

            return newID;
        }

        /// <summary>
        /// Updates an existing trip record in tblTrip.
        /// Calls stored procedure: spEditTrip
        /// </summary>
        /// <param name="trip">Trip object with updated values.</param>
        public void EditTrip(Trip trip)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand("spEditTrip", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TripID", trip.TripID);
                cmd.Parameters.AddWithValue("@CustomerID", trip.CustomerID);
                cmd.Parameters.AddWithValue("@VehicleID", trip.VehicleID);
                cmd.Parameters.AddWithValue("@DriverID", trip.DriverID.HasValue ? (object)trip.DriverID.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@TripTypeID", trip.TripTypeID);
                cmd.Parameters.AddWithValue("@TripDate", trip.TripDate);

                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Soft deletes a trip by setting IsActive to 0.
        /// Calls stored procedure: spDeleteTrip
        /// Never performs a hard delete.
        /// </summary>
        /// <param name="tripID">The ID of the trip to deactivate.</param>
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
        /// Filters trips by trip type and/or date.
        /// Calls stored procedure: spFilterTrips
        /// </summary>
        /// <param name="tripTypeID">Optional trip type ID to filter by. Pass null for all.</param>
        /// <param name="tripDate">Optional date to filter by. Pass null for all.</param>
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
                            CustomerID = (int)reader["CustomerID"],
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

        // =============================================
        // VALIDATE TRIP
        // =============================================

        /// <summary>
        /// Validates all fields of a Trip object before any database write.
        /// Returns an error message string, or empty string if valid.
        /// </summary>
        /// <param name="trip">The Trip object to validate.</param>
        public string ValidateTrip(Trip trip)
        {
            // CustomerID must be greater than zero
            if (trip.CustomerID <= 0)
                return "A valid Customer must be selected.";

            // VehicleID must be greater than zero
            if (trip.VehicleID <= 0)
                return "A valid Vehicle must be selected.";

            // TripTypeID must be greater than zero
            if (trip.TripTypeID <= 0)
                return "A valid Trip Type must be selected.";

            // TripDate must not be in the past
            if (trip.TripDate < DateTime.Today)
                return "Trip Date cannot be in the past.";

            // DriverID is optional — null is valid for self-drive rentals
            // No validation required for DriverID

            return string.Empty;
        }
    }
}
