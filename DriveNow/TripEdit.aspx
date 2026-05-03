<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripEdit.aspx.cs" Inherits="DriveNow.TripEdit" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Edit Trip</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripEdit" runat="server">

    <div class="navbar">
        <a href="MainMenu.aspx" class="brand">DriveNow</a>
        <div class="nav-links">
            <a href="TripList.aspx">← Trip List</a>
            <a href="MainMenu.aspx">Main Menu</a>
        </div>
    </div>

    <div class="container-sm">
        <h1 style="margin-bottom:20px">Edit Trip</h1>
        <div class="card">
            <asp:Label ID="lblError"   runat="server" CssClass="error"   Visible="false" />
            <asp:Label ID="lblSuccess" runat="server" CssClass="success" Visible="false" />
            <asp:HiddenField ID="hdnTripID" runat="server" />

            <div class="field">
                <label>Customer ID *</label>
                <asp:TextBox ID="txtCustomerID" runat="server" />
            </div>
            <div class="field">
                <label>Vehicle ID *</label>
                <asp:TextBox ID="txtVehicleID" runat="server" />
            </div>
            <div class="field">
                <label>Driver ID</label>
                <asp:TextBox ID="txtDriverID" runat="server" />
                <div class="hint">Leave blank for self-drive rentals.</div>
            </div>
            <div class="field">
                <label>Trip Type *</label>
                <asp:DropDownList ID="ddlTripType" runat="server" />
            </div>
            <div class="field">
                <label>Trip Date * (dd/MM/yyyy)</label>
                <asp:TextBox ID="txtTripDate" runat="server" />
            </div>

            <asp:Button ID="btnSave"   runat="server" Text="Save Changes" CssClass="btn btn-primary"   OnClick="btnSave_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel"        CssClass="btn btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" />
        </div>
    </div>

    <div class="footer">DriveNow Admin System &nbsp;|&nbsp; CTEC2713N &nbsp;|&nbsp; Niels Brock Copenhagen</div>

</form>
</body>
</html>
