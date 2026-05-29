# GitHub Repository Structure — DriveNow Team Project

**Repository:** https://github.com/Shakayet-59065/DriveNow-TeamProject  
**Personal Branch:** `trip-records` (Musanna — Trip Records & Trip Type Catalogue)

```
DriveNow-TeamProject/
│
├── DriveNow/                          ← ASP.NET WebForms project (Presentation + Middle layer)
│   ├── App_Code/
│   │   ├── TripManager.cs             ← Musanna: Trip & TripType business logic (middle layer)
│   │   ├── DatabaseHelper.cs          ← Shared: SQL Server connection helper
│   │   ├── CustomerManager.cs         ← Tahmid: Customer management
│   │   ├── ContributorManager.cs      ← Ushna: Contributor applications
│   │   ├── DriverManager.cs           ← Redoy: Driver management
│   │   └── VehicleManager.cs          ← Prodip: Vehicle inventory
│   ├── TripAdd.aspx / TripAdd.aspx.cs ← Musanna: Add Trip page
│   ├── TripEdit.aspx                  ← Musanna: Edit Trip page
│   ├── TripList.aspx                  ← Musanna: Trip list with filter
│   ├── TripTypeAdd.aspx               ← Musanna: Add TripType page
│   ├── TripTypeEdit.aspx              ← Musanna: Edit TripType page
│   ├── TripTypeList.aspx              ← Musanna: TripType catalogue list
│   ├── Login.aspx                     ← Musanna: Login page (shared)
│   ├── MainMenu.aspx                  ← Musanna: Main navigation menu (shared)
│   └── ...
│
├── DriveNow.Tests/                    ← Musanna: MSTest unit test project
│   ├── TripManagerTests.cs            ← 12 unit tests for ValidateTrip()
│   ├── TripTypeManagerTests.cs        ← 12 unit tests for ValidateTripType()
│   ├── DriveNow.Tests.csproj          ← .NET 4.8, MSTest 3.0.4
│   └── packages.config                ← NuGet: MSTest.TestAdapter + TestFramework 3.0.4
│
├── DataLayer/
│   └── SQL/                           ← 32 numbered SQL scripts (tables + stored procedures)
│       ├── 1_Tables_And_TestData.sql
│       ├── ...
│       └── 32_UniquenessConstraints_And_DuplicateChecks.sql
│
├── TestEvidence/                      ← Musanna: Test evidence linking tests to Portfolio 2
│   ├── README.md                      ← Maps each test method to BVA test log rows
│   └── GitHubStructure.md             ← This file
│
├── DriveNow-TeamProject.slnx          ← Visual Studio solution file
└── README.md                          ← Project overview
```

## Three-Tier Architecture

```
PRESENTATION LAYER          MIDDLE LAYER                DATA LAYER
.aspx / .aspx.cs    →   App_Code/*.cs Manager   →   SQL Stored Procedures
(User interface)        (Business logic)             (Database — no inline SQL)
```

## Musanna's Tables

| Table | Purpose |
|---|---|
| tblTripType | Trip type catalogue (e.g. Standard, Premium, Economy) |
| tblTrip | Individual trip records |
| tblCustomerTrip | Junction table — customer to trip relationship |

## Branch Strategy

| Branch | Developer | Component |
|---|---|---|
| `main` | Shared | Final merged product |
| `trip-records` | Musanna | Trip Records + TripType Catalogue |
| Other branches | Team members | Customer, Driver, Vehicle, Contributor |
