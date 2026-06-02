# Testing — Trip Records component (Musanna, P2893543)

Testing evidence for the **TripManager** component (Trip Records & Trip Type Catalogue),
structured per the Portfolio 2 testing requirements.

```
Testing/
├── TestScripts/    MSTest unit-test code that actually runs the validation (24 tests)
├── TestInputs/     The boundary & invalid values used as test inputs
├── TestResults/    The recorded results of running the tests (24/24 passed)
├── Screenshots/    Evidence screenshots (DB, Test Explorer, GitHub)
└── TestLogs/       Completed boundary-value test-log tables
```

- **Framework:** MSTest 3.0.4 — see `../DriveNow.Tests/`
- **What is tested:** `TripManager.ValidateTrip()` and `TripManager.ValidateTripType()`
- **Result:** 24 / 24 tests passed (real execution — see TestResults + Screenshots)
- **Full formatted test logs with screenshots:** `Portfolio 2.docx`
