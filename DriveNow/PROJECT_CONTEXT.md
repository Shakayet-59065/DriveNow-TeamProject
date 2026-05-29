# DriveNow — Full Project Context File
> Give this file to any AI alongside the task. It covers everything about the project.
> Last updated: 2026-05-10

---

## 1. WHAT IS THIS PROJECT?

**DriveNow** is a vehicle-rental web application built as a team project for the module **CTEC2713N** at **Niels Brock Copenhagen Business College**. It is a full-stack ASP.NET Web Forms application that lets customers browse a fleet of rental cars, book trips online, and allows staff to manage the entire business (vehicles, drivers, trips, customers, contributors).

**SCRUM Master:** Musanna (the user who owns this repo)  
**Project type:** Academic team project — real, fully functional web app  
**Status:** Feature-complete and buildable; images fixed with Wikimedia Commons URLs

---

## 2. TECHNOLOGY STACK

| Layer | Technology |
|---|---|
| Framework | ASP.NET Web Forms, .NET Framework 4.8 |
| Language | C# (code-behind pattern) |
| Database | SQL Server LocalDB `(localdb)\MSSQLLocalDB`, database name `DriveNow` |
| Data access | ADO.NET + Stored Procedures only (no inline SQL, no ORM) |
| Auth | Session-based (no ASP.NET Identity) |
| Password security | PBKDF2, 100,000 iterations, 16-byte salt, 32-byte hash |
| Styling | Custom CSS (`Content/Site.css`) — dark teal theme |
| Car images | Wikimedia Commons direct thumbnail URLs (no API key needed) |
| IDE | Visual Studio 2022 |
| Solution file | `DriveNow-TeamProject.slnx` |

---

## 3. HOW TO RUN THE PROJECT

1. Open `DriveNow-TeamProject\DriveNow-TeamProject.slnx` in Visual Studio 2022.
2. Open SQL Server Management Studio (SSMS). Connect with:
   - Server: `(localdb)\MSSQLLocalDB`
   - Authentication: **Windows Authentication** (no username/password)
3. Run all **8 SQL scripts** in order from `DataLayer\SQL\`:
   - `1_Tables_And_TestData.sql`
   - `2_Stored_Procedures.sql`
   - `3_Update_Vehicles.sql`
   - `4_Inactive_Procs.sql`
   - `5_Seats_And_More_Vehicles.sql`
   - `6_Extra_Vehicles.sql`
   - `7_Fix_Seats_And_More_Vehicles.sql`
   - `8_Retention_And_HardDelete.sql` ← GDPR/ethics script
4. Press F5 in Visual Studio to run.

---

## 4. DATABASE SCHEMA (All 8 Tables)

### tblVehicle
| Column | Type | Notes |
|---|---|---|
| VehicleID | INT PK | Auto-increment |
| Make | NVARCHAR(50) | e.g. "Toyota" |
| Model | NVARCHAR(50) | e.g. "Corolla" |
| RegistrationNo | NVARCHAR(20) | Unique plate |
| DailyRate | DECIMAL(10,2) | Rental price per day |
| IsAvailable | BIT | 1=active in fleet, 0=removed |
| Seats | INT | Actual seat count from DB |
| DateAdded | DATE | When vehicle was added |

### tblTrip
| Column | Type | Notes |
|---|---|---|
| TripID | INT PK | Auto-increment |
| CustomerID | INT FK | → tblCustomer |
| VehicleID | INT FK | → tblVehicle |
| DriverID | INT FK NULL | Optional assigned driver |
| TripTypeID | INT FK | → tblTripType |
| TripDate | DATE | Date of trip |
| IsDeleted | BIT | Soft delete flag |

### tblTripType
| Column | Type | Notes |
|---|---|---|
| TripTypeID | INT PK | |
| TypeName | NVARCHAR(100) | e.g. "City Tour", "Airport Transfer" |
| Description | NVARCHAR(500) | |
| BaseRate | DECIMAL(10,2) | Additional cost on top of vehicle rate |

### tblCustomer
| Column | Type | Notes |
|---|---|---|
| CustomerID | INT PK | |
| FullName | NVARCHAR(100) | |
| Email | NVARCHAR(150) | Unique |
| Phone | NVARCHAR(20) | |
| PasswordHash | NVARCHAR(255) | PBKDF2 hash |
| RegisterDate | DATE | |
| IsActive | BIT | Soft delete |

### tblDriver
| Column | Type | Notes |
|---|---|---|
| DriverID | INT PK | |
| FullName | NVARCHAR(100) | |
| Email | NVARCHAR(150) | |
| Phone | NVARCHAR(20) | |
| LicenceNo | NVARCHAR(50) | |
| DateOfBirth | DATE | Must be 18+ |
| JoinDate | DATE | |
| IsActive | BIT | |

### tblContributor
| Column | Type | Notes |
|---|---|---|
| ContributorID | INT PK | |
| FullName | NVARCHAR(100) | |
| Email | NVARCHAR(150) | |
| Phone | NVARCHAR(20) | |
| ContributorType | NVARCHAR(20) | "Driver" or "VehicleOwner" |
| IsApproved | BIT | Staff approves applications |
| ApplicationDate | DATE | |
| RetentionMonths | INT NULL | 3 or 6 — set on hard delete consent |
| RetentionConsentDate | DATE NULL | Date consent was given |

### tblContribVehicle
| Column | Type | Notes |
|---|---|---|
| ContribVehicleID | INT PK | |
| ContributorID | INT FK | → tblContributor |
| Make | NVARCHAR(50) | |
| Model | NVARCHAR(50) | |
| RegistrationNo | NVARCHAR(20) | |
| DailyRate | DECIMAL(10,2) | |
| Seats | INT | |

### tblCustomerTrip
| Column | Type | Notes |
|---|---|---|
| CustomerTripID | INT PK | |
| TripID | INT FK | → tblTrip |
| CustomerID | INT FK | → tblCustomer |
| PickupLocation | NVARCHAR(200) | |
| PickupDate | DATETIME | |
| DropoffLocation | NVARCHAR(200) | |
| DropoffDate | DATETIME | |
| Notes | NVARCHAR(500) NULL | |

---

## 5. APPLICATION ARCHITECTURE

### Pattern
3-tier Web Forms:
```
ASPX (UI/Markup)
  ↕ Events (PostBack)
ASPX.CS (Code-Behind / Presentation Logic)
  ↕ Method calls
App_Code/*.cs (Manager classes — Business Logic)
  ↕ ADO.NET SqlCommand
SQL Server LocalDB (Stored Procedures only)
```

### Session Variables
| Key | Value | Set by |
|---|---|---|
| `Session["LoggedIn"]` | `true` | Staff login page |
| `Session["StaffName"]` | string | Staff login page |
| `Session["CustomerLoggedIn"]` | `true` | Default.aspx / Login.aspx |
| `Session["CustomerID"]` | int | Customer login |
| `Session["CustomerName"]` | string | Customer login |
| `Session["CustomerEmail"]` | string | Customer login |
| `Session["FlashMessage"]` | "welcome_back:Name" etc. | Various pages |
| `Session["BookingRef"]` | "DNW-YYMMDD-XXXX" | BookTrip.aspx |

---

## 6. ALL PAGES — PURPOSE & FLOW

### Public Pages (no login required)
| Page | Purpose |
|---|---|
| `Default.aspx` | Home page. Shows hero section, featured fleet (3 cars), login modal, register modal, rental enquiry form. |
| `BrowseFleet.aspx` | Grid of all available vehicles with images, specs, daily rate. "Book" button → BookTrip (customers) or Login (guests). |
| `VehicleDetail.aspx?vid=X` | Full detail page for one vehicle: image, specs, seats, category, doors, mileage estimate, book button. |
| `Login.aspx` | Staff and customer login in tabs. Has "Forgot password?" link. Redirects to `returnUrl` param if present. |
| `ForgotPassword.aspx?type=staff|customer` | Shows reset instructions. Does NOT reveal whether account exists (anti-enumeration). |

### Customer Pages (requires `Session["CustomerLoggedIn"]`)
| Page | Purpose |
|---|---|
| `CustomerPortal.aspx` | Customer dashboard with trip history, account info. |
| `BookTrip.aspx?vid=X` | 4-step booking wizard: (1) Trip details, (2) Insurance, (3) Add-ons, (4) Payment. Sends confirmation email. |
| `BookingConfirmed.aspx` | Displays booking reference, all trip details. |

### Staff Admin Pages (requires `Session["LoggedIn"]`)
#### Layout
All admin pages share a sidebar nav + right-panel layout. Action buttons (Add, Find, Filter) are in the **topbar right** and **section header** of the right panel — NOT in the sidebar.

#### Vehicle Management
| Page | Purpose |
|---|---|
| `VehicleList.aspx` | Table of all vehicles. Active / Removed status tabs. Inline Edit, Delete buttons. |
| `VehicleAdd.aspx` | Form to add a vehicle. |
| `VehicleEdit.aspx?vid=X` | Edit vehicle fields. |
| `VehicleFind.aspx` | Search by registration number or make/model. |
| `VehicleFilter.aspx` | Filter by availability status and date range. |

#### Driver Management
| Page | Purpose |
|---|---|
| `DriverList.aspx` | Table of drivers. Active / Inactive tabs. |
| `DriverAdd.aspx` | Add driver (validates age 18+). |
| `DriverEdit.aspx?did=X` | Edit driver. |
| `DriverDelete.aspx?did=X` | Soft-delete (sets IsActive=0). |
| `DriverFind.aspx` | Search by name or licence number. |
| `DriverFilter.aspx` | Filter by join date range, active status. |

#### Trip Management (Musanna's section)
| Page | Purpose |
|---|---|
| `TripList.aspx` | All trips. Filter by type, date. |
| `TripAdd.aspx` | Create trip record (links customer, vehicle, driver, type). |
| `TripEdit.aspx?tid=X` | Edit trip. |
| `TripFind.aspx` | Search trips by ID or date. |
| `TripFilter.aspx` | Filter by trip type or date range. |
| `TripTypeList.aspx` | Catalogue of trip types. |
| `TripTypeAdd.aspx` | Add new trip type. |
| `TripTypeEdit.aspx?ttid=X` | Edit trip type. |

#### Customer Management
| Page | Purpose |
|---|---|
| `CustomerList.aspx` | All customers. |
| `CustomerAdd.aspx` | Register customer from staff side. |
| `CustomerEdit.aspx?cid=X` | Edit customer. |
| `CustomerFind.aspx` | Search by name or email. |
| `CustomerFilter.aspx` | Filter by register date, active status. |

#### Contributor Management (Ethics-sensitive)
| Page | Purpose |
|---|---|
| `ContributorList.aspx` | All contributor applications. Has normal soft-delete AND "Permanent Delete" button (purple). |
| `ContributorAdd.aspx` | Submit an application (Driver or VehicleOwner type). |
| `ContributorEdit.aspx?cid=X` | Edit application, change approval status. |
| `ContributorFind.aspx` | Search by name/email. |
| `ContributorFilter.aspx` | Filter by type and approval status. |
| `ContribVehicleList.aspx?cid=X` | Vehicles linked to a contributor. |
| `ContribVehicleAdd.aspx` | Add vehicle to contributor. |
| `ContribVehicleEdit.aspx` | Edit contributor vehicle. |

---

## 7. BOOKING FLOW (4-Step Wizard — BookTrip.aspx)

```
Step 1 — Trip Details
  • Select trip type (ddlTripType — loaded from tblTripType)
  • Enter pickup location, pickup date, pickup time
  • Enter dropoff location, dropoff date, dropoff time
  • Optional notes
  • Validates: all fields required, pickup not in past, dropoff after pickup,
    min 1 hour duration, max 365 days

Step 2 — Insurance
  • Basic — Third-Party (FREE)
  • Standard — Damage & Theft (+£X/day)
  • Premium — Full Comprehensive (+£X/day)
  • Elite — Ultimate Protection (+£X/day)
  • Choice stored in hidden field hdnInsurance

Step 3 — Add-Ons (per day charges)
  • GPS Navigation (+£5), Mobile Mount (+£3), Baby/Child Seat (+£8)
  • Booster Seat (+£5), Cycle Carrier (+£10), Roof Box (+£12)
  • 4G WiFi Hotspot (+£6), Dashcam (+£4)

Step 4 — Payment Summary + Card Details
  • Shows: vehicle cost, insurance cost, addons cost, total
  • Cardholder name, 16-digit card number, expiry month/year, CVV
  • Must accept Terms & Conditions checkbox
  • Must accept GDPR data processing consent checkbox
  • On submit: calls spAddTrip + spAddCustomerTrip stored procedures
  • Generates booking reference: DNW-YYMMDD-XXXX
  • Sends HTML confirmation email (SMTP, fails silently if not configured)
  • Redirects to BookingConfirmed.aspx
```

---

## 8. BUSINESS LOGIC — MANAGER CLASSES

### VehicleManager (App_Code/VehicleManager.cs)
- `ListVehicles()` → List<Vehicle> (active only)
- `FindVehicle(id)` → Vehicle
- `AddVehicle(make, model, reg, rate, seats)` → calls spAddVehicle
- `UpdateVehicle(id, make, model, reg, rate, seats)` → calls spUpdateVehicle
- `RemoveVehicle(id)` → sets IsAvailable=0 (soft delete)

### TripManager (App_Code/TripManager.cs)
- `ListTrips()` → all trips with joined names
- `FindTrip(id)` → single trip
- `AddTrip(...)`, `UpdateTrip(...)`, `DeleteTrip(id)` (soft)
- `ListTripTypes()`, `FindTripType(id)`, `AddTripType(...)`, `UpdateTripType(...)`

### CustomerManager (App_Code/CustomerManager.cs)
- `ListCustomers()`, `FindCustomer(id)`, `AddCustomer(...)`, `UpdateCustomer(...)`
- `ValidateCustomer(name, email, phone)` → returns error string or ""
- Soft delete via IsActive flag

### DriverManager (App_Code/DriverManager.cs)
- `ListDrivers()`, `FindDriver(id)`, `AddDriver(...)`, `UpdateDriver(...)`
- `DeleteDriver(id)` → soft delete
- Validates age ≥ 18 (DateOfBirth check)
- Validates LicenceNo not empty

### ContributorManager (App_Code/ContributorManager.cs)
- `ListContributors()`, `FindContributor(id)`
- `AddContributor(...)`, `UpdateContributor(...)`
- `ApproveContributor(id)` → sets IsApproved=1
- `DeleteContributor(id)` → soft delete (IsApproved=0 or similar)
- `HardDelete(contributorID, retentionMonths)` → calls spHardDeleteContributor
  - Requires retentionMonths = 3 or 6
  - Records consent date, then permanently deletes contributor + linked vehicles
- ContribVehicle CRUD: `ListVehicles(contributorID)`, `AddVehicle(...)`, `UpdateVehicle(...)`, `RemoveVehicle(...)`

### DatabaseHelper (App_Code/DatabaseHelper.cs)
```csharp
// Returns an open SqlConnection to DriveNow LocalDB
SqlConnection conn = DatabaseHelper.GetConnection();
// Connection string: Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=DriveNow;Integrated Security=True;
```
All managers call this — never write connection strings elsewhere.

### PasswordHelper (App_Code/PasswordHelper.cs)
```csharp
string hash = PasswordHelper.HashPassword(plaintext);   // PBKDF2, 100k iterations
bool ok     = PasswordHelper.VerifyPassword(input, hash); // constant-time compare
```

### CarImages (App_Code/CarImages.cs)
```csharp
string url = CarImages.GetUrl(make, model);
// Returns specific Wikimedia Commons 800px thumbnail URL per make+model
// Covers 30+ makes, 60+ models. Falls back to BMW 3-Series image.
```
Used by: BrowseFleet.aspx.cs, VehicleDetail.aspx.cs, BookTrip.aspx.cs, Default.aspx.cs

---

## 9. VALIDATION RULES

### Vehicle
- Make: required, max 50 chars
- Model: required, max 50 chars
- RegistrationNo: required, max 20 chars, unique
- DailyRate: required, 0.01–9999.99
- Seats: required, integer > 0

### Customer
- FullName: required, max 100 chars
- Email: required, max 150 chars, must be unique
- Phone: required, max 20 chars
- Password: required (hashed before storage, never stored plain)

### Driver
- FullName, Email, Phone: required
- LicenceNo: required, max 50 chars
- DateOfBirth: required, must be at least 18 years before today

### Contributor
- FullName, Email, Phone: required
- ContributorType: must be exactly "Driver" or "VehicleOwner"
- Hard delete: retentionMonths must be exactly 3 or 6 (enforced in SQL stored procedure too)

### Trip / Booking
- All foreign keys required (CustomerID, VehicleID, TripTypeID)
- TripDate cannot be in the past
- Pickup datetime cannot be in past (with 5-minute grace)
- Dropoff must be after pickup
- Duration: minimum 1 hour, maximum 365 days

### Payment (BookTrip step 4)
- Cardholder name: min 2 chars
- Card number: exactly 16 digits
- Expiry: must not be in the past
- CVV: 3 or 4 digits
- Terms & GDPR consent: both checkboxes required

---

## 10. ETHICS & GDPR FEATURES

### Contributor Hard Delete (Permanent Delete)
**Why it exists:** GDPR gives individuals the "right to erasure." Contributors can request full removal.

**Flow:**
1. Staff clicks "Permanent Delete" (purple button) on ContributorList.aspx
2. A consent modal opens asking: *"How long should this contributor's data be retained before final deletion?"*
3. Staff selects **3 months** or **6 months** (radio buttons)
4. Staff clicks "I Confirm — Permanently Delete"
5. System calls `spHardDeleteContributor(@ContributorID, @RetentionMonths, @ConsentDate)`
6. SQL procedure: validates months ∈ {3,6}, records `RetentionMonths` + `RetentionConsentDate` in tblContributor, then deletes linked `tblContribVehicle` records, then deletes the contributor row
7. Page shows: "Contributor permanently deleted. Data retained for X months per consent."

**Why the 2-column addition (RetentionMonths, RetentionConsentDate):** Creates an audit trail in the database proving that retention policy was followed before deletion.

### GDPR in Booking
- Step 4 of booking requires explicit `chkDataConsent` checkbox — cannot book without it
- Customer email is only used for booking confirmation; email sending fails silently
- No third-party analytics or tracking

### Password Security
- No plain-text passwords ever stored
- PBKDF2 with 100,000 iterations — computationally expensive to brute-force
- Constant-time verification prevents timing attacks

### Forgot Password
- Same response shown whether or not account exists — prevents user enumeration attacks

---

## 11. UI / DESIGN DECISIONS

- **Dark teal theme** — CSS variables `--teal`, `--teal-light`, `--bg-dark`, `--grey`
- **Admin layout:** Left sidebar (navigation only) + right panel (content + topbar with action buttons)
- **Action buttons location:** Add, Find, Filter buttons are in the **right panel topbar and section header** for all admin list pages — they were deliberately moved there from the sidebar for better UX
- **Status tabs:** VehicleList has Active/Removed tabs; DriverList has Active/Inactive tabs
- **Car images:** All from Wikimedia Commons (free, no API key, exact car-model match)
- **Flash messages:** Stored in `Session["FlashMessage"]` as "type:data" strings, displayed once then cleared

---

## 12. FILE STRUCTURE (Key Files Only)

```
DriveNow-TeamProject/
├── DriveNow-TeamProject.slnx          ← Open this in Visual Studio
└── DriveNow/
    ├── App_Code/
    │   ├── CarImages.cs               ← Shared car image URL lookup
    │   ├── ContributorManager.cs      ← Includes HardDelete (GDPR)
    │   ├── CustomerManager.cs
    │   ├── DatabaseHelper.cs          ← GetConnection() — single entry point to DB
    │   ├── DriverManager.cs
    │   ├── PasswordHelper.cs          ← PBKDF2 hashing
    │   ├── TripManager.cs             ← Also manages TripTypes
    │   └── VehicleManager.cs
    ├── Content/
    │   ├── Site.css                   ← All styling
    │   └── logo.png
    ├── Properties/
    │   └── AssemblyInfo.cs
    ├── [Public pages]
    │   ├── Default.aspx / .cs / .designer.cs
    │   ├── Login.aspx / .cs / .designer.cs
    │   ├── ForgotPassword.aspx / .cs / .designer.cs
    │   ├── BrowseFleet.aspx / .cs / .designer.cs
    │   └── VehicleDetail.aspx / .cs / .designer.cs
    ├── [Customer pages]
    │   ├── CustomerPortal.aspx / .cs / .designer.cs
    │   ├── BookTrip.aspx / .cs / .designer.cs
    │   └── BookingConfirmed.aspx / .cs / .designer.cs
    ├── [Vehicle admin]
    │   ├── VehicleList / Add / Edit / Find / Filter .aspx (+.cs +.designer.cs)
    ├── [Driver admin]
    │   ├── DriverList / Add / Edit / Delete / Find / Filter .aspx (+.cs +.designer.cs)
    ├── [Trip admin]
    │   ├── TripList / Add / Edit / Find / Filter .aspx (+.cs +.designer.cs)
    │   └── TripTypeList / Add / Edit .aspx (+.cs +.designer.cs)
    ├── [Customer admin]
    │   ├── CustomerList / Add / Edit / Find / Filter .aspx (+.cs +.designer.cs)
    ├── [Contributor admin]
    │   ├── ContributorList / Add / Edit / Find / Filter .aspx (+.cs +.designer.cs)
    │   └── ContribVehicleList / Add / Edit .aspx (+.cs +.designer.cs)
    ├── DriveNow.csproj
    ├── Web.config
    ├── Global.asax / .cs
    └── PROJECT_CONTEXT.md             ← THIS FILE

DataLayer/
└── SQL/
    ├── 1_Tables_And_TestData.sql
    ├── 2_Stored_Procedures.sql
    ├── 3_Update_Vehicles.sql
    ├── 4_Inactive_Procs.sql
    ├── 5_Seats_And_More_Vehicles.sql
    ├── 6_Extra_Vehicles.sql
    ├── 7_Fix_Seats_And_More_Vehicles.sql
    └── 8_Retention_And_HardDelete.sql  ← GDPR script (run last)
```

---

## 13. STORED PROCEDURES (Key ones)

| Stored Procedure | Purpose |
|---|---|
| `spAddVehicle` | Insert vehicle |
| `spUpdateVehicle` | Update vehicle fields |
| `spRemoveVehicle` | Soft-delete vehicle (IsAvailable=0) |
| `spAddDriver` | Insert driver |
| `spUpdateDriver` | Update driver |
| `spDeleteDriver` | Soft-delete driver |
| `spAddTrip` | Insert trip, returns @NewTripID (OUTPUT param) |
| `spUpdateTrip` | Update trip |
| `spDeleteTrip` | Soft-delete trip (IsDeleted=1) |
| `spAddCustomerTrip` | Insert tblCustomerTrip booking detail |
| `spAddTripType` | Insert trip type |
| `spUpdateTripType` | Update trip type |
| `spAddCustomer` | Insert customer |
| `spUpdateCustomer` | Update customer |
| `spCustomerLogin` | Returns customer row for login check |
| `spAddContributor` | Insert contributor application |
| `spUpdateContributor` | Update contributor |
| `spApproveContributor` | Set IsApproved=1 |
| `spDeleteContributor` | Soft-delete contributor |
| `spHardDeleteContributor` | GDPR hard delete: validates months, records consent, deletes contrib + vehicles |
| `spAddContribVehicle` | Link vehicle to contributor |
| `spUpdateContribVehicle` | Update contributor vehicle |
| `spRemoveContribVehicle` | Remove vehicle from contributor |

---

## 14. KNOWN PATTERNS & CONVENTIONS

### Code-Behind Pattern (all pages follow this)
```csharp
protected void Page_Load(object sender, EventArgs e)
{
    if (IsPostBack) return;       // Only load data on first load
    // Check session auth
    // Load data into controls
}
```

### Designer File Pattern
Every `.aspx` page has a `.aspx.designer.cs` file declaring all server controls as `protected` fields. If a new server control is added in markup, it MUST be added to the designer file too or it won't compile.

### Stored Procedure Call Pattern
```csharp
using (SqlConnection conn = DatabaseHelper.GetConnection())
using (SqlCommand cmd = new SqlCommand("spProcName", conn))
{
    cmd.CommandType = CommandType.StoredProcedure;
    cmd.Parameters.AddWithValue("@Param", value);
    cmd.ExecuteNonQuery(); // or ExecuteReader() or ExecuteScalar()
}
```

### Image Pattern
```csharp
string url = CarImages.GetUrl(make, model);
// In markup: <%# CarImages.GetUrl(Eval("Make").ToString(), Eval("Model").ToString()) %>
// Or via code-behind: imgVehicle.ImageUrl = CarImages.GetUrl(v.Make, v.Model);
```

### Flash Message Pattern
```csharp
// Set (before redirect):
Session["FlashMessage"] = "booking_confirmed:Toyota Corolla";
Response.Redirect("BookingConfirmed.aspx");

// Read (on target page, clear after showing):
string flash = Session["FlashMessage"] as string;
Session.Remove("FlashMessage");
```

---

## 15. THINGS THAT WERE FIXED / ADDED (Session History)

1. **SQL setup errors** — Fixed: use Windows Authentication in SSMS, not SQL Server auth
2. **Admin panel layout** — Action buttons moved from sidebar to right-panel topbar for all list pages
3. **Forgot Password** — Added ForgotPassword.aspx (works for both staff and customer)
4. **Contributor hard delete** — Added "Permanent Delete" with ethics consent modal (3 or 6 month retention choice)
5. **Script 8 (GDPR)** — New SQL script adding RetentionMonths + RetentionConsentDate + spHardDeleteContributor
6. **Database docs** — Full README updated with all 8 tables and their attributes
7. **Car images** — All images replaced with specific Wikimedia Commons URLs per model. Old code used ~18 generic Unsplash photos shared across 60+ cars. Now every car has its own correct image.
8. **CarImages.cs** — Shared static helper so BrowseFleet, VehicleDetail, BookTrip, and Default all use same URLs without code duplication

---

## 16. QUICK REFERENCE FOR AI TASKS

**"Add a new page"**
→ Create `.aspx` + `.aspx.cs` + `.aspx.designer.cs`. Add all three to `DriveNow.csproj`. Auth check: `if (Session["LoggedIn"] == null) Response.Redirect("Login.aspx");`

**"Add a new DB column"**
→ Write a new numbered SQL script (e.g. `9_YourFeature.sql`). Update the relevant Manager class. Update the stored procedures.

**"Add a new stored procedure"**
→ Write in a SQL script with `CREATE OR ALTER PROCEDURE`. Call from Manager class using the pattern in section 14.

**"Fix a build error about control not found"**
→ The control is missing from the `.aspx.designer.cs` file. Add it as `protected global::System.Web.UI.WebControls.ControlType controlName;`

**"Car image not showing"**
→ Edit `App_Code/CarImages.cs`. Add the make/model case with its Wikimedia Commons URL.

**"Add validation"**
→ In the Manager class `Validate*` method, return an error string. In code-behind, show in a Label.

**Connection string (for reference)**
```
Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=DriveNow;Integrated Security=True;
```
