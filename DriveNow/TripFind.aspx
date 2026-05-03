<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripFind.aspx.cs" Inherits="DriveNow.TripFind" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Find Trip</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripFind" runat="server">

    <div class="navbar">
        <a href="MainMenu.aspx" class="brand">DriveNow</a>
        <div class="nav-links">
            <a href="TripList.aspx">← Trip List</a>
            <a href="MainMenu.aspx">Main Menu</a>
        </div>
    </div>

    <div class="container-sm">
        <h1 style="margin-bottom:20px">Find Trip</h1>

        <div class="card">
            <div class="search-row">
                <asp:TextBox ID="txtTripID" runat="server" placeholder="Enter Trip ID" />
                <asp:Button ID="btnFind" runat="server" Text="Find" CssClass="btn btn-primary" OnClick="btnFind_Click" />
            </div>
        </div>

        <asp:Label ID="lblError" runat="server" CssClass="error" Visible="false" />

        <asp:Panel ID="pnlResult" runat="server" Visible="false">
            <div class="card">
                <div class="result-label">Trip ID</div>
                <div class="result-value"><asp:Label ID="lblTripID"     runat="server" /></div>
                <div class="result-label">Customer ID</div>
                <div class="result-value"><asp:Label ID="lblCustomerID" runat="server" /></div>
                <div class="result-label">Vehicle ID</div>
                <div class="result-value"><asp:Label ID="lblVehicleID"  runat="server" /></div>
                <div class="result-label">Driver ID</div>
                <div class="result-value"><asp:Label ID="lblDriverID"   runat="server" /></div>
                <div class="result-label">Trip Type</div>
                <div class="result-value"><asp:Label ID="lblTypeName"   runat="server" /></div>
                <div class="result-label">Trip Date</div>
                <div class="result-value"><asp:Label ID="lblTripDate"   runat="server" /></div>
                <div class="result-label">Status</div>
                <div class="result-value"><asp:Label ID="lblStatus"     runat="server" /></div>
            </div>
        </asp:Panel>
    </div>

    <div class="footer">DriveNow Admin System &nbsp;|&nbsp; CTEC2713N &nbsp;|&nbsp; Niels Brock Copenhagen</div>

</form>
</body>
</html>
