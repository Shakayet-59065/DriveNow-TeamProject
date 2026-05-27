<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerAdd.aspx.cs" Inherits="DriveNow.CustomerAdd" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Add Customer — DriveNow Admin</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"        class="dn-nav-item">■ Dashboard</a>
            <div class="dn-nav-label">Team</div>
            <a href="TripList.aspx"        class="dn-nav-item">■ Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item">■ Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item active">■ Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item">■ Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item">■ Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item">■ Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div>CTEC2713N · Niels Brock</div>
            <a href="Logout.aspx" class="dn-sidebar-logout">&#x2192; Log out</a>
        </div>
    </div>
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Add Customer</span>
                <span class="dn-page-sub">Register a new customer account</span>
            </div>
            <div class="dn-topbar-actions">
                <a href="CustomerList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Back to List</a>
            </div>
        </div>
        <div class="dn-content">
            <asp:Label ID="lblMessage" runat="server" CssClass="dn-alert-success" Visible="false" />
            <asp:Label ID="lblError"   runat="server" CssClass="dn-alert-error"   Visible="false" />
            <div class="dn-form-card">
                <div class="dn-field">
                    <label class="dn-label">Full Name <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="dn-input" placeholder="e.g. Alice Hansen" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Full name is required." CssClass="dn-hint" Display="Dynamic" ForeColor="" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Email <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="dn-input" TextMode="Email" placeholder="e.g. alice@example.com" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." CssClass="dn-hint" Display="Dynamic" ForeColor="" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Enter a valid email address." CssClass="dn-hint" Display="Dynamic" ForeColor="" ValidationExpression="^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Phone <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="dn-input" placeholder="e.g. +45 20 00 11 11" />
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Phone is required." CssClass="dn-hint" Display="Dynamic" ForeColor="" />
                    <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Phone must contain only digits, spaces, +, - or brackets." CssClass="dn-hint" Display="Dynamic" ForeColor="" ValidationExpression="^[\d\s\+\-\(\)]{6,}$" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Password <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="dn-input" TextMode="Password" placeholder="Min 8 chars, 1 uppercase, 1 number" />
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password is required." CssClass="dn-hint" Display="Dynamic" ForeColor="" />
                    <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password must be at least 8 characters, include 1 uppercase letter and 1 number." CssClass="dn-hint" Display="Dynamic" ForeColor="" ValidationExpression="^(?=.*[A-Z])(?=.*\d).{8,}$" />
                </div>
                <!-- GDPR / Staff data-handling notice -->
                <div style="background:#0f172a;border:1px solid rgba(20,184,166,.2);border-radius:8px;padding:.9rem 1rem;margin-bottom:1.1rem;font-size:.78rem;color:#5eead4;line-height:1.65;">
                    <strong>&#9888; Data Protection Reminder</strong><br />
                    You are registering personal data (name, email address, phone number) for a new customer account. Ensure the customer has consented to their data being stored in the DriveNow system. Data is processed under GDPR Article 6(1)(b) — performance of a contract. Do not create accounts on behalf of customers without their explicit written or verbal consent. All account creation events are logged for audit purposes.
                </div>

                <div class="dn-form-actions">
                    <asp:Button ID="btnAdd"  runat="server" Text="Add Customer" CssClass="dn-btn dn-btn-primary"   OnClick="btnAdd_Click" />
                    <asp:Button ID="btnBack" runat="server" Text="Cancel"       CssClass="dn-btn dn-btn-secondary" OnClick="btnBack_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
        <div class="dn-footer">DriveNow Admin · CTEC2713N · Niels Brock Copenhagen · Customer Management</div>
    </div>
</div>
</form>
<script>
    /* ── Mobile sidebar toggle ───────────────────────────── */
    function toggleSidebar() {
        document.body.classList.toggle('sidebar-open');
    }
    /* Close sidebar when clicking the dark overlay backdrop */
    document.addEventListener('click', function(e) {
        if (document.body.classList.contains('sidebar-open') &&
            !e.target.closest('.dn-sidebar') &&
            !e.target.closest('.dn-mobile-menu-btn')) {
            document.body.classList.remove('sidebar-open');
        }
    });
</script>
</body>
</html>


