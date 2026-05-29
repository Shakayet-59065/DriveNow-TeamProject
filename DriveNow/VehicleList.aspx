<%-- DriveNow — Vehicle List Page (VehicleList.aspx)
     Shows all fleet vehicles in a table with Active / Removed tab switching.
     Includes stat cards, a currency converter, and Edit/Remove/Restore/Hard Delete actions.
     Module: CTEC2713N | Developer: Musanna --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VehicleList.aspx.cs" Inherits="DriveNow.VehicleList" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Vehicle Inventory</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        .dn-sidebar-module { padding:14px 20px 10px; border-bottom:1px solid rgba(255,255,255,.07); margin-bottom:6px; }
        .dn-sidebar-module-label { font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:#14b8a6;margin-bottom:4px; }
        .dn-sidebar-module-title { font-size:15px;font-weight:700;color:#fff; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">

    <!-- ═══ SIDEBAR — Fixed left-hand navigation panel visible on all admin pages ═══ -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo">
            <img src="Content/logo.png" alt="DriveNow" />
        </div>

        <!-- Current module indicator -->
        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Vehicle Dashboard</div>
        </div>

        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>

            <div class="dn-nav-label">NAVIGATE</div>
            <a href="TripList.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
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

    <!-- ═══ MAIN CONTENT AREA — Page title, tabs, stats, currency converter, and vehicle table ═══ -->
    <div class="dn-main">
        <!-- Top bar: page title on the left, quick action buttons on the right -->
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Vehicle Inventory</span>
                <span class="dn-page-sub">Manage all DriveNow fleet vehicles</span>
            </div>
            <div class="dn-topbar-right">
                <!-- Buttons to add a new vehicle or search/filter the list -->
                <a href="VehicleAdd.aspx"    class="dn-btn dn-btn-primary dn-btn-sm">+ Add Vehicle</a>
                <a href="VehicleFind.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">Find</a>
                <a href="VehicleFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
                <asp:Button ID="btnExportCsv" runat="server" Text="⬇ Export CSV"
                    CssClass="dn-btn dn-btn-secondary dn-btn-sm"
                    OnClick="btnExportCsv_Click" CausesValidation="false"
                    ToolTip="Download all vehicles as a CSV file (opens in Excel)" />
            </div>
        </div>

        <div class="dn-content">

            <!-- Section heading above the vehicle table -->
            <div class="dn-section-head">
                <div class="dn-section-title">All Vehicles</div>
            </div>

            <!-- Stat cards: live counts from the database — filled by the code-behind -->
            <div class="dn-stats">
                <!-- Total number of vehicles ever added (active + removed) -->
                <div class="dn-stat dn-stat-3">
                    <div class="dn-stat-num"><asp:Label ID="lblTotalVehicles"   runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Total Vehicles</div>
                </div>
                <!-- Number of vehicles currently in service (IsAvailable = true) -->
                <div class="dn-stat dn-stat-3">
                    <div class="dn-stat-num"><asp:Label ID="lblActiveVehicles"  runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Active</div>
                </div>
                <!-- Number of vehicles removed from service (soft-deleted) -->
                <div class="dn-stat dn-stat-3">
                    <div class="dn-stat-num"><asp:Label ID="lblRemovedVehicles" runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Removed</div>
                </div>
                <!-- Average daily hire rate across all active vehicles — updates with currency picker -->
                <div class="dn-stat dn-stat-3">
                    <div class="dn-stat-num" id="statAvgRateBox">
                        <asp:Label ID="lblAvgRate" runat="server" Text="&pound;0" />
                    </div>
                    <div class="dn-stat-label">Avg Daily Rate</div>
                </div>
                <!-- Hidden field stores the GBP average so the JavaScript converter can use it -->
                <asp:HiddenField ID="hfAvgRateGbp" runat="server" Value="0" />
            </div>

            <!-- Success or error message shown after an action (e.g. vehicle removed) -->
            <asp:Label ID="lblMessage" runat="server" Text="" Visible="false" />

            <!-- Currency converter dropdown — JavaScript converts all prices on screen without a page reload -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:14px;font-size:13px;color:#64748b;">
                Display prices in:
                <select id="currencyPicker" onchange="convertVehiclePrices(this.value)"
                        style="border:1px solid #e2e8f0;border-radius:6px;padding:4px 10px;font-size:13px;color:#0f172a;background:#fff;">
                    <option value="GBP">GBP (£)</option>
                    <option value="EUR">EUR (€)</option>
                    <option value="USD">USD ($)</option>
                    <option value="DKK">DKK (kr)</option>
                    <option value="SEK">SEK (kr)</option>
                    <option value="NOK">NOK (kr)</option>
                    <option value="AUD">AUD ($)</option>
                </select>
            </div>

            <!-- Search bar — filters by ID, Reg No, Make, Model or Seats -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;flex-wrap:wrap;">
                <span class="material-symbols-outlined" style="font-size:18px;color:#64748b;">search</span>
                <input type="text" id="vehicleSearch" placeholder="Search by ID, Reg No, Make, Model, Seats…"
                    oninput="filterVehicleTable(this.value)"
                    style="border:1px solid #e2e8f0;border-radius:7px;padding:.45rem .9rem;font-size:.88rem;color:#0f172a;background:#fff;width:340px;outline:none;"
                    onfocus="this.style.borderColor='#0d9488'" onblur="this.style.borderColor='#e2e8f0'" />
                <button type="button" onclick="document.getElementById('vehicleSearch').value='';filterVehicleTable('');"
                    style="background:transparent;border:none;color:#94a3b8;cursor:pointer;font-size:.85rem;padding:.45rem .5rem;"
                    title="Clear search">&#10005;</button>
                <span id="vehSearchCount" style="font-size:.78rem;color:#64748b;"></span>
                <span style="font-size:.72rem;color:#94a3b8;">· Click any column header to sort</span>
            </div>

            <!-- Vehicle data table — populated by LoadVehicles() in the code-behind -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvVehicles" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="dn-table"
                    GridLines="None"
                    OnRowCommand="gvVehicles_RowCommand">
                    <Columns>
                        <%-- Vehicle ID formatted as #VEH-001 for easy identification --%>
                        <asp:TemplateField HeaderText="ID">
                            <ItemTemplate>
                                <span class="dn-trip-id">#VEH-<%# string.Format("{0:D3}", Eval("VehicleID")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%-- Core vehicle data columns --%>
                        <asp:BoundField DataField="RegistrationNo" HeaderText="Reg No" />
                        <asp:BoundField DataField="Make"           HeaderText="Make" />
                        <asp:BoundField DataField="Model"          HeaderText="Model" />
                        <%-- Daily rate stored in GBP — the data-gbp attribute lets JavaScript convert it --%>
                        <asp:TemplateField HeaderText="Daily Rate">
                            <ItemTemplate>
                                <span class="veh-price" data-gbp="<%# string.Format("{0:F2}", Eval("DailyRate")) %>">
                                    <span class="price-sym">&pound;</span><span class="price-val"><%# string.Format("{0:F2}", Eval("DailyRate")) %></span>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Seats"     HeaderText="Seats" />
                        <asp:BoundField DataField="DateAdded" HeaderText="Date Added" DataFormatString="{0:dd MMM yyyy}" />
                        <%-- Status badge: green dot = Active (in service), red dot = Removed (out of service) --%>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsAvailable"))
                                    ? "<span class=\"dn-status\"><span class=\"dn-dot dn-dot-green\"></span> Active</span>"
                                    : "<span class=\"dn-status\"><span class=\"dn-dot dn-dot-red\"></span> Removed</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <%-- Active row buttons: Edit the vehicle or Remove it from service (soft-delete) --%>
                                <asp:LinkButton runat="server" CommandName="EditVehicle"
                                    CommandArgument='<%# Eval("VehicleID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# Convert.ToBoolean(Eval("IsAvailable")) %>'>Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteVehicle"
                                    CommandArgument='<%# Eval("VehicleID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# Convert.ToBoolean(Eval("IsAvailable")) %>'
                                    OnClientClick="return confirm('Remove this vehicle from service? Record is kept for audit.');">Remove</asp:LinkButton>
                                <%-- Removed row buttons: Restore the vehicle or permanently Hard Delete it --%>
                                <asp:LinkButton runat="server" CommandName="RestoreVehicle"
                                    CommandArgument='<%# Eval("VehicleID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsAvailable")) %>'>Restore</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="HardDeleteVehicle"
                                    CommandArgument='<%# Eval("VehicleID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsAvailable")) %>'
                                    OnClientClick="return confirm('PERMANENTLY delete this vehicle? This cannot be undone.');">Hard Delete</asp:LinkButton>
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
    // Exchange rates relative to GBP (1 GBP = X of the target currency)
    var V_RATES   = { GBP:1, EUR:1.18, USD:1.27, DKK:8.72, SEK:13.5, NOK:13.9, AUD:1.98 };
    // Currency symbols displayed next to the price
    var V_SYMBOLS = {
        GBP: '£',
        EUR: '€',
        USD: '$',
        DKK: 'kr',
        SEK: 'kr',
        NOK: 'kr',
        AUD: 'A$'
    };
    // Whether the symbol goes before the number (£10) or after (10 kr)
    var V_PREFIX  = { GBP:true, EUR:true, USD:true, DKK:false, SEK:false, NOK:false, AUD:true };

    // ── Live search — searches ID, Reg No, Make, Model, Seats ───────────
    function filterVehicleTable(q) {
        q = (q || '').trim().toLowerCase();
        var table   = document.querySelector('.dn-table');
        var countEl = document.getElementById('vehSearchCount');
        if (!table) return;
        var rows = table.querySelectorAll('tr');
        var visible = 0;
        for (var i = 1; i < rows.length; i++) {
            var cells = rows[i].querySelectorAll('td');
            if (!cells.length) continue;
            // cols: 0=ID, 1=RegNo, 2=Make, 3=Model, 4=Rate, 5=Date, 6=Seats, 7=Status, 8=Actions
            var text = '';
            for (var c = 0; c <= 7; c++) text += (cells[c] ? cells[c].textContent : '') + ' ';
            var match = !q || text.toLowerCase().indexOf(q) !== -1;
            rows[i].style.display = match ? '' : 'none';
            if (match) visible++;
        }
        if (countEl) countEl.textContent = q ? visible + ' vehicle' + (visible !== 1 ? 's' : '') + ' found' : '';
    }

    // ── Column sort ───────────────────────────────────────────────────────
    // Attaches click handlers to all <th> cells after the grid renders.
    var _vehSortCol = -1, _vehSortAsc = true;
    document.addEventListener('DOMContentLoaded', function () {
        var table = document.querySelector('.dn-table');
        if (!table) return;
        var ths = table.querySelectorAll('th');
        ths.forEach(function (th, idx) {
            th.style.cursor = 'pointer';
            th.title = 'Click to sort';
            th.addEventListener('click', function () {
                sortVehicleTable(idx);
            });
        });
    });
    function sortVehicleTable(col) {
        var table = document.querySelector('.dn-table');
        if (!table) return;
        var asc = (_vehSortCol === col) ? !_vehSortAsc : true;
        _vehSortCol = col; _vehSortAsc = asc;
        var tbody = table.querySelector('tbody') || table;
        var rows  = Array.prototype.slice.call(table.querySelectorAll('tr')).slice(1);
        rows.sort(function (a, b) {
            var ca = a.querySelectorAll('td')[col];
            var cb = b.querySelectorAll('td')[col];
            var ta = ca ? ca.textContent.trim() : '';
            var tb = cb ? cb.textContent.trim() : '';
            // Numeric sort for rate / seats columns
            var na = parseFloat(ta.replace(/[^0-9.]/g, ''));
            var nb = parseFloat(tb.replace(/[^0-9.]/g, ''));
            var cmp = (!isNaN(na) && !isNaN(nb)) ? (na - nb) : ta.localeCompare(tb);
            return asc ? cmp : -cmp;
        });
        rows.forEach(function (r) { tbody.appendChild(r); });
        // Update sort arrow indicators
        var ths = table.querySelectorAll('th');
        ths.forEach(function (th, i) {
            th.textContent = th.textContent.replace(/ [▲▼]$/, '');
            if (i === col) th.textContent += asc ? ' ▲' : ' ▼';
        });
    }

    // Called when the user picks a currency — converts all prices on screen without a page reload
    function convertVehiclePrices(code) {
        var rate   = V_RATES[code]   || 1;
        var sym    = V_SYMBOLS[code] || code;
        var prefix = V_PREFIX[code]  !== false;

        // Loop through every price cell and recalculate using the stored GBP base value
        document.querySelectorAll('.veh-price').forEach(function(el) {
            var base = parseFloat(el.getAttribute('data-gbp'));
            var amt  = (base * rate).toFixed(2);
            el.querySelector('.price-sym').textContent = prefix ? sym : '';
            el.querySelector('.price-val').textContent = prefix ? amt : (amt + ' ' + sym);
        });

        // Also update the Average Daily Rate stat card using the hidden GBP value
        var hfEl  = document.getElementById('<%= hfAvgRateGbp.ClientID %>');
        var statEl = document.getElementById('<%= lblAvgRate.ClientID %>');
        if (hfEl && statEl) {
            var baseAvg   = parseFloat(hfEl.value) || 0;
            var converted = (baseAvg * rate).toFixed(2);
            statEl.textContent = prefix ? (sym + converted) : (converted + ' ' + sym);
        }
    }
</script>
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
