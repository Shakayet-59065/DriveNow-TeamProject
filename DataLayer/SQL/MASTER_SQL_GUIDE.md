# DriveNow — Master SQL Reference Guide
**Module:** CTEC2713N · Niels Brock Copenhagen  
**Run scripts in order: 1 → 30** (each script is additive / idempotent)

---

## Tables in the Database

| Table | Purpose |
|---|---|
| `tblStaff` | Admin/staff login accounts with BCrypt-hashed passwords |
| `tblCustomer` | Customer accounts (portal login, profile, loyalty tier) |
| `tblDriver` | Driver records: licence, DOB, join date, rating, gender |
| `tblVehicle` | Fleet vehicles: reg no (**unique**), make, model, seats, daily rate, photo URL |
| `tblTripType` | Trip type definitions (name, base price, category) |
| `tblTrip` | Bookings: customer + vehicle + driver + dates + status |
| `tblContributor` | Contributor applications: Driver / VehicleOwner / OwnerDriver |
| `tblContribVehicle` | Vehicle details attached to a contributor application |
| `tblPasswordResetToken` | One-time tokens for staff/customer password resets |
| `tblEmailVerification` | Email verification tokens for new customer registration |

---

## Stored Procedures (alphabetical)

| Procedure | Script | Purpose |
|---|---|---|
| `spAddContributor` | 12 | Insert a new contributor application |
| `spAddCustomer` | 2 | Register a new customer account |
| `spAddDriver` | 2 | Add a new driver record |
| `spAddStaff` | 18 | Add a new staff member (BCrypt password) |
| `spAddTrip` | 2 | Create a trip booking |
| `spAddTripType` | 2 | Add a trip type |
| `spAddVehicle` | 2 | Add a vehicle to the fleet |
| `spApproveContributor` | 12 | Approve a contributor — creates Driver/Vehicle records automatically |
| `spCancelCustomerTrip` | 17 | Customer-initiated trip cancellation with refund calculation |
| `spCheckDuplicateLicence` | 30 | Returns 1 if a licence number already exists (cross tblContributor + tblDriver) |
| `spCheckDuplicateVehicleReg` | 30 | Returns 1 if a vehicle reg already exists in tblVehicle |
| `spCheckEmailExists` | 16 | Returns 1/0 for email existence check (used on registration) |
| `spDeleteCustomer` | 8 | Soft-delete a customer (IsActive = 0) |
| `spDeleteDriver` | 4 | Soft-deactivate a driver (IsActive = 0) |
| `spDeleteVehicle` | 4 | Soft-remove a vehicle (IsAvailable = 0) |
| `spDeleteTripType` | 8 | Soft-delete a trip type |
| `spEditContributor` | 28 | Update all contributor fields + sync tblVehicle/tblDriver on approval |
| `spEditCustomer` | 2 | Update customer profile |
| `spEditDriver` | 2 | Update driver record |
| `spEditTrip` | 2 | Update trip details |
| `spEditTripType` | 2 | Update trip type |
| `spEditVehicle` | 2 | Update vehicle details |
| `spFilterDrivers` | 4 | List drivers with optional name/licence filter + active flag |
| `spFilterTripTypes` | 15 | Advanced trip type filter by category/price range |
| `spFilterVehicles` | 2 | List vehicles with optional make/model filter |
| `spFindContributor` | 12 | Find a contributor by ID |
| `spFindCustomer` | 2 | Find a customer by ID |
| `spFindDriver` | 2 | Find a driver by ID |
| `spFindVehicle` | 2 | Find a vehicle by ID |
| `spGetCustomerDashboard` | 10 | Returns customer stats for the portal dashboard |
| `spGetCustomerTrips` | 2 | Returns all trips for a customer (portal) |
| `spGetDashboardStats` | 10 | Returns admin dashboard summary (totals, revenue, etc.) |
| `spGetDriverProfile` | 24 | Returns full driver profile with trip count and rating |
| `spGetStaffProfile` | 10 | Returns staff profile details |
| `spHardDeleteCustomer` | 8 | Permanently delete a customer |
| `spHardDeleteDriver` | 11 | Permanently delete a driver |
| `spHardDeleteVehicle` | 11 | Permanently delete a vehicle |
| `spHardDeleteTripType` | 11 | Permanently delete a trip type |
| `spListContributors` | 12 | List all contributors (with optional filter) |
| `spListCustomers` | 2 | List all customers |
| `spListDrivers` | 2 | List all active drivers |
| `spListVehicles` | 2 | List all vehicles |
| `spLoginCustomer` | 2 | Validate customer email + password |
| `spLoginStaff` | 2 | Validate staff username + BCrypt password |
| `spMarkCarReturned` | 18 | Mark a trip as returned and set DropoffDate |
| `spResetCustomerPassword` | 14 | Update customer password (from reset flow) |
| `spResetStaffPassword` | 20 | Update staff password from token |
| `spRestoreCustomer` | 11 | Restore a soft-deleted customer |
| `spRestoreDriver` | 11 | Restore a deactivated driver |
| `spRestoreVehicle` | 11 | Restore a removed vehicle |
| `spRestoreTripType` | 11 | Restore a soft-deleted trip type |
| `spSaveEmailVerificationToken` | 20 | Store email verification token for new customer |
| `spSavePasswordResetToken` | 13 | Store a password-reset token |
| `spUpdateDriverRating` | 25 | Update driver rating + gender + specialty fields |
| `spVerifyCustomerEmail` | 20 | Consume email verification token |
| `spVerifyPasswordResetToken` | 13 | Validate a password-reset token |

---

## Script File Index

| # | File | Contents |
|---|---|---|
| 1 | `1_Tables_And_TestData.sql` | CREATE TABLE for all core tables + initial test data |
| 2 | `2_Stored_Procedures.sql` | Core CRUD stored procedures for all entities |
| 3 | `3_Update_Vehicles.sql` | Add more test vehicles |
| 4 | `4_Inactive_Procs.sql` | spDeleteDriver, spDeleteVehicle, spDeleteTripType, spFilterDrivers |
| 5 | `5_Seats_And_More_Vehicles.sql` | Add Seats column to tblVehicle + extra vehicles |
| 6 | `6_Extra_Vehicles.sql` | Additional test vehicles |
| 7 | `7_Fix_Seats_And_More_Vehicles.sql` | Fix Seats data for existing vehicles |
| 8 | `8_Retention_And_HardDelete.sql` | spHardDelete* procedures + soft-delete for customers |
| 9 | `9_Staff_Email_Phone.sql` | Add Email + Phone columns to tblStaff |
| 10 | `10_Dashboard_And_Profile_Procs.sql` | spGetDashboardStats, spGetCustomerDashboard, spGetStaffProfile |
| 11 | `11_Restore_And_HardDelete.sql` | spRestore* + spHardDelete* for Driver/Vehicle/TripType |
| 12 | `12_ApproveContributor.sql` | tblContributor + tblContribVehicle + spAddContributor + spApproveContributor |
| 13 | `13_PasswordReset.sql` | tblPasswordResetToken + spSavePasswordResetToken + spVerifyPasswordResetToken |
| 14 | `14_UpdateCustomerPassword.sql` | spResetCustomerPassword |
| 15 | `15_TripTypeAdvancedFilter.sql` | spFilterTripTypes with category/price-range parameters |
| 16 | `16_EmailExists.sql` | spCheckEmailExists |
| 17 | `17_CancelCustomerTrip.sql` | spCancelCustomerTrip with refund logic |
| 18 | `18_StaffBCrypt_AutoDriver_CarReturned_AddStaff.sql` | BCrypt staff login, spMarkCarReturned, spAddStaff |
| 19 | `19_StaffRole.sql` | Add Role column to tblStaff |
| 20 | `20_EmailVerification_StaffPasswordReset.sql` | tblEmailVerification, email verification flow, staff password reset |
| 21 | `21_AvailabilityCheck_LoyaltyTier_Fixes.sql` | Vehicle availability check for bookings, loyalty tier calculation |
| 22 | `22_TripList_DropoffDate.sql` | Add DropoffDate column to tblTrip |
| 23 | `23_AdminCancelledTrips.sql` | Admin cancel trip view + cancelled trip handling |
| 24 | `24_DriverProfile.sql` | spGetDriverProfile with extended driver details |
| 25 | `25_DriverRatingGenderSpecialty.sql` | Add Rating, Gender, Specialty columns to tblDriver + spUpdateDriverRating |
| 26 | `26_ContributorFullApproval.sql` | Extend tblContributor with LicenceNumber, DOB, DailyRate, Colour, Seats, photo URLs + upgrade spApproveContributor |
| 27 | `27_VehiclePhotoUrl.sql` | Add PhotoUrl column to tblVehicle |
| 28 | `28_ContributorEdit_ExtendedFields.sql` | Add LicenceIssueDate, LicenceExpiryDate to tblContributor + upgrade spEditContributor |
| 29 | `29_TestData_UserJourneys.sql` | Full test data for all 5 user journey scenarios |
| **30** | **`30_UniquenessConstraints_And_DuplicateChecks.sql`** | **UNIQUE indexes on RegistrationNo + LicenceNumber + spCheckDuplicate* procedures** |
| — | `RUNTHIS_FixStaffLogin.sql` | Emergency fix: resets staff login if BCrypt is missing |
| — | `RUNTHIS_ResetAdminPassword.sql` | Reset admin password to default |

---

## Validation Rules (enforced in both layers)

### Phone Number
- Must start with `+` (country code required)
- Total digits (after stripping formatting): **7–15**  
- Per-country length enforced in JS (50+ country codes) and C# server-side
- Examples: `+44 7700 900000` (UK, 12 digits), `+45 12345678` (DK, 10 digits), `+1 2125551234` (US, 11 digits)

### Driving Licence Number
- Pattern: `^(?=(?:.*[A-Za-z]){2})(?=(?:.*[0-9]){2})[A-Za-z0-9\-]{5,20}$`
- 5–20 characters, at least **2 letters** AND **2 digits**
- Example UK format: `SMIT9701157JS9AB`
- Must be **unique** across tblContributor and tblDriver

### Vehicle Registration Number
- Must be **unique** in tblVehicle (UNIQUE index enforced by Script 30)
- Stored UPPER-CASE

### Date of Birth (Driver / OwnerDriver)
- Must be ≥ 01/01/1970
- Contributor must be ≥ 18 years old (DOB ≤ today − 18 years)

### Licence Issue Date (Driver / OwnerDriver)
- Must be ≥ 1 year ago (issue date ≤ today − 1 year)

---

## Files Outside the Numbered Sequence (Legacy — do not re-run)

| File | Notes |
|---|---|
| `CreateTables.sql` (root) | Original table definitions — superseded by Script 1 |
| `DriveNow_DataLayer_Musanna.sql` | Early development data layer — superseded by Script 2 |
| `Fix_AllMissingObjects.sql` | One-off emergency fix — already applied |
| `Fix_CustomerLogin.sql` | One-off emergency fix — already applied |
| `Setup_*.sql` files | One-off setup scripts — already applied |
