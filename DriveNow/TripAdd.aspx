<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripAdd.aspx.cs" Inherits="DriveNow.TripAdd" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Add Trip</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripAdd" runat="server">

    <div class="navbar">
        <a href="MainMenu.aspx" class="brand">DriveNow</a>
        <div class="nav-links">
            <a href="TripList.aspx">← Trip List</a>
            <a href="MainMenu.aspx">Main Menu</a>
        </div>
    </div>

    <div class="container-sm">
        <h1 style="margin-bottom:20px">Add Trip</h1>
        <div class="card">
            <asp:Label ID="lblError"   runat="server" CssClass="error"   Visible="false" />
            <asp:Label ID="lblSuccess" runat="server" CssClass="success" Visible="false" />

            <div class="field">
                <label>Customer ID *</label>
                <asp:TextBox ID="txtCustomerID" runat="server" placeholder="Enter Customer ID" />
            </div>
            <div class="field">
                <label>Vehicle ID *</label>
                <asp:TextBox ID="txtVehicleID" runat="server" placeholder="Enter Vehicle ID" />
            </div>
            <div class="field">
                <label>Driver ID</label>
                <asp:TextBox ID="txtDriverID" runat="server" placeholder="Leave blank for self-drive" />
                <div class="hint">Leave blank for self-drive rentals — no driver required.</div>
            </div>
            <div class="field">
                <label>Trip Type *</label>
                <asp:DropDownList ID="ddlTripType" runat="server" />
            </div>
            <div class="field">
                <label>Trip Date * (dd/MM/yyyy)</label>
                <asp:TextBox ID="txtTripDate" runat="server" placeholder="e.g. 01/06/2026" />
            </div>

            <asp:Button ID="btnSave"   runat="server" Text="Save"   CssClass="btn btn-primary"   OnClick="btnSave_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" />
        </div>
    </div>

    <div class="footer">DriveNow Admin System &nbsp;|&nbsp; CTEC2713N &nbsp;|&nbsp; Niels Brock Copenhagen</div>

</form>
</body>
</html>
