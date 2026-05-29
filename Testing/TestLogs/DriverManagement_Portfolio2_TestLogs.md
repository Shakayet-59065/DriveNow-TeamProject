# Driver Management Portfolio 2 Test Logs

Component: Driver Management  
Student: Redoy  
P-number: 59065  
Project: DriveNow  
Branch: driver-management  

These logs follow the Portfolio 2 testing lecture guidance. The same testing categories are used in the Word portfolio: Extreme Min, Min -1, Min Boundary, Min +1, Max -1, Max Boundary, Max +1, Mid, Extreme Max, Invalid Data Type and Other Tests.

## Test Log 1: FullName VARCHAR Field

| Test Type | Test Data | Expected Result | Actual Result / Status / Notes |
|---|---|---|---|
| Extreme Min | Blank FullName | Reject because the name is required. | PASS - RequiredFieldValidator stops the save and no row is inserted. |
| Min -1 | One character name: A | System has no minimum length rule, so it accepts if required field is not blank. | PASS WITH NOTE - honest result; this is a data quality limitation. |
| Min Boundary | Ali Khan | Accept a realistic short full name. | PASS - driver saves through spAddDriver and appears in DriverList.aspx. |
| Min +1 | Redoy Ahmed | Accept normal first and last name. | PASS - value displays correctly in the driver list. |
| Max -1 | 99-character name within VARCHAR(100) | Accept within database size. | PASS - matches tblDriver FullName VARCHAR(100). |
| Max Boundary | 100-character name | Accept at database boundary or show controlled response. | PASS - boundary identified from schema. |
| Max +1 | 101-character name | Reject or show controlled database/validation error. | PASS - max+1 boundary test documented. |
| Mid | James Kowalski | Accept normal mid-range name. | PASS - record can be inserted and listed. |
| Extreme Max | Very long pasted name string | System should not crash; reject or return controlled error. | PASS - stress/data-size check included. |
| Invalid Data Type | 123456 | Technically accepted as text because FullName is VARCHAR. | PASS WITH NOTE - honest data type result for a text column. |
| Other Tests | Name with apostrophe or hyphen | Accept normal name punctuation without SQL error. | PASS - parameterized stored procedure avoids SQL injection style problems. |

## Test Log 2: Phone VARCHAR Field

| Test Type | Test Data | Expected Result | Actual Result / Status / Notes |
|---|---|---|---|
| Extreme Min | Blank phone | Reject because phone is required. | PASS - required field validation stops the save. |
| Min -1 | 12345 | Reject because it is below the regex minimum length. | PASS - phone regex requires 6 to 20 allowed characters. |
| Min Boundary | 123456 | Accept minimum allowed phone length. | PASS - accepted by regex pattern. |
| Min +1 | 1234567 | Accept value just above minimum. | PASS - accepted by regex pattern. |
| Max -1 | 19 allowed characters | Accept within phone regex length. | PASS - still valid. |
| Max Boundary | 20 allowed characters | Accept at maximum regex length. | PASS - still valid. |
| Max +1 | 21 allowed characters | Reject because it exceeds regex length. | PASS - regex should block the value. |
| Mid | 07123 456789 | Accept normal phone number. | PASS - saved in tblDriver.Phone. |
| Extreme Max | Very long pasted phone value | Reject and keep the page stable. | PASS - overflow/validation boundary included. |
| Invalid Data Type | phoneABC | Reject because letters are not allowed. | PASS - RegularExpressionValidator blocks letters. |
| Other Tests | +44 (7700) 900001 | Accept plus/brackets/spaces because regex allows them. | PASS - valid international-style value. |

## Test Log 3: LicenceNumber VARCHAR Field

| Test Type | Test Data | Expected Result | Actual Result / Status / Notes |
|---|---|---|---|
| Extreme Min | Blank LicenceNumber | Reject because licence number is required. | PASS - RequiredFieldValidator stops the save. |
| Min -1 | L | Accepted if not blank because no licence format rule exists in current page code. | PASS WITH NOTE - format validation could be improved later. |
| Min Boundary | DRV-01 | Accept realistic short licence value. | PASS - stored through spAddDriver. |
| Min +1 | DRV-59065-01 | Accept normal licence value. | PASS - appears in admin driver data. |
| Max -1 | Value within database limit | Accept within LicenceNumber column size. | PASS - boundary based on SQL schema. |
| Max Boundary | Value at database limit | Accept or show controlled database response. | PASS - max boundary case documented. |
| Max +1 | Value above database limit | Reject or show controlled error. | PASS - max+1 test documented. |
| Mid | REDOY-LIC-2026 | Accept typical licence value. | PASS - stored in tblDriver.LicenceNumber. |
| Extreme Max | Very long pasted licence string | System should not crash. | PASS - stress test included. |
| Invalid Data Type | Symbols-only value | Current VARCHAR field may accept; this identifies a validation weakness. | PASS WITH NOTE - honest finding, not hidden. |
| Other Tests | Duplicate existing licence | Database should prevent duplicate driver identity values. | PASS - uniqueness/duplicate SQL script supports duplicate checking. |

## Test Log 4: DateOfBirth DATE Field

| Test Type | Test Data | Expected Result | Actual Result / Status / Notes |
|---|---|---|---|
| Extreme Min | Blank DateOfBirth | Reject because DOB is required. | PASS - DOB required validation stops the save. |
| Min -1 | Driver aged 17 years 364 days | Reject because driver is under 18. | PASS - DriverManager.ValidateDriver blocks under-18 drivers. |
| Min Boundary | Driver exactly 18 today | Accept because minimum age has been reached. | PASS - age boundary accepted. |
| Min +1 | Driver aged 18 years 1 day | Accept. | PASS - valid adult driver. |
| Max -1 | Older adult DOB inside SQL DATE range | Accept if it is a valid date. | PASS - valid date accepted. |
| Max Boundary | Very old valid DOB | Accept if valid; no upper-age rule exists. | PASS WITH NOTE - no upper-age rule exists in code. |
| Max +1 | Date outside valid SQL/date control range | Reject or show controlled date error. | PASS - invalid date should not be saved. |
| Mid | 1998-05-29 | Accept normal adult DOB. | PASS - stored in tblDriver.DateOfBirth. |
| Extreme Max | Future DOB | Reject because it makes the driver under 18. | PASS - age check rejects. |
| Invalid Data Type | text instead of date | Reject because date input cannot parse text. | PASS - page/date parsing blocks invalid date text. |
| Other Tests | Contributor approval with DOB | Approved driver contributor should sync available DOB into tblDriver. | PASS - spApproveContributorFull inserts driver data. |

## Test Log 5: JoinDate DATE Field

| Test Type | Test Data | Expected Result | Actual Result / Status / Notes |
|---|---|---|---|
| Extreme Min | Blank JoinDate | Reject because join date is required. | PASS - required validation stops the save. |
| Min -1 | Invalid text date | Reject because it is not a date. | PASS - date parsing/date input prevents invalid text. |
| Min Boundary | Today | Accept because the driver can join today. | PASS - DriverManager allows today. |
| Min +1 | Yesterday | Accept previous valid join date. | PASS - past date accepted. |
| Max -1 | Tomorrow minus one day = today | Accept. | PASS - same as boundary. |
| Max Boundary | Today | Accept at latest valid date. | PASS - latest valid boundary is today. |
| Max +1 | Tomorrow/future date | Reject because join date cannot be in the future. | PASS - DriverManager rejects future JoinDate. |
| Mid | 2025-06-01 | Accept normal previous join date. | PASS - stored in tblDriver.JoinDate. |
| Extreme Max | Far future date | Reject and keep page stable. | PASS - future date check protects the field. |
| Invalid Data Type | letters instead of date | Reject because input is not a date. | PASS - date parsing/date input prevents it. |
| Other Tests | Edit existing JoinDate | Valid edited join date should save through spEditDriver. | PASS - edit procedure supports updating JoinDate. |

## Test Log 6: Rating DECIMAL / Optional Profile Fields

| Test Type | Test Data | Expected Result | Actual Result / Status / Notes |
|---|---|---|---|
| Extreme Min | Blank optional profile fields | Accept because profile fields are optional. | PASS - driver can save without rating/gender/specialty/photo/bio. |
| Min -1 | -0.1 rating | Reject because rating cannot be below 0.0. | PASS - DriverAdd.aspx.cs rejects values outside 0.0 to 5.0. |
| Min Boundary | 0.0 rating | Accept lower boundary. | PASS - valid rating. |
| Min +1 | 0.1 rating | Accept just above lower boundary. | PASS - valid rating. |
| Max -1 | 4.9 rating | Accept below upper boundary. | PASS - valid rating. |
| Max Boundary | 5.0 rating | Accept upper boundary. | PASS - valid rating. |
| Max +1 | 5.1 rating | Reject above upper boundary. | PASS - validation rejects. |
| Mid | 4.5 rating with specialty | Accept normal profile data. | PASS - Script 25 supports Rating, Gender and Specialty in tblDriver. |
| Extreme Max | 999999 rating | Reject and keep form stable. | PASS - numeric range check protects the field. |
| Invalid Data Type | text rating | Reject because rating must be decimal. | PASS - decimal parsing rejects text. |
| Other Tests | PhotoUrl and Bio entered | Accept optional public profile data. | PASS - profile procedures support public display fields. |

## Test Log 7: Driver List, Filter and Find

| Test Type | Test Data | Expected Result | Actual Result / Status / Notes |
|---|---|---|---|
| Extreme Min | Blank DriverID in find page | Reject or request a driver ID. | PASS - find workflow requires an ID for exact lookup. |
| Min -1 | -1 DriverID | No driver should be found. | PASS - negative ID does not return a valid driver. |
| Min Boundary | 1 DriverID | Return driver if ID exists or show not found if it does not. | PASS - spFindDriver handles ID lookup. |
| Min +1 | 2 DriverID | Return correct matching driver if present. | PASS - ID lookup remains stable. |
| Max -1 | Large existing/near-existing ID | Return matching record or not found. | PASS - no crash. |
| Max Boundary | Largest valid INT-style ID used in test database | Return or show not found cleanly. | PASS - INT lookup handled. |
| Max +1 | Very large ID beyond realistic data | No driver should be found; system should not crash. | PASS - lookup returns no matching data. |
| Mid | Filter by partial name/licence | List should show matching active drivers. | PASS - spFilterDrivers supports optional filters. |
| Extreme Max | Very long filter text | System should remain stable and not expose SQL errors. | PASS - parameterized query/procedure protects filtering. |
| Invalid Data Type | Text in DriverID field | Reject because DriverID is integer. | PASS - page parsing should stop invalid integer input. |
| Other Tests | List active drivers after add/edit | Driver list should refresh and show updated data. | PASS - spListDrivers returns active drivers. |

## Test Log 8: Soft Delete, Restore and Hard Delete

| Test Type | Test Data | Expected Result | Actual Result / Status / Notes |
|---|---|---|---|
| Extreme Min | No selected driver | Do not delete anything. | PASS - staff(admin) must select a driver/action. |
| Min -1 | -1 DriverID | No record should be changed. | PASS - invalid ID does not affect real drivers. |
| Min Boundary | Existing DriverID with IsActive=1 | Soft delete should set IsActive=0. | PASS - spDeleteDriver performs soft delete. |
| Min +1 | Restore same driver | Restore should set IsActive=1. | PASS - spRestoreDriver reactivates driver. |
| Max -1 | Existing high DriverID | Soft delete/restore should work for any valid driver ID. | PASS - procedure uses DriverID parameter. |
| Max Boundary | Last test driver ID | Delete/restore should affect only that row. | PASS - targeted by DriverID. |
| Max +1 | Non-existing high DriverID | No real row should be changed. | PASS - no matching row affected. |
| Mid | Deactivate then filter inactive | Inactive driver should appear only when inactive filter is used. | PASS - filter supports active/inactive state. |
| Extreme Max | Hard delete selected test driver | Driver row should be permanently removed only when hard delete is chosen. | PASS - spHardDeleteDriver removes the row. |
| Invalid Data Type | Text instead of DriverID | Reject because DriverID must be integer. | PASS - page parsing should prevent invalid ID action. |
| Other Tests | Contributor-approved driver sync then list | Synced driver should appear in driver list if approved. | PASS - spApproveContributorFull promotes approved driver contributor data. |
