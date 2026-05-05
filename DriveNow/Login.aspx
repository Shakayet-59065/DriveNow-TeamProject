<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="DriveNow.Login" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Staff Login</title>
    <!-- Responsive viewport for mobile devices -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <!-- Shared stylesheet -->
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body class="dn-login-body">
<form id="frmLogin" runat="server">

    <div class="dn-login-box">
        <!-- DriveNow logo -->
        <img class="dn-login-logo" src="Content/logo.png" alt="DriveNow" />

        <!-- Page heading -->
        <div class="dn-login-title">Staff Portal</div>
        <div class="dn-login-sub">Sign in to access the DriveNow admin system</div>

        <!-- Error message — shown if login fails -->
        <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false" />

        <!-- Username field -->
        <div class="dn-field">
            <label class="dn-label">Username</label>
            <asp:TextBox ID="txtUsername" runat="server" CssClass="dn-input" placeholder="Enter your username" />
        </div>

        <!-- Password field -->
        <div class="dn-field">
            <label class="dn-label">Password</label>
            <asp:TextBox ID="txtPassword" runat="server" CssClass="dn-input" TextMode="Password" placeholder="Enter your password" />
        </div>

        <!-- Login button -->
        <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="dn-login-btn" OnClick="btnLogin_Click" />
    </div>

</form>
</body>
</html>
