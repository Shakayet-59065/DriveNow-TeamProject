<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VehicleAdd.aspx.cs" Inherits="DriveNow.VehicleAdd" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Add Vehicle — DriveNow Admin</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="form1" runat="server" enctype="multipart/form-data">
<div class="dn-shell">

    <div class="dn-sidebar">
        <div class="dn-sidebar-logo">
            <img src="Content/logo.png" alt="DriveNow" />
        </div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx" class="dn-nav-item">■ Dashboard</a>
            <div class="dn-nav-label">Team</div>
            <a href="TripList.aspx"        class="dn-nav-item">■ Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item">■ Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item">■ Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item">■ Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item active">■ Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item">■ Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div>CTEC2713N · Niels Brock</div>
            <a href="Logout.aspx" class="dn-sidebar-logout">&#x2192; Log out</a>
        </div>
    </div>

    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Add Vehicle</span>
                <span class="dn-page-sub">Add a new vehicle to the DriveNow fleet</span>
            </div>
            <div class="dn-topbar-actions">
                <a href="VehicleList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Back to List</a>
            </div>
        </div>

        <div class="dn-content">
            <asp:Label ID="lblError"   runat="server" Text="" Visible="false" CssClass="dn-alert-error" />
            <asp:Label ID="lblSuccess" runat="server" Text="" Visible="false" CssClass="dn-alert-success" />

            <div class="dn-form-card">
                <div class="dn-field">
                    <label class="dn-label">Registration Number <span class="required">*</span></label>
                    <asp:TextBox ID="txtRegistrationNo" runat="server" CssClass="dn-input" MaxLength="20" placeholder="e.g. AB21 HKL" />
                    <span class="dn-hint">Must be unique. Maximum 20 characters.</span>
                </div>
                <div class="dn-field">
                    <label class="dn-label">Make <span class="required">*</span></label>
                    <asp:TextBox ID="txtMake" runat="server" CssClass="dn-input" MaxLength="50" placeholder="e.g. Toyota, BMW, Ford" />
                    <span class="dn-hint">Vehicle manufacturer. Maximum 50 characters.</span>
                </div>
                <div class="dn-field">
                    <label class="dn-label">Model <span class="required">*</span></label>
                    <asp:TextBox ID="txtModel" runat="server" CssClass="dn-input" MaxLength="50" placeholder="e.g. Corolla, 5 Series, Focus" />
                    <span class="dn-hint">Vehicle model. Maximum 50 characters.</span>
                </div>
                <div class="dn-field">
                    <label class="dn-label">Daily Rate (£) <span class="required">*</span></label>
                    <asp:TextBox ID="txtDailyRate" runat="server" CssClass="dn-input" MaxLength="10" placeholder="e.g. 45.00" />
                    <span class="dn-hint">Daily rental cost in GBP. Must be greater than zero.</span>
                </div>
                <div class="dn-field">
                    <label class="dn-label">Seats <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlSeats" runat="server" CssClass="dn-input">
                        <asp:ListItem Value="2">2 Seats</asp:ListItem>
                        <asp:ListItem Value="4">4 Seats</asp:ListItem>
                        <asp:ListItem Value="5" Selected="True">5 Seats</asp:ListItem>
                        <asp:ListItem Value="7">7 Seats</asp:ListItem>
                        <asp:ListItem Value="8">8 Seats</asp:ListItem>
                        <asp:ListItem Value="9">9 Seats</asp:ListItem>
                    </asp:DropDownList>
                    <span class="dn-hint">Number of passenger seats in the vehicle.</span>
                </div>
                <div class="dn-field">
                    <label class="dn-label">Date Added <span class="required">*</span></label>
                    <asp:TextBox ID="txtDateAdded" runat="server" CssClass="dn-input" TextMode="Date" />
                    <span class="dn-hint">Date the vehicle joined the DriveNow fleet.</span>
                </div>
                <!-- Vehicle Photo — optional but recommended for fleet listings -->
                <div class="dn-field">
                    <label class="dn-label">Vehicle Photo (optional)</label>
                    <div style="border:2px dashed rgba(20,184,166,.35);border-radius:10px;padding:1.1rem;text-align:center;cursor:pointer;transition:border-color .2s;" onclick="document.getElementById('<%= fuVehiclePhoto.ClientID %>').click()" onmouseover="this.style.borderColor='#14b8a6'" onmouseout="this.style.borderColor='rgba(20,184,166,.35)'">
                        <div id="photoLabel" style="font-size:.82rem;color:#64748b;">Click to attach a photo (JPG, PNG, WebP — max 5 MB)</div>
                        <asp:FileUpload ID="fuVehiclePhoto" runat="server" accept=".jpg,.jpeg,.png,.webp" style="display:none;"
                            onchange="var f=this.files[0];if(f)document.getElementById('photoLabel').textContent='Attached: '+f.name;" />
                    </div>
                    <span class="dn-hint">This photo will appear on the public fleet page and vehicle detail page. If not uploaded, a stock photo is used automatically.</span>
                </div>
                <div class="dn-form-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save Vehicle" CssClass="dn-btn dn-btn-primary" OnClick="btnSave_Click" />
                    <a href="VehicleList.aspx" class="dn-btn dn-btn-secondary">Cancel</a>
                </div>
            </div>
        </div>

        <div class="dn-footer">
            DriveNow Admin · CTEC2713N · Niels Brock Copenhagen · Prodip · Vehicle Inventory
        </div>
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

