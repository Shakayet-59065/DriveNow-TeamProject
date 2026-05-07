using System;
using System.Configuration;
using System.Data.SqlClient;

public class clsCustomer
{
    public int UserID { get; set; }
    public string FullName { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }
    public string PasswordHash { get; set; }
    public DateTime RegisterDate { get; set; }
    public bool IsActive { get; set; }

    public bool Valid(string fullName, string email, string phone, string password, string registerDate)
    {
        DateTime tempDate;

        if (string.IsNullOrWhiteSpace(fullName) || fullName.Length > 100)
            return false;

        if (string.IsNullOrWhiteSpace(email) || !email.Contains("@") || email.Length > 100)
            return false;

        if (string.IsNullOrWhiteSpace(phone) || phone.Length > 20)
            return false;

        if (string.IsNullOrWhiteSpace(password) || password.Length > 255)
            return false;

        if (!DateTime.TryParse(registerDate, out tempDate))
            return false;

        return true;
    }

    public void Add()
    {
        string connectionString =
            ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        using (SqlConnection con = new SqlConnection(connectionString))
        {
            string sql =
                "INSERT INTO tblUser (FullName, Email, Phone, PasswordHash, RegisterDate, IsActive) " +
                "VALUES (@FullName, @Email, @Phone, @PasswordHash, @RegisterDate, @IsActive)";

            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@FullName", FullName);
                cmd.Parameters.AddWithValue("@Email", Email);
                cmd.Parameters.AddWithValue("@Phone", Phone);
                cmd.Parameters.AddWithValue("@PasswordHash", PasswordHash);
                cmd.Parameters.AddWithValue("@RegisterDate", RegisterDate);
                cmd.Parameters.AddWithValue("@IsActive", true);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    public bool Find(int userID)
    {
        string connectionString =
            ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        using (SqlConnection con = new SqlConnection(connectionString))
        {
            string sql = "SELECT * FROM tblUser WHERE UserID = @UserID";

            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@UserID", userID);

                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        UserID = Convert.ToInt32(reader["UserID"]);
                        FullName = reader["FullName"].ToString();
                        Email = reader["Email"].ToString();
                        Phone = reader["Phone"].ToString();
                        PasswordHash = reader["PasswordHash"].ToString();
                        RegisterDate = Convert.ToDateTime(reader["RegisterDate"]);
                        IsActive = Convert.ToBoolean(reader["IsActive"]);

                        return true;
                    }

                    return false;
                }
            }
        }
    }

    public void Update()
    {
        string connectionString =
            ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        using (SqlConnection con = new SqlConnection(connectionString))
        {
            string sql =
                "UPDATE tblUser SET FullName=@FullName, Email=@Email, Phone=@Phone, PasswordHash=@PasswordHash, RegisterDate=@RegisterDate " +
                "WHERE UserID=@UserID";

            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@FullName", FullName);
                cmd.Parameters.AddWithValue("@Email", Email);
                cmd.Parameters.AddWithValue("@Phone", Phone);
                cmd.Parameters.AddWithValue("@PasswordHash", PasswordHash);
                cmd.Parameters.AddWithValue("@RegisterDate", RegisterDate);
                cmd.Parameters.AddWithValue("@UserID", UserID);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    public void Delete()
    {
        string connectionString =
            ConfigurationManager.ConnectionStrings["DBConnection"].ConnectionString;

        using (SqlConnection con = new SqlConnection(connectionString))
        {
            string sql = "UPDATE tblUser SET IsActive = 0 WHERE UserID = @UserID";

            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@UserID", UserID);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

}