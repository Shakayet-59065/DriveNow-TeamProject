<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripTypeEdit.aspx.cs" Inherits="DriveNow.TripTypeEdit" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Edit Trip Type</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripTypeEdit" runat="server">

    <div class="navbar">
        <a href="MainMenu.aspx" class="brand">DriveNow</a>
        <div class="nav-links">
            <a href="TripTypeList.aspx">← Trip Type List</a>
            <a href="MainMenu.aspx">Main Menu</a>
        </div>
    </div>

    <div class="container-sm">
        <h1 style="margin-bottom:20px">Edit Trip Type</h1>
        <div class="card">
            <asp:Label ID="lblError"   runat="server" CssClass="error"   Visible="false" />
            <asp:Label ID="lblSuccess" runat="server" CssClass="success" Visible="false" />
            <asp:HiddenField ID="hdnTripTypeID" runat="server" />

            <div class="field">
                <label>Type Name *</label>
                <asp:TextBox ID="txtTypeName" runat="server" MaxLength="50" />
            </div>
            <div class="field">
                <label>Description</label>
                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" MaxLength="200" />
            </div>
            <div class="field">
                <label>Base Rate *</label>
                <asp:TextBox ID="txtBaseRate" runat="server" />
            </div>

            <asp:Button ID="btnSave"   runat="server" Text="Save Changes" CssClass="btn btn-primary"   OnClick="btnSave_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel"        CssClass="btn btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" />
        </div>
    </div>

    <div class="footer">DriveNow Admin System &nbsp;|&nbsp; CTEC2713N &nbsp;|&nbsp; Niels Brock Copenhagen</div>

</form>
</body>
</html>
