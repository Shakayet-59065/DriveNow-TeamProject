<%-- DriveNow — Staff Login Page (Login.aspx)
     The sign-in page for admin staff. Customers log in via the modal on Default.aspx instead.
     Handles: username/password entry, Enter-key submit, Forgot Password link.
     Module: CTEC2713N --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="DriveNow.Login" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Staff Sign In</title>
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        body.dn-login-body { display:flex; align-items:center; justify-content:center; min-height:100vh; background:#f1f5f9; }
        .dn-login-box { width:100%; max-width:420px; padding:2.2rem; }
        .type-badge {
            display:inline-flex; align-items:center; gap:.5rem;
            background:#1A2332; color:#fff; font-weight:700; font-size:.82rem;
            letter-spacing:.06em; text-transform:uppercase; padding:.35rem .9rem;
            border-radius:99px; margin-bottom:1rem;
        }
        @media (max-width: 480px) {
            .dn-login-body { padding: 1rem; }
            .dn-login-box  { padding: 24px 18px; border-radius: 12px; }
            .dn-login-title { font-size: 1.3rem; }
        }
        @media (max-width: 380px) {
            .dn-login-box { padding: 20px 14px; }
            .dn-input { font-size: .85rem; }
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body class="dn-login-body">
<form id="frmLogin" runat="server">

    <div class="dn-login-box">
        <div class="dn-login-title">DriveNow Staff Portal</div>
        <div class="dn-login-sub" style="margin-bottom:.5rem;">Sign in as Staff / Administrator</div>
        <div class="type-badge">Staff Access</div>

        <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false" />

        <!-- Error message shown if credentials are wrong — hidden by default -->
        <!-- Staff login fields — Panel with DefaultButton so Enter fires Sign In -->
        <asp:Panel ID="pnlLoginFields" runat="server" DefaultButton="btnLogin">
        <div class="dn-field">
            <label class="dn-label">Username</label>
            <asp:TextBox ID="txtUsername" runat="server" CssClass="dn-input" placeholder="Enter your username" MaxLength="50" />
        </div>
        <div class="dn-field">
            <label class="dn-label">Password</label>
            <asp:TextBox ID="txtStaffPassword" runat="server" CssClass="dn-input" TextMode="Password" placeholder="Enter your password" MaxLength="100" />
            <div style="text-align:right;margin-top:5px;">
                <a href="ForgotPassword.aspx?type=staff" style="font-size:.78rem;color:#0d9488;text-decoration:none;">Forgot password?</a>
            </div>
        </div>

        <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="dn-login-btn" OnClick="btnLogin_Click" CausesValidation="false" />
        </asp:Panel>

        <p style="font-size:.82rem;color:#64748B;text-align:center;margin-top:1rem;">
            <a href="Default.aspx" style="color:#64748B;">&#8592; Back to homepage</a>
        </p>
        <p style="font-size:.75rem;color:#94a3b8;text-align:center;margin-top:.25rem;">
            Customer login is available on the <a href="Default.aspx" style="color:#0d9488;">DriveNow homepage</a>.
        </p>
    </div>

</form>
<script>
// Allows pressing Enter in the username or password field to submit the form
(function () {
    function submitLogin(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            // Programmatically click the Sign In button when Enter is pressed
            var btn = document.getElementById('<%= btnLogin.ClientID %>');
            if (btn) btn.click();
        }
    }
    // Attach the Enter-key listener to both the username and password inputs
    var u = document.getElementById('<%= txtUsername.ClientID %>');
    var p = document.getElementById('<%= txtStaffPassword.ClientID %>');
    if (u) u.addEventListener('keydown', submitLogin);
    if (p) p.addEventListener('keydown', submitLogin);
})();
</script>
</body>
</html>
