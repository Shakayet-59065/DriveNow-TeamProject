<%-- 
    Page: ContributorEdit.aspx
    Developer: Ushna
    Component: Contributor Applications
    Purpose: Loads an existing contributor record by ContributorID
             passed in the query string (?id=). Staff can update
             all fields including approval status. Validates before save.
--%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContributorEdit.aspx.cs" Inherits="DriveNow.EditContributor" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Edit Contributor</title>
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
                    <div class="dn-topbar-title">Edit Contributor</div>
                    <div class="dn-topbar-right">
                        <a href="ContributorList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Back to List</a>
                    </div>
                </div>

                <!-- CONTENT -->
                <div class="dn-content">

                    <div class="dn-page-header">
                        <div>
                            <div class="dn-page-title">Edit Contributor Application</div>
                            <div class="dn-page-sub">
                                Editing record:
                                <asp:Label ID="lblContributorID" runat="server" />
                            </div>
                        </div>
                    </div>

                    <%-- Success or error message --%>
                    <asp:Label ID="lblMessage" runat="server" Visible="false" />

                    <div class="dn-form-card">

                        <div class="dn-field">
                            <label class="dn-label">Full Name <span class="required">*</span></label>
                            <asp:TextBox ID="txtFullName" runat="server"
                                CssClass="dn-input" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvFullName" runat="server"
                                ControlToValidate="txtFullName"
                                ErrorMessage="Full name is required."
                                CssClass="dn-hint" Display="Dynamic" />
                        </div>

                        <div class="dn-field">
                            <label class="dn-label">Email Address <span class="required">*</span></label>
                            <asp:TextBox ID="txtEmail" runat="server"
                                CssClass="dn-input" MaxLength="150" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ErrorMessage="Email address is required."
                                CssClass="dn-hint" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                ErrorMessage="Please enter a valid email address."
                                CssClass="dn-hint" Display="Dynamic" />
                        </div>

                        <div class="dn-field">
                            <label class="dn-label">Phone Number <span class="required">*</span></label>
                            <asp:TextBox ID="txtPhone" runat="server"
                                CssClass="dn-input" MaxLength="20" />
                            <asp:RequiredFieldValidator ID="rfvPhone" runat="server"
                                ControlToValidate="txtPhone"
                                ErrorMessage="Phone number is required."
                                CssClass="dn-hint" Display="Dynamic" />
                        </div>

                        <div class="dn-field">
                            <label class="dn-label">Contributor Type <span class="required">*</span></label>
                            <asp:DropDownList ID="ddlContributorType" runat="server" CssClass="dn-select">
                                <asp:ListItem Value="">-- Select Type --</asp:ListItem>
                                <asp:ListItem Value="Driver">Driver</asp:ListItem>
                                <asp:ListItem Value="VehicleOwner">VehicleOwner</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvContributorType" runat="server"
                                ControlToValidate="ddlContributorType"
                                InitialValue=""
                                ErrorMessage="Please select a contributor type."
                                CssClass="dn-hint" Display="Dynamic" />
                        </div>

                        <div class="dn-field">
                            <label class="dn-label">Application Date <span class="required">*</span></label>
                            <asp:TextBox ID="txtApplicationDate" runat="server"
                                CssClass="dn-input" TextMode="Date" />
                            <asp:RequiredFieldValidator ID="rfvApplicationDate" runat="server"
                                ControlToValidate="txtApplicationDate"
                                ErrorMessage="Application date is required."
                                CssClass="dn-hint" Display="Dynamic" />
                        </div>

                        <div class="dn-field">
                            <label class="dn-label">Approval Status</label>
                            <asp:DropDownList ID="ddlIsApproved" runat="server" CssClass="dn-select">
                                <asp:ListItem Value="false">Pending</asp:ListItem>
                                <asp:ListItem Value="true">Approved</asp:ListItem>
                            </asp:DropDownList>
                            <div class="dn-hint">Changing to Approved will activate this contributor.</div>
                        </div>

                        <div class="dn-form-actions">
                            <asp:Button ID="btnSave" runat="server" Text="Save Changes"
                                CssClass="dn-btn dn-btn-primary"
                                OnClick="btnSave_Click" />
                            <a href="ContributorList.aspx" class="dn-btn dn-btn-secondary">Cancel</a>
                        </div>

                    </div>
                </div>
                <div class="dn-footer">DriveNow Admin System · CTEC2713N · Niels Brock Copenhagen</div>
            </div>
        </div>
    </form>
</body>
</html>