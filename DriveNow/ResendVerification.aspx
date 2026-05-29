<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResendVerification.aspx.cs" Inherits="DriveNow.ResendVerification" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Resend Verification</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800&display=swap" rel="stylesheet" />
    <style>
        :root{--navy:#1A2332;--navy-deep:#0D1520;--teal:#0D9488;--teal-light:#14B8A6;}
        *{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:'Outfit',Arial,sans-serif;background:var(--navy-deep);color:#fff;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:2rem;}
        .card{background:rgba(26,35,50,.9);border:1px solid rgba(255,255,255,.09);border-radius:20px;padding:3rem 2.5rem;max-width:440px;width:100%;}
        h1{font-size:1.5rem;font-weight:800;margin-bottom:.5rem;}
        p{color:#94a3b8;font-size:.9rem;line-height:1.65;margin-bottom:1.4rem;}
        .field{margin-bottom:1.2rem;}
        .field label{display:block;font-size:.8rem;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:#14b8a6;margin-bottom:.4rem;}
        .field input{width:100%;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.12);border-radius:8px;padding:.7rem .95rem;color:#fff;font-size:.92rem;outline:none;}
        .field input:focus{border-color:#0d9488;}
        .btn{width:100%;background:#0d9488;color:#fff;border:none;border-radius:10px;padding:.8rem;font-size:.95rem;font-weight:700;cursor:pointer;margin-top:.5rem;}
        .btn:hover{background:#14b8a6;}
        .alert{border-radius:10px;padding:1rem 1.2rem;font-size:.88rem;margin-bottom:1.2rem;}
        .alert-success{background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.3);color:#5eead4;}
        .alert-error{background:rgba(239,68,68,.12);border:1px solid rgba(239,68,68,.3);color:#fca5a5;}
        .back{display:block;text-align:center;color:#64748b;font-size:.82rem;margin-top:1rem;text-decoration:none;}
        .back:hover{color:#fff;}
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
<form id="form1" runat="server">
    <div class="card">
        <div style="font-size:2rem;margin-bottom:1rem;">✉️</div>
        <h1>Resend Verification Email</h1>
        <p>Enter your email address and we'll generate a new verification link for your account.</p>

        <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

        <asp:Panel ID="pnlForm" runat="server">
            <div class="field">
                <label>Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="you@example.com" MaxLength="150" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                    CssClass="alert alert-error" ErrorMessage="Email is required." Display="Dynamic" />
            </div>
            <asp:Button ID="btnResend" runat="server" Text="Resend Verification Link" CssClass="btn"
                OnClick="btnResend_Click" />
        </asp:Panel>

        <a href="Default.aspx" class="back">← Back to Sign In</a>
    </div>
</form>
</body>
</html>
