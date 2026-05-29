<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverDelete.aspx.cs" Inherits="DriveNow.DriverDelete" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow - Delete Driver</title>
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
            <a href="DriverAdd.aspx" class="dn-nav-item"><span class="dn-nav-icon">+</span> Add Driver</a>
            <a href="DriverList.aspx" class="dn-nav-item active"><span class="dn-nav-icon">☰</span> List Drivers</a>
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
            <div class="dn-topbar-title">Delete Driver</div>
            <div class="dn-topbar-right"><a href="DriverList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Back to List</a></div>
        </div>
        <div class="dn-content">
            <div class="dn-page-header"><div><div class="dn-page-title">Deactivate Driver</div><div class="dn-page-sub">Soft delete - record stays in database with IsActive = 0</div></div></div>
            <asp:HiddenField ID="hdnDriverID" runat="server"/>
            <asp:Label ID="lblMessage" runat="server" CssClass="dn-alert-success" Visible="false"/>
            <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false"/>
            <div class="dn-form-card">
                <div class="dn-alert-error" style="margin-bottom:20px;">
                    <strong>Warning:</strong> You are about to deactivate this driver.<br/>
                    <asp:Label ID="lblDriverInfo" runat="server" style="display:block;margin-top:8px;font-weight:500;"/>
                    <br/><span style="font-size:12px;color:#94a3b8;">GDPR - data preserved. FK integrity with trip records maintained.</span>
                </div>
                <div class="dn-form-actions">
                    <asp:Button ID="btnDelete" runat="server" Text="Confirm Deactivate" CssClass="dn-btn dn-btn-danger" OnClick="btnDelete_Click"/>
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