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
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        .ce-section { margin-top: 1.5rem; }
        .ce-section-head {
            font-size: .7rem; font-weight: 700; letter-spacing: .09em; text-transform: uppercase;
            color: #14b8a6; margin-bottom: 1rem; padding-bottom: .5rem;
            border-bottom: 1px solid rgba(13,148,136,.2);
        }
        .ce-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0 1.5rem; }
        @media(max-width:700px){ .ce-grid { grid-template-columns: 1fr; } }
        .ce-hint { font-size: .72rem; color: #64748b; margin-top: .25rem; }
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
                <nav class="dn-sidebar-nav">
                    <div class="dn-nav-label">Main</div>
                    <a href="MainMenu.aspx" class="dn-nav-item">
                         Main Menu
                    </a>
                    <div class="dn-nav-label">Contributors</div>
                    <a href="ContributorList.aspx" class="dn-nav-item active">
                         List Contributors
                    </a>
                    <a href="ContributorAdd.aspx" class="dn-nav-item">
                         Add Contributor
                    </a>
                    <a href="ContributorFind.aspx" class="dn-nav-item">
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
                                CssClass="dn-input" MaxLength="20" placeholder="+44 7700 900000" />
                            <asp:RequiredFieldValidator ID="rfvPhone" runat="server"
                                ControlToValidate="txtPhone"
                                ErrorMessage="Phone number is required."
                                CssClass="dn-hint" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revPhone" runat="server"
                                ControlToValidate="txtPhone"
                                ValidationExpression="^\+[1-9][0-9\s\-\(\)]{5,17}$"
                                ErrorMessage="Phone must start with a country code (e.g. +44) and contain 7–15 digits."
                                CssClass="dn-hint" Display="Dynamic" />
                            <div class="ce-hint">Include country code, e.g. +44 7700 900000 (UK) or +45 12345678 (DK).</div>
                        </div>

                        <div class="dn-field">
                            <label class="dn-label">Contributor Type <span class="required">*</span></label>
                            <asp:DropDownList ID="ddlContributorType" runat="server" CssClass="dn-select">
                                <asp:ListItem Value="">-- Select Type --</asp:ListItem>
                                <asp:ListItem Value="Driver">Driver</asp:ListItem>
                                <asp:ListItem Value="VehicleOwner">VehicleOwner</asp:ListItem>
                                <asp:ListItem Value="OwnerDriver">Owner &amp; Driver</asp:ListItem>
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

                        <div class="dn-field">
                            <label class="dn-label">Internal Notes</label>
                            <asp:TextBox ID="txtNotes" runat="server" CssClass="dn-input" TextMode="MultiLine" Rows="3" MaxLength="1000" />
                            <div class="ce-hint">Staff-only notes — not visible to the contributor.</div>
                        </div>

                        <!-- ═══ DRIVER CREDENTIALS (Driver / OwnerDriver) ═══ -->
                        <asp:Panel ID="pnlDriverSection" runat="server" CssClass="ce-section">
                            <div class="ce-section-head">Driver Credentials</div>
                            <div class="ce-grid">
                                <div class="dn-field">
                                    <label class="dn-label">Licence Number</label>
                                    <asp:TextBox ID="txtLicenceNumber" runat="server" CssClass="dn-input" MaxLength="50" placeholder="e.g. SMIT9701157JS9AB" />
                                    <asp:RegularExpressionValidator ID="revLicenceNumber" runat="server"
                                        ControlToValidate="txtLicenceNumber"
                                        ValidationExpression="^(?=(?:.*[A-Za-z]){2})(?=(?:.*[0-9]){2})[A-Za-z0-9\-]{5,20}$"
                                        ErrorMessage="Licence number must be 5–20 characters with at least 2 letters and 2 digits."
                                        CssClass="ce-hint" Display="Dynamic" ForeColor="Red" />
                                    <div class="ce-hint">5–20 chars, ≥2 letters and ≥2 digits. Example: SMIT9701157JS9AB</div>
                                </div>
                                <div class="dn-field">
                                    <label class="dn-label">Date of Birth</label>
                                    <asp:TextBox ID="txtDateOfBirth" runat="server" CssClass="dn-input" TextMode="Date"
                                        onchange="ceValidateDOB(this.value);" />
                                    <div id="ceDobMsg" class="ce-hint" style="color:#dc2626;display:none;"></div>
                                    <div class="ce-hint">Must be on or after 01/01/1970 and contributor must be ≥18 years old.</div>
                                </div>
                                <div class="dn-field">
                                    <label class="dn-label">Licence Issue Date</label>
                                    <asp:TextBox ID="txtLicenceIssueDate" runat="server" CssClass="dn-input" TextMode="Date"
                                        onchange="ceValidateLicenceIssue(this.value);" />
                                    <div id="ceIssueDateMsg" class="ce-hint" style="color:#dc2626;display:none;"></div>
                                    <div class="ce-hint">Must be at least 1 year ago.</div>
                                </div>
                                <div class="dn-field">
                                    <label class="dn-label">Licence Expiry Date</label>
                                    <asp:TextBox ID="txtLicenceExpiryDate" runat="server" CssClass="dn-input" TextMode="Date" />
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- ═══ VEHICLE DETAILS (VehicleOwner / OwnerDriver) ═══ -->
                        <asp:Panel ID="pnlVehicleSection" runat="server" CssClass="ce-section">
                            <div class="ce-section-head">Vehicle Details</div>
                            <div class="ce-grid">
                                <div class="dn-field">
                                    <label class="dn-label">Make</label>
                                    <asp:TextBox ID="txtVehicleMake" runat="server" CssClass="dn-input" MaxLength="50" />
                                </div>
                                <div class="dn-field">
                                    <label class="dn-label">Model</label>
                                    <asp:TextBox ID="txtVehicleModel" runat="server" CssClass="dn-input" MaxLength="50" />
                                </div>
                                <div class="dn-field">
                                    <label class="dn-label">Year</label>
                                    <asp:TextBox ID="txtVehicleYear" runat="server" CssClass="dn-input" MaxLength="4" />
                                </div>
                                <div class="dn-field">
                                    <label class="dn-label">Registration No.</label>
                                    <asp:TextBox ID="txtVehicleReg" runat="server" CssClass="dn-input" MaxLength="20" />
                                    <div class="ce-hint">Searchable in the Vehicles tab once approved.</div>
                                </div>
                                <div class="dn-field">
                                    <label class="dn-label">Colour</label>
                                    <asp:TextBox ID="txtVehicleColour" runat="server" CssClass="dn-input" MaxLength="30" />
                                </div>
                                <div class="dn-field">
                                    <label class="dn-label">Seats</label>
                                    <asp:TextBox ID="txtVehicleSeats" runat="server" CssClass="dn-input" MaxLength="2" />
                                </div>
                                <div class="dn-field">
                                    <label class="dn-label">Daily Rate (£)</label>
                                    <asp:TextBox ID="txtVehicleDailyRate" runat="server" CssClass="dn-input" MaxLength="8" />
                                    <div class="ce-hint">Rate shown on fleet page. Synced to tblVehicle on save.</div>
                                </div>
                            </div>

                            <%-- Vehicle Photo Upload -%>
                            <div class="dn-field" style="margin-top:1rem;">
                                <label class="dn-label">Vehicle Photo</label>

                                <%-- Show current photo if one exists --%>
                                <asp:Panel ID="pnlCurrentVehiclePhoto" runat="server" Visible="false" style="margin-bottom:.75rem;">
                                    <div style="font-size:.75rem;color:#94a3b8;margin-bottom:.4rem;">Current photo:</div>
                                    <asp:Image ID="imgCurrentContribVehicle" runat="server" AlternateText="Current vehicle photo"
                                        style="max-width:280px;border-radius:10px;border:1px solid rgba(255,255,255,.12);display:block;margin-bottom:.5rem;" />
                                    <asp:CheckBox ID="chkRemoveVehiclePhoto" runat="server" Text=" Remove photo" />
                                </asp:Panel>

                                <%-- No photo placeholder when none is set --%>
                                <asp:Panel ID="pnlNoVehiclePhoto" runat="server" Visible="false" style="margin-bottom:.75rem;">
                                    <div style="width:200px;height:120px;border:2px dashed rgba(255,255,255,.15);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#64748b;font-size:.8rem;">No photo yet</div>
                                </asp:Panel>

                                <%-- Upload zone --%>
                                <div style="border:2px dashed rgba(20,184,166,.35);border-radius:10px;padding:1rem;text-align:center;cursor:pointer;transition:border-color .2s;"
                                     onclick="document.getElementById('<%= fuContribVehiclePhoto.ClientID %>').click()"
                                     onmouseover="this.style.borderColor='#14b8a6'" onmouseout="this.style.borderColor='rgba(20,184,166,.35)'">
                                    <div id="cvPhotoLabel" style="font-size:.82rem;color:#64748b;">Click to upload vehicle photo (JPG, PNG, WebP)</div>
                                    <asp:FileUpload ID="fuContribVehiclePhoto" runat="server" accept=".jpg,.jpeg,.png,.webp" style="display:none;"
                                        onchange="var f=this.files[0];if(f)document.getElementById('cvPhotoLabel').textContent='Selected: '+f.name;" />
                                </div>
                                <asp:HiddenField ID="hfCurrentVehiclePhotoUrl" runat="server" />
                            </div>
                        </asp:Panel>

                        <div class="dn-form-actions">
                            <asp:Button ID="btnSave" runat="server" Text="Save Changes"
                                CssClass="dn-btn dn-btn-primary"
                                OnClick="btnSave_Click"
                                OnClientClick="return ceValidateForm();" />
                            <a href="ContributorList.aspx" class="dn-btn dn-btn-secondary">Cancel</a>
                        </div>

                    </div>
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
    document.addEventListener('click', function(e) {
        if (document.body.classList.contains('sidebar-open') &&
            !e.target.closest('.dn-sidebar') &&
            !e.target.closest('.dn-mobile-menu-btn')) {
            document.body.classList.remove('sidebar-open');
        }
    });

    /* ── Phone country-code validator ────────────────────────
       Returns {ok, msg}. Checks E.164: starts with +, digits 7-15.
       Also validates per-country length where known.            */
    var CE_PHONE_RULES = {
        '1':['US/CA',11,11],'7':['RU',11,11],'20':['EG',11,12],'27':['ZA',11,11],
        '30':['GR',12,12],'31':['NL',11,11],'32':['BE',10,11],'33':['FR',11,11],
        '34':['ES',11,11],'36':['HU',11,11],'39':['IT',10,12],'40':['RO',11,11],
        '41':['CH',11,11],'43':['AT',10,13],'44':['GB',12,12],'45':['DK',10,10],
        '46':['SE',11,13],'47':['NO',10,10],'48':['PL',11,11],'49':['DE',11,13],
        '52':['MX',12,12],'54':['AR',12,13],'55':['BR',12,13],'56':['CL',11,11],
        '57':['CO',12,12],'60':['MY',10,11],'61':['AU',11,11],'62':['ID',10,13],
        '63':['PH',12,12],'64':['NZ',10,12],'65':['SG',10,10],'66':['TH',11,11],
        '81':['JP',11,12],'82':['KR',11,12],'84':['VN',11,12],'86':['CN',13,13],
        '90':['TR',12,12],'91':['IN',12,12],'92':['PK',12,12],'94':['LK',11,11],
        '98':['IR',12,12],'212':['MA',12,12],'213':['DZ',12,12],'216':['TN',11,11],
        '234':['NG',12,13],'254':['KE',12,12],'255':['TZ',12,12],'256':['UG',12,12],
        '880':['BD',12,13],'966':['SA',12,12],'971':['AE',12,12],'972':['IL',12,12],
        '974':['QA',11,11],'977':['NP',12,12],'994':['AZ',12,12],'998':['UZ',12,12]
    };
    function ceValidatePhone(val) {
        if (!val) return { ok: false, msg: 'Phone number is required.' };
        if (val.charAt(0) !== '+') return { ok: false, msg: 'Phone must start with a country code, e.g. +44 or +45.' };
        var digits = val.replace(/[^\d]/g, '');
        if (digits.length < 7)  return { ok: false, msg: 'Phone number is too short — minimum 7 digits after the country code.' };
        if (digits.length > 15) return { ok: false, msg: 'Phone number is too long — maximum 15 digits (E.164 standard).' };
        // Country-code specific check (try 3, 2, 1 digit codes)
        var stripped = val.replace(/^\+/, '').replace(/[^\d]/g, '');
        for (var len = 3; len >= 1; len--) {
            var cc = stripped.substring(0, len);
            if (CE_PHONE_RULES[cc]) {
                var rule = CE_PHONE_RULES[cc];
                var total = digits.length; // includes country code digits
                if (total < rule[1]) return { ok: false, msg: 'Phone too short for +' + cc + ' (' + rule[0] + '). Expected ' + rule[1] + ' digits total.' };
                if (total > rule[2]) return { ok: false, msg: 'Phone too long for +' + cc + ' (' + rule[0] + '). Expected max ' + rule[2] + ' digits total.' };
                break;
            }
        }
        return { ok: true, msg: '' };
    }

    /* ── DOB validator ──────────────────────────────────────── */
    function ceValidateDOB(val) {
        var el = document.getElementById('ceDobMsg');
        if (!val) { if (el) el.style.display = 'none'; return true; }
        var dob    = new Date(val + 'T00:00:00');
        var minDt  = new Date('1970-01-01T00:00:00');
        var maxDt  = new Date(); maxDt.setFullYear(maxDt.getFullYear() - 18);
        var ok = (dob >= minDt && dob <= maxDt);
        if (el) { el.style.display = ok ? 'none' : 'block'; el.textContent = ok ? '' : 'DOB must be between 01 Jan 1970 and 18 years before today.'; }
        return ok;
    }

    /* ── Licence issue date validator ───────────────────────── */
    function ceValidateLicenceIssue(val) {
        var el = document.getElementById('ceIssueDateMsg');
        if (!val) { if (el) el.style.display = 'none'; return true; }
        var issued  = new Date(val + 'T00:00:00');
        var cutoff  = new Date(); cutoff.setFullYear(cutoff.getFullYear() - 1);
        var ok = (issued <= cutoff);
        if (el) { el.style.display = ok ? 'none' : 'block'; el.textContent = ok ? '' : 'Licence must have been issued at least 1 year ago.'; }
        return ok;
    }

    /* ── Master form validator (runs before postback) ───────── */
    function ceValidateForm() {
        var ddl  = document.getElementById('<%= ddlContributorType.ClientID %>');
        var type = ddl ? ddl.value : '';
        var isDriver = (type === 'Driver' || type === 'OwnerDriver');

        // Phone validation (always)
        var phoneTxt = document.getElementById('<%= txtPhone.ClientID %>');
        if (phoneTxt) {
            var pr = ceValidatePhone(phoneTxt.value.trim());
            if (!pr.ok) { alert(pr.msg); phoneTxt.focus(); return false; }
        }

        if (!isDriver) return true;

        var dobEl   = document.getElementById('<%= txtDateOfBirth.ClientID %>');
        var issueEl = document.getElementById('<%= txtLicenceIssueDate.ClientID %>');
        var dobOk   = ceValidateDOB(dobEl   ? dobEl.value   : '');
        var issOk   = ceValidateLicenceIssue(issueEl ? issueEl.value : '');
        if (!dobOk || !issOk) return false;
        return true;
    }

    /* ── Show / hide driver credentials and vehicle panels ── */
    function updateSections() {
        var ddl   = document.getElementById('<%= ddlContributorType.ClientID %>');
        var type  = ddl ? ddl.value : '';
        var drv   = document.getElementById('<%= pnlDriverSection.ClientID %>');
        var veh   = document.getElementById('<%= pnlVehicleSection.ClientID %>');
        var isDriver = (type === 'Driver'  || type === 'OwnerDriver');
        var isOwner  = (type === 'VehicleOwner' || type === 'OwnerDriver');
        if (drv) drv.style.display = isDriver ? '' : 'none';
        if (veh) veh.style.display = isOwner  ? '' : 'none';
    }

    /* Run on load and whenever the type dropdown changes */
    document.addEventListener('DOMContentLoaded', updateSections);
    (function () {
        var ddl = document.getElementById('<%= ddlContributorType.ClientID %>');
        if (ddl) ddl.addEventListener('change', updateSections);
    })();
</script>
</body>
</html>



