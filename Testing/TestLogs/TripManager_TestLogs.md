# Boundary-Value Test Logs — TripManager

**Tester:** Khandakar Musanna (P2893543) | **Date:** 27/05/2026
PASS = the system behaved as expected. (Full formatted tables + screenshots are in `Portfolio 2.docx`.)

## 1. BaseRate — DECIMAL(8,2), must be > 0 (Required)

| Test Type | Test Data | Expected | Actual | Status |
|-----------|-----------|----------|--------|--------|
| Extreme Min | -9999.99 | Error: "Base Rate must be greater than zero." | Error shown | PASS |
| Min -1 | 0.00 | Error: "Base Rate must be greater than zero." | Error shown | PASS |
| Min (Boundary) | 0.01 | Accept — saved | Saved & redirected | PASS |
| Min +1 | 0.02 | Accept — saved | Saved | PASS |
| Large | 9999.99 | Accept — saved | Saved | PASS |
| Invalid Data Type | "abc" | Error: "Base Rate must be a valid number" | Error shown | PASS |

## 2. TypeName — VARCHAR(50), required, 1–50 chars

| Test Type | Test Data | Expected | Actual | Status |
|-----------|-----------|----------|--------|--------|
| Extreme Min | (empty) | Error: "Type Name is required." | Error shown | PASS |
| Invalid | (whitespace only) | Error: "Type Name is required." | Error shown | PASS |
| Max (Boundary) | 50 characters | Accept | Saved | PASS |
| Max +1 | 51 characters | Error: "50 characters or fewer." | Error shown | PASS |

## 3. Description — VARCHAR(200), optional, 0–200 chars

| Test Type | Test Data | Expected | Actual | Status |
|-----------|-----------|----------|--------|--------|
| Min | (null/empty) | Accept (optional field) | Saved | PASS |
| Max (Boundary) | 200 characters | Accept | Saved | PASS |
| Max +1 | 201 characters | Error: "200 characters or fewer." | Error shown | PASS |

## 4. TripDate — DATE, today or future (Required)

| Test Type | Test Data | Expected | Actual | Status |
|-----------|-----------|----------|--------|--------|
| Min -1 | yesterday | Error: "Trip Date cannot be in the past." | Error shown | PASS |
| Min (Boundary) | today | Accept | Saved | PASS |
| Above | +6 months | Accept | Saved | PASS |
| Extreme Max | +2 years | Accept | Saved | PASS |
| Invalid Data Type | "notadate" | Rejected by date parser | Rejected | PASS |

## 5. CustomerID / VehicleID / TripTypeID — INT foreign keys, must be > 0 (Required)

| Test Type | Test Data | Expected | Actual | Status |
|-----------|-----------|----------|--------|--------|
| Min -1 (CustomerID) | 0 | Error: "A valid Customer must be selected." | Error shown | PASS |
| Below (CustomerID) | -99 | Error | Error shown | PASS |
| Valid (CustomerID) | 1 | Accept | Saved | PASS |
| Min -1 (VehicleID) | 0 | Error: "A valid Vehicle must be selected." | Error shown | PASS |
| Below (VehicleID) | -5 | Error | Error shown | PASS |
| Min -1 (TripTypeID) | 0 | Error: "A valid Trip Type must be selected." | Error shown | PASS |

> Note: CustomerID, VehicleID and TripTypeID are all INT — per the lecturer's guidance, one
> representative INT type is enough, but all three are shown here for completeness.
