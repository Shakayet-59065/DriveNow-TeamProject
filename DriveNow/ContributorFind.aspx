<%-- 
    Page: ContributorFind.aspx
    Developer: Ushna
    Component: Contributor Applications
    Purpose: Allows staff to search for a specific contributor
             by ContributorID or full name (partial match).
             Displays the matching record in a result card.
--%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContributorFind.aspx.cs" Inherits="DriveNow.FindContributor" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Find Contributor</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="dn-shell">

            <!-- SIDEBAR -->
            <div class="dn-sidebar">
                <div class="dn-sidebar-logo">
                    <img src="Content/logo.png" alt="DriveNow" />
                </div>
                <nav class="dn-sidebar-nav">
                    <div class="dn-nav-label">Main</div>
                    <a href="MainMenu.aspx" class="dn-nav-item">
                         Main Menu
                    </a>
                    <div class="dn-nav-label">Contributors</div>
                    <a href="ContributorList.aspx" class="dn-nav-item">
                         List Contributors
                    </a>
                    <a href="ContributorAdd.aspx" class="dn-nav-item">
                         Add Contributor
                    </a>
                    <a href="ContributorFind.aspx" class="dn-nav-item active">
                         Find Contributor
                    </a>
                    <a href="ContributorFilter.aspx" class="dn-nav-item">
                         Filter Contributors
                    </a>
                    <div class="dn-nav-label">Team</div>
                    <a href="TripList.aspx" class="dn-nav-item">
                         Trip Records
                    </a>
                    <a href="CustomerList.aspx" class="dn-nav-item">
                         Customers
                    </a>
                    <a href="VehicleList.aspx" class="dn-nav-item">
                         Vehicles
                    </a>
                    <a href="DriverList.aspx" class="dn-nav-item">
                         Drivers
                    </a>
                    <div class="dn-nav-label">ADMIN</div>
                    <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
                </nav>
                <div class="dn-sidebar-footer">
                    <div class="dn-sidebar-user">
                        <div class="dn-sidebar-avatar">U</div>
                        <div>
                            <div class="dn-sidebar-name">Ushna</div>
                            <div class="dn-sidebar-role">Contributor Applications</div>
                        </div>
                    </div>
                    <a href="Logout.aspx" class="dn-sidebar-logout">⏻ Logout</a>
                </div>
            </div>

            <!-- MAIN -->
            <div class="dn-main">

                <!-- TOPBAR -->
                <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
                    <div class="dn-topbar-title">Find Contributor</div>
                    <div class="dn-topbar-right">
                        <a href="ContributorList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Back to List</a>
                    </div>
                </div>

                <!-- CONTENT -->
                <div class="dn-content">

                    <div class="dn-page-header">
                        <div>
                            <div class="dn-page-title">Find a Contributor</div>
                            <div class="dn-page-sub">Search by ID or full name</div>
                        </div>
                    </div>

                    <%-- Error message --%>
                    <asp:Label ID="lblMessage" runat="server" Visible="false" />

                    <%-- Search inputs --%>
                    <div class="dn-form-card" style="margin-bottom:20px;">
                        <div class="dn-search-row">
                            <div style="flex:1;">
                                <label class="dn-label">Contributor ID</label>
                                <asp:TextBox ID="txtContributorID" runat="server"
                                    CssClass="dn-input" placeholder="e.g. 3" />
                            </div>
                            <div style="flex:2;">
                                <label class="dn-label">Full Name</label>
                                <asp:TextBox ID="txtFullName" runat="server"
                                    CssClass="dn-input" placeholder="e.g. Ahmed" />
                            </div>
                            <div style="align-self:flex-end;">
                                <asp:Button ID="btnSearch" runat="server" Text="Search"
                                    CssClass="dn-btn dn-btn-primary"
                                    OnClick="btnSearch_Click" />
                            </div>
                        </div>
                        <div class="dn-hint" style="margin-top:8px;">
                            Enter an ID, a name, or both. Leave both blank to show all records.
                        </div>
                    </div>

                    <%-- Results table --%>
                    <asp:Panel ID="pnlResults" runat="server" Visible="false">
                        <div class="dn-section-head">
                            <div class="dn-section-title">
                                Search Results —
                                <asp:Label ID="lblResultCount" runat="server" />
                            </div>
                        </div>
                        <div class="dn-table-wrap">
                            <asp:GridView ID="gvResults" runat="server"
                                AutoGenerateColumns="false"
                                DataKeyNames="ContributorID"
                                EmptyDataText="No contributors found matching your search."
                                CssClass="dn-table"
                                GridLines="None">
                                <Columns>
                                    <asp:TemplateField HeaderText="ID">
                                        <ItemTemplate>
                                            <span class="dn-trip-id">#CON-<%# DataBinder.Eval(Container.DataItem, "ContributorID") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="FullName"        HeaderText="Full Name" />
                                    <asp:BoundField DataField="Email"           HeaderText="Email"     />
                                    <asp:BoundField DataField="Phone"           HeaderText="Phone"     />
                                    <asp:TemplateField HeaderText="Type">
                                        <ItemTemplate>
                                            <span class="dn-type-pill"><%# DataBinder.Eval(Container.DataItem, "ContributorType") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="ApplicationDate" HeaderText="Date Applied"
                                        DataFormatString="{0:dd/MM/yyyy}" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <%# Convert.ToBoolean(DataBinder.Eval(Container.DataItem, "IsApproved"))
                                                ? "<span class='dn-status'><span class='dn-dot dn-dot-green'></span> Approved</span>"
                                                : "<span class='dn-status'><span class='dn-dot dn-dot-amber'></span> Pending</span>" %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <asp:Button ID="btnEdit" runat="server" Text="Edit"
                                                CssClass="dn-action-edit"
                                                CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                                OnClick="btnEdit_Click" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </asp:Panel>

                </div>
                <div class="dn-footer">DriveNow Admin System · CTEC2713N · Niels Brock Copenhagen</div>
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



