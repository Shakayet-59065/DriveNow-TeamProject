# Driver Management Testing Folder

Component: Driver Management  
Student: Redoy  
P-number: 59065  
Project: DriveNow-TeamProject  
Branch: driver-management

This folder follows the Portfolio 2 testing lecture instructions. The lecturer asked for testing evidence to be organised in GitHub instead of only writing test logs manually.

## Folder Structure

| Folder | Purpose |
|---|---|
| `TestScripts` | Manual test checklist and SQL test script used to check the Driver Management database/procedures. |
| `TestInputs` | Boundary-value and invalid-data test inputs used for the test logs. |
| `TestResults` | Notes/results from running or checking the tests. |
| `Screenshots` | Place for final screenshot evidence from browser, Visual Studio, SSMS and GitHub. |
| `TestLogs` | Completed Portfolio 2 Driver Management test logs. |

## Included Files

- `TestScripts/DriverManagement_SQL_TestScript.sql`
- `TestScripts/DriverManagement_ManualTestChecklist.md`
- `TestInputs/DriverManagement_BoundaryInputs.csv`
- `TestResults/DriverManagement_TestResults.md`
- `TestLogs/DriverManagement_Portfolio2_TestLogs.md`
- `Screenshots/README.md`

## Testing Areas Covered

- Required field validation for driver name, phone, licence number, date of birth and join date.
- Boundary value testing for VARCHAR, DATE, DECIMAL and INT-style inputs.
- Invalid data type testing.
- Driver rating validation from 0.0 to 5.0.
- Driver list, find and filter workflow.
- Soft delete, restore and hard delete workflow.
- SQL Server stored procedure and table checks.
- Approved contributor to driver sync evidence.

## How To Use

1. Run the DriveNow project in Visual Studio.
2. Set up the database using the scripts in `DataLayer/SQL`.
3. Use `TestInputs/DriverManagement_BoundaryInputs.csv` as the test data.
4. Use `TestScripts/DriverManagement_SQL_TestScript.sql` in SSMS for database evidence.
5. Record evidence in `TestResults` and screenshots in `Screenshots`.
6. Use `TestLogs/DriverManagement_Portfolio2_TestLogs.md` and the Word portfolio for final submission evidence.
