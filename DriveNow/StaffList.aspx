<%-- DriveNow — Staff Directory Page (StaffList.aspx)
     Admin-only page showing all staff accounts with toggle Active/Inactive and Add Staff actions.
     Only the super-admin (Role = Admin) can see this page — regular Staff are redirected away.
     Module: CTEC2713N | Developer: Musanna --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StaffList.aspx.cs" Inherits="DriveNow.StaffList" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Staff Directory</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        .dn-sidebar-module{padding:14px 20px 10px;border-bottom:1px solid rgba(255,255,255,.07);margin-bottom:6px;}
        .dn-sidebar-module-label{font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:#14b8a6;margin-bottom:4px;}
        .dn-sidebar-module-title{font-size:15px;font-weight:700;color:#fff;}
        .staff-avatar{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#0d9488,#1a2332);display:inline-flex;align-items:center;justify-content:center;font-size:.85rem;font-weight:700;color:#fff;flex-shrink:0;vertical-align:middle;margin-right:.5rem;}
        .role-pill{display:inline-block;padding:.15rem .6rem;border-radius:99px;font-size:.72rem;font-weight:700;border:1px solid;}
        .role-admin{background:rgba(239,68,68,.12);border-color:rgba(239,68,68,.3);color:#fca5a5;}
        .role-staff{background:rgba(13,148,136,.1);border-color:rgba(13,148,136,.25);color:#5eead4;}
    </style>
</head>
<body>
<form id="frmStaffList" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>

        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Staff Directory</div>
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
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>

            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx"   class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>

        <div class="dn-sidebar-footer">
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

    <!-- MAIN -->
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Staff Directory</span>
                <span class="dn-page-sub">All DriveNow staff members</span>
            </div>
            <div class="dn-topbar-right">
                <% if (IsAdmin) { %><a href="AddStaff.aspx" class="dn-btn dn-btn-primary dn-btn-sm">+ Add Staff</a><% } %>
                <a href="MainMenu.aspx"  class="dn-btn dn-btn-secondary dn-btn-sm">&#8592; Dashboard</a>
            </div>
        </div>

        <div class="dn-content">

            <!-- Status tabs -->
            <div class="dn-pills" style="margin-bottom:14px;">
                <a href="StaffList.aspx"              class='<%= TabCss("active") %>'>Active</a>
                <a href="StaffList.aspx?tab=inactive" class='<%= TabCss("inactive") %>'>Former</a>
            </div>

            <!-- Stat cards -->
            <div class="dn-stats" style="margin-bottom:1.2rem;">
                <div class="dn-stat dn-stat-3">
                    <div class="dn-stat-num"><asp:Label ID="lblTotalStaff"  runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Total Staff</div>
                </div>
                <div class="dn-stat dn-stat-3">
                    <div class="dn-stat-num"><asp:Label ID="lblActiveStaff" runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Active</div>
                </div>
                <div class="dn-stat dn-stat-3">
                    <div class="dn-stat-num"><asp:Label ID="lblFormerStaff" runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Former</div>
                </div>
            </div>

            <asp:Label ID="lblMessage" runat="server" Visible="false" />
            <% if (!IsAdmin) { %>
            <div style="background:rgba(251,191,36,.08);border:1px solid rgba(251,191,36,.2);border-radius:10px;padding:.8rem 1rem;font-size:.82rem;color:#fbbf24;margin-bottom:1rem;">
                &#9888; You are viewing staff records in read-only mode. Only Admin-level accounts can edit, add or deactivate staff members.
            </div>
            <% } %>

            <div class="dn-table-wrap">
                <asp:GridView ID="gvStaff" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No staff records found."
                    OnRowCommand="gvStaff_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="ID">
                            <ItemTemplate>
                                <span class="dn-trip-id">#STF-<%# string.Format("{0:D3}", Eval("StaffID")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Name">
                            <ItemTemplate>
                                <span class="staff-avatar"><%# GetInitial(Eval("FullName")) %></span>
                                <%# System.Web.HttpUtility.HtmlEncode(Eval("FullName").ToString()) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Username" HeaderText="Username" />
                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate>
                                <%# RenderRolePill(Eval("Role")) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Email">
                            <ItemTemplate>
                                <%# Eval("Email") == DBNull.Value || string.IsNullOrEmpty(Eval("Email").ToString())
                                    ? "<span style=\"color:#64748b;\">—</span>"
                                    : System.Web.HttpUtility.HtmlEncode(Eval("Email").ToString()) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Phone">
                            <ItemTemplate>
                                <%# Eval("Phone") == DBNull.Value || string.IsNullOrEmpty(Eval("Phone").ToString())
                                    ? "<span style=\"color:#64748b;\">—</span>"
                                    : System.Web.HttpUtility.HtmlEncode(Eval("Phone").ToString()) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# GetStatusBadge(Eval("IsActive")) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <%-- Edit: admin only --%>
                                <% if (IsAdmin) { %>
                                <a href='<%# "StaffEdit.aspx?id=" + Eval("StaffID") %>' class="dn-action-edit">Edit</a>
                                <asp:LinkButton runat="server" CommandName="ToggleActive"
                                    CommandArgument='<%# Eval("StaffID") %>'
                                    CssClass='<%# Convert.ToBoolean(Eval("IsActive") ?? true) ? "dn-action-del" : "dn-action-edit" %>'
                                    OnClientClick='<%# Convert.ToBoolean(Eval("IsActive") ?? true) ? "return confirm(\"Deactivate this staff member?\");" : "return confirm(\"Reactivate this staff member?\");" %>'>
                                    <%# Convert.ToBoolean(Eval("IsActive") ?? true) ? "Deactivate" : "Reactivate" %>
                                </asp:LinkButton>
                                <% } else { %>
                                <span style="color:#475569;font-size:.8rem;">View only</span>
                                <% } %>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <div class="dn-footer">DriveNow Admin &middot; CTEC2713N &middot; Niels Brock Copenhagen</div>
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
