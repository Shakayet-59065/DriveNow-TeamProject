using System.Data.SqlClient;

namespace DriveNow.MiddleLayer
{
    /// <summary>
    /// Provides a shared database connection for all manager classes.
    /// All components use this helper to connect to the DriveNow database.
    /// </summary>
    public class DatabaseHelper
    {
        // Connection string for LocalDB instance
        // Server: DESKTOP-ECUQPO0\LOCALDB#8436EF88
        // Database: DriveNow
        private static readonly string ConnectionString =
            @"Data Source=DESKTOP-ECUQPO0\LOCALDB#8436EF88;Initial Catalog=DriveNow;Integrated Security=True;";

        /// <summary>
        /// Returns an open SqlConnection to the DriveNow database.
        /// Caller is responsible for closing the connection.
        /// </summary>
        public static SqlConnection GetConnection()
        {
            SqlConnection connection = new SqlConnection(ConnectionString);
            connection.Open();
            return connection;
        }
    }
}
