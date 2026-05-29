<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="DriveNow.ForgotPassword" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Forgot Password</title>
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        body { display:flex; align-items:center; justify-content:center; min-height:100vh; background:#f1f5f9; }
        .dn-forgot-box { width:100%; max-width:420px; padding:2.2rem; }
        .dn-back-link { font-size:.82rem; color:#64748B; text-align:center; margin-top:1rem; }
        .dn-back-link a { color:#0D9488; text-decoration:none; }
        .dn-back-link a:hover { text-decoration:underline; }
        .dn-steps { font-size:.82rem; color:#64748B; background:#f8fafb; border:1px solid #e2e8f0; border-radius:8px; padding:12px 16px; margin-bottom:1.2rem; line-height:1.7; }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
<form id="frmForgotPassword" runat="server">
    <div class="dn-login-box dn-forgot-box">
        <div class="dn-login-title">Reset Password</div>
        <p class="dn-login-sub" style="margin-bottom:1.2rem;">
            <asp:Literal ID="litSubtitle" runat="server" />
        </p>

        <!-- Success / error messages -->
        <asp:Label ID="lblMessage" runat="server" Visible="false" />

        <!-- Step hint -->
        <asp:Panel ID="pnlHint" runat="server">
            <div class="dn-steps">
                <strong>How to reset:</strong><br />
                1. Enter your <asp:Literal ID="litFieldLabel" runat="server" /> below.<br />
                2. Contact your system administrator — they will issue a temporary password.<br />
                3. Log in with the temporary password, then change it immediately.
            </div>
        </asp:Panel>

        <!-- Reset form -->
        <asp:Panel ID="pnlForm" runat="server">
            <div class="dn-field">
                <label class="dn-label"><asp:Literal ID="litInputLabel" runat="server" /> <span style="color:#ef4444">*</span></label>
                <asp:TextBox ID="txtIdentifier" runat="server" CssClass="dn-input"
                    placeholder="" MaxLength="150" />
                <asp:RequiredFieldValidator ID="rfvIdentifier" runat="server"
                    ControlToValidate="txtIdentifier"
                    ErrorMessage="This field is required."
                    CssClass="dn-alert-error"
                    Display="Dynamic"
                    ValidationGroup="forgot" />
                <asp:RegularExpressionValidator ID="revEmailFormat" runat="server"
                    ControlToValidate="txtIdentifier"
                    ErrorMessage="Please enter a valid email address."
                    CssClass="dn-alert-error"
                    Display="Dynamic"
                    ValidationGroup="forgot"
                    ValidationExpression="^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$"
                    Enabled="false" />
            </div>

            <asp:Button ID="btnSubmit" runat="server"
                Text="Send Reset Request"
                CssClass="dn-login-btn"
                OnClick="btnSubmit_Click"
                ValidationGroup="forgot" />
        </asp:Panel>

        <p class="dn-back-link">
            <a href="<%= UserType == "customer" ? "Default.aspx" : "Login.aspx" %>">&#8592; Back to Sign In</a>
        </p>
    </div>
</form>
</body>
</html>
