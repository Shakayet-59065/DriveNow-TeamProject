# DriveNow — Team Project

On-demand ride and vehicle rental platform built as a team project for **CTEC2713N — Agile Development** at **Niels Brock Copenhagen, 2026**.

---

## Prerequisites

Install everything below before opening the project:

| Tool | Version | Download |
|------|---------|---------|
| Visual Studio 2022 (Community is fine) | 17+ | [visualstudio.microsoft.com](https://visualstudio.microsoft.com/) |
| ASP.NET and web development workload | — | Included in VS installer |
| SQL Server Express with LocalDB | Any | Included with Visual Studio installer |
| SQL Server Management Studio (SSMS) | Any | [aka.ms/ssmsfullsetup](https://aka.ms/ssmsfullsetup) |
| .NET Framework 4.8 | — | Included with Windows 10/11 |

---

## Quick Setup — copy and run in 5 steps

### 1. Copy the project

Copy the entire `DriveNow-TeamProject` folder anywhere on your machine. No install needed beyond the prerequisites above.

### 2. Set up the database

Open **SSMS** → connect to `(localdb)\MSSQLLocalDB` → run **all 7 scripts** once in order:

```
DataLayer\SQL\1_Tables_And_TestData.sql         ← creates all tables + demo data
DataLayer\SQL\2_Stored_Procedures.sql           ← creates all stored procedures
DataLayer\SQL\3_Update_Vehicles.sql             ← vehicle data patches
DataLayer\SQL\4_Inactive_Procs.sql              ← procs for Active/Inactive toggles
DataLayer\SQL\5_Seats_And_More_Vehicles.sql     ← adds Seats column + expands fleet to 27 vehicles
DataLayer\SQL\6_Extra_Vehicles.sql              ← adds 27 more vehicles across all price bands
DataLayer\SQL\7_Fix_Seats_And_More_Vehicles.sql ← corrects seat counts + 13 more variety vehicles
DataLayer\SQL\8_Retention_And_HardDelete.sql   ← adds data-retention consent columns + permanent delete proc
```

> **Important:** Scripts 5–8 were added after the initial setup. If you ran only scripts 1–4 previously, run 5–8 now — they are all safe to re-run.

If the `DriveNow` database doesn't exist yet, run this first in SSMS:
```sql
CREATE DATABASE DriveNow;
```

All scripts are safe to re-run (`CREATE OR ALTER`, `IF NOT EXISTS`).

### 3. Open the solution

Double-click `DriveNow-TeamProject.slnx` (or open it from **File → Open → Project/Solution** in Visual Studio 2022).

### 4. Check the connection string

Open `DriveNow\Web.config`. The default connection string uses **LocalDB** — no changes needed on most machines:

```xml
<add name="DriveNowDB"
     connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=DriveNow;Integrated Security=True;"
     providerName="System.Data.SqlClient" />
```

If you are using a named SQL Server instance instead, change `(localdb)\MSSQLLocalDB` to your server name (e.g. `.\SQLEXPRESS`).

### 5. Build and run

Press **Ctrl + F5** in Visual Studio. The site opens in your default browser at `http://localhost:<port>/Default.aspx`.

---

## Test login credentials

### Staff portal — `Login.aspx` (select "I am Staff")
| Username | Password |
|----------|----------|
| admin    | admin123 |
| musanna  | pass123  |
| prodip   | pass123  |
| redoy    | pass123  |
| ushno    | pass123  |
| tahmid   | pass123  |

### Customer portal — homepage or `Login.aspx` (select "I am a Customer")
| Email            | Password |
|------------------|----------|
| alice@email.com  | pass123  |
| bob@email.com    | pass123  |
| clara@email.com  | pass123  |

---

## Project structure

```
DriveNow-TeamProject/
├── DriveNow-TeamProject.slnx        ← Open this in Visual Studio 2022
│
├── DataLayer/
│   ├── SQL/                         ← Run all 7 scripts in SSMS (in order)
│   │   ├── 1_Tables_And_TestData.sql
│   │   ├── 2_Stored_Procedures.sql
│   │   ├── 3_Update_Vehicles.sql
│   │   ├── 4_Inactive_Procs.sql
│   │   ├── 5_Seats_And_More_Vehicles.sql
│   │   ├── 6_Extra_Vehicles.sql
│   │   ├── 7_Fix_Seats_And_More_Vehicles.sql
│   │   ├── 8_Retention_And_HardDelete.sql
│   │   └── README.md
│   └── (legacy individual scripts — kept for reference)
│
├── DriveNow/                        ← ASP.NET Web Application project
│   ├── App_Code/                    ← Business logic (Manager classes)
│   │   ├── CustomerManager.cs
│   │   ├── VehicleManager.cs
│   │   ├── DriverManager.cs
│   │   ├── TripManager.cs
│   │   ├── ContributorManager.cs
│   │   ├── DatabaseHelper.cs
│   │   └── PasswordHelper.cs
│   ├── Content/
│   │   ├── Site.css                 ← Staff portal stylesheet
│   │   └── logo.png
│   ├── Web.config                   ← Connection string lives here
│   ├── DriveNow.csproj
│   │
│   ├── Default.aspx                 ← Customer-facing home page
│   ├── BrowseFleet.aspx             ← Browse available vehicles
│   ├── VehicleDetail.aspx           ← Single vehicle details + booking
│   ├── BookTrip.aspx                ← Trip booking (customer login required)
│   ├── CustomerPortal.aspx          ← Customer dashboard
│   ├── Login.aspx / Logout.aspx     ← Shared login (staff & customer)
│   ├── MainMenu.aspx                ← Staff dashboard
│   │
│   ├── Customer*.aspx               ← Staff: customer management
│   ├── Driver*.aspx                 ← Staff: driver management
│   ├── Vehicle*.aspx                ← Staff: vehicle management
│   ├── Trip*.aspx                   ← Staff: trip & trip-type management
│   └── Contributor*.aspx            ← Staff: contributor applications
│
├── MiddleLayer/                     ← Legacy scaffold (not used by project)
├── PresentationLayer/               ← Legacy scaffold (not used by project)
├── packages/                        ← NuGet packages (auto-restored by VS)
├── .gitignore
└── README.md                        ← This file
```

---

## Features

### Customer-facing
- **Home page** — hero section, featured fleet preview, rent form, currency converter
- **Browse Fleet** — full vehicle list with Budget / Mid-Range / Premium filter, live currency conversion (GBP / EUR / USD / DKK / SEK / NOK / AUD)
- **Vehicle Detail** — specs, gallery, pricing in selected currency
- **Book a Trip** — form for logged-in customers
- **Customer Portal** — view booking history, manage account
- **Customer Registration / Login** — modal on homepage or dedicated Login.aspx

### Staff portal (requires staff login)
| Section | Pages | Developer |
|---------|-------|-----------|
| Trip Records | List, Add, Edit, Find, Filter, TripType List/Add/Edit | Musanna |
| Vehicle Inventory | List (with currency), Add, Edit, Find, Filter, Detail | Prodip |
| Driver Management | List, Add, Edit, Delete, Find, Filter | Redoy |
| Contributor Applications | List (All/Approved/Pending), Add, Edit, Find, Filter, Contrib Vehicles | Ushno |
| Customer Management | List (Active/Inactive), Add, Edit, Find, Filter | Tahmid |

All list pages have **Active / Inactive** (or Approved / Pending) tab switchers — soft deletes by default.  
Contributor Manager has a **Permanent Delete** option that first asks for a data-retention period (3 or 6 months) as an ethical consent step before any hard delete.

---

## Database — how to view and understand the data

Open **SSMS** → connect to `(localdb)\MSSQLLocalDB` → expand **DriveNow** → **Tables**.

### Quick queries

```sql
-- All tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- All columns for a table (e.g. tblDriver)
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME = 'tblDriver';

-- Count rows in every table
SELECT 'tblStaff'        AS Tbl, COUNT(*) AS Rows FROM tblStaff        UNION ALL
SELECT 'tblCustomer',             COUNT(*)         FROM tblCustomer      UNION ALL
SELECT 'tblVehicle',              COUNT(*)         FROM tblVehicle       UNION ALL
SELECT 'tblDriver',               COUNT(*)         FROM tblDriver        UNION ALL
SELECT 'tblTripType',             COUNT(*)         FROM tblTripType      UNION ALL
SELECT 'tblTrip',                 COUNT(*)         FROM tblTrip          UNION ALL
SELECT 'tblContributor',          COUNT(*)         FROM tblContributor   UNION ALL
SELECT 'tblContribVehicle',       COUNT(*)         FROM tblContribVehicle;
```

### Table attribute reference

| Table | Column | Type | Notes |
|-------|--------|------|-------|
| **tblStaff** | StaffID | INT IDENTITY | Primary key |
| | Username | VARCHAR(50) | Login username |
| | PasswordHash | VARCHAR(255) | Hashed password |
| | FullName | VARCHAR(100) | Display name |
| | IsActive | BIT | 1 = active staff member |
| **tblCustomer** | CustomerID | INT IDENTITY | Primary key |
| | FullName | VARCHAR(100) | Customer full name |
| | Email | VARCHAR(150) | Login email (unique) |
| | Phone | VARCHAR(20) | Contact number |
| | PasswordHash | VARCHAR(255) | BCrypt hash |
| | RegisterDate | DATE | Account creation date |
| | IsActive | BIT | 0 = deactivated (soft delete) |
| **tblVehicle** | VehicleID | INT IDENTITY | Primary key |
| | RegistrationNo | VARCHAR(20) | Plate number |
| | Make | VARCHAR(50) | Manufacturer (e.g. BMW) |
| | Model | VARCHAR(50) | Model name |
| | DailyRate | DECIMAL(8,2) | Hire price per day (GBP) |
| | DateAdded | DATE | When vehicle was added |
| | IsAvailable | BIT | 0 = removed from service |
| | Seats | INT | Number of passenger seats |
| **tblDriver** | DriverID | INT IDENTITY | Primary key |
| | FullName | VARCHAR(100) | Driver full name |
| | Phone | VARCHAR(20) | Contact number |
| | LicenceNumber | VARCHAR(30) | Driving licence ref |
| | DateOfBirth | DATE | DOB |
| | JoinDate | DATE | When driver joined |
| | IsActive | BIT | 0 = inactive driver |
| **tblTripType** | TripTypeID | INT IDENTITY | Primary key |
| | TypeName | VARCHAR(50) | Unique type label |
| | Description | VARCHAR(200) | Explanation |
| | BaseRate | DECIMAL(8,2) | Base charge (GBP) |
| | CreatedDate | DATE | When type was created |
| | IsActive | BIT | 0 = soft deleted |
| **tblTrip** | TripID | INT IDENTITY | Primary key |
| | CustomerId | INT | FK → tblCustomer |
| | VehicleID | INT | FK → tblVehicle |
| | DriverID | INT NULL | FK → tblDriver (NULL for self-drive) |
| | TripTypeID | INT | FK → tblTripType |
| | TripDate | DATE | Date of the trip |
| | IsActive | BIT | 0 = cancelled/inactive |
| **tblContributor** | ContributorID | INT IDENTITY | Primary key |
| | FullName | VARCHAR(100) | Applicant name |
| | Email | VARCHAR(150) | Contact email |
| | Phone | VARCHAR(20) | Contact phone |
| | ContributorType | VARCHAR(20) | "Driver" or "VehicleOwner" |
| | ApplicationDate | DATE | Date application submitted |
| | IsApproved | BIT | 0 = pending, 1 = approved |
| | RetentionMonths | INT NULL | Data retention period chosen (3 or 6) |
| | RetentionConsentDate | DATE NULL | Date consent was given |
| **tblContribVehicle** | ContribVehicleID | INT IDENTITY | Primary key |
| | ContributorID | INT | FK → tblContributor |
| | Make | VARCHAR(50) | Vehicle manufacturer |
| | Model | VARCHAR(50) | Vehicle model |
| | Year | INT | Year of manufacture |
| | RegistrationNo | VARCHAR(20) | Plate number |
| | IsAvailable | BIT | 0 = soft deleted |

---

## Tech stack

| Layer | Technology |
|-------|-----------|
| Presentation | ASP.NET Web Forms (.aspx), HTML5, CSS3, vanilla JS |
| Business logic | C# (.NET Framework 4.8), Manager classes in App_Code |
| Data access | ADO.NET, SQL Server stored procedures |
| Database | SQL Server Express / LocalDB |
| Auth | Session-based (staff: `Session["LoggedIn"]`, customer: `Session["CustomerLoggedIn"]`) |
| Passwords | BCrypt hashing via PasswordHelper |

---

## Team

| Name | Role | Section | Branch |
|------|------|---------|--------|
| Musanna | SCRUM Master | Trip Records | `trip-records` |
| Prodip | Developer | Vehicle Inventory | `vehicle-inventory` |
| Redoy | Developer | Driver Management | `driver-management` |
| Ushna | Developer | Contributor Applications | `contributor-applications` |
| Tahmid | Developer | Customer Management | `customer-management` |

---

## Branch rules

- Never push directly to `main`.
- Each person works on their own feature branch only.
- Commit after every session with a clear message.
- `main` contains the integrated, working version.
