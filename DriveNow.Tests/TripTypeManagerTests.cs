using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

// DriveNow — Unit Tests for TripManager.ValidateTripType()
// Developer: Musanna | P59038 | CTEC2713N
// Tests cover all validation rules for the TripType catalogue.
// No database connection is needed — pure business logic tests.

namespace DriveNow.Tests
{
    [TestClass]
    public class TripTypeManagerTests
    {
        private TripManager manager;

        [TestInitialize]
        public void Setup()
        {
            manager = new TripManager();
        }

        // Helper: builds a valid TripType for positive-path tests
        private TripType ValidTripType()
        {
            return new TripType
            {
                TypeName    = "Economy Trip",
                Description = "Standard short-distance ride.",
                BaseRate    = 10.00m,
                CreatedDate = DateTime.Today,
                IsActive    = true
            };
        }

        // ─── STANDARD TESTS (as shown in labs) ───────────────────────────────

        [TestMethod]
        [Description("All fields valid — expects no validation error returned.")]
        public void ValidateTripType_ValidData_ReturnsNoError()
        {
            TripType tt = ValidTripType();
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual(string.Empty, result);
        }

        [TestMethod]
        [Description("TypeName is empty string — expects 'required' error.")]
        public void ValidateTripType_EmptyTypeName_ReturnsError()
        {
            TripType tt = ValidTripType();
            tt.TypeName = "";
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual("Type Name is required.", result);
        }

        [TestMethod]
        [Description("BaseRate is -1 (negative) — expects 'greater than zero' error.")]
        public void ValidateTripType_NegativeBaseRate_ReturnsError()
        {
            TripType tt = ValidTripType();
            tt.BaseRate = -1.00m;
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual("Base Rate must be greater than zero.", result);
        }

        [TestMethod]
        [Description("BaseRate is exactly 0.00 — expects 'greater than zero' error.")]
        public void ValidateTripType_ZeroBaseRate_ReturnsError()
        {
            TripType tt = ValidTripType();
            tt.BaseRate = 0.00m;
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual("Base Rate must be greater than zero.", result);
        }

        // ─── ADDITIONAL TESTS (above and beyond labs) ─────────────────────────

        [TestMethod]
        [Description("TypeName exactly 50 characters (upper boundary) — expects no error.")]
        public void ValidateTripType_TypeNameExactly50Chars_ReturnsNoError()
        {
            TripType tt = ValidTripType();
            tt.TypeName = new string('A', 50);
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual(string.Empty, result,
                "50 characters is the maximum allowed — it should pass validation.");
        }

        [TestMethod]
        [Description("TypeName is 51 characters (1 over boundary) — expects length error.")]
        public void ValidateTripType_TypeName51Chars_ReturnsError()
        {
            TripType tt = ValidTripType();
            tt.TypeName = new string('A', 51);
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual("Type Name must be 50 characters or fewer.", result);
        }

        [TestMethod]
        [Description("Description exactly 200 characters (upper boundary) — expects no error.")]
        public void ValidateTripType_DescriptionExactly200Chars_ReturnsNoError()
        {
            TripType tt = ValidTripType();
            tt.Description = new string('X', 200);
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual(string.Empty, result,
                "200 characters is the maximum allowed for Description — should pass.");
        }

        [TestMethod]
        [Description("Description is 201 characters (1 over boundary) — expects length error.")]
        public void ValidateTripType_Description201Chars_ReturnsError()
        {
            TripType tt = ValidTripType();
            tt.Description = new string('X', 201);
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual("Description must be 200 characters or fewer.", result);
        }

        [TestMethod]
        [Description("TypeName is whitespace only — IsNullOrWhiteSpace should catch this, expects 'required' error.")]
        public void ValidateTripType_WhitespaceOnlyTypeName_ReturnsError()
        {
            TripType tt = ValidTripType();
            tt.TypeName = "   ";
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual("Type Name is required.", result,
                "Whitespace-only TypeName should be treated as empty by IsNullOrWhiteSpace.");
        }

        [TestMethod]
        [Description("BaseRate = 0.01 (minimum valid value, 1p above zero boundary) — expects no error.")]
        public void ValidateTripType_MinimumValidBaseRate_ReturnsNoError()
        {
            TripType tt = ValidTripType();
            tt.BaseRate = 0.01m;
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual(string.Empty, result,
                "0.01 is strictly greater than zero — should pass validation.");
        }

        [TestMethod]
        [Description("Description is null (not provided) — null description is allowed, expects no error.")]
        public void ValidateTripType_NullDescription_ReturnsNoError()
        {
            TripType tt = ValidTripType();
            tt.Description = null;
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual(string.Empty, result,
                "Description is optional — null should not trigger a validation error.");
        }

        [TestMethod]
        [Description("BaseRate is very large (£999,999.99) — no upper limit defined, expects no error.")]
        public void ValidateTripType_VeryLargeBaseRate_ReturnsNoError()
        {
            TripType tt = ValidTripType();
            tt.BaseRate = 999999.99m;
            string result = manager.ValidateTripType(tt);
            Assert.AreEqual(string.Empty, result,
                "No upper limit on BaseRate is defined — large values should pass.");
        }
    }
}
