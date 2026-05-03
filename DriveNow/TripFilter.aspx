<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripFilter.aspx.cs" Inherits="DriveNow.TripFilter" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Filter Trips</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripFilter" runat="server">

    <div class="navbar">
        <a href="MainMenu.aspx" class="brand">DriveNow</a>
        <div class="nav-links">
            <a href="TripList.aspx">← Trip List</a>
            <a href="MainMenu.aspx">Main Menu</a>
        </div>
    </div>

    <div class="container">
        <h1 style="margin-bottom:20px">Filter Trips</h1>

        <div class="card">
            <div class="filter-row">
                <div class="filter-field">
                    <label>Trip Type</label>
                    <asp:DropDownList ID="ddlTripType" runat="server" />
                </div>
                <div class="filter-field">
                    <label>Trip Date (dd/MM/yyyy)</label>
                    <asp:TextBox ID="txtTripDate" runat="server" placeholder="Optional" />
                </div>
                <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn btn-primary" OnClick="btnFilter_Click" />
                <asp:Button ID="btnClear"  runat="server" Text="Clear"  CssClass="btn btn-secondary" OnClick="btnClear_Click" CausesValidation="false" />
            </div>
        </div>

        <asp:Label ID="lblError" runat="server" CssClass="error" Visible="false" />

        <div class="card">
            <asp:GridView ID="gvTrips" runat="server"
                AutoGenerateColumns="false"
                Width="100%"
                EmptyDataText="No trips match the selected filters.">
                <Columns>
                    <asp:BoundField DataField="TripID"     HeaderText="ID" />
                    <asp:BoundField DataField="CustomerID" HeaderText="Customer ID" />
                    <asp:BoundField DataField="VehicleID"  HeaderText="Vehicle ID" />
                    <asp:BoundField DataField="DriverID"   HeaderText="Driver ID" NullDisplayText="Self-Drive" />
                    <asp:BoundField DataField="TypeName"   HeaderText="Trip Type" />
                    <asp:BoundField DataField="TripDate"   HeaderText="Date" DataFormatString="{0:dd/MM/yyyy}" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <div class="footer">DriveNow Admin System &nbsp;|&nbsp; CTEC2713N &nbsp;|&nbsp; Niels Brock Copenhagen</div>

</form>
</body>
</html>
