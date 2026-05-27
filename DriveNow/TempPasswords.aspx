<%--
    Page:      TempPasswords.aspx
    Module:    Admin — Customer Password Resets
    Purpose:   Displays all customer forgot-password requests from
               tblPasswordResetRequest.  Admin can issue a system-generated
               temporary password for any pending request.  The generated
               password is displayed prominently so the admin can communicate
               it to the customer by phone or e-mail.
               Once the customer logs in with the temp password the request
               is automatically marked Resolved and the plain-text value
               is removed from the database.
--%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TempPasswords.aspx.cs" Inherits="DriveNow.TempPasswords" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Temporary Passwords</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        /* Sidebar module label */
        .dn-sidebar-module { padding:14px 20px 10px; border-bottom:1px solid rgba(255,255,255,.07); margin-bottom:6px; }
        .dn-sidebar-module-label { font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:#14b8a6;margin-bottom:4px; }
        .dn-sidebar-module-title { font-size:15px;font-weight:700;color:#fff; }

        /* Issued-password highlight panel */
        .dn-temp-issued {
            background:#f0fdf4;
            border:2px solid #22c55e;
            border-radius:12px;
            padding:20px 24px;
            margin-bottom:20px;
        }
        .dn-temp-issued h3 { font-size:15px; font-weight:700; color:#166534; margin:0 0 6px; }
        .dn-temp-issued .dn-pw-display {
            font-family: 'Courier New', monospace;
            font-size:22px;
            font-weight:700;
            letter-spacing:.15em;
            color:#0f172a;
            background:#fff;
            border:2px solid #22c55e;
            border-radius:8px;
            padding:10px 20px;
            display:inline-block;
            margin:8px 0;
        }
        .dn-temp-issued p { font-size:13px; color:#15803d; margin:4px 0 0; }

        /* Status pill for requests */
        .dn-status-pending  { background:#fef3c7; color:#92400e; padding:3px 10px; border-radius:20px; font-size:11px; font-weight:600; }
        .dn-status-issued   { background:#dbeafe; color:#1e40af; padding:3px 10px; border-radius:20px; font-size:11px; font-weight:600; }
        .dn-status-resolved { background:#dcfce7; color:#166534; padding:3px 10px; border-radius:20px; font-size:11px; font-weight:600; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">

    <!-- ── SIDEBAR ──────────────────────────────────────────── -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo">
            <img src="Content/logo.png" alt="DriveNow" />
        </div>

        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Admin Dashboard</div>
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
            <a href="TempPasswords.aspx" class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
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

    <!-- ── MAIN PANEL ───────────────────────────────────────── -->
    <div class="dn-main">

        <!-- Top bar -->
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Temporary Passwords</span>
                <span class="dn-page-sub">Manage customer password reset requests</span>
            </div>
        </div>

        <div class="dn-content">

            <!-- Issued password confirmation panel -->
            <asp:Panel ID="pnlIssuedPassword" runat="server" Visible="false">
                <div class="dn-temp-issued">
                    <h3>&#10003; Temporary Password Issued</h3>
                    <div>Customer: <strong><asp:Label ID="lblIssuedName"  runat="server" /></strong>
                         &nbsp;|&nbsp; Email: <strong><asp:Label ID="lblIssuedEmail" runat="server" /></strong></div>
                    <div class="dn-pw-display"><asp:Label ID="lblIssuedPw" runat="server" /></div>
                    <p>&#9888; This password is shown once. Please communicate it to the customer now.<br />
                       It will be removed from this screen the next time this page is loaded.</p>
                </div>
            </asp:Panel>

            <!-- General alert label -->
            <asp:Label ID="lblMessage" runat="server" Visible="false" />

            <!-- Stat cards -->
            <div class="dn-stats">
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblTotal"    runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Total Requests</div>
                </div>
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblPending"  runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Pending</div>
                </div>
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblIssued"   runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Temp Issued</div>
                </div>
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblResolved" runat="server" Text="0" /></div>
                    <div class="dn-stat-label">Resolved</div>
                </div>
            </div>

            <!-- Section header -->
            <div class="dn-section-head">
                <div class="dn-section-title">Password Reset Requests</div>
            </div>

            <!-- Requests grid -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvRequests" runat="server"
                    AutoGenerateColumns="false"
                    EmptyDataText="No password reset requests found."
                    CssClass="dn-table"
                    GridLines="None"
                    OnRowCommand="gvRequests_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="ID">
                            <ItemTemplate>
                                <span class="dn-trip-id">#PWD-<%# string.Format("{0:D3}", Eval("RequestID")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="FullName"    HeaderText="Customer" />
                        <asp:BoundField DataField="Email"       HeaderText="Email" />
                        <asp:BoundField DataField="Phone"       HeaderText="Phone" />

                        <asp:BoundField DataField="RequestDate" HeaderText="Requested"
                            DataFormatString="{0:dd MMM yyyy HH:mm}" />

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# GetStatusBadge(
                                        Convert.ToBoolean(Eval("IsResolved")),
                                        Convert.ToBoolean(Eval("IsIssued"))) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Temp Password">
                            <ItemTemplate>
                                <%# Eval("TempPasswordDisplay") != DBNull.Value && !string.IsNullOrEmpty(Eval("TempPasswordDisplay").ToString())
                                    ? "<span style=\"font-family:monospace;font-weight:700;color:#1e40af;letter-spacing:.08em;\">"
                                        + Eval("TempPasswordDisplay") + "</span>"
                                    : "<span style=\"color:#94a3b8;\">—</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <%-- Issue button: visible only for pending or re-issue for expired --%>
                                <asp:LinkButton runat="server"
                                    CommandName="IssueTempPw"
                                    CommandArgument='<%# Eval("RequestID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsResolved")) %>'
                                    OnClientClick="return confirm('Issue a new temporary password for this customer?');">
                                    <%# Convert.ToBoolean(Eval("IsIssued")) ? "Re-issue" : "Issue Temp Password" %>
                                </asp:LinkButton>
                                <%-- Resolved marker --%>
                                <asp:LinkButton runat="server"
                                    CommandName="dummy"
                                    CssClass="dn-action-edit"
                                    Visible='<%# Convert.ToBoolean(Eval("IsResolved")) %>'
                                    Enabled="false"
                                    style="opacity:.45;cursor:default;">
                                    &#10003; Resolved
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- ── STAFF RESET REQUESTS ─────────────────────────────── -->
            <div class="dn-section-head" style="margin-top:2rem;">
                <div class="dn-section-title">Staff Password Reset Requests</div>
            </div>

            <!-- Staff issued-password confirmation panel -->
            <asp:Panel ID="pnlStaffIssuedPassword" runat="server" Visible="false">
                <div class="dn-temp-issued">
                    <h3>&#10003; Temporary Password Issued for Staff</h3>
                    <div>Staff Member: <strong><asp:Label ID="lblStaffIssuedName" runat="server" /></strong>
                         &nbsp;|&nbsp; Username: <strong><asp:Label ID="lblStaffIssuedUsername" runat="server" /></strong></div>
                    <div class="dn-pw-display"><asp:Label ID="lblStaffIssuedPw" runat="server" /></div>
                    <p>&#9888; Communicate this password to the staff member securely. It is shown once only.<br />
                       They will be required to set a new password on first login.</p>
                </div>
            </asp:Panel>

            <div class="dn-table-wrap">
                <asp:GridView ID="gvStaffRequests" runat="server"
                    AutoGenerateColumns="false"
                    EmptyDataText="No staff password reset requests found."
                    CssClass="dn-table"
                    GridLines="None"
                    OnRowCommand="gvStaffRequests_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="ID">
                            <ItemTemplate>
                                <span class="dn-trip-id">#SPWD-<%# string.Format("{0:D3}", Eval("ResetID")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="FullName"    HeaderText="Staff Member" />
                        <asp:BoundField DataField="Username"    HeaderText="Username" />
                        <asp:BoundField DataField="RequestDate" HeaderText="Requested" DataFormatString="{0:dd MMM yyyy HH:mm}" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# GetStatusBadge(Convert.ToBoolean(Eval("IsResolved")), Convert.ToBoolean(Eval("IsIssued"))) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Temp Password">
                            <ItemTemplate>
                                <%# Eval("TempPasswordDisplay") != DBNull.Value && !string.IsNullOrEmpty(Eval("TempPasswordDisplay").ToString())
                                    ? "<span style=\"font-family:monospace;font-weight:700;color:#1e40af;letter-spacing:.08em;\">" + Eval("TempPasswordDisplay") + "</span>"
                                    : "<span style=\"color:#94a3b8;\">—</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton runat="server"
                                    CommandName="IssueStaffTempPw"
                                    CommandArgument='<%# Eval("ResetID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsResolved")) %>'
                                    OnClientClick="return confirm('Issue a new temporary password for this staff member?');">
                                    <%# Convert.ToBoolean(Eval("IsIssued")) ? "Re-issue" : "Issue Temp Password" %>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="dummy" CssClass="dn-action-edit"
                                    Visible='<%# Convert.ToBoolean(Eval("IsResolved")) %>'
                                    Enabled="false" style="opacity:.45;cursor:default;">
                                    &#10003; Resolved
                                </asp:LinkButton>
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

