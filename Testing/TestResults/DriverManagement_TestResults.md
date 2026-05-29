# Driver Management Test Results

These results should be updated after running the web application and SQL script. The Portfolio 2 document records the current expected behaviour based on the implemented ASPX validation, DriverManager methods and SQL stored procedures.

| Test Area | Evidence To Record | Status |
|---|---|---|
| Required fields | Screenshot of Add Driver validation messages | To capture in Visual Studio/browser |
| DOB boundary | Under-18 rejection and exactly-18 acceptance | To capture in browser |
| Join date boundary | Future date rejection | To capture in browser |
| Rating decimal | 0.0, 5.0 accepted and 5.1/text rejected | To capture in browser |
| SQL table/procedure | SSMS output from DriverManagement_SQL_TestScript.sql | To capture in SSMS |
| Soft delete/restore/hard delete | Driver list before and after actions | To capture in browser/SSMS |
| GitHub evidence | driver-management branch commit history | Captured from GitHub/local git |
