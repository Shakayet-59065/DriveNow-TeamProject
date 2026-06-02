using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

// DriveNow — Unit Tests for TripManager.ValidateTrip()
// Developer: Musanna | P59038 | CTEC2713N
// Tests cover all validation rules in the business logic layer.
// No database connection is needed — these tests are pure unit tests.

namespace DriveNow.Tests
{
    [TestClass]
    public class TripManagerTests
    {
        private TripManager manager;

        [TestInitialize]
        public void Setup()
        {
            manager = new TripManager();
        }

        // Helper: builds a valid Trip for positive-path tests
        private Trip ValidTrip()
        {
            return new Trip
            {
                CustomerId = 1,
                VehicleID  = 1,
                TripTypeID = 1,
                DriverID   = null,
                TripDate   = DateTime.Today.AddDays(1)
            };
        }

        // ─── STANDARD TESTS (as shown in labs) ───────────────────────────────

        [TestMethod]
        [Description("All required fields valid — expects no validation error returned.")]
        public void ValidateTrip_ValidData_ReturnsNoError()
        {
            Trip trip = ValidTrip();
            string result = manager.ValidateTrip(trip);
            Assert.AreEqual(string.Empty, result);
        }

        [TestMethod]
        [Description("CustomerID is 0 (default dropdown) — expects error message.")]
        public void ValidateTrip_MissingCustomerID_ReturnsError()
        {
            Trip trip = ValidTrip();
            trip.CustomerId = 0;
            string result = manager.ValidateTrip(trip);
            Assert.IsFalse(string.IsNullOrEmpty(result),
                "Expected a validation error when CustomerID is 0.");
        }

        [TestMethod]
        [Description("VehicleID is 0 (default dropdown) — expects error message.")]
        public void ValidateTrip_MissingVehicleID_ReturnsError()
        {
            Trip trip = ValidTrip();
            trip.VehicleID = 0;
            string result = manager.ValidateTrip(trip);
            Assert.IsFalse(string.IsNullOrEmpty(result),
                "Expected a validation error when VehicleID is 0.");
        }

        [TestMethod]
        [Description("TripTypeID is 0 (default dropdown) — expects error message.")]
        public void ValidateTrip_MissingTripTypeID_ReturnsError()
        {
            Trip trip = ValidTrip();
            trip.TripTypeID = 0;
            string result = manager.ValidateTrip(trip);
            Assert.IsFalse(string.IsNullOrEmpty(result),
                "Expected a validation error when TripTypeID is 0.");
        }

        [TestMethod]
        [Description("TripDate set to yesterday — expects 'cannot be in the past' error.")]
        public void ValidateTrip_PastTripDate_ReturnsError()
        {
            Trip trip = ValidTrip();
            trip.TripDate = DateTime.Today.AddDays(-1);
            string result = manager.ValidateTrip(trip);
            Assert.AreEqual("Trip Date cannot be in the past.", result);
        }

        // ─── ADDITIONAL TESTS (above and beyond labs) ─────────────────────────

        [TestMethod]
        [Description("TripDate = today (boundary value) — today is valid, expects no error.")]
        public void ValidateTrip_TodayDate_ReturnsNoError()
        {
            Trip trip = ValidTrip();
            trip.TripDate = DateTime.Today;
            string result = manager.ValidateTrip(trip);
            Assert.AreEqual(string.Empty, result,
                "Today should be a valid trip date — the rule is 'cannot be in the past', today is not past.");
        }

        [TestMethod]
        [Description("TripDate set 6 months in the future — expects no error.")]
        public void ValidateTrip_FutureTripDate_ReturnsNoError()
        {
            Trip trip = ValidTrip();
            trip.TripDate = DateTime.Today.AddMonths(6);
            string result = manager.ValidateTrip(trip);
            Assert.AreEqual(string.Empty, result);
        }

        [TestMethod]
        [Description("DriverID is null (self-drive) — DriverID is optional, expects no error.")]
        public void ValidateTrip_NullDriverID_DoesNotAffectValidation()
        {
            Trip trip = ValidTrip();
            trip.DriverID = null;
            string result = manager.ValidateTrip(trip);
            Assert.AreEqual(string.Empty, result,
                "DriverID is nullable — a trip without a driver (self-drive) should still be valid.");
        }

        [TestMethod]
        [Description("CustomerID is negative — expects validation error (negative ID is invalid).")]
        public void ValidateTrip_NegativeCustomerID_ReturnsError()
        {
            Trip trip = ValidTrip();
            trip.CustomerId = -99;
            string result = manager.ValidateTrip(trip);
            Assert.IsFalse(string.IsNullOrEmpty(result),
                "Expected a validation error when CustomerID is negative.");
        }

        [TestMethod]
        [Description("VehicleID is negative — expects validation error.")]
        public void ValidateTrip_NegativeVehicleID_ReturnsError()
        {
            Trip trip = ValidTrip();
            trip.VehicleID = -5;
            string result = manager.ValidateTrip(trip);
            Assert.IsFalse(string.IsNullOrEmpty(result),
                "Expected a validation error when VehicleID is negative.");
        }

        [TestMethod]
        [Description("TripDate is exactly 2 years in the future — no upper date limit defined, expects no error.")]
        public void ValidateTrip_FarFutureTripDate_ReturnsNoError()
        {
            Trip trip = ValidTrip();
            trip.TripDate = DateTime.Today.AddYears(2);
            string result = manager.ValidateTrip(trip);
            Assert.AreEqual(string.Empty, result,
                "No upper date limit is defined — a far-future date should still be valid.");
        }

        [TestMethod]
        [Description("All FK fields are 0 simultaneously — first error encountered should be CustomerID.")]
        public void ValidateTrip_AllFKsZero_ReturnsFirstError()
        {
            Trip trip = ValidTrip();
            trip.CustomerId = 0;
            trip.VehicleID  = 0;
            trip.TripTypeID = 0;
            string result = manager.ValidateTrip(trip);
            Assert.IsFalse(string.IsNullOrEmpty(result),
                "At least one validation error should be returned when all FK fields are 0.");
        }
    }
}
