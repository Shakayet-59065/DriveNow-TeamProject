<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverPublicProfile.aspx.cs" Inherits="DriveNow.DriverPublicProfile" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Driver Profile — DriveNow</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500&display=swap" rel="stylesheet" />
    <style>
        :root{--navy:#1A2332;--navy-deep:#0D1520;--teal:#0D9488;--teal-light:#14B8A6;--white:#fff;--grey:#94A3B8;--font-head:'Outfit',Arial,sans-serif;--font-body:'DM Sans',Arial,sans-serif;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:var(--font-body);background:var(--navy-deep);color:var(--white);min-height:100vh;}

        nav{display:flex;align-items:center;justify-content:space-between;padding:1rem 2rem;background:rgba(13,21,32,.95);backdrop-filter:blur(12px);position:sticky;top:0;z-index:100;border-bottom:1px solid rgba(255,255,255,.07);}
        .nav-logo{font-family:var(--font-head);font-size:1.4rem;font-weight:800;color:var(--white);text-decoration:none;}
        .nav-logo span{color:var(--teal-light);}
        .btn{display:inline-flex;align-items:center;padding:.55rem 1.2rem;border-radius:8px;font-family:var(--font-head);font-weight:600;font-size:.85rem;text-decoration:none;border:none;cursor:pointer;transition:all .2s;}
        .btn-ghost{background:transparent;color:var(--white);border:1.5px solid rgba(255,255,255,.2);}
        .btn-ghost:hover{border-color:var(--teal-light);color:var(--teal-light);}
        .btn-sm{padding:.4rem .9rem;font-size:.8rem;}

        .page{max-width:760px;margin:0 auto;padding:3rem 2rem 5rem;}

        /* Profile card */
        .profile-card{background:rgba(26,35,50,.85);border:1px solid rgba(255,255,255,.09);border-radius:20px;overflow:hidden;}

        /* Hero banner */
        .hero-banner{background:linear-gradient(135deg,rgba(13,148,136,.22) 0%,rgba(20,184,166,.08) 100%);padding:2.5rem 2rem 2rem;display:flex;align-items:flex-start;gap:1.8rem;border-bottom:1px solid rgba(255,255,255,.07);}
        .avatar{width:96px;height:96px;border-radius:50%;background:linear-gradient(135deg,var(--teal),#0f766e);display:flex;align-items:center;justify-content:center;font-family:var(--font-head);font-size:2rem;font-weight:800;color:#fff;flex-shrink:0;overflow:hidden;border:3px solid rgba(20,184,166,.4);}
        .avatar img{width:100%;height:100%;object-fit:cover;}
        .hero-info{flex:1;min-width:0;}
        .driver-label{font-size:.7rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--teal-light);margin-bottom:.35rem;}
        .driver-name{font-family:var(--font-head);font-size:clamp(1.5rem,4vw,2rem);font-weight:800;line-height:1.15;margin-bottom:.5rem;word-break:break-word;}
        .exp-text{font-size:.82rem;color:var(--grey);margin-bottom:.75rem;}
        .badges{display:flex;flex-wrap:wrap;gap:.5rem;margin-bottom:.5rem;}

        /* Stars */
        .stars{display:flex;align-items:center;gap:.15rem;margin-top:.5rem;}
        .star-full{color:#FBBF24;font-size:1.1rem;}
        .star-empty{color:rgba(255,255,255,.2);font-size:1.1rem;}
        .rating-num{font-family:var(--font-head);font-size:.85rem;font-weight:700;color:var(--teal-light);margin-left:.4rem;}
        .no-rating{font-size:.82rem;color:var(--grey);font-style:italic;}

        /* Badges */
        .gender-badge,.specialty-badge{display:inline-block;padding:.22rem .75rem;border-radius:99px;font-size:.74rem;font-weight:700;}
        .gender-m{background:rgba(59,130,246,.18);color:#93C5FD;}
        .gender-f{background:rgba(236,72,153,.15);color:#F9A8D4;}
        .gender-x{background:rgba(168,85,247,.15);color:#D8B4FE;}
        .specialty-badge{background:rgba(13,148,136,.2);color:var(--teal-light);border:1px solid rgba(13,148,136,.3);}

        /* Body sections */
        .profile-body{padding:1.8rem 2rem;}
        .section-label{font-size:.7rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--teal-light);margin-bottom:.6rem;}
        .bio-text{font-size:.92rem;line-height:1.75;color:rgba(255,255,255,.8);}
        .bio-empty{color:var(--grey);font-style:italic;}

        .divider{height:1px;background:rgba(255,255,255,.07);margin:1.6rem 0;}

        .info-row{display:flex;align-items:center;gap:.6rem;font-size:.88rem;color:rgba(255,255,255,.7);margin-bottom:.55rem;}
        .info-row .info-label{color:var(--grey);min-width:80px;}

        /* Not found */
        .not-found{text-align:center;padding:5rem 2rem;}
        .not-found .icon{font-size:3.5rem;margin-bottom:1rem;}
        .not-found h2{font-family:var(--font-head);font-size:1.4rem;margin-bottom:.5rem;}
        .not-found p{color:var(--grey);font-size:.9rem;margin-bottom:2rem;}

        /* Animations */
        @keyframes fadeUp{from{opacity:0;transform:translateY(18px);}to{opacity:1;transform:none;}}
        .profile-card{animation:fadeUp .45s ease;transition:box-shadow .25s;}
        .profile-card:hover{box-shadow:0 0 0 1px rgba(20,184,166,.2),0 16px 48px rgba(0,0,0,.25);}
        .btn:active{transform:scale(.96);}
        .btn-ghost{transition:border-color .2s,color .2s,transform .18s,box-shadow .18s;}
        .btn-ghost:hover{box-shadow:0 4px 14px rgba(13,148,136,.2);}
        .avatar{transition:transform .25s,box-shadow .25s;}
        .profile-card:hover .avatar{transform:scale(1.04);box-shadow:0 0 0 4px rgba(20,184,166,.25);}

        @media(max-width:600px){
            .hero-banner{flex-direction:column;align-items:center;text-align:center;}
            .badges{justify-content:center;}
            .stars{justify-content:center;}
            .profile-body{padding:1.4rem 1.2rem;}
            .page{padding:2rem 1rem 4rem;}
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
    <form id="form1" runat="server">
        <!-- NAV -->
        <nav>
            <a href="CustomerPortal.aspx" class="nav-logo">Drive<span>Now</span></a>
            <a href="CustomerPortal.aspx" class="btn btn-ghost btn-sm">&#8592; My Dashboard</a>
        </nav>

        <div class="page">

            <%-- Not found panel --%>
            <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
                <div class="not-found">
                    <div class="icon">&#128694;</div>
                    <h2>Driver Not Found</h2>
                    <p>This driver profile doesn't exist or is no longer available.</p>
                    <a href="CustomerPortal.aspx" class="btn btn-ghost">&#8592; Back to Dashboard</a>
                </div>
            </asp:Panel>

            <%-- Profile panel --%>
            <asp:Panel ID="pnlProfile" runat="server" Visible="false">
                <div class="profile-card">

                    <!-- Hero -->
                    <div class="hero-banner">
                        <div class="avatar">
                            <asp:Literal ID="litAvatarContent" runat="server" />
                        </div>
                        <div class="hero-info">
                            <div class="driver-label">Your Driver</div>
                            <div class="driver-name"><asp:Literal ID="litName" runat="server" /></div>
                            <div class="exp-text"><asp:Literal ID="litExp" runat="server" /></div>
                            <div class="badges">
                                <asp:Literal ID="litGenderBadge" runat="server" />
                                <asp:Literal ID="litSpecialtyBadge" runat="server" />
                            </div>
                            <asp:Literal ID="litStars" runat="server" />
                        </div>
                    </div>

                    <!-- Body -->
                    <div class="profile-body">

                        <div class="section-label">About</div>
                        <div class="bio-text"><asp:Literal ID="litBio" runat="server" /></div>

                        <div class="divider"></div>

                        <div class="section-label">Details</div>
                        <div class="info-row">
                            <span class="info-label">Member since</span>
                            <span><asp:Literal ID="litJoinDate" runat="server" /></span>
                        </div>

                        <div style="margin-top:2rem;text-align:center;">
                            <a href="CustomerPortal.aspx" class="btn btn-ghost">&#8592; Back to My Dashboard</a>
                        </div>

                    </div>
                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>
