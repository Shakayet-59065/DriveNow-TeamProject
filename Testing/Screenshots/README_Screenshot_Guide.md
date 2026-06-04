# Screenshots Guide — Driver Management
## Where to take each screenshot and what to name it

**Tester:** Redoy | **Component:** Driver Management | **Date:** June 2026

---

Place all screenshots as .png files in this folder (`Testing/Screenshots/`) AND embed them in the Portfolio 2 Word document.

---

## Screenshot 1 — tblDriver Table Structure
**File name:** `01_tblDriver_structure.png`

**Where:**
1. Open SSMS → connect to `(localdb)\MSSQLLocalDB`
2. Expand: Databases → DriveNow → Tables → dbo.tblDriver → Columns
3. Screenshot showing all columns: DriverID, FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, IsActive, PhotoUrl, Bio, Rating, Gender, Specialty

**Caption in Word doc:** "SSMS — tblDriver table structure showing all columns and data types for the Driver Management component."

---

## Screenshot 2 — Live tblDriver Query (real data rows)
**File name:** `02_tblDriver_query.png`

**Where:**
1. In SSMS, open a new query window against DriveNow
2. Run: `SELECT * FROM tblDriver ORDER BY DriverID;`
3. Screenshot the results grid showing real driver rows

**Caption:** "SSMS — Live query of tblDriver showing real driver records in the database."

---

## Screenshot 3 — Driver Stored Procedure Open in SSMS
**File name:** `03_spAddDriver_procedure.png`

**Where:**
1. In SSMS: Databases → DriveNow → Programmability → Stored Procedures → dbo.spAddDriver
2. Right-click → Modify (or Script as → ALTER TO → New Query Window)
3. Screenshot showing the spAddDriver code

**Caption:** "SSMS — spAddDriver stored procedure open, showing parameters for FullName, Phone, LicenceNumber, DateOfBirth, JoinDate, and optional profile fields."

---

## Screenshot 4 — Validation Error (form rejecting bad value)
**File name:** `04_validation_error.png`

**Where:**
1. Run the DriveNow app (Ctrl+F5 in Visual Studio)
2. Log in → go to Driver Management → Add Driver
3. Leave Full Name empty (or enter a future date of birth)
4. Click "Add Driver"
5. Screenshot showing the red error message (e.g., "Full name is required." or "Driver must be at least 18 years old.")

**Caption:** "App — DriverAdd.aspx form rejecting an invalid value. The validation error message is displayed in red."

---

## Screenshot 5 — Successful Save
**File name:** `05_successful_save.png`

**Where:**
1. On the Add Driver form, fill in all valid details:
   - Full Name: James Anderson
   - Phone: +4512345678
   - Licence Number: ANDE9901157JA9
   - Date of Birth: (35 years ago — e.g., 1991-06-04)
   - Join Date: (today's date)
   - Rating: 4.5 (optional)
2. Click "Add Driver"
3. Screenshot showing the green success message: "Driver added! ID: #DRV-XXX"

**Caption:** "App — DriverAdd.aspx form accepting a valid driver record and displaying the success message with the assigned driver ID."

---

## Screenshot 6 — SQL Test Script Output
**File name:** `06_sql_test_output.png`

**Where:**
1. Open SSMS → open `Testing/TestScripts/DriverManagement_SQL_PassFail_Tests.sql`
2. Execute the script (F5)
3. Screenshot the Results tab showing the test results table (TestName, Status columns visible)

**Caption:** "SSMS — SQL pass/fail test script output for Driver Management. All boundary tests executed against the live DriveNow database."

---

## Screenshot 7 — GitHub Branch Commit History
**File name:** `07_github_commit_history.png`

**Where:**
1. Go to: https://github.com/Shakayet-59065/DriveNow-TeamProject
2. Switch to the `driver-management` branch
3. Click "X commits" (near the top right of the file list)
4. Screenshot showing the list of commits on the driver-management branch

**Caption:** "GitHub — Commit history for the driver-management branch showing development progress."

---

## Screenshot 8 — GitHub Pull Request and Merge
**File name:** `08_github_pr_merge.png`

**Where:**
1. On GitHub, go to Pull Requests tab
2. Find the PR from `driver-management` → `main`
3. Screenshot the PR page showing it is merged (purple "Merged" badge)

**Caption:** "GitHub — Pull Request from driver-management branch into main, showing successful merge."

---

## Embedding in the Word Document

After taking all 8 screenshots:
1. Open `Redoy_Portfolio2_DriverManagement.docx`
2. Go to Section 3 — Screenshots
3. For each screenshot, insert it under its heading (Insert → Pictures → This Device)
4. Add the caption text below each image
5. Resize images to fit the page width (about 16 cm wide)
