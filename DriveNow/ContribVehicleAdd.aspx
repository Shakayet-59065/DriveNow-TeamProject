<%-- 
    Page: ContribVehicleAdd.aspx
    Developer: Ushna
    Component: Contributor Applications
    Purpose: Form for adding a new vehicle record linked to an
             existing contributor. ContributorID passed via
             query string (?id=). Validates all inputs before
             writing to tblContribVehicle.
--%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContribVehicleAdd.aspx.cs" Inherits="DriveNow.AddContribVehicle" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Add Contributor Vehicle</title>
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
                        <span class="dn-nav-icon">⌂</span> Main Menu
                    </a>
                    <div class="dn-nav-label">Contributors</div>
                    <a href="ContributorList.aspx" class="dn-nav-item active">
                        <span class="dn-nav-icon">☰</span> List Contributors
                    </a>
                    <a href="ContributorAdd.aspx" class="dn-nav-item">
                        <span class="dn-nav-icon">+</span> Add Contributor
                    </a>
                    <a href="ContributorFind.aspx" class="dn-nav-item">
                        <span class="dn-nav-icon">🔍</span> Find Contributor
                    </a>
                    <a href="ContributorFilter.aspx" class="dn-nav-item">
                        <span class="dn-nav-icon">⚡</span> Filter Contributors
                    </a>
                    <div class="dn-nav-label">Team</div>
                    <a href="#" class="dn-nav-item">
                        <span class="dn-nav-icon">🚗</span> Trip Records
                    </a>
                    <a href="#" class="dn-nav-item">
                        <span class="dn-nav-icon">👤</span> Customers
                    </a>
                    <a href="#" class="dn-nav-item">
                        <span class="dn-nav-icon">🚘</span> Vehicles
                    </a>
                    <a href="#" class="dn-nav-item">
                        <span class="dn-nav-icon">🧑</span> Drivers
                    </a>
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
                    <div class="dn-topbar-title">Add Contributor Vehicle</div>
                    <div class="dn-topbar-right">
                        <asp:HyperLink ID="hlBack" runat="server"
                            CssClass="dn-btn dn-btn-secondary dn-btn-sm">
                            ← Back to Vehicles
                        </asp:HyperLink>
                    </div>
                </div>

                <!-- CONTENT -->
                <div class="dn-content">

                    <div class="dn-page-header">
                        <div>
                            <div class="dn-page-title">Add New Vehicle</div>
                            <div class="dn-page-sub">
                                Linking vehicle to contributor:
                                <asp:Label ID="lblContributorID" runat="server" />
                            </div>
                        </div>
                    </div>

                    <%-- Message label --%>
                    <asp:Label ID="lblMessage" runat="server" Visible="false" />

                    <div class="dn-form-card">

                        <div class="dn-field">
                            <label class="dn-label">Make <span class="required">*</span></label>
                            <asp:TextBox ID="txtMake" runat="server"
                                CssClass="dn-input" MaxLength="50"
                                placeholder="e.g. Toyota" />
                            <asp:RequiredFieldValidator ID="rfvMake" runat="server"
                                ControlToValidate="txtMake"
                                ErrorMessage="Vehicle make is required."
                                CssClass="dn-hint" Display="Dynamic" />
                        </div>

                        <div class="dn-field">
                            <label class="dn-label">Model <span class="required">*</span></label>
                            <asp:TextBox ID="txtModel" runat="server"
                                CssClass="dn-input" MaxLength="50"
                                placeholder="e.g. Corolla" />
                            <asp:RequiredFieldValidator ID="rfvModel" runat="server"
                                ControlToValidate="txtModel"
                                ErrorMessage="Vehicle model is required."
                                CssClass="dn-hint" Display="Dynamic" />
                        </div>

                        <div class="dn-field">
                            <label class="dn-label">Year <span class="required">*</span></label>
                            <asp:TextBox ID="txtYear" runat="server"
                                CssClass="dn-input" MaxLength="4"
                                placeholder="e.g. 2020" />
                            <asp:RequiredFieldValidator ID="rfvYear" runat="server"
                                ControlToValidate="txtYear"
                                ErrorMessage="Year is required."
                                CssClass="dn-hint" Display="Dynamic" />
                            <asp:RangeValidator ID="rvYear" runat="server"
                                ControlToValidate="txtYear"
                                MinimumValue="1990" MaximumValue="2100"
                                Type="Integer"
                                ErrorMessage="Year must be between 1990 and 2100."
                                CssClass="dn-hint" Display="Dynamic" />
                        </div>

                        <div class="dn-field">
                            <label class="dn-label">Registration Number <span class="required">*</span></label>
                            <asp:TextBox ID="txtRegistrationNo" runat="server"
                                CssClass="dn-input" MaxLength="20"
                                placeholder="e.g. AB19 XYZ" />
                            <asp:RequiredFieldValidator ID="rfvRegistrationNo" runat="server"
                                ControlToValidate="txtRegistrationNo"
                                ErrorMessage="Registration number is required."
                                CssClass="dn-hint" Display="Dynamic" />
                        </div>

                        <div class="dn-form-actions">
                            <asp:Button ID="btnSave" runat="server" Text="Save Vehicle"
                                CssClass="dn-btn dn-btn-primary"
                                OnClick="btnSave_Click" />
                            <asp:HyperLink ID="hlCancel" runat="server"
                                CssClass="dn-btn dn-btn-secondary">Cancel</asp:HyperLink>
                        </div>

                    </div>
                </div>
                <div class="dn-footer">DriveNow Admin System · CTEC2713N · Niels Brock Copenhagen</div>
            </div>
        </div>
    </form>
</body>
</html>