using System.Configuration;
using System.Data.SqlClient;

namespace DriveNow
{
    /// <summary>
    /// Provides a shared SQL Server database connection for all
    /// manager classes in the DriveNow system.
    /// All components call DatabaseHelper.GetConnection() to
    /// obtain a connection to the DriveNow database.
    /// Developer: Tahmid | CTEC2713N | Niels Brock Copenhagen
    /// </summary>
    public class DatabaseHelper
    {
        /// <summary>
        /// Connection string for the DriveNow database.
        /// Read from Web.config so the SQL Server instance can be changed
        /// without recompiling the website.
        /// </summary>
        private static readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["DriveNowDB"].ConnectionString;

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
