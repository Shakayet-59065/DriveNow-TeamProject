<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripList.aspx.cs" Inherits="DriveNow.TripList" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Trip List</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripList" runat="server">

    <div class="navbar">
        <a href="MainMenu.aspx" class="brand">DriveNow</a>
        <div class="nav-links">
            <a href="TripFilter.aspx">Filter</a>
            <a href="TripFind.aspx">Find</a>
            <a href="MainMenu.aspx">← Main Menu</a>
        </div>
    </div>

    <div class="container">
        <div class="page-header">
            <h1>Trip Records</h1>
            <a href="TripAdd.aspx" class="btn btn-primary">+ Add Trip</a>
        </div>

        <asp:Label ID="lblError" runat="server" CssClass="error" Visible="false" />

        <div class="card">
            <asp:GridView ID="gvTrips" runat="server"
                AutoGenerateColumns="false"
                DataKeyNames="TripID"
                OnRowCommand="gvTrips_RowCommand"
                Width="100%">
                <Columns>
                    <asp:BoundField DataField="TripID"     HeaderText="ID" />
                    <asp:BoundField DataField="CustomerID" HeaderText="Customer ID" />
                    <asp:BoundField DataField="VehicleID"  HeaderText="Vehicle ID" />
                    <asp:BoundField DataField="DriverID"   HeaderText="Driver ID" NullDisplayText="Self-Drive" />
                    <asp:BoundField DataField="TypeName"   HeaderText="Trip Type" />
                    <asp:BoundField DataField="TripDate"   HeaderText="Date" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="actions">
                                <asp:LinkButton runat="server" CommandName="EditTrip"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    CssClass="btn btn-edit btn-sm">Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteTrip"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    CssClass="btn btn-danger btn-sm"
                                    OnClientClick="return confirm('Soft delete this trip?');">Delete</asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <div class="footer">DriveNow Admin System &nbsp;|&nbsp; CTEC2713N &nbsp;|&nbsp; Niels Brock Copenhagen</div>

</form>
</body>
</html>
