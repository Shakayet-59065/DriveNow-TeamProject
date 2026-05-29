<%--
    Page: ContributorAdd.aspx  |  Developer: Ushna  |  Module: CTEC2713N
    Staff form to register a new contributor application.
    Mirrors ContributorApply.aspx fields (Driver / VehicleOwner / OwnerDriver)
    so staff can enter exactly the same data on behalf of an applicant.
    No CV upload — staff can approve directly. Vehicle photo uploads are
    supported so the vehicle appears in the fleet with the correct image.
--%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContributorAdd.aspx.cs" Inherits="DriveNow.AddContributor" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Add Contributor</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        /* ── Type-card selector (same pattern as ContributorApply) ── */
        .ca-type-cards { display:grid; grid-template-columns:repeat(3,1fr); gap:1rem; margin-bottom:1.4rem; }
        @media(max-width:700px){ .ca-type-cards { grid-template-columns:1fr; } }
        .ca-type-card { border:2px solid rgba(255,255,255,.1); border-radius:12px; padding:1.1rem 1.2rem; cursor:pointer; transition:border-color .2s,background .2s,transform .15s; }
        .ca-type-card:hover { border-color:#14b8a6; background:rgba(13,148,136,.06); transform:translateY(-1px); }
        .ca-type-card.selected { border-color:#14b8a6; background:rgba(13,148,136,.10); }
        .ca-type-card input[type=radio] { display:none; }
        .ca-type-icon { font-size:.6rem; font-weight:800; letter-spacing:.06em; color:#14b8a6; margin-bottom:.4rem; }
        .ca-type-title { font-size:.92rem; font-weight:700; color:#fff; margin-bottom:.18rem; }
        .ca-type-desc  { font-size:.76rem; color:#94a3b8; }
        /* ── Conditional sections ── */
        .ca-section { display:none; background:rgba(13,148,136,.07); border:1px solid rgba(13,148,136,.2); border-radius:10px; padding:1.1rem 1.2rem; margin-bottom:1.1rem; }
        .ca-section-label { font-size:.7rem; font-weight:700; letter-spacing:.09em; text-transform:uppercase; color:#14b8a6; margin-bottom:.9rem; }
        /* ── Photo upload drop zone ── */
        .ca-photo-zone { border:2px dashed rgba(255,255,255,.18); border-radius:10px; padding:1.1rem; text-align:center; cursor:pointer; transition:border-color .2s; }
        .ca-photo-zone:hover { border-color:#14b8a6; }
        .ca-photo-hint { font-size:.78rem; color:#94a3b8; }
        /* ── 2-col grid inside sections ── */
        .ca-grid2 { display:grid; grid-template-columns:1fr 1fr; gap:1rem; }
        @media(max-width:580px){ .ca-grid2 { grid-template-columns:1fr; } }
    </style>
</head>
<body>
<form id="form1" runat="server" enctype="multipart/form-data">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>
            <div class="dn-nav-label">NAVIGATE</div>
            <a href="TripList.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <a href="StaffProfile.aspx" style="text-decoration:none;" title="View your profile">
                <div class="dn-sidebar-user">
                    <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                    <div>
                        <div class="dn-sidebar-name"><asp:Label ID="lblUsername" runat="server" /></div>
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
            <div class="dn-topbar-title">Add Contributor</div>
            <div class="dn-topbar-right">
                <a href="ContributorList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">&#8592; Back to List</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-page-header">
                <div>
                    <div class="dn-page-title">New Contributor Application</div>
                    <div class="dn-page-sub">Fill in all required fields — vehicle or driver info shown based on type selected</div>
                </div>
            </div>

            <asp:Label ID="lblMessage" runat="server" Visible="false" />

            <div class="dn-form-card">

                <!-- ── STEP 1: Contributor type ── -->
                <div style="margin-bottom:1.4rem;">
                    <div class="dn-label" style="margin-bottom:.75rem;">Contributor Type <span class="required">*</span></div>
                    <div class="ca-type-cards">
                        <label class="ca-type-card" id="cardOwner" onclick="caSelectType('VehicleOwner')">
                            <asp:RadioButton ID="rbOwner" runat="server" GroupName="ContribType" />
                            <div class="ca-type-icon">VEH</div>
                            <div class="ca-type-title">Vehicle Owner</div>
                            <div class="ca-type-desc">List vehicle — earns while not in use</div>
                        </label>
                        <label class="ca-type-card" id="cardDriver" onclick="caSelectType('Driver')">
                            <asp:RadioButton ID="rbDriver" runat="server" GroupName="ContribType" />
                            <div class="ca-type-icon">DRV</div>
                            <div class="ca-type-title">Driver</div>
                            <div class="ca-type-desc">Drives for DriveNow on flexible schedule</div>
                        </label>
                        <label class="ca-type-card" id="cardOwnerDriver" onclick="caSelectType('OwnerDriver')">
                            <asp:RadioButton ID="rbOwnerDriver" runat="server" GroupName="ContribType" />
                            <div class="ca-type-icon">OWD</div>
                            <div class="ca-type-title">Owner &amp; Driver</div>
                            <div class="ca-type-desc">Owns vehicle AND drives for DriveNow</div>
                        </label>
                    </div>
                    <asp:HiddenField ID="hfContribType" runat="server" Value="" />
                    <asp:Label ID="lblTypeError" runat="server" CssClass="dn-hint" Visible="false" Text="Please select a contributor type." style="color:#f87171;" />
                </div>

                <!-- ── STEP 2: Personal details ── -->
                <div class="dn-field">
                    <label class="dn-label">Full Name <span class="required">*</span></label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="dn-input" MaxLength="100" placeholder="Applicant full legal name" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Full name is required." CssClass="dn-hint" Display="Dynamic" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Email Address <span class="required">*</span></label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="dn-input" MaxLength="150" placeholder="applicant@email.com" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." CssClass="dn-hint" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email address." CssClass="dn-hint" Display="Dynamic" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Phone Number <span class="required">*</span></label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="dn-input" MaxLength="30" placeholder="+45 70 10 20 30" />
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Phone number is required." CssClass="dn-hint" Display="Dynamic" />
                </div>

                <!-- ── VEHICLE DETAILS (VehicleOwner / OwnerDriver) ── -->
                <div class="ca-section" id="vehicleSection">
                    <div class="ca-section-label">Vehicle Details</div>
                    <div class="ca-grid2">
                        <div class="dn-field">
                            <label class="dn-label">Make</label>
                            <asp:TextBox ID="txtVehicleMake" runat="server" CssClass="dn-input" MaxLength="50" placeholder="e.g. BMW" />
                        </div>
                        <div class="dn-field">
                            <label class="dn-label">Model</label>
                            <asp:TextBox ID="txtVehicleModel" runat="server" CssClass="dn-input" MaxLength="50" placeholder="e.g. 5 Series" />
                        </div>
                        <div class="dn-field">
                            <label class="dn-label">Year</label>
                            <asp:TextBox ID="txtVehicleYear" runat="server" CssClass="dn-input" MaxLength="4" placeholder="2022" TextMode="Number" />
                        </div>
                        <div class="dn-field">
                            <label class="dn-label">Registration No.</label>
                            <asp:TextBox ID="txtVehicleReg" runat="server" CssClass="dn-input" MaxLength="20" placeholder="AB12 CDE" />
                        </div>
                        <div class="dn-field">
                            <label class="dn-label">Colour</label>
                            <asp:TextBox ID="txtVehicleColour" runat="server" CssClass="dn-input" MaxLength="30" placeholder="e.g. Midnight Blue" />
                        </div>
                        <div class="dn-field">
                            <label class="dn-label">Seats</label>
                            <asp:DropDownList ID="ddlVehicleSeats" runat="server" CssClass="dn-input">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem Value="2">2</asp:ListItem>
                                <asp:ListItem Value="4">4</asp:ListItem>
                                <asp:ListItem Value="5" Selected="True">5</asp:ListItem>
                                <asp:ListItem Value="7">7</asp:ListItem>
                                <asp:ListItem Value="8">8</asp:ListItem>
                                <asp:ListItem Value="9">9</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="dn-field">
                            <label class="dn-label">Daily Rate (&pound;/day)</label>
                            <asp:TextBox ID="txtVehicleDailyRate" runat="server" CssClass="dn-input" TextMode="Number" placeholder="e.g. 85.00" />
                        </div>
                    </div>
                    <div class="dn-field" style="margin-top:.4rem;">
                        <label class="dn-label">Vehicle Photo</label>
                        <div class="ca-photo-zone" onclick="document.getElementById('<%= fuVehiclePhoto.ClientID %>').click()">
                            <div id="vehiclePhotoLabel" class="ca-photo-hint">Click to attach vehicle photo (JPG, PNG — max 5 MB)</div>
                            <asp:FileUpload ID="fuVehiclePhoto" runat="server" accept=".jpg,.jpeg,.png,.webp" style="display:none;" onchange="caUpdateLabel(this.id,'vehiclePhotoLabel')" />
                        </div>
                        <span class="dn-hint">This photo will appear in the public fleet listing and admin vehicle tab.</span>
                    </div>
                </div>

                <!-- ── DRIVER CREDENTIALS (Driver / OwnerDriver) ── -->
                <div class="ca-section" id="driverSection">
                    <div class="ca-section-label">Driver Credentials</div>
                    <div class="dn-field">
                        <label class="dn-label">Driving Licence Number</label>
                        <asp:TextBox ID="txtLicenceNumber" runat="server" CssClass="dn-input" MaxLength="50" placeholder="e.g. SMIT9701157JS9A" />
                        <asp:Label ID="lblLicenceError" runat="server" CssClass="dn-hint" Visible="false" Text="Licence number is required for Driver applicants." style="color:#f87171;" />
                    </div>
                    <div class="ca-grid2">
                        <div class="dn-field">
                            <label class="dn-label">Licence Issue Date</label>
                            <asp:TextBox ID="txtLicenceIssueDate" runat="server" CssClass="dn-input" TextMode="Date" />
                        </div>
                        <div class="dn-field">
                            <label class="dn-label">Licence Expiry Date</label>
                            <asp:TextBox ID="txtLicenceExpiryDate" runat="server" CssClass="dn-input" TextMode="Date" />
                        </div>
                        <div class="dn-field">
                            <label class="dn-label">Date of Birth</label>
                            <asp:TextBox ID="txtDateOfBirth" runat="server" CssClass="dn-input" TextMode="Date" />
                            <span class="dn-hint">Required for driver identity verification.</span>
                        </div>
                        <div class="dn-field">
                            <label class="dn-label">Years of Driving Experience</label>
                            <asp:TextBox ID="txtDrivingYears" runat="server" CssClass="dn-input" MaxLength="3" TextMode="Number" placeholder="e.g. 5" />
                        </div>
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Driver Profile Photo</label>
                        <div class="ca-photo-zone" onclick="document.getElementById('<%= fuProfilePhoto.ClientID %>').click()">
                            <div id="profilePhotoLabel" class="ca-photo-hint">Click to attach profile photo (JPG, PNG — max 5 MB)</div>
                            <asp:FileUpload ID="fuProfilePhoto" runat="server" accept=".jpg,.jpeg,.png" style="display:none;" onchange="caUpdateLabel(this.id,'profilePhotoLabel')" />
                        </div>
                    </div>
                </div>

                <!-- ── Application date ── -->
                <div class="dn-field">
                    <label class="dn-label">Application Date <span class="required">*</span></label>
                    <asp:TextBox ID="txtApplicationDate" runat="server" CssClass="dn-input" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvApplicationDate" runat="server" ControlToValidate="txtApplicationDate" ErrorMessage="Application date is required." CssClass="dn-hint" Display="Dynamic" />
                </div>

                <!-- GDPR / data-handling notice -->
                <div style="background:rgba(13,148,136,.07);border:1px solid rgba(13,148,136,.2);border-radius:8px;padding:.9rem 1rem;margin-bottom:1.1rem;font-size:.78rem;color:#5eead4;line-height:1.65;">
                    <strong>&#9888; Data Protection Reminder</strong><br />
                    You are registering personal data on behalf of a contributor applicant. Confirm the applicant has been informed of how their data will be used and has given consent. Data is held under GDPR Article 6(1)(a). Applicants may withdraw consent at any time.
                </div>

                <div class="dn-form-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save Contributor" CssClass="dn-btn dn-btn-primary" OnClick="btnSave_Click" />
                    <a href="ContributorList.aspx" class="dn-btn dn-btn-secondary">Cancel</a>
                </div>

            </div><!-- end dn-form-card -->
        </div><!-- end dn-content -->

        <div class="dn-footer">DriveNow Admin System &middot; CTEC2713N &middot; Niels Brock Copenhagen</div>
    </div><!-- end dn-main -->

</div><!-- end dn-shell -->
</form>

<script>
    /* ── Type card selection ── */
    function caSelectType(type) {
        document.getElementById('<%= hfContribType.ClientID %>').value = type;
        ['cardOwner','cardDriver','cardOwnerDriver'].forEach(function(id) {
            document.getElementById(id).classList.remove('selected');
        });
        var map = { 'VehicleOwner':'cardOwner', 'Driver':'cardDriver', 'OwnerDriver':'cardOwnerDriver' };
        if (map[type]) document.getElementById(map[type]).classList.add('selected');
        document.getElementById('vehicleSection').style.display = (type === 'VehicleOwner' || type === 'OwnerDriver') ? 'block' : 'none';
        document.getElementById('driverSection').style.display  = (type === 'Driver'       || type === 'OwnerDriver') ? 'block' : 'none';
    }
    /* ── File label update ── */
    function caUpdateLabel(inputId, labelId) {
        var input = document.getElementById(inputId);
        var label = document.getElementById(labelId);
        if (input && input.files && input.files.length > 0)
            label.textContent = 'Attached: ' + input.files[0].name;
    }
    /* ── Mobile sidebar ── */
    function toggleSidebar() { document.body.classList.toggle('sidebar-open'); }
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
