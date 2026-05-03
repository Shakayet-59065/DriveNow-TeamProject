<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripTypeList.aspx.cs" Inherits="DriveNow.TripTypeList" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Trip Type List</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripTypeList" runat="server">

    <div class="navbar">
        <a href="MainMenu.aspx" class="brand">DriveNow</a>
        <div class="nav-links">
            <a href="MainMenu.aspx">← Main Menu</a>
        </div>
    </div>

    <div class="container">
        <div class="page-header">
            <h1>Trip Type Catalogue</h1>
            <a href="TripTypeAdd.aspx" class="btn btn-primary">+ Add Trip Type</a>
        </div>

        <asp:Label ID="lblError" runat="server" CssClass="error" Visible="false" />

        <div class="card">
            <asp:GridView ID="gvTripTypes" runat="server"
                AutoGenerateColumns="false"
                DataKeyNames="TripTypeID"
                OnRowCommand="gvTripTypes_RowCommand"
                Width="100%">
                <Columns>
                    <asp:BoundField DataField="TripTypeID"  HeaderText="ID" />
                    <asp:BoundField DataField="TypeName"    HeaderText="Type Name" />
                    <asp:BoundField DataField="Description" HeaderText="Description" />
                    <asp:BoundField DataField="BaseRate"    HeaderText="Base Rate" DataFormatString="{0:F2}" />
                    <asp:BoundField DataField="CreatedDate" HeaderText="Created" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge <%# (bool)Eval("IsActive") ? "badge-active" : "badge-inactive" %>'>
                                <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="actions">
                                <asp:LinkButton runat="server" CommandName="EditType"
                                    CommandArgument='<%# Eval("TripTypeID") %>'
                                    CssClass="btn btn-edit btn-sm">Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteType"
                                    CommandArgument='<%# Eval("TripTypeID") %>'
                                    CssClass="btn btn-danger btn-sm"
                                    OnClientClick="return confirm('Soft delete this trip type?');">Delete</asp:LinkButton>
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
