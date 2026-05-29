# Test Evidence — Musanna (P2893543) | CTEC2713N

## Overview

This folder contains evidence that the Boundary Value Analysis (BVA) test logs in
Portfolio 2 are backed by real, executable unit tests.

**Developer:** Musanna | P2893543  
**Component:** Trip Records & Trip Type Catalogue  
**Test Framework:** MSTest (Microsoft.VisualStudio.TestTools.UnitTesting) v3.0.4  
**Test Project:** `DriveNow.Tests/`  
**Total Tests:** 24 (12 ValidateTrip + 12 ValidateTripType)  
**Test Results Screenshot:** See Portfolio 2, Section 3 — Visual Studio Test Explorer

---

## How the tests link to Portfolio 2 test logs

Each test method below corresponds directly to a row in the BVA test logs in the Portfolio 2 document.

### Test Log 1 — BaseRate (TripType)

| Test Method | Input | Expected | Portfolio 2 Row |
|---|---|---|---|
| `ValidateTripType_ValidData_ReturnsNoError` | BaseRate = 25.00 | No error | Valid case |
| `ValidateTripType_ZeroBaseRate_ReturnsError` | BaseRate = 0 | Error | Boundary: 0 invalid |
| `ValidateTripType_NegativeBaseRate_ReturnsError` | BaseRate = -1 | Error | Below boundary |
| `ValidateTripType_MinimumValidBaseRate_ReturnsNoError` | BaseRate = 0.01 | No error | Boundary: smallest valid |
| `ValidateTripType_LargeBaseRate_ReturnsNoError` | BaseRate = 9999.99 | No error | Far above boundary |

### Test Log 2 — TypeName (TripType)

| Test Method | Input | Expected | Portfolio 2 Row |
|---|---|---|---|
| `ValidateTripType_EmptyTypeName_ReturnsError` | TypeName = "" | Error | Empty — invalid |
| `ValidateTripType_WhitespaceTypeName_ReturnsError` | TypeName = "   " | Error | Whitespace — invalid |
| `ValidateTripType_Exactly50CharsTypeName_ReturnsNoError` | TypeName = 50 chars | No error | Boundary: 50 valid |
| `ValidateTripType_51CharsTypeName_ReturnsError` | TypeName = 51 chars | Error | Boundary: 51 invalid |
| `ValidateTripType_NullDescription_ReturnsNoError` | Description = null | No error | Optional field |

### Test Log 3 — Description (TripType)

| Test Method | Input | Expected | Portfolio 2 Row |
|---|---|---|---|
| `ValidateTripType_Exactly200CharsDescription_ReturnsNoError` | Description = 200 chars | No error | Boundary: 200 valid |
| `ValidateTripType_201CharsDescription_ReturnsError` | Description = 201 chars | Error | Boundary: 201 invalid |

### Test Log 4 — TripDate (Trip)

| Test Method | Input | Expected | Portfolio 2 Row |
|---|---|---|---|
| `ValidateTrip_PastTripDate_ReturnsError` | TripDate = yesterday | Error | Below boundary |
| `ValidateTrip_TodayDate_ReturnsNoError` | TripDate = today | No error | Boundary: today valid |
| `ValidateTrip_FutureTripDate_ReturnsNoError` | TripDate = +6 months | No error | Above boundary |
| `ValidateTrip_FarFutureTripDate_ReturnsNoError` | TripDate = +2 years | No error | Far above boundary |

### Test Log 5 — CustomerID (Trip)

| Test Method | Input | Expected | Portfolio 2 Row |
|---|---|---|---|
| `ValidateTrip_MissingCustomerID_ReturnsError` | CustomerID = 0 | Error | Boundary: 0 invalid |
| `ValidateTrip_NegativeCustomerID_ReturnsError` | CustomerID = -99 | Error | Below boundary |
| `ValidateTrip_ValidData_ReturnsNoError` | CustomerID = 1 | No error | Valid case |

### Test Log 6 — VehicleID (Trip)

| Test Method | Input | Expected | Portfolio 2 Row |
|---|---|---|---|
| `ValidateTrip_MissingVehicleID_ReturnsError` | VehicleID = 0 | Error | Boundary: 0 invalid |
| `ValidateTrip_NegativeVehicleID_ReturnsError` | VehicleID = -5 | Error | Below boundary |

### Test Log 7 — TripTypeID (Trip)

| Test Method | Input | Expected | Portfolio 2 Row |
|---|---|---|---|
| `ValidateTrip_MissingTripTypeID_ReturnsError` | TripTypeID = 0 | Error | Boundary: 0 invalid |
| `ValidateTrip_AllFKsZero_ReturnsFirstError` | All FKs = 0 | Error | Multiple invalid FKs |

### Test Log 8 — DriverID (Trip — nullable/self-drive)

| Test Method | Input | Expected | Portfolio 2 Row |
|---|---|---|---|
| `ValidateTrip_NullDriverID_DoesNotAffectValidation` | DriverID = null | No error | Null = self-drive, valid |

---

## How to run the tests

1. Open `DriveNow-TeamProject.slnx` in Visual Studio 2022
2. Let NuGet restore packages automatically (MSTest.TestAdapter 3.0.4)
3. Open **Test > Test Explorer**
4. Click **Run All Tests**
5. All 24 tests should show green (passed)

## Test Results File

After running, Visual Studio generates a `.trx` file in `DriveNow.Tests/TestResults/`.
This file is excluded from git (generated output), but a screenshot of Test Explorer
is included in Portfolio 2.
