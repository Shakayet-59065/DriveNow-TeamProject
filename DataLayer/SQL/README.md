# DriveNow — SQL Setup Scripts

Run these scripts **in order** against a fresh `DriveNow` database.

## Scripts

| # | File | Purpose | Run when |
|---|------|---------|----------|
| 1 | `1_Tables_And_TestData.sql` | Creates every table and inserts demo data | Once, on a fresh database |
| 2 | `2_Stored_Procedures.sql` | Creates all stored procedures | After Script 1, or when a proc is missing |
| 3 | `3_Update_Vehicles.sql` | Patches vehicle data and adds missing columns | After Script 2 |
| 4 | `4_Inactive_Procs.sql` | Adds `spListInactiveTrips` and `spListInactiveTripTypes` | After Script 2 (needed for Active/Inactive tabs) |
| 5 | `5_Seats_And_More_Vehicles.sql` | Adds Seats column to tblVehicle, expands fleet to 27 vehicles across all price bands, updates vehicle stored procedures | After Script 3 (needed for seat filter on Browse Fleet) |
| 6 | `6_Extra_Vehicles.sql` | Adds 27 more vehicles — 9 budget (under £60), 9 mid-range (£60–£100), 9 premium (over £100) including exotic models | After Script 5 (safe to re-run, uses WHERE NOT EXISTS) |
| 7 | `7_Fix_Seats_And_More_Vehicles.sql` | Corrects seat counts and adds 13 more variety vehicles | After Script 6 (safe to re-run) |
| 8 | `8_Retention_And_HardDelete.sql` | Adds RetentionMonths/RetentionConsentDate to tblContributor; creates `spHardDeleteContributor` for the permanent delete feature | After Script 7 |

All scripts use `CREATE OR ALTER` / `IF NOT EXISTS` — safe to re-run.

---

## How to run in SSMS

1. Open **SSMS** → connect to `(localdb)\MSSQLLocalDB`
2. Run once if the database doesn't exist yet:
   ```sql
   CREATE DATABASE DriveNow;
   ```
3. Open each script file → set the target database to **DriveNow** → click **Execute**
4. Run them in order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

---

## Test login credentials

### Staff — `Login.aspx` → "I am Staff"
| Username | Password |
|----------|----------|
| admin    | admin123 |
| musanna  | pass123  |
| prodip   | pass123  |
| redoy    | pass123  |
| ushno    | pass123  |
| tahmid   | pass123  |

### Customers — `Default.aspx` modal or `Login.aspx` → "I am a Customer"
| Email            | Password |
|------------------|----------|
| alice@email.com  | pass123  |
| bob@email.com    | pass123  |
| clara@email.com  | pass123  |

---

## How to view the database in SSMS

1. Connect to `(localdb)\MSSQLLocalDB` in SSMS.
2. Expand **Databases → DriveNow → Tables** to see all tables.
3. Right-click any table → **Select Top 1000 Rows** to browse data.
4. Right-click any table → **Design** to see column definitions.

### Quick diagnostic queries

```sql
-- List all tables
SELECT TABLE_NAME
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE'
ORDER  BY TABLE_NAME;

-- Show all columns for a table (replace tblDriver with any table name)
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME = 'tblDriver'
ORDER  BY ORDINAL_POSITION;

-- Row counts across all tables
SELECT 'tblStaff'          AS TableName, COUNT(*) AS Rows FROM tblStaff          UNION ALL
SELECT 'tblCustomer',                    COUNT(*)         FROM tblCustomer        UNION ALL
SELECT 'tblVehicle',                     COUNT(*)         FROM tblVehicle         UNION ALL
SELECT 'tblDriver',                      COUNT(*)         FROM tblDriver          UNION ALL
SELECT 'tblTripType',                    COUNT(*)         FROM tblTripType        UNION ALL
SELECT 'tblTrip',                        COUNT(*)         FROM tblTrip            UNION ALL
SELECT 'tblContributor',                 COUNT(*)         FROM tblContributor     UNION ALL
SELECT 'tblContribVehicle',              COUNT(*)         FROM tblContribVehicle;

-- List all stored procedures
SELECT name FROM sys.procedures ORDER BY name;
```

---

## Table attribute reference

### tblStaff
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| StaffID | INT IDENTITY | No | Primary key, auto-increment |
| Username | VARCHAR(50) | No | Login username, must be unique |
| PasswordHash | VARCHAR(255) | No | Plain text for dev — use hashed in production |
| FullName | VARCHAR(100) | No | Display name shown in the portal |
| IsActive | BIT | No | 1 = active staff member; 0 = disabled |

### tblCustomer
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| CustomerID | INT IDENTITY | No | Primary key |
| FullName | VARCHAR(100) | No | Customer full name |
| Email | VARCHAR(150) | No | Login email — must be unique |
| Phone | VARCHAR(20) | No | Contact number |
| PasswordHash | VARCHAR(255) | No | BCrypt hashed password |
| RegisterDate | DATE | No | Account creation date |
| IsActive | BIT | No | 0 = deactivated (soft delete) |

### tblVehicle
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| VehicleID | INT IDENTITY | No | Primary key |
| RegistrationNo | VARCHAR(20) | No | Plate number |
| Make | VARCHAR(50) | No | Manufacturer (e.g. BMW, Toyota) |
| Model | VARCHAR(50) | No | Model name (e.g. 3 Series) |
| DailyRate | DECIMAL(8,2) | No | Hire price per day in GBP |
| DateAdded | DATE | No | Date vehicle was added to fleet |
| IsAvailable | BIT | No | 1 = active in fleet; 0 = removed from service |
| Seats | INT | No | Number of passenger seats (added by Script 5) |

### tblDriver
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| DriverID | INT IDENTITY | No | Primary key |
| FullName | VARCHAR(100) | No | Driver full name |
| Phone | VARCHAR(20) | No | Contact number |
| LicenceNumber | VARCHAR(30) | No | Driving licence reference |
| DateOfBirth | DATE | No | Driver date of birth |
| JoinDate | DATE | No | Date driver joined DriveNow |
| IsActive | BIT | No | 0 = driver deactivated (soft delete) |

### tblTripType
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| TripTypeID | INT IDENTITY | No | Primary key |
| TypeName | VARCHAR(50) | No | Unique type label (e.g. "Short Ride") |
| Description | VARCHAR(200) | Yes | Explanation of the trip type |
| BaseRate | DECIMAL(8,2) | No | Base charge in GBP |
| CreatedDate | DATE | No | When the type was created |
| IsActive | BIT | No | 0 = soft deleted trip type |

### tblTrip
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| TripID | INT IDENTITY | No | Primary key |
| CustomerId | INT | No | FK → tblCustomer.CustomerID |
| VehicleID | INT | No | FK → tblVehicle.VehicleID |
| DriverID | INT | Yes | FK → tblDriver.DriverID; NULL for self-drive trips |
| TripTypeID | INT | No | FK → tblTripType.TripTypeID |
| TripDate | DATE | No | Date the trip takes / took place |
| IsActive | BIT | No | 0 = cancelled or soft-deleted trip |

### tblContributor
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| ContributorID | INT IDENTITY | No | Primary key |
| FullName | VARCHAR(100) | No | Applicant full name |
| Email | VARCHAR(150) | No | Contact email |
| Phone | VARCHAR(20) | No | Contact phone |
| ContributorType | VARCHAR(20) | No | Must be exactly "Driver" or "VehicleOwner" |
| ApplicationDate | DATE | No | Date application was submitted |
| IsApproved | BIT | No | 0 = pending; 1 = approved by staff |
| RetentionMonths | INT | Yes | Data retention period chosen before permanent delete (3 or 6) |
| RetentionConsentDate | DATE | Yes | Date staff recorded retention consent |

### tblContribVehicle
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| ContribVehicleID | INT IDENTITY | No | Primary key |
| ContributorID | INT | No | FK → tblContributor.ContributorID |
| Make | VARCHAR(50) | No | Vehicle manufacturer |
| Model | VARCHAR(50) | No | Vehicle model name |
| Year | INT | No | Year of manufacture |
| RegistrationNo | VARCHAR(20) | No | Plate number |
| IsAvailable | BIT | No | 0 = vehicle soft-deleted |

---

## Legacy scripts (reference only)

The files directly in `DataLayer/` (e.g. `DriveNow_DataLayer_Musanna.sql`, `Setup_AllMissingProcs.sql`) are the original team members' individual scripts kept for reference. **Use the numbered scripts in this folder instead.**
