# Driver Management Manual Test Checklist

This checklist follows the Portfolio 2 testing lecture guidance. Each test log in the portfolio should be linked to a real input, expected result, actual result, pass/fail status, and evidence screenshot where possible.

## Workflow
1. Set up the DriveNow database using the SQL scripts in `DataLayer/SQL`.
2. Run the web application from Visual Studio.
3. Use the values in `Testing/TestInputs/DriverManagement_BoundaryInputs.csv`.
4. Record the actual system behaviour in `Testing/TestResults/DriverManagement_TestResults.md`.
5. Capture screenshots of validation errors, successful inserts, SQL table data and GitHub evidence.
6. Copy the final results into the Portfolio 2 test log tables.

## Screenshots To Capture
- Add Driver required field validation.
- DOB under-18 rejection.
- Future JoinDate rejection.
- Rating 5.1 or text rejection.
- Successful driver insert in Driver List.
- SQL Server query showing inserted driver row.
- Soft delete, restore and hard delete evidence.
- GitHub branch commit history.
