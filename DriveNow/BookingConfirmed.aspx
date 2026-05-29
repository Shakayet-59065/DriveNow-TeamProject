<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BookingConfirmed.aspx.cs" Inherits="DriveNow.BookingConfirmed" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Booking Confirmed — DriveNow</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500&display=swap" rel="stylesheet" />
    <style>
        :root{--navy:#1A2332;--navy-deep:#0D1520;--teal:#0D9488;--teal-light:#14B8A6;--white:#fff;--grey:#94A3B8;--green:#22C55E;--font-head:'Outfit',Arial,sans-serif;--font-body:'DM Sans',Arial,sans-serif;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:var(--font-body);background:var(--navy-deep);color:var(--white);min-height:100vh;}

        nav{display:flex;align-items:center;justify-content:space-between;padding:1rem 2rem;background:rgba(13,21,32,.95);border-bottom:1px solid rgba(255,255,255,.07);}
        .nav-logo{font-family:var(--font-head);font-size:1.4rem;font-weight:800;color:var(--white);text-decoration:none;}
        .nav-logo span{color:var(--teal-light);}
        .btn{display:inline-flex;align-items:center;padding:.55rem 1.3rem;border-radius:8px;font-family:var(--font-head);font-weight:600;font-size:.88rem;text-decoration:none;border:none;cursor:pointer;transition:all .2s;}
        .btn-teal{background:var(--teal);color:var(--white);}
        .btn-teal:hover{background:var(--teal-light);}
        .btn-ghost{background:transparent;color:var(--white);border:1.5px solid rgba(255,255,255,.2);}
        .btn-ghost:hover{border-color:var(--white);}

        .page{max-width:680px;margin:0 auto;padding:3rem 2rem 5rem;text-align:center;}

        .check-ring{width:90px;height:90px;border-radius:50%;border:3px solid var(--green);display:flex;align-items:center;justify-content:center;margin:0 auto 1.8rem;background:rgba(34,197,94,.08);}
        .check-ring svg{color:var(--green);}

        .page-title{font-family:var(--font-head);font-size:clamp(1.6rem,4vw,2.2rem);font-weight:800;margin-bottom:.5rem;}
        .page-sub{color:var(--grey);font-size:.96rem;margin-bottom:2rem;}

        .ref-box{background:rgba(13,148,136,.1);border:2px solid rgba(13,148,136,.35);border-radius:12px;padding:1.2rem 1.5rem;margin-bottom:2rem;display:inline-block;min-width:280px;}
        .ref-label{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.12em;color:var(--teal-light);margin-bottom:.4rem;}
        .ref-number{font-family:var(--font-head);font-size:1.7rem;font-weight:800;letter-spacing:.07em;color:var(--white);}

        .detail-card{background:rgba(26,35,50,.7);border:1px solid rgba(255,255,255,.09);border-radius:14px;padding:1.6rem;margin-bottom:1.8rem;text-align:left;}
        .detail-title{font-family:var(--font-head);font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.1em;color:var(--teal-light);margin-bottom:1rem;}
        .detail-row{display:flex;justify-content:space-between;align-items:baseline;padding:.5rem 0;border-bottom:1px solid rgba(255,255,255,.05);font-size:.88rem;}
        .detail-row:last-child{border-bottom:none;}
        .detail-row .lbl{color:var(--grey);}
        .detail-row .val{font-weight:600;text-align:right;max-width:65%;}
        .detail-total .val{color:var(--teal-light);font-size:1.1rem;font-family:var(--font-head);}

        .info-box{background:rgba(13,148,136,.07);border:1px solid rgba(13,148,136,.2);border-radius:10px;padding:1.1rem 1.3rem;margin-bottom:1.8rem;text-align:left;font-size:.87rem;color:rgba(255,255,255,.8);line-height:1.65;}
        .info-box strong{color:var(--white);}

        .note-box{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07);border-radius:10px;padding:.9rem 1.2rem;margin-bottom:2rem;font-size:.83rem;color:var(--grey);}

        .action-btns{display:flex;gap:1rem;justify-content:center;flex-wrap:wrap;}
        .btn-lg{padding:.75rem 2rem;font-size:.96rem;}
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
<form id="form1" runat="server">
<nav>
    <a href="Default.aspx" class="nav-logo">Drive<span>Now</span></a>
    <a href="CustomerPortal.aspx" class="btn btn-ghost">My Dashboard</a>
</nav>

<div class="page">
    <div class="check-ring" aria-hidden="true">
        <svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="20 6 9 17 4 12"/>
        </svg>
    </div>

    <h1 class="page-title">Booking Confirmed!</h1>
    <p class="page-sub">Your DriveNow booking is confirmed. Keep your reference handy.</p>

    <div class="ref-box">
        <div class="ref-label">Booking Reference</div>
        <div class="ref-number"><asp:Literal ID="litBookingRef" runat="server" /></div>
    </div>

    <div class="detail-card">
        <div class="detail-title">Booking Details</div>
        <div class="detail-row"><span class="lbl">Vehicle</span><span class="val"><asp:Literal ID="litVehicle" runat="server" /></span></div>
        <div class="detail-row"><span class="lbl">Pickup</span><span class="val"><asp:Literal ID="litPickup" runat="server" /></span></div>
        <div class="detail-row"><span class="lbl">Drop-off</span><span class="val"><asp:Literal ID="litDropoff" runat="server" /></span></div>
        <div class="detail-row"><span class="lbl">Duration</span><span class="val"><asp:Literal ID="litDays" runat="server" /></span></div>
        <div class="detail-row"><span class="lbl">Insurance</span><span class="val"><asp:Literal ID="litInsurance" runat="server" /></span></div>
        <div class="detail-row"><span class="lbl">Add-Ons</span><span class="val"><asp:Literal ID="litAddons" runat="server" /></span></div>
        <div class="detail-row detail-total"><span class="lbl">Total Charged</span><span class="val"><asp:Literal ID="litTotal" runat="server" /></span></div>
    </div>

    <asp:Literal ID="litInstructions" runat="server" />

    <div class="note-box">
        A confirmation has been sent to your registered email address.
    </div>

    <div class="action-btns">
        <a href="CustomerPortal.aspx" class="btn btn-teal btn-lg">View My Bookings</a>
        <a href="BrowseFleet.aspx" class="btn btn-ghost btn-lg">Browse More Vehicles</a>
    </div>
</div>
</form>
</body>
</html>
