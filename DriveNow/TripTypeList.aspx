<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripTypeList.aspx.cs" Inherits="DriveNow.TripTypeList" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Trip Type List</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripTypeList" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"     class="dn-nav-item"><span class="dn-nav-icon">⬛</span>Dashboard</a>
            <a href="TripList.aspx"     class="dn-nav-item"><span class="dn-nav-icon">🛣</span>Trips</a>
            <a href="TripTypeList.aspx" class="dn-nav-item active"><span class="dn-nav-icon">🏷</span>Trip Types</a>
            <div class="dn-nav-label">Team</div>
            <a href="#" class="dn-nav-item"><span class="dn-nav-icon">👤</span>Users</a>
            <a href="#" class="dn-nav-item"><span class="dn-nav-icon">🚗</span>Drivers</a>
            <a href="#" class="dn-nav-item"><span class="dn-nav-icon">🚙</span>Vehicles</a>
            <a href="#" class="dn-nav-item"><span class="dn-nav-icon">📝</span>Contributors</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div class="dn-sidebar-user">
                <div class="dn-sidebar-avatar">A</div>
                <div><div class="dn-sidebar-name">Admin</div><div class="dn-sidebar-role">Staff Portal</div></div>
            </div>
            <a href="Logout.aspx" class="dn-sidebar-logout">↩ Log out</a>
        </div>
    </div>

    <!-- MAIN -->
    <div class="dn-main">
        <div class="dn-topbar">
            <div class="dn-topbar-title">Trip Type Catalogue</div>
            <div class="dn-topbar-right">
                <a href="MainMenu.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Dashboard</a>
                <a href="TripTypeAdd.aspx" class="dn-btn dn-btn-primary dn-btn-sm">+ Add Trip Type</a>
            </div>
        </div>

        <div class="dn-content">

            <!-- Error message -->
            <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false" />

            <!-- Section header -->
            <div class="dn-section-head">
                <div class="dn-section-title">All Trip Types</div>
            </div>

            <!-- Trip Types GridView -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvTripTypes" runat="server"
                    AutoGenerateColumns="false"
                    DataKeyNames="TripTypeID"
                    OnRowCommand="gvTripTypes_RowCommand"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No trip types found.">
                    <Columns>
                        <asp:BoundField DataField="TripTypeID"  HeaderText="ID" />
                        <asp:BoundField DataField="TypeName"    HeaderText="Type Name" />
                        <asp:BoundField DataField="Description" HeaderText="Description" />
                        <asp:BoundField DataField="BaseRate"    HeaderText="Base Rate" DataFormatString="{0:F2}" />
                        <asp:BoundField DataField="CreatedDate" HeaderText="Created"   DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class="dn-status">
                                    <span class='dn-dot <%# (bool)Eval("IsActive") ? "dn-dot-green" : "dn-dot-red" %>'></span>
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="EditType"
                                    CommandArgument='<%# Eval("TripTypeID") %>'
                                    CssClass="dn-action-edit">Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteType"
                                    CommandArgument='<%# Eval("TripTypeID") %>'
                                    CssClass="dn-action-del"
                                    OnClientClick="return confirm('Soft delete this trip type?');">Delete</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
        <div class="dn-footer">DriveNow Admin System &nbsp;·&nbsp; CTEC2713N &nbsp;·&nbsp; Niels Brock Copenhagen</div>
    </div>

</div>
</form>
</body>
</html>
