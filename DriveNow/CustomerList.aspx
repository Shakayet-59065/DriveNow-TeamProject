<%-- DriveNow — Customer List Page
     Displays all registered customers in a table with Active / Inactive tab switching.
     Stat cards at the top show total and active customer counts.
     Each row has Edit, Deactivate (soft-delete), Restore, and Hard Delete actions.
     Logic is handled in CustomerList.aspx.cs (code-behind file).
     Module: CTEC2713N | Developer: Tahmid --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerList.aspx.cs" Inherits="DriveNow.CustomerList" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Customer Management — DriveNow Admin</title>
    <!-- Google Material Symbols icon font for sidebar navigation icons -->
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <!-- Main admin stylesheet -->
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">

    <!-- ═══ SIDEBAR NAVIGATION ═══ -->
    <div class="dn-sidebar">
        <!-- DriveNow logo -->
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <!-- Navigation links — "active" marks the current page -->
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"        class="dn-nav-item">■ Dashboard</a>
            <div class="dn-nav-label">Team</div>
            <a href="TripList.aspx"        class="dn-nav-item">■ Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item">■ Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item active">■ Customers</a><!-- Active: current page -->
            <a href="DriverList.aspx"      class="dn-nav-item">■ Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item">■ Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item">■ Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <!-- Shows the logged-in staff member's initial in an avatar circle, linking to their profile -->
            <a href="StaffProfile.aspx" style="text-decoration:none;" title="View your profile">
                <div class="dn-sidebar-user">
                    <!-- Avatar: first letter of the username, e.g. "T" for Tahmid -->
                    <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                    <div>
                        <div class="dn-sidebar-name"><%= Session["Username"] %></div>
                        <div class="dn-sidebar-role">Staff Portal &rsaquo;</div>
                    </div>
                </div>
            </a>
            <a href="Logout.aspx" class="dn-sidebar-logout">&#x2192; Sign Out</a>
        </div>
    </div>

    <!-- ═══ MAIN CONTENT AREA ═══ -->
    <div class="dn-main">
        <!-- Top bar: page title on the left, action buttons on the right -->
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Customer Management</span>
                <span class="dn-page-sub">Manage all DriveNow customers</span>
            </div>
            <div class="dn-topbar-actions">
                <!-- Quick access buttons to add, find, or filter customers -->
                <a href="CustomerAdd.aspx"    class="dn-btn dn-btn-primary dn-btn-sm">+ Add Customer</a>
                <a href="CustomerFind.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">Find</a>
                <a href="CustomerFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
                <asp:Button ID="btnExportCsv" runat="server" Text="⬇ Export CSV"
                    CssClass="dn-btn dn-btn-secondary dn-btn-sm"
                    OnClick="btnExportCsv_Click" CausesValidation="false"
                    ToolTip="Download all customers as a CSV file (opens in Excel)" />
            </div>
        </div>
        <div class="dn-content">
            <!-- Summary stat cards: Total customers and Active customers counts -->
            <div class="dn-stats">
                <div class="dn-stat dn-stat-2">
                    <div class="dn-stat-num"><asp:Label ID="lblTotal"  runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Total Customers</div>
                </div>
                <div class="dn-stat dn-stat-2">
                    <div class="dn-stat-num"><asp:Label ID="lblActive" runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Active</div>
                </div>
            </div>
            <!-- Success or error message shown after an action -->
            <asp:Label ID="lblMessage" runat="server" Text="" Visible="false" />
            <!-- Search bar — client-side filter by ID, Name, Email, Phone -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;flex-wrap:wrap;">
                <span class="material-symbols-outlined" style="font-size:18px;color:#64748b;">search</span>
                <input type="text" id="customerSearch" placeholder="Search by ID, Name, Email, Phone…"
                    oninput="filterCustomerTable(this.value)"
                    style="border:1px solid #e2e8f0;border-radius:7px;padding:.45rem .9rem;font-size:.88rem;color:#0f172a;background:#fff;width:320px;outline:none;"
                    onfocus="this.style.borderColor='#0d9488'" onblur="this.style.borderColor='#e2e8f0'" />
                <button type="button" onclick="document.getElementById('customerSearch').value='';filterCustomerTable('');"
                    style="background:transparent;border:none;color:#94a3b8;cursor:pointer;font-size:.85rem;padding:.45rem .5rem;"
                    title="Clear search">&#10005;</button>
                <span id="custSearchCount" style="font-size:.78rem;color:#64748b;"></span>
                <span style="font-size:.72rem;color:#94a3b8;">· Click any column header to sort</span>
            </div>

            <!-- Customer data table — filled by LoadCustomers() in the code-behind -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvCustomers" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="dn-table"
                    GridLines="None"
                    DataKeyNames="CustomerID"
                    OnRowCommand="gvCustomers_RowCommand">
                    <Columns>
                        <%-- Customer ID formatted as #CUS-001 --%>
                        <asp:TemplateField HeaderText="ID">
                            <ItemTemplate><span class="dn-trip-id">#CUS-<%# string.Format("{0:D3}", Eval("CustomerID")) %></span></ItemTemplate>
                        </asp:TemplateField>
                        <%-- Customer personal details --%>
                        <asp:BoundField DataField="FullName"     HeaderText="Full Name" />
                        <asp:BoundField DataField="Email"        HeaderText="Email" />
                        <asp:BoundField DataField="Phone"        HeaderText="Phone" />
                        <asp:BoundField DataField="RegisterDate" HeaderText="Registered" DataFormatString="{0:dd MMM yyyy}" />
                        <%-- Green dot = Active, Red dot = Inactive --%>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsActive"))
                                    ? "<span class=\"dn-status\"><span class=\"dn-dot-green\"></span> Active</span>"
                                    : "<span class=\"dn-status\"><span class=\"dn-dot-red\"></span> Inactive</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%-- Action buttons change based on whether the customer is active or inactive --%>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <%-- Active row: Edit or Deactivate (soft-delete) --%>
                                <asp:LinkButton runat="server" CommandName="EditCustomer"
                                    CommandArgument='<%# Eval("CustomerID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# Convert.ToBoolean(Eval("IsActive")) %>'>Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteCustomer"
                                    CommandArgument='<%# Eval("CustomerID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# Convert.ToBoolean(Eval("IsActive")) %>'
                                    OnClientClick="return confirm('Deactivate this customer?');">Deactivate</asp:LinkButton>
                                <%-- Inactive row: Restore back to active, or permanently Hard Delete --%>
                                <asp:LinkButton runat="server" CommandName="RestoreCustomer"
                                    CommandArgument='<%# Eval("CustomerID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsActive")) %>'>Restore</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="HardDeleteCustomer"
                                    CommandArgument='<%# Eval("CustomerID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsActive")) %>'
                                    OnClientClick="return confirm('PERMANENTLY delete this customer? This cannot be undone.');">Hard Delete</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <!-- Footer at the bottom of the admin page -->
        <div class="dn-footer">DriveNow Admin · CTEC2713N · Niels Brock Copenhagen · Customer Management</div>
    </div>
</div>
</form>
<script>
    /* ── Mobile sidebar toggle ───────────────────────────── */
    function toggleSidebar() {
        document.body.classList.toggle('sidebar-open');
    }
    document.addEventListener('click', function(e) {
        if (document.body.classList.contains('sidebar-open') &&
            !e.target.closest('.dn-sidebar') &&
            !e.target.closest('.dn-mobile-menu-btn')) {
            document.body.classList.remove('sidebar-open');
        }
    });

    /* ── Live search — searches all visible text columns ──── */
    function filterCustomerTable(q) {
        q = (q || '').trim().toLowerCase();
        var table   = document.querySelector('.dn-table');
        var countEl = document.getElementById('custSearchCount');
        if (!table) return;
        var rows = table.querySelectorAll('tr');
        var visible = 0;
        for (var i = 1; i < rows.length; i++) {
            var cells = rows[i].querySelectorAll('td');
            if (!cells.length) continue;
            var text = '';
            for (var c = 0; c <= 6; c++) text += (cells[c] ? cells[c].textContent : '') + ' ';
            var match = !q || text.toLowerCase().indexOf(q) !== -1;
            rows[i].style.display = match ? '' : 'none';
            if (match) visible++;
        }
        if (countEl) countEl.textContent = q ? visible + ' customer' + (visible !== 1 ? 's' : '') + ' found' : '';
    }

    /* ── Column sort ─────────────────────────────────────── */
    var _cusSortCol = -1, _cusSortAsc = true;
    document.addEventListener('DOMContentLoaded', function () {
        var table = document.querySelector('.dn-table');
        if (!table) return;
        table.querySelectorAll('th').forEach(function (th, idx) {
            th.style.cursor = 'pointer'; th.title = 'Click to sort';
            th.addEventListener('click', function () { sortCustomerTable(idx); });
        });
    });
    function sortCustomerTable(col) {
        var table = document.querySelector('.dn-table');
        if (!table) return;
        var asc = (_cusSortCol === col) ? !_cusSortAsc : true;
        _cusSortCol = col; _cusSortAsc = asc;
        var tbody = table.querySelector('tbody') || table;
        var rows  = Array.prototype.slice.call(table.querySelectorAll('tr')).slice(1);
        rows.sort(function (a, b) {
            var ca = a.querySelectorAll('td')[col];
            var cb = b.querySelectorAll('td')[col];
            var ta = ca ? ca.textContent.trim() : '';
            var tb = cb ? cb.textContent.trim() : '';
            var cmp = ta.localeCompare(tb);
            return asc ? cmp : -cmp;
        });
        rows.forEach(function (r) { tbody.appendChild(r); });
        table.querySelectorAll('th').forEach(function (th, i) {
            th.textContent = th.textContent.replace(/ [▲▼]$/, '');
            if (i === col) th.textContent += asc ? ' ▲' : ' ▼';
        });
    }
</script>
</body>
</html>


