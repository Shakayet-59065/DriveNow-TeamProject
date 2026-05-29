<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerifyEmail.aspx.cs" Inherits="DriveNow.VerifyEmail" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Verify Email</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800&display=swap" rel="stylesheet" />
    <style>
        :root{--navy:#1A2332;--navy-deep:#0D1520;--teal:#0D9488;--teal-light:#14B8A6;}
        *{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:'Outfit',Arial,sans-serif;background:var(--navy-deep);color:#fff;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:2rem;}
        .card{background:rgba(26,35,50,.9);border:1px solid rgba(255,255,255,.09);border-radius:20px;padding:3rem 2.5rem;max-width:480px;width:100%;text-align:center;}
        .icon{font-size:3.5rem;margin-bottom:1.2rem;}
        h1{font-size:1.6rem;font-weight:800;margin-bottom:.6rem;}
        p{color:#94a3b8;font-size:.93rem;line-height:1.65;margin-bottom:1.4rem;}
        .btn{display:inline-block;background:var(--teal);color:#fff;padding:.75rem 2rem;border-radius:10px;font-weight:700;font-size:.95rem;text-decoration:none;margin-top:.5rem;}
        .btn:hover{background:var(--teal-light);}
        .alert-success{background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.3);color:#5eead4;border-radius:10px;padding:1rem;margin-bottom:1.2rem;font-size:.9rem;}
        .alert-error{background:rgba(239,68,68,.12);border:1px solid rgba(239,68,68,.3);color:#fca5a5;border-radius:10px;padding:1rem;margin-bottom:1.2rem;font-size:.9rem;}
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
<form id="form1" runat="server">
    <div class="card">
        <div class="icon"><asp:Literal ID="litIcon" runat="server" Text="✉️" /></div>
        <h1><asp:Literal ID="litTitle" runat="server" Text="Verifying Email..." /></h1>
        <asp:Label ID="lblMessage" runat="server" Visible="false" />
        <p><asp:Literal ID="litBody" runat="server" /></p>
        <asp:HyperLink ID="lnkAction" runat="server" CssClass="btn" Visible="false" />
    </div>
</form>
</body>
</html>
