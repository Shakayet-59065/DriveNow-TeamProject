<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverAdd.aspx.cs" Inherits="DriveNow.DriverAdd" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow - Add Driver</title>
    <link rel="stylesheet" href="Content/Site.css"/>
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow"/></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx" class="dn-nav-item"><span class="dn-nav-icon">■</span> Dashboard</a>
            <div class="dn-nav-label">DRIVER MANAGEMENT</div>
            <a href="DriverAdd.aspx" class="dn-nav-item active"><span class="dn-nav-icon">+</span> Add Driver</a>
            <a href="DriverList.aspx" class="dn-nav-item"><span class="dn-nav-icon">☰</span> List Drivers</a>
            <a href="DriverFind.aspx" class="dn-nav-item"><span class="dn-nav-icon"></span> Find Driver</a>
            <a href="DriverFilter.aspx" class="dn-nav-item"><span class="dn-nav-icon">▿</span> Filter Drivers</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div class="dn-sidebar-user"><div class="dn-sidebar-avatar">RD</div><div><div class="dn-sidebar-name">Redoy</div><div class="dn-sidebar-role">Driver Management</div></div></div>
            <a href="Logout.aspx" class="dn-sidebar-logout">Ⓧ Sign Out</a>
        </div>
    </div>
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-title">Add New Driver</div>
            <div class="dn-topbar-right"><a href="DriverList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Back to List</a></div>
        </div>
        <div class="dn-content">
            <div class="dn-page-header"><div><div class="dn-page-title">Add New Driver</div><div class="dn-page-sub">Register a new driver in the DriveNow system</div></div></div>
            <asp:Label ID="lblMessage" runat="server" CssClass="dn-alert-success" Visible="false"/>
            <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false"/>
            <div class="dn-form-card">
                <div class="dn-field"><label class="dn-label">Full Name <span class="required">*</span></label><asp:TextBox ID="txtFullName" runat="server" CssClass="dn-input" placeholder="e.g. James Anderson"/><asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Full name is required." CssClass="dn-hint" Display="Dynamic" ForeColor=""/></div>
                <div class="dn-field"><label class="dn-label">Phone <span class="required">*</span></label><asp:TextBox ID="txtPhone" runat="server" CssClass="dn-input" placeholder="e.g. 07700900111"/><asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Phone is required." CssClass="dn-hint" Display="Dynamic" ForeColor=""/><asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone" ValidationExpression="^[\+\d\s\-\(\)]{6,20}$" ErrorMessage="Enter a valid phone number (digits, spaces, + or - only)." CssClass="dn-hint" Display="Dynamic" ForeColor=""/></div>
                <div class="dn-field"><label class="dn-label">Licence Number <span class="required">*</span></label><asp:TextBox ID="txtLicenceNumber" runat="server" CssClass="dn-input" placeholder="e.g. ANDE9901157JA9"/><asp:RequiredFieldValidator ID="rfvLicence" runat="server" ControlToValidate="txtLicenceNumber" ErrorMessage="Licence is required." CssClass="dn-hint" Display="Dynamic" ForeColor=""/></div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                    <div class="dn-field"><label class="dn-label">Licence Issue Date</label><asp:TextBox ID="txtLicenceIssueDate" runat="server" CssClass="dn-input" TextMode="Date"/><div class="dn-hint">Date the driving licence was issued.</div></div>
                    <div class="dn-field"><label class="dn-label">Licence Expiry Date</label><asp:TextBox ID="txtLicenceExpiryDate" runat="server" CssClass="dn-input" TextMode="Date"/><div class="dn-hint">Date the driving licence expires.</div></div>
                </div>
                <div class="dn-field"><label class="dn-label">Date of Birth <span class="required">*</span></label><asp:TextBox ID="txtDateOfBirth" runat="server" CssClass="dn-input" TextMode="Date"/><div class="dn-hint">Must be 18 or older</div><asp:RequiredFieldValidator ID="rfvDOB" runat="server" ControlToValidate="txtDateOfBirth" ErrorMessage="Date of birth is required." CssClass="dn-hint" Display="Dynamic" ForeColor=""/></div>
                <div class="dn-field"><label class="dn-label">Join Date <span class="required">*</span></label><asp:TextBox ID="txtJoinDate" runat="server" CssClass="dn-input" TextMode="Date"/><asp:RequiredFieldValidator ID="rfvJoin" runat="server" ControlToValidate="txtJoinDate" ErrorMessage="Join date is required." CssClass="dn-hint" Display="Dynamic" ForeColor=""/></div>
                <div class="dn-field"><label class="dn-label">Photo URL <span style="color:#64748b;font-weight:400;">(optional)</span></label><asp:TextBox ID="txtPhotoUrl" runat="server" CssClass="dn-input" placeholder="e.g. https://example.com/photo.jpg" MaxLength="500"/><div class="dn-hint">Direct URL to a driver profile photo. Leave blank to use initials avatar.</div></div>
                <div class="dn-field"><label class="dn-label">Short Bio <span style="color:#64748b;font-weight:400;">(optional)</span></label><asp:TextBox ID="txtBio" runat="server" CssClass="dn-input" TextMode="MultiLine" placeholder="e.g. Experienced driver with 8 years in the industry, specialising in airport transfers." MaxLength="300"/><div class="dn-hint">Up to 300 characters. Visible to customers when selecting a driver.</div></div>
                <div class="dn-field"><label class="dn-label">Rating <span style="color:#64748b;font-weight:400;">(optional, 0.0 – 5.0)</span></label><asp:TextBox ID="txtRating" runat="server" CssClass="dn-input" placeholder="e.g. 4.5" MaxLength="3"/><div class="dn-hint">Initial star rating (e.g. 4.5). Can be updated later.</div></div>
                <div class="dn-field"><label class="dn-label">Gender <span style="color:#64748b;font-weight:400;">(optional)</span></label><asp:DropDownList ID="ddlGender" runat="server" CssClass="dn-input"><asp:ListItem Value="" Text="-- Not specified --"/><asp:ListItem Value="M" Text="Male"/><asp:ListItem Value="F" Text="Female"/><asp:ListItem Value="X" Text="Non-binary / Other"/></asp:DropDownList></div>
                <div class="dn-field"><label class="dn-label">Specialty <span style="color:#64748b;font-weight:400;">(optional)</span></label><asp:TextBox ID="txtSpecialty" runat="server" CssClass="dn-input" placeholder="e.g. Airport Transfers, City Tours, Long Distance" MaxLength="100"/><div class="dn-hint">Shown as a tag on the driver card. Helps customers choose.</div></div>
                <!-- GDPR / Staff data-handling notice -->
                <div style="background:#0f172a;border:1px solid rgba(20,184,166,.2);border-radius:8px;padding:.9rem 1rem;margin-bottom:1.1rem;font-size:.78rem;color:#5eead4;line-height:1.65;">
                    <strong>&#9888; Data Protection Reminder</strong><br />
                    You are registering personal data (name, phone, date of birth, and driving licence number) belonging to a third party. Ensure you have obtained the individual's explicit consent before entering their data into this system. This information is processed under GDPR Article 6(1)(b) — contract — and Article 9 for health/identity data. Staff must not share or export this data without authorisation. Access is logged for audit purposes.
                </div>

                <div class="dn-form-actions">
                    <asp:Button ID="btnAdd" runat="server" Text="Add Driver" CssClass="dn-btn dn-btn-primary" OnClick="btnAdd_Click"/>
                    <asp:Button ID="btnBack" runat="server" Text="Cancel" CssClass="dn-btn dn-btn-secondary" OnClick="btnBack_Click" CausesValidation="false"/>
                </div>
            </div>
        </div>
        <div class="dn-footer">DriveNow · CTEC2713N · Niels Brock Copenhagen</div>
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