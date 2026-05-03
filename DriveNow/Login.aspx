<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="DriveNow.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Login</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f5f7;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .login-box {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
            width: 360px;
        }
        h2 {
            text-align: center;
            color: #1a1a2e;
            margin-bottom: 24px;
        }
        .field {
            margin-bottom: 16px;
        }
        label {
            display: block;
            font-weight: bold;
            margin-bottom: 4px;
            color: #333;
            font-size: 13px;
        }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        .btn-login {
            width: 100%;
            padding: 12px;
            background-color: #1a1a2e;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 15px;
            cursor: pointer;
            margin-top: 8px;
        }
        .btn-login:hover {
            background-color: #2d3561;
        }
        .error {
            color: red;
            font-size: 13px;
            text-align: center;
            margin-top: 10px;
        }
        .logo {
            text-align: center;
            font-size: 24px;
            font-weight: bold;
            color: #1a1a2e;
            margin-bottom: 8px;
        }
        .tagline {
            text-align: center;
            color: #999;
            font-size: 12px;
            margin-bottom: 28px;
        }
    </style>
</head>
<body>
    <form id="frmLogin" runat="server">
        <div class="login-box">
            <div class="logo">DriveNow</div>
            <div class="tagline">Your ride. Your choice.</div>
            <h2>Staff Login</h2>

            <div class="field">
                <label for="txtUsername">Username</label>
                <asp:TextBox ID="txtUsername" runat="server" placeholder="Enter username" />
            </div>

            <div class="field">
                <label for="txtPassword">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Enter password" />
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn-login" OnClick="btnLogin_Click" />

            <asp:Label ID="lblError" runat="server" CssClass="error" Visible="false" />
        </div>
    </form>
</body>
</html>
