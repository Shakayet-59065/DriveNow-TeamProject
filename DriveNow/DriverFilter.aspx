<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverFilter.aspx.cs" Inherits="DriveNow.DriverFilter" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow - Filter Drivers</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
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
            <a href="DriverList.aspx" class="dn-nav-item"><span class="dn-nav-icon">☰</span> List Drivers</a>
            <a href="DriverFind.aspx" class="dn-nav-item"><span class="dn-nav-icon"></span> Find Driver</a>
            <a href="DriverFilter.aspx" class="dn-nav-item active"><span class="dn-nav-icon">▿</span> Filter Drivers</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div class="dn-sidebar-user"><div class="dn-sidebar-avatar">RD</div><div><div class="dn-sidebar-name">Redoy</div><div class="dn-sidebar-role">Driver Management</div></div></div>
            <a href="Logout.aspx" class="dn-sidebar-logout">Ⓧ Sign Out</a>
        </div>
    </div>
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-title">Filter Drivers</div>
            <div class="dn-topbar-right"><a href="DriverAdd.aspx" class="dn-btn dn-btn-primary dn-btn-sm">+ Add Driver</a></div>
        </div>
        <div class="dn-content">
            <div class="dn-page-header"><div><div class="dn-page-title">Filter Drivers</div><div class="dn-page-sub">Filter by join date or status - inactive drivers visible here only</div></div></div>
            <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false"/>
            <div class="dn-filter-row">
                <div class="dn-filter-field"><label class="dn-label">Join Date From</label><asp:TextBox ID="txtDateFrom" runat="server" CssClass="dn-input" placeholder="YYYY-MM-DD"/></div>
                <div class="dn-filter-field"><label class="dn-label">Join Date To</label><asp:TextBox ID="txtDateTo" runat="server" CssClass="dn-input" placeholder="YYYY-MM-DD"/></div>
                <div class="dn-filter-field">
                    <label class="dn-label">Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="dn-select">
                        <asp:ListItem Text="All Drivers" Value=""/>
                        <asp:ListItem Text="Active Only" Value="1"/>
                        <asp:ListItem Text="Inactive Only" Value="0"/>
                    </asp:DropDownList>
                </div>
                <div style="display:flex;align-items:flex-end;"><asp:Button ID="btnFilter" runat="server" Text="Apply Filter" CssClass="dn-btn dn-btn-primary" OnClick="btnFilter_Click"/></div>
            </div>
            <div class="dn-table-wrap">
                <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="False" Visible="false" CssClass="dn-table" EmptyDataText="No drivers match." GridLines="None">
                    <Columns>
                        <asp:TemplateField HeaderText="ID"><ItemTemplate><span class="dn-trip-id">#DRV-<%# Eval("DriverID") %></span></ItemTemplate></asp:TemplateField>
                        <asp:BoundField DataField="FullName" HeaderText="Full Name"/>
                        <asp:BoundField DataField="Phone" HeaderText="Phone"/>
                        <asp:BoundField DataField="LicenceNumber" HeaderText="Licence"/>
                        <asp:BoundField DataField="JoinDate" HeaderText="Join Date" DataFormatString="{0:yyyy-MM-dd}"/>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class="dn-status">
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "dn-dot dn-dot-green" : "dn-dot dn-dot-red" %>'></span>
                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <a href='DriverEdit.aspx?id=<%# Eval("DriverID") %>' class="dn-action-edit">Edit</a>
                                <a href='DriverDelete.aspx?id=<%# Eval("DriverID") %>' class="dn-action-del">Delete</a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
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