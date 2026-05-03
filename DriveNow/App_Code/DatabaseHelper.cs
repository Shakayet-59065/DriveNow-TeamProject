using System.Data.SqlClient;

namespace DriveNow
{
    public class DatabaseHelper
    {
        private static readonly string ConnectionString =
    @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=DriveNow;Integrated Security=True;";

        public static SqlConnection GetConnection()
        {
            SqlConnection connection = new SqlConnection(ConnectionString);
            connection.Open();
            return connection;
        }
    }
}