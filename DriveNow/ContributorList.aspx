<%--
    Page: ContributorList.aspx
    Developer: Ushna
    Component: Contributor Applications
    Purpose: Displays all contributor application records from tblContributor.
             Staff can edit, soft-delete, or permanently delete (GDPR consent modal).
             Vehicles button only shown for VehicleOwner contributors.
--%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContributorList.aspx.cs" Inherits="DriveNow.ListContributors" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Contributor Applications</title>
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

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo">
            <img src="Content/logo.png" alt="DriveNow" />
        </div>

        <!-- Current module indicator -->
        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Contributor Dashboard</div>
        </div>

        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>

            <div class="dn-nav-label">NAVIGATE</div>
            <a href="TripList.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
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

    <!-- MAIN PANEL -->
    <div class="dn-main">

        <!-- TOPBAR -->
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Contributor Applications</span>
                <span class="dn-page-sub">Manage all DriveNow contributor records</span>
            </div>
            <div class="dn-topbar-right">
                <span class="dn-topbar-date"><asp:Label ID="lblDate" runat="server" /></span>
                <a href="ContributorAdd.aspx"    class="dn-btn dn-btn-primary dn-btn-sm">+ Add Contributor</a>
                <a href="ContributorFind.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">Find</a>
                <a href="ContributorFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
                <asp:Button ID="btnExportCsv" runat="server" Text="⬇ Export CSV"
                    CssClass="dn-btn dn-btn-secondary dn-btn-sm"
                    OnClick="btnExportCsv_Click" CausesValidation="false"
                    ToolTip="Download all contributor applications as a CSV file (opens in Excel)" />
            </div>
        </div>

        <!-- CONTENT -->
        <div class="dn-content">

            <!-- Stat cards -->
            <div class="dn-stats">
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblTotalCount"    runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Total Applications</div>
                </div>
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblApprovedCount" runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Approved</div>
                </div>
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblPendingCount"  runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Pending</div>
                </div>
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblDriverCount"   runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Drivers</div>
                </div>
            </div>

            <asp:Label ID="lblError" runat="server" Visible="false" />

            <!-- Status tabs -->
            <div class="dn-pills" style="margin-bottom:14px;">
                <a href="ContributorList.aspx"              class='<%= TabCss("all") %>'>All</a>
                <a href="ContributorList.aspx?tab=approved" class='<%= TabCss("approved") %>'>Approved</a>
                <a href="ContributorList.aspx?tab=pending"  class='<%= TabCss("pending") %>'>Pending</a>
            </div>

            <!-- Section header — title only, no duplicate buttons -->
            <div class="dn-section-head">
                <div class="dn-section-title">All Contributor Records</div>
            </div>

            <!-- Search bar — client-side filter by ID, Name, Email, Phone, Type -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;flex-wrap:wrap;">
                <span class="material-symbols-outlined" style="font-size:18px;color:#64748b;">search</span>
                <input type="text" id="contribSearch" placeholder="Search by ID, Name, Email, Phone, Type…"
                    oninput="filterContribTable(this.value)"
                    style="border:1px solid #e2e8f0;border-radius:7px;padding:.45rem .9rem;font-size:.88rem;color:#0f172a;background:#fff;width:340px;outline:none;"
                    onfocus="this.style.borderColor='#0d9488'" onblur="this.style.borderColor='#e2e8f0'" />
                <button type="button" onclick="document.getElementById('contribSearch').value='';filterContribTable('');"
                    style="background:transparent;border:none;color:#94a3b8;cursor:pointer;font-size:.85rem;padding:.45rem .5rem;"
                    title="Clear search">&#10005;</button>
                <span id="contribSearchCount" style="font-size:.78rem;color:#64748b;"></span>
                <span style="font-size:.72rem;color:#94a3b8;">· Click any column header to sort</span>
            </div>

            <!-- Table -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvContributors" runat="server"
                    AutoGenerateColumns="false"
                    DataKeyNames="ContributorID"
                    EmptyDataText="No contributor records found."
                    CssClass="dn-table"
                    GridLines="None">
                    <Columns>
                        <asp:TemplateField HeaderText="ID">
                            <ItemTemplate>
                                <span class="dn-trip-id">#CON-<%# DataBinder.Eval(Container.DataItem, "ContributorID") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="FullName"        HeaderText="Full Name" />
                        <asp:BoundField DataField="Email"           HeaderText="Email" />
                        <asp:BoundField DataField="Phone"           HeaderText="Phone" />
                        <asp:TemplateField HeaderText="Type">
                            <ItemTemplate>
                                <span class="dn-type-pill"><%# DataBinder.Eval(Container.DataItem, "ContributorType") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="ApplicationDate" HeaderText="Date Applied" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(DataBinder.Eval(Container.DataItem, "IsApproved"))
                                    ? "<span class='dn-status'><span class='dn-dot dn-dot-green'></span> Approved</span>"
                                    : "<span class='dn-status'><span class='dn-dot dn-dot-amber'></span> Pending</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <%-- View button — opens full application detail page --%>
                                <asp:Button ID="btnView" runat="server" Text="View"
                                    CssClass="dn-action-edit"
                                    CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                    OnClick="btnView_Click" />
                                <%-- Approve button — only visible for pending (IsApproved=false) --%>
                                <asp:Button ID="btnApprove" runat="server" Text="&#10003; Approve"
                                    CssClass="dn-action-edit"
                                    CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                    OnClick="btnApprove_Click"
                                    Visible='<%# !Convert.ToBoolean(DataBinder.Eval(Container.DataItem, "IsApproved")) %>'
                                    OnClientClick="return confirm('Approve this contributor application? Use the View page for a full approve-and-promote action.');" />
                                <asp:Button ID="btnEdit" runat="server" Text="Edit"
                                    CssClass="dn-action-edit"
                                    CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                    OnClick="btnEdit_Click" />
                                <asp:Button ID="btnDelete" runat="server" Text="Deactivate"
                                    CssClass="dn-action-del"
                                    CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                    OnClick="btnDelete_Click"
                                    OnClientClick="return confirm('Deactivate this contributor? The record is kept in the database.');" />
                                <asp:Button ID="btnHardDelete" runat="server" Text="Perm. Delete"
                                    CssClass="dn-action-perm-del"
                                    CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                    OnClick="btnHardDelete_Click"
                                    OnClientClick='<%# "return openRetentionModal(" + DataBinder.Eval(Container.DataItem, "ContributorID") + ");" %>' />
                                <asp:Button ID="btnVehicles" runat="server" Text="Vehicles"
                                    CssClass="dn-action-edit"
                                    CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                    OnClick="btnVehicles_Click"
                                    ToolTip="View vehicles registered to this VehicleOwner contributor"
                                    Visible='<%# DataBinder.Eval(Container.DataItem, "ContributorType").ToString() == "VehicleOwner" || DataBinder.Eval(Container.DataItem, "ContributorType").ToString() == "OwnerDriver" %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
        <div class="dn-footer">DriveNow Admin &middot; CTEC2713N &middot; Niels Brock Copenhagen</div>
    </div>
</div>

<!-- Hidden fields for permanent delete retention consent -->
<asp:HiddenField ID="hfHardDeleteID"     runat="server" Value="0" />
<asp:HiddenField ID="hfRetentionMonths"  runat="server" Value="0" />
<asp:HiddenField ID="hfConsentConfirmed" runat="server" Value="0" />

<!-- Hidden button triggered by JS after modal consent -->
<asp:Button ID="btnConfirmHardDelete" runat="server"
    style="display:none;"
    OnClick="btnConfirmHardDelete_Click"
    CausesValidation="false" />

<!-- Data Retention Consent Modal (GDPR) -->
<div id="retentionModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,.55);z-index:9999;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:12px;padding:32px;max-width:480px;width:90%;box-shadow:0 20px 60px rgba(0,0,0,.3);">
        <h3 style="font-size:17px;font-weight:700;color:#0f172a;margin:0 0 8px;">Permanent Delete — Data Retention Consent</h3>
        <p style="font-size:13px;color:#475569;margin-bottom:16px;line-height:1.6;">
            This will <strong>permanently remove</strong> the contributor record from the database.
            Please confirm how long data should be retained in backup archives for compliance.
        </p>
        <div style="background:#fef2f2;border:1px solid #fecaca;border-radius:8px;padding:12px 16px;margin-bottom:16px;font-size:12.5px;color:#991b1b;">
            <strong>Warning:</strong> This cannot be undone. Linked vehicle records will also be permanently deleted.
        </div>
        <div style="margin-bottom:18px;">
            <label style="font-size:13px;font-weight:600;color:#374151;display:block;margin-bottom:10px;">Data retention period (backup archives):</label>
            <label style="display:flex;align-items:center;gap:10px;font-size:13px;color:#0f172a;cursor:pointer;margin-bottom:8px;">
                <input type="radio" name="retentionChoice" value="3" style="accent-color:#0d9488;" />
                3 months &mdash; minimum compliance period
            </label>
            <label style="display:flex;align-items:center;gap:10px;font-size:13px;color:#0f172a;cursor:pointer;">
                <input type="radio" name="retentionChoice" value="6" style="accent-color:#0d9488;" />
                6 months &mdash; extended retention for audit trail
            </label>
        </div>
        <div style="background:#f0fdfa;border:1px solid #99f6e4;border-radius:8px;padding:12px 16px;margin-bottom:20px;font-size:12px;color:#065f46;">
            By clicking <strong>Confirm Permanent Delete</strong>, you consent to the data being
            retained in backup archives for the selected period before full erasure.
        </div>
        <div style="display:flex;gap:10px;justify-content:flex-end;">
            <button type="button" onclick="closeRetentionModal()"
                style="padding:8px 20px;border:1px solid #e2e8f0;border-radius:22px;background:#fff;color:#475569;font-size:13px;cursor:pointer;">
                Cancel
            </button>
            <button type="button" onclick="confirmHardDelete()"
                style="padding:8px 20px;border:none;border-radius:22px;background:#ef4444;color:#fff;font-size:13px;font-weight:600;cursor:pointer;">
                Confirm Permanent Delete
            </button>
        </div>
    </div>
</div>

</form>

<script>
    function openRetentionModal(id) {
        document.getElementById('<%= hfHardDeleteID.ClientID %>').value = id;
        document.getElementById('retentionModal').style.display = 'flex';
        return false;
    }
    function closeRetentionModal() {
        document.getElementById('retentionModal').style.display = 'none';
    }
    function confirmHardDelete() {
        var chosen = document.querySelector('input[name="retentionChoice"]:checked');
        if (!chosen) {
            alert('Please select a data retention period before confirming.');
            return;
        }
        document.getElementById('<%= hfRetentionMonths.ClientID %>').value  = chosen.value;
        document.getElementById('<%= hfConsentConfirmed.ClientID %>').value = '1';
        document.getElementById('retentionModal').style.display = 'none';
        document.getElementById('<%= btnConfirmHardDelete.ClientID %>').click();
    }
</script>

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

    /* ── Live search — ID, Name, Email, Phone, Type, Status ─── */
    function filterContribTable(q) {
        q = (q || '').trim().toLowerCase();
        var table   = document.querySelector('.dn-table');
        var countEl = document.getElementById('contribSearchCount');
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
        if (countEl) countEl.textContent = q ? visible + ' contributor' + (visible !== 1 ? 's' : '') + ' found' : '';
    }

    /* ── Column sort ─────────────────────────────────────────── */
    var _cSortCol = -1, _cSortAsc = true;
    document.addEventListener('DOMContentLoaded', function () {
        var table = document.querySelector('.dn-table');
        if (!table) return;
        table.querySelectorAll('th').forEach(function (th, idx) {
            th.style.cursor = 'pointer';
            th.title = 'Click to sort';
            th.addEventListener('click', function () { sortContribTable(idx); });
        });
    });
    function sortContribTable(col) {
        var table = document.querySelector('.dn-table');
        if (!table) return;
        var asc = (_cSortCol === col) ? !_cSortAsc : true;
        _cSortCol = col; _cSortAsc = asc;
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


