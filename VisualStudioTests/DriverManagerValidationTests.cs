// DriveNow — Driver Management Validation Unit Tests
// Module: CTEC2713N — Agile Development Team Project
// Developer: Redoy | P-Number: 59065
// Institution: Niels Brock Copenhagen
// Framework: MSTest (.NET 4.8)
//
// These tests verify the DriverValidationRules helper class which mirrors
// the validation logic in DriverManager.ValidateDriver() (App_Code/DriverManager.cs).
// Tests cover: FullName (TEXT), LicenceNumber (TEXT), DateOfBirth (DATE),
//              Rating (DECIMAL), IsActive (BOOLEAN/BIT) — one type each per marking scheme.

using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace DriveNow.DriverManagement.Tests
{
    // ══════════════════════════════════════════════════════════════════════════
    // Validation helper — mirrors DriverManager.ValidateDriver() logic.
    // Kept in this file so the test project is self-contained and can be
    // opened and run without the main DriveNow web project.
    // ══════════════════════════════════════════════════════════════════════════
    public static class DriverValidationRules
    {
        // ── FullName: required, max 100 chars, letters/spaces/hyphens/apostrophes only ──
        public static string ValidateFullName(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return "Full name is required.";
            if (value.Trim().Length > 100)
                return "Full name must be 100 characters or fewer.";
            foreach (char c in value)
                if (!char.IsLetter(c) && c != ' ' && c != '-' && c != '\'')
                    return "Full name must use letters only (hyphens and apostrophes allowed).";
            return "";
        }

        // ── LicenceNumber: required, max 30 chars, must not be whitespace-only ──
        public static string ValidateLicenceNumber(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return "Licence number is required.";
            if (value.Trim().Length > 30)
                return "Licence number must be 30 characters or fewer.";
            return "";
        }

        // ── DateOfBirth: must be in past, driver must be at least 18 years old ──
        public static string ValidateDateOfBirth(DateTime dob, DateTime today)
        {
            if (dob >= today)
                return "Date of birth must be in the past.";
            int age = today.Year - dob.Year;
            if (dob.Date > today.AddYears(-age)) age--;
            if (age < 18)
                return "Driver must be at least 18 years old.";
            return "";
        }

        // ── Rating: optional; if provided must be 0.0–5.0, one decimal place ──
        public static string ValidateRating(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return "";   // optional field — blank is valid
            if (!decimal.TryParse(value, out decimal rating))
                return "Rating must be a number between 0.0 and 5.0.";
            if (rating < 0m)
                return "Rating must be a number between 0.0 and 5.0.";
            if (rating > 5m)
                return "Rating must be a number between 0.0 and 5.0.";
            return "";
        }

        // ── IsActive: BIT field — only 0 or 1 are valid user-facing values ──
        public static string ValidateIsActive(int value)
        {
            if (value == 0 || value == 1)
                return "";
            return "IsActive must be 0 (inactive) or 1 (active).";
        }

        // ── JoinDate: must not be in the future ──
        public static string ValidateJoinDate(DateTime joinDate, DateTime today)
        {
            if (joinDate > today)
                return "Join date cannot be in the future.";
            return "";
        }

        // ── Phone: required, 6–20 chars, digits/spaces/+/-/() only ──
        public static string ValidatePhone(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return "Phone is required.";
            string t = value.Trim();
            if (t.Length < 6)
                return "Phone number must be at least 6 characters.";
            if (t.Length > 20)
                return "Phone number must be 20 characters or fewer.";
            foreach (char c in t)
                if (!char.IsDigit(c) && c != '+' && c != '-' && c != ' ' && c != '(' && c != ')')
                    return "Phone must contain only digits, spaces, +, -, ( or ).";
            return "";
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // TEST CLASS: FullName (VARCHAR 100, TEXT type)
    // Covers: Extreme Min, Min Boundary, Min+1, Mid, Max-1, Max, Max+1,
    //         Extreme Max, Invalid Data Type (digits, specials, null-like)
    // ══════════════════════════════════════════════════════════════════════════
    [TestClass]
    public class FullNameTests
    {
        // ── Extreme Min ──────────────────────────────────────────────────────
        [TestMethod]
        public void FullName_Empty_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateFullName("").Length > 0,
               "Expected error for empty FullName");

        [TestMethod]
        public void FullName_WhitespaceOnly_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateFullName("   ").Length > 0,
               "Expected error for whitespace-only FullName");

        // ── Min Boundary ─────────────────────────────────────────────────────
        [TestMethod]
        public void FullName_OneLetter_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateFullName("A"),
               "Single letter should be valid");

        // ── Min + 1 ───────────────────────────────────────────────────────────
        [TestMethod]
        public void FullName_TwoLetters_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateFullName("Jo"),
               "Two letters should be valid");

        // ── Mid ───────────────────────────────────────────────────────────────
        [TestMethod]
        public void FullName_TypicalName_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateFullName("James Anderson"),
               "Typical name should be valid");

        [TestMethod]
        public void FullName_NameWithHyphen_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateFullName("Anne-Marie"),
               "Hyphenated name should be valid");

        [TestMethod]
        public void FullName_NameWithApostrophe_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateFullName("O'Brien"),
               "Name with apostrophe should be valid");

        // ── Max - 1 ───────────────────────────────────────────────────────────
        [TestMethod]
        public void FullName_NinetyNineChars_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateFullName(new string('A', 99)),
               "99-character name should be valid");

        // ── Max Boundary ──────────────────────────────────────────────────────
        [TestMethod]
        public void FullName_ExactlyOneHundredChars_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateFullName(new string('A', 100)),
               "Exactly 100 characters should be accepted (VARCHAR 100 limit)");

        // ── Max + 1 ───────────────────────────────────────────────────────────
        [TestMethod]
        public void FullName_OneHundredOneChars_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateFullName(new string('A', 101)).Length > 0,
               "101 characters should exceed the VARCHAR(100) limit");

        // ── Extreme Max ───────────────────────────────────────────────────────
        [TestMethod]
        public void FullName_TwoHundredChars_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateFullName(new string('A', 200)).Length > 0,
               "200 characters should be rejected");

        // ── Invalid Data Types ────────────────────────────────────────────────
        [TestMethod]
        public void FullName_DigitsOnly_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateFullName("12345").Length > 0,
               "Digits-only should be rejected — name must use letters");

        [TestMethod]
        public void FullName_MixedLettersAndDigits_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateFullName("Redoy123").Length > 0,
               "Mixed letters+digits should be rejected");

        [TestMethod]
        public void FullName_SpecialCharacters_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateFullName("Name@#!").Length > 0,
               "Special characters (@, #, !) should be rejected");

        [TestMethod]
        public void FullName_Null_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateFullName(null).Length > 0,
               "Null should be treated as empty and return error");
    }

    // ══════════════════════════════════════════════════════════════════════════
    // TEST CLASS: LicenceNumber (VARCHAR 30, TEXT type, required, unique)
    // ══════════════════════════════════════════════════════════════════════════
    [TestClass]
    public class LicenceNumberTests
    {
        // ── Extreme Min ──────────────────────────────────────────────────────
        [TestMethod]
        public void Licence_Empty_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateLicenceNumber("").Length > 0,
               "Empty licence number should be rejected");

        [TestMethod]
        public void Licence_SpacesOnly_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateLicenceNumber("   ").Length > 0,
               "Spaces-only should be treated as empty and rejected");

        // ── Min Boundary ─────────────────────────────────────────────────────
        [TestMethod]
        public void Licence_OneCharacter_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateLicenceNumber("X"),
               "Single character licence should be accepted");

        // ── Min + 1 ───────────────────────────────────────────────────────────
        [TestMethod]
        public void Licence_TwoCharacters_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateLicenceNumber("AB"),
               "Two-character licence should be accepted");

        // ── Mid ───────────────────────────────────────────────────────────────
        [TestMethod]
        public void Licence_TypicalValue_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateLicenceNumber("ANDE9901157JA9"),
               "Typical 14-char licence should be accepted");

        [TestMethod]
        public void Licence_NumericValue_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateLicenceNumber("12345678"),
               "Numeric licence should be accepted (no format restriction beyond length)");

        // ── Max - 1 ───────────────────────────────────────────────────────────
        [TestMethod]
        public void Licence_TwentyNineChars_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateLicenceNumber(new string('L', 29)),
               "29-character licence should be accepted");

        // ── Max Boundary ──────────────────────────────────────────────────────
        [TestMethod]
        public void Licence_ExactlyThirtyChars_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateLicenceNumber(new string('L', 30)),
               "Exactly 30 characters should be accepted (VARCHAR 30 limit)");

        // ── Max + 1 ───────────────────────────────────────────────────────────
        [TestMethod]
        public void Licence_ThirtyOneChars_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateLicenceNumber(new string('L', 31)).Length > 0,
               "31 characters should exceed VARCHAR(30) limit");

        // ── Extreme Max ───────────────────────────────────────────────────────
        [TestMethod]
        public void Licence_FiftyChars_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateLicenceNumber(new string('L', 50)).Length > 0,
               "50 characters should be rejected");

        // ── Invalid Data Type ─────────────────────────────────────────────────
        [TestMethod]
        public void Licence_Null_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateLicenceNumber(null).Length > 0,
               "Null should return error");
    }

    // ══════════════════════════════════════════════════════════════════════════
    // TEST CLASS: DateOfBirth (DATE type, required, must be 18+)
    // ══════════════════════════════════════════════════════════════════════════
    [TestClass]
    public class DateOfBirthTests
    {
        // Fixed "today" for deterministic tests
        private static readonly DateTime Today = new DateTime(2026, 6, 4);

        // ── Extreme Min (very old — no lower age limit) ────────────────────
        [TestMethod]
        public void DateOfBirth_VeryOldDate_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateDateOfBirth(new DateTime(1924, 6, 4), Today),
               "102-year-old driver: no upper age limit — should be accepted");

        // ── Min Boundary ─────────────────────────────────────────────────────
        [TestMethod]
        public void DateOfBirth_ExactlyOneHundredYearsOld_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateDateOfBirth(new DateTime(1926, 6, 4), Today),
               "Exactly 100 years old should be accepted");

        // ── Mid ───────────────────────────────────────────────────────────────
        [TestMethod]
        public void DateOfBirth_ThirtyFiveYearsOld_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateDateOfBirth(new DateTime(1991, 6, 4), Today),
               "35-year-old driver should be accepted");

        [TestMethod]
        public void DateOfBirth_TwentyFiveYearsOld_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateDateOfBirth(new DateTime(2001, 6, 4), Today),
               "25-year-old driver should be accepted");

        // ── Max - 1 (one day over 18) ─────────────────────────────────────
        [TestMethod]
        public void DateOfBirth_EighteenYearsAndOneDay_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateDateOfBirth(new DateTime(2008, 6, 3), Today),
               "18 years and 1 day old: should be accepted");

        // ── Max Boundary (exactly 18) ─────────────────────────────────────
        [TestMethod]
        public void DateOfBirth_ExactlyEighteenToday_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateDateOfBirth(new DateTime(2008, 6, 4), Today),
               "Exactly 18 years old today: boundary — should be accepted");

        // ── Max + 1 (one day under 18) ────────────────────────────────────
        [TestMethod]
        public void DateOfBirth_SeventeenYearsThreeHundredSixtyFourDays_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateDateOfBirth(new DateTime(2008, 6, 5), Today).Length > 0,
               "17 years 364 days: one day under 18 — should be rejected");

        // ── Too young ─────────────────────────────────────────────────────
        [TestMethod]
        public void DateOfBirth_TenYearsOld_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateDateOfBirth(new DateTime(2016, 6, 4), Today).Length > 0,
               "10-year-old: clearly under 18 — should be rejected");

        // ── Extreme Max (future date) ─────────────────────────────────────
        [TestMethod]
        public void DateOfBirth_Tomorrow_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateDateOfBirth(Today.AddDays(1), Today).Length > 0,
               "Future date: born tomorrow — should be rejected");

        [TestMethod]
        public void DateOfBirth_FarFuture_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateDateOfBirth(new DateTime(2099, 1, 1), Today).Length > 0,
               "Far-future date should be rejected");

        // ── Same day as today (age = 0) ───────────────────────────────────
        [TestMethod]
        public void DateOfBirth_Today_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateDateOfBirth(Today, Today).Length > 0,
               "Born today (age 0) should be rejected");

        // ── Leap year boundary ────────────────────────────────────────────
        [TestMethod]
        public void DateOfBirth_LeapDayExactlyEighteen_IsValid()
        {
            // Born 29 Feb 2008 — exactly 18 on 4 June 2026? No, 18th anniversary is 29 Feb 2026
            // which doesn't exist, so it becomes 1 Mar 2026 — so at 4 June 2026 they are 18+
            var dob = new DateTime(2008, 2, 29);
            string result = DriverValidationRules.ValidateDateOfBirth(dob, Today);
            Assert.AreEqual("", result,
                "Born 29 Feb 2008: on 4 June 2026 they are 18+ (leap day handled correctly)");
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // TEST CLASS: Rating (DECIMAL type, optional, 0.0–5.0)
    // ══════════════════════════════════════════════════════════════════════════
    [TestClass]
    public class RatingTests
    {
        // ── Optional — blank is always valid ──────────────────────────────
        [TestMethod]
        public void Rating_Blank_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating(""),
               "Blank rating: optional field — should be accepted (stored as NULL)");

        [TestMethod]
        public void Rating_Null_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating(null),
               "Null rating: optional field — should be accepted");

        [TestMethod]
        public void Rating_WhitespaceOnly_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating("   "),
               "Whitespace-only rating: treated as blank — should be accepted");

        // ── Extreme Min ───────────────────────────────────────────────────
        [TestMethod]
        public void Rating_ExtremelyNegative_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateRating("-99.9").Length > 0,
               "-99.9 is far below 0.0 — should be rejected");

        // ── Min - 1 ───────────────────────────────────────────────────────
        [TestMethod]
        public void Rating_NegativePoint1_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateRating("-0.1").Length > 0,
               "-0.1 is just below the minimum 0.0 — should be rejected");

        // ── Min Boundary ──────────────────────────────────────────────────
        [TestMethod]
        public void Rating_Zero_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating("0.0"),
               "0.0 is the minimum valid rating — should be accepted");

        [TestMethod]
        public void Rating_ZeroNoDecimal_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating("0"),
               "0 (no decimal) should be accepted as 0.0");

        // ── Min + 1 ───────────────────────────────────────────────────────
        [TestMethod]
        public void Rating_Point1_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating("0.1"),
               "0.1 is just above minimum — should be accepted");

        // ── Mid ───────────────────────────────────────────────────────────
        [TestMethod]
        public void Rating_MidValue_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating("2.5"),
               "2.5 is a typical mid-range rating — should be accepted");

        [TestMethod]
        public void Rating_FourPointFive_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating("4.5"),
               "4.5 is a common high rating — should be accepted");

        // ── Max - 1 ───────────────────────────────────────────────────────
        [TestMethod]
        public void Rating_FourPoint9_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating("4.9"),
               "4.9 is just below maximum — should be accepted");

        // ── Max Boundary ──────────────────────────────────────────────────
        [TestMethod]
        public void Rating_ExactlyFive_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating("5.0"),
               "5.0 is the maximum valid rating — should be accepted");

        [TestMethod]
        public void Rating_FiveNoDecimal_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateRating("5"),
               "5 (no decimal) should be accepted as 5.0");

        // ── Max + 1 ───────────────────────────────────────────────────────
        [TestMethod]
        public void Rating_FivePoint1_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateRating("5.1").Length > 0,
               "5.1 is just above the maximum 5.0 — should be rejected");

        // ── Extreme Max ───────────────────────────────────────────────────
        [TestMethod]
        public void Rating_ExtremelyHigh_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateRating("999.9").Length > 0,
               "999.9 is far above 5.0 — should be rejected");

        // ── Invalid Data Types ────────────────────────────────────────────
        [TestMethod]
        public void Rating_Text_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateRating("five").Length > 0,
               "Non-numeric text should be rejected");

        [TestMethod]
        public void Rating_Letters_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateRating("abc").Length > 0,
               "Alphabetic string should be rejected — not a number");

        [TestMethod]
        public void Rating_SpecialChars_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateRating("@5.0").Length > 0,
               "String with special chars should be rejected");
    }

    // ══════════════════════════════════════════════════════════════════════════
    // TEST CLASS: IsActive (BIT / BOOLEAN type)
    // ══════════════════════════════════════════════════════════════════════════
    [TestClass]
    public class IsActiveTests
    {
        [TestMethod]
        public void IsActive_One_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateIsActive(1),
               "1 (active) is a valid BIT value");

        [TestMethod]
        public void IsActive_Zero_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateIsActive(0),
               "0 (inactive/soft-deleted) is a valid BIT value");

        [TestMethod]
        public void IsActive_Two_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateIsActive(2).Length > 0,
               "2 is out of BIT range (SQL Server coerces, but app should reject)");

        [TestMethod]
        public void IsActive_Negative_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateIsActive(-1).Length > 0,
               "-1 is not a valid BIT value");
    }

    // ══════════════════════════════════════════════════════════════════════════
    // TEST CLASS: JoinDate (DATE type)
    // ══════════════════════════════════════════════════════════════════════════
    [TestClass]
    public class JoinDateTests
    {
        private static readonly DateTime Today = new DateTime(2026, 6, 4);

        [TestMethod]
        public void JoinDate_Today_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateJoinDate(Today, Today),
               "Today's date is a valid join date");

        [TestMethod]
        public void JoinDate_Yesterday_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateJoinDate(Today.AddDays(-1), Today),
               "Yesterday is a valid join date");

        [TestMethod]
        public void JoinDate_YearsAgo_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidateJoinDate(new DateTime(2020, 1, 1), Today),
               "Past join date should be accepted");

        [TestMethod]
        public void JoinDate_Tomorrow_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateJoinDate(Today.AddDays(1), Today).Length > 0,
               "Future join date should be rejected");

        [TestMethod]
        public void JoinDate_FarFuture_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidateJoinDate(new DateTime(2099, 1, 1), Today).Length > 0,
               "Far-future join date should be rejected");
    }

    // ══════════════════════════════════════════════════════════════════════════
    // TEST CLASS: Phone (VARCHAR 20)
    // ══════════════════════════════════════════════════════════════════════════
    [TestClass]
    public class PhoneTests
    {
        [TestMethod]
        public void Phone_Empty_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidatePhone("").Length > 0,
               "Empty phone should be rejected");

        [TestMethod]
        public void Phone_TooShort_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidatePhone("12345").Length > 0,
               "5-digit phone (below minimum 6) should be rejected");

        [TestMethod]
        public void Phone_MinBoundary_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidatePhone("123456"),
               "6-digit phone is the minimum boundary — should be accepted");

        [TestMethod]
        public void Phone_TypicalUK_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidatePhone("+4412345678"),
               "Typical phone with + prefix should be accepted");

        [TestMethod]
        public void Phone_TypicalDanish_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidatePhone("+45 12 34 56 78"),
               "Danish phone number format should be accepted");

        [TestMethod]
        public void Phone_MaxBoundary_IsValid()
            => Assert.AreEqual("", DriverValidationRules.ValidatePhone("+4512345678901234"),
               "16-char phone within limit should be accepted");

        [TestMethod]
        public void Phone_TooLong_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidatePhone("123456789012345678901").Length > 0,
               "21-char phone exceeds VARCHAR(20) limit — should be rejected");

        [TestMethod]
        public void Phone_Letters_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidatePhone("ABCDEFG").Length > 0,
               "Letters in phone should be rejected");

        [TestMethod]
        public void Phone_SpecialChars_ReturnsError()
            => Assert.IsTrue(DriverValidationRules.ValidatePhone("07700@900111").Length > 0,
               "@ symbol in phone should be rejected");
    }
}
