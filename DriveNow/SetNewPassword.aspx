<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SetNewPassword.aspx.cs" Inherits="DriveNow.SetNewPassword" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Set New Password</title>
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background: #f1f5f9;
        }

        .dn-setnew-wrap {
            width: 100%;
            max-width: 440px;
            padding: 2.4rem 2.2rem;
        }

        .dn-setnew-banner {
            background: #fef3c7;
            border: 1px solid #f59e0b;
            border-radius: 10px;
            padding: 12px 16px;
            font-size: .84rem;
            color: #92400e;
            margin-bottom: 1.4rem;
            line-height: 1.6;
        }

        .dn-setnew-banner strong { display: block; margin-bottom: 2px; }

        .dn-pw-rules {
            font-size: .78rem;
            color: #64748b;
            margin-top: 4px;
            padding-left: 2px;
        }

        .dn-back-link { font-size:.82rem; color:#64748b; text-align:center; margin-top:1rem; }
        .dn-back-link a { color:#0D9488; text-decoration:none; }
        .dn-back-link a:hover { text-decoration:underline; }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
<form id="form1" runat="server">
<div class="dn-login-box dn-setnew-wrap">

    <!-- Branding -->
    <div class="dn-login-title">Set New Password</div>
    <p class="dn-login-sub" style="margin-bottom:1.2rem;">
        You logged in with a temporary password. Please choose a new permanent password to continue.
    </p>

    <!-- Temporary-password notice -->
    <div class="dn-setnew-banner">
        <strong>&#9888; Action required</strong>
        You must set a new password before you can access your dashboard.
        Your temporary password has already been deactivated.
    </div>

    <!-- Server-side message (error or success) -->
    <asp:Label ID="lblMessage" runat="server" Visible="false" />

    <!-- New password field -->
    <div class="dn-field">
        <label class="dn-label">New Password <span style="color:#ef4444">*</span></label>
        <asp:TextBox ID="txtNewPassword" runat="server"
            TextMode="Password"
            CssClass="dn-input"
            placeholder="At least 8 characters"
            autocomplete="new-password" />
        <asp:RequiredFieldValidator ID="rfvNew" runat="server"
            ControlToValidate="txtNewPassword"
            ErrorMessage="New password is required."
            CssClass="dn-alert-error"
            Display="Dynamic"
            ValidationGroup="setnew" />
        <asp:RegularExpressionValidator ID="revNew" runat="server"
            ControlToValidate="txtNewPassword"
            ValidationExpression="^.{8,}$"
            ErrorMessage="Password must be at least 8 characters."
            CssClass="dn-alert-error"
            Display="Dynamic"
            ValidationGroup="setnew" />
        <div class="dn-pw-rules">Minimum 8 characters.</div>
    </div>

    <!-- Confirm password field -->
    <div class="dn-field">
        <label class="dn-label">Confirm New Password <span style="color:#ef4444">*</span></label>
        <asp:TextBox ID="txtConfirmPassword" runat="server"
            TextMode="Password"
            CssClass="dn-input"
            placeholder="Re-enter your new password"
            autocomplete="new-password" />
        <asp:RequiredFieldValidator ID="rfvConfirm" runat="server"
            ControlToValidate="txtConfirmPassword"
            ErrorMessage="Please confirm your new password."
            CssClass="dn-alert-error"
            Display="Dynamic"
            ValidationGroup="setnew" />
        <asp:CompareValidator ID="cvMatch" runat="server"
            ControlToValidate="txtConfirmPassword"
            ControlToCompare="txtNewPassword"
            ErrorMessage="Passwords do not match."
            CssClass="dn-alert-error"
            Display="Dynamic"
            ValidationGroup="setnew" />
    </div>

    <!-- Submit -->
    <asp:Button ID="btnSetPassword" runat="server"
        Text="Set Password &amp; Continue"
        CssClass="dn-login-btn"
        ValidationGroup="setnew"
        OnClick="btnSetPassword_Click" />

    <p class="dn-back-link">
        <a href="Logout.aspx">&#8592; Cancel and sign out</a>
    </p>
</div>
</form>
</body>
</html>
