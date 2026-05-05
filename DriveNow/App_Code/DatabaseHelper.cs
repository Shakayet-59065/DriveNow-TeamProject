using System.Data.SqlClient;

namespace DriveNow
{
    /// <summary>
    /// Provides a shared SQL Server database connection for all
    /// manager classes in the DriveNow system.
    /// All components call DatabaseHelper.GetConnection() to
    /// obtain a connection to the DriveNow database.
    /// Developer: Musanna | CTEC2713N | Niels Brock Copenhagen
    /// </summary>
    public class DatabaseHelper
    {
        /// <summary>
        /// Connection string for the DriveNow LocalDB instance.
        /// Server: DESKTOP-ECUQPO0\LOCALDB#8436EF88
        /// Database: DriveNow
        /// Authentication: Windows (Integrated Security)
        /// </summary>
        private static readonly string ConnectionString =
            @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=DriveNow;Integrated Security=True;";

        /// <summary>
        /// Opens and returns a SqlConnection to the DriveNow database.
        /// The caller is responsible for closing the connection.
        /// Always used inside a using block to ensure proper disposal.
        /// </summary>
        /// <returns>An open SqlConnection to the DriveNow database.</returns>
        public static SqlConnection GetConnection()
        {
            // Create a new connection using the shared connection string
            SqlConnection connection = new SqlConnection(ConnectionString);

            // Open the connection before returning it to the caller
            connection.Open();

            return connection;
        }
    }
}