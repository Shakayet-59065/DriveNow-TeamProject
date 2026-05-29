<%-- DriveNow — Driver List Page (DriverList.aspx)
     Shows all drivers in a table with Active / Inactive tab switching.
     Each row has Profile, Edit, Deactivate, Restore, and Hard Delete actions.
     Module: CTEC2713N | Developer: Musanna --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverList.aspx.cs" Inherits="DriveNow.DriverList" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Driver List</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css"/>
    <style>
        .dn-sidebar-module { padding:14px 20px 10px; border-bottom:1px solid rgba(255,255,255,.07); margin-bottom:6px; }
        .dn-sidebar-module-label { font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:#14b8a6;margin-bottom:4px; }
        .dn-sidebar-module-title { font-size:15px;font-weight:700;color:#fff; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">

    <!-- ═══ SIDEBAR — Fixed left-hand navigation panel with links to all admin sections ═══ -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow"/></div>

        <!-- Current module indicator -->
        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Driver Dashboard</div>
        </div>

        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>

            <div class="dn-nav-label">NAVIGATE</div>
            <a href="TripList.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>

        <div class="dn-sidebar-footer">
            <!-- Shows the logged-in staff member's name from session -->
            <a href="StaffProfile.aspx" style="text-decoration:none;" title="View your profile">
                <div class="dn-sidebar-user">
                    <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                    <div>
                        <div class="dn-sidebar-name"><%= Session["Username"] %></div>
                        <div class="dn-sidebar-role">Staff Portal &rsaquo;</div>
                    </div>
                </div>
            </a>
            <a href="Logout.aspx" class="dn-sidebar-logout">Sign Out</a>
        </div>
    </div>

    <!-- ═══ MAIN CONTENT AREA — Page title, tabs, and driver table ═══ -->
    <div class="dn-main">
        <!-- Top bar: page title on the left, quick action buttons on the right -->
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Driver Records</span>
                <span class="dn-page-sub">Manage all DriveNow drivers</span>
            </div>
            <div class="dn-topbar-right">
                <!-- Buttons to add a new driver or search/filter the list -->
                <a href="DriverAdd.aspx"    class="dn-btn dn-btn-primary dn-btn-sm">+ Add Driver</a>
                <a href="DriverFind.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">Find</a>
                <a href="DriverFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
                <asp:Button ID="btnExportCsv" runat="server" Text="⬇ Export CSV"
                    CssClass="dn-btn dn-btn-secondary dn-btn-sm"
                    OnClick="btnExportCsv_Click" CausesValidation="false"
                    ToolTip="Download all drivers as a CSV file (opens in Excel)" />
            </div>
        </div>

        <div class="dn-content">

            <!-- Section heading above the driver table -->
            <div class="dn-section-head">
                <div class="dn-section-title">All Drivers</div>
            </div>

            <!-- Success or error message shown after an action (e.g. driver deactivated) -->
            <asp:Label ID="lblMessage" runat="server" Visible="false" />

            <!-- Search bar — client-side filter by ID, Name, Phone, Licence No -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;flex-wrap:wrap;">
                <span class="material-symbols-outlined" style="font-size:18px;color:#64748b;">search</span>
                <input type="text" id="driverSearch" placeholder="Search by ID, Name, Phone, Licence No…"
                    oninput="filterDriverTable(this.value)"
                    style="border:1px solid #e2e8f0;border-radius:7px;padding:.45rem .9rem;font-size:.88rem;color:#0f172a;background:#fff;width:340px;outline:none;"
                    onfocus="this.style.borderColor='#0d9488'" onblur="this.style.borderColor='#e2e8f0'" />
                <button type="button" onclick="document.getElementById('driverSearch').value='';filterDriverTable('');"
                    style="background:transparent;border:none;color:#94a3b8;cursor:pointer;font-size:.85rem;padding:.45rem .5rem;"
                    title="Clear search">&#10005;</button>
                <span id="drvSearchCount" style="font-size:.78rem;color:#64748b;"></span>
                <span style="font-size:.72rem;color:#94a3b8;">· Click any column header to sort</span>
            </div>

            <!-- Driver data table — populated by LoadDrivers() in the code-behind -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvDrivers" runat="server"
                    AutoGenerateColumns="False"
                    DataKeyNames="DriverID"
                    OnRowCommand="gvDrivers_RowCommand"
                    CssClass="dn-table"
                    EmptyDataText="No drivers found."
                    GridLines="None">
                    <Columns>
                        <%-- Driver ID formatted as #DRV-1 for easy identification --%>
                        <asp:TemplateField HeaderText="ID">
                            <ItemTemplate><span class="dn-trip-id">#DRV-<%# Eval("DriverID") %></span></ItemTemplate>
                        </asp:TemplateField>
                        <%-- Core driver details --%>
                        <asp:BoundField DataField="FullName"      HeaderText="Full Name"/>
                        <asp:BoundField DataField="Phone"         HeaderText="Phone"/>
                        <asp:BoundField DataField="LicenceNumber" HeaderText="Licence No"/>
                        <asp:BoundField DataField="DateOfBirth"   HeaderText="Date of Birth" DataFormatString="{0:yyyy-MM-dd}"/>
                        <asp:BoundField DataField="JoinDate"      HeaderText="Joined"        DataFormatString="{0:yyyy-MM-dd}"/>
                        <%-- Status badge: green dot = Active, red dot = Inactive --%>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsActive"))
                                    ? "<span class=\"dn-status\"><span class=\"dn-dot dn-dot-green\"></span> Active</span>"
                                    : "<span class=\"dn-status\"><span class=\"dn-dot dn-dot-red\"></span> Inactive</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <%-- Profile link is always shown — opens the driver's full detail page --%>
                                <a href='DriverDetail.aspx?id=<%# Eval("DriverID") %>&admin=1' class="dn-action-edit" title="View full profile">Profile</a>
                                <%-- Active row buttons: Edit the driver record or Deactivate (soft-delete) --%>
                                <asp:LinkButton runat="server" CommandName="EditDriver"
                                    CommandArgument='<%# Eval("DriverID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# Convert.ToBoolean(Eval("IsActive")) %>'>Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteDriver"
                                    CommandArgument='<%# Eval("DriverID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# Convert.ToBoolean(Eval("IsActive")) %>'
                                    OnClientClick="return confirm('Deactivate this driver?');">Deactivate</asp:LinkButton>
                                <%-- Inactive row buttons: Restore the driver or permanently Hard Delete --%>
                                <asp:LinkButton runat="server" CommandName="RestoreDriver"
                                    CommandArgument='<%# Eval("DriverID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsActive")) %>'>Restore</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="HardDeleteDriver"
                                    CommandArgument='<%# Eval("DriverID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsActive")) %>'
                                    OnClientClick="return confirm('PERMANENTLY delete this driver? This cannot be undone.');">Hard Delete</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- Footer bar at the bottom of every admin page -->
        <div class="dn-footer">DriveNow Admin &middot; CTEC2713N &middot; Niels Brock Copenhagen</div>
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

    /* ── Live search — ID, Name, Phone, Licence No, DOB, Joined ─ */
    function filterDriverTable(q) {
        q = (q || '').trim().toLowerCase();
        var table   = document.querySelector('.dn-table');
        var countEl = document.getElementById('drvSearchCount');
        if (!table) return;
        var rows = table.querySelectorAll('tr');
        var visible = 0;
        for (var i = 1; i < rows.length; i++) {
            var cells = rows[i].querySelectorAll('td');
            if (!cells.length) continue;
            // cols: 0=ID, 1=Name, 2=Phone, 3=LicenceNo, 4=DOB, 5=Joined, 6=Status, 7=Actions
            var text = '';
            for (var c = 0; c <= 6; c++) text += (cells[c] ? cells[c].textContent : '') + ' ';
            var match = !q || text.toLowerCase().indexOf(q) !== -1;
            rows[i].style.display = match ? '' : 'none';
            if (match) visible++;
        }
        if (countEl) countEl.textContent = q ? visible + ' driver' + (visible !== 1 ? 's' : '') + ' found' : '';
    }

    /* ── Column sort ─────────────────────────────────────────── */
    var _drvSortCol = -1, _drvSortAsc = true;
    document.addEventListener('DOMContentLoaded', function () {
        var table = document.querySelector('.dn-table');
        if (!table) return;
        table.querySelectorAll('th').forEach(function (th, idx) {
            th.style.cursor = 'pointer';
            th.title = 'Click to sort';
            th.addEventListener('click', function () { sortDriverTable(idx); });
        });
    });
    function sortDriverTable(col) {
        var table = document.querySelector('.dn-table');
        if (!table) return;
        var asc = (_drvSortCol === col) ? !_drvSortAsc : true;
        _drvSortCol = col; _drvSortAsc = asc;
        var tbody = table.querySelector('tbody') || table;
        var rows  = Array.prototype.slice.call(table.querySelectorAll('tr')).slice(1);
        rows.sort(function (a, b) {
            var ca = a.querySelectorAll('td')[col];
            var cb = b.querySelectorAll('td')[col];
            var ta = ca ? ca.textContent.trim() : '';
            var tb = cb ? cb.textContent.trim() : '';
            var na = parseFloat(ta.replace(/[^0-9.]/g, ''));
            var nb = parseFloat(tb.replace(/[^0-9.]/g, ''));
            var cmp = (!isNaN(na) && !isNaN(nb)) ? (na - nb) : ta.localeCompare(tb);
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


