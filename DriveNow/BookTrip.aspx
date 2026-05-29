<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BookTrip.aspx.cs" Inherits="DriveNow.BookTrip" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Book a Trip — DriveNow</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500&display=swap" rel="stylesheet" />
    <style>
        :root{--navy:#1A2332;--navy-deep:#0D1520;--teal:#0D9488;--teal-light:#14B8A6;--white:#fff;--grey:#94A3B8;--red:#EF4444;--font-head:'Outfit',Arial,sans-serif;--font-body:'DM Sans',Arial,sans-serif;}
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

        .page{max-width:780px;margin:0 auto;padding:2.5rem 2rem 5rem;}
        .back{display:inline-flex;align-items:center;gap:.4rem;color:var(--grey);font-size:.88rem;text-decoration:none;margin-bottom:1.8rem;transition:color .2s;}
        .back:hover{color:var(--white);}

        /* PROGRESS BAR */
        .progress-wrap{display:flex;align-items:center;margin-bottom:2rem;}
        .progress-step{display:flex;flex-direction:column;align-items:center;gap:.35rem;flex:1;position:relative;}
        .progress-step:not(:last-child)::after{content:'';position:absolute;top:14px;left:calc(50% + 14px);right:calc(-50% + 14px);height:2px;background:rgba(255,255,255,.12);}
        .progress-step.done::after,.progress-step.active::after{background:var(--teal);}
        .step-circle{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:var(--font-head);font-size:.82rem;font-weight:700;border:2px solid rgba(255,255,255,.15);color:var(--grey);}
        .progress-step.active .step-circle{background:var(--teal);border-color:var(--teal);color:var(--white);}
        .progress-step.done .step-circle{background:rgba(13,148,136,.3);border-color:var(--teal);color:var(--teal-light);}
        .step-label{font-size:.72rem;color:var(--grey);font-weight:600;text-align:center;}
        .progress-step.active .step-label{color:var(--white);}

        .page-label{font-size:.75rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--teal-light);margin-bottom:.5rem;}
        .page-title{font-family:var(--font-head);font-size:clamp(1.5rem,4vw,2rem);font-weight:800;margin-bottom:1.8rem;}

        .vehicle-card{display:flex;align-items:center;gap:1.2rem;background:rgba(26,35,50,.8);border:1px solid rgba(255,255,255,.1);border-radius:12px;padding:1.2rem;margin-bottom:1.8rem;}
        .vehicle-card img{width:110px;height:70px;object-fit:cover;border-radius:8px;flex-shrink:0;}
        .vc-name{font-family:var(--font-head);font-size:1.1rem;font-weight:700;}
        .vc-rate{color:var(--teal-light);font-family:var(--font-head);font-weight:700;font-size:1rem;margin-top:.3rem;}
        .vc-reg{color:var(--grey);font-size:.8rem;margin-top:.2rem;}

        .form-card{background:rgba(26,35,50,.7);border:1px solid rgba(255,255,255,.08);border-radius:14px;padding:2rem;}
        .form-grid{display:grid;grid-template-columns:1fr 1fr;gap:1.2rem;}
        .form-group{display:flex;flex-direction:column;gap:.4rem;}
        .form-group.full{grid-column:1/-1;}
        label{font-size:.82rem;font-weight:600;color:rgba(255,255,255,.75);}
        label .req{color:var(--red);margin-left:.2rem;}
        input,select,textarea{background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.12);border-radius:8px;padding:.7rem 1rem;color:var(--white);font-family:var(--font-body);font-size:.9rem;width:100%;transition:border .2s;}
        input:focus,select:focus,textarea:focus{outline:none;border-color:var(--teal);}
        input.invalid,select.invalid,textarea.invalid{border-color:var(--red)!important;}
        select option{background:#1A2332;}
        textarea{resize:vertical;min-height:70px;}
        .field-error{font-size:.76rem;color:#FCA5A5;display:none;}
        .field-error.show{display:block;}
        .divider{grid-column:1/-1;border:none;border-top:1px solid rgba(255,255,255,.08);margin:.2rem 0;}
        .section-label{grid-column:1/-1;font-family:var(--font-head);font-size:.78rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:var(--teal-light);margin-top:.3rem;}
        .submit-row{grid-column:1/-1;display:flex;gap:1rem;margin-top:.5rem;}
        .btn-submit{flex:1;padding:.85rem;font-size:1rem;font-family:var(--font-head);font-weight:700;background:var(--teal);color:var(--white);border:none;border-radius:10px;cursor:pointer;transition:background .2s;}
        .btn-submit:hover{background:var(--teal-light);}
        .alert{padding:.85rem 1.2rem;border-radius:8px;font-size:.9rem;margin-bottom:1.5rem;}
        .alert-error{background:rgba(239,68,68,.12);border:1px solid rgba(239,68,68,.3);color:#FCA5A5;}
        .alert-info{background:rgba(13,148,136,.1);border:1px solid rgba(13,148,136,.25);color:#5EEAD4;font-size:.88rem;}

        /* BOOKING SUMMARY */
        .summary-box{background:rgba(13,148,136,.07);border:1px solid rgba(13,148,136,.25);border-radius:12px;padding:1.5rem;margin-bottom:1.5rem;}
        .summary-title{font-family:var(--font-head);font-size:.82rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--teal-light);margin-bottom:1rem;}
        .summary-row{display:flex;justify-content:space-between;align-items:baseline;padding:.45rem 0;border-bottom:1px solid rgba(255,255,255,.05);font-size:.88rem;}
        .summary-row:last-child{border-bottom:none;padding-top:.8rem;margin-top:.2rem;}
        .summary-row .lbl{color:var(--grey);}
        .summary-row .val{font-weight:600;text-align:right;}
        .summary-total{font-family:var(--font-head);font-size:1.25rem;font-weight:800;color:var(--teal-light);}
        .summary-total .lbl{color:var(--white);font-size:.95rem;}

        /* INSURANCE CARDS */
        .ins-grid{display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-bottom:1.5rem;}
        .ins-card{border:2px solid rgba(255,255,255,.1);border-radius:12px;padding:1.3rem 1.2rem 1.2rem;cursor:pointer;transition:all .2s;position:relative;}
        .ins-card:hover{border-color:rgba(13,148,136,.5);background:rgba(13,148,136,.05);}
        .ins-card.selected{border-color:var(--teal);background:rgba(13,148,136,.12);}
        .ins-card input[type=radio]{position:absolute;opacity:0;pointer-events:none;}
        .ins-tier{font-family:var(--font-head);font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.09em;color:var(--teal-light);margin-bottom:.3rem;}
        .ins-name{font-family:var(--font-head);font-size:1rem;font-weight:700;margin-bottom:.5rem;}
        .ins-price{font-family:var(--font-head);font-size:1.1rem;font-weight:800;color:var(--teal-light);margin-bottom:.7rem;}
        .ins-price span{font-size:.78rem;font-weight:400;color:var(--grey);}
        .ins-features{list-style:none;font-size:.8rem;color:rgba(255,255,255,.7);}
        .ins-features li{padding:.18rem 0;}
        .ins-features li::before{content:'✓ ';color:var(--teal-light);font-weight:700;}
        .ins-check{position:absolute;top:.8rem;right:.8rem;width:20px;height:20px;border-radius:50%;border:2px solid rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;font-size:.68rem;font-weight:700;transition:all .2s;}
        .ins-card.selected .ins-check{background:var(--teal);border-color:var(--teal);color:#fff;}
        .ins-card.selected .ins-check::after{content:'✓';}
        @media(max-width:580px){.ins-grid{grid-template-columns:1fr;}}

        /* PAYMENT CARD */
        .card-row{display:grid;grid-template-columns:2fr 1fr 1fr;gap:1rem;}
        .card-hint{font-size:.75rem;color:var(--grey);margin-top:.25rem;}
        .secure-note{grid-column:1/-1;display:flex;align-items:center;gap:.5rem;font-size:.8rem;color:var(--grey);padding:.75rem 1rem;background:rgba(255,255,255,.03);border-radius:8px;border:1px solid rgba(255,255,255,.06);}
        .secure-note svg{flex-shrink:0;opacity:.6;}
        .checkbox-row{grid-column:1/-1;display:flex;align-items:flex-start;gap:.75rem;padding:.5rem 0;}
        .checkbox-row input[type=checkbox]{width:18px;height:18px;flex-shrink:0;margin-top:2px;accent-color:var(--teal);}
        .checkbox-row label{font-size:.83rem;color:rgba(255,255,255,.75);font-weight:400;}
        .checkbox-row label a{color:var(--teal-light);text-decoration:none;}
        .checkbox-row label a:hover{text-decoration:underline;}
        .payment-icons{display:flex;gap:.5rem;margin-bottom:1.2rem;}
        .pay-icon{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.1);border-radius:5px;padding:.3rem .6rem;font-size:.7rem;font-weight:700;color:rgba(255,255,255,.5);letter-spacing:.05em;}

        /* ADD-ONS */
        .addon-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:.85rem;margin-bottom:1.5rem;}
        .addon-card{display:flex;align-items:center;gap:.85rem;background:rgba(26,35,50,.7);border:2px solid rgba(255,255,255,.1);border-radius:12px;padding:1rem 1.1rem;cursor:pointer;transition:all .2s;position:relative;}
        .addon-card:hover{border-color:rgba(13,148,136,.45);background:rgba(13,148,136,.05);}
        .addon-card.addon-selected{border-color:var(--teal);background:rgba(13,148,136,.12);}
        .addon-chk-wrap{position:relative;display:flex;align-items:center;}
        .addon-chk-wrap input[type=checkbox]{width:18px;height:18px;accent-color:var(--teal);cursor:pointer;}
        .addon-icon{font-size:1.4rem;line-height:1;flex-shrink:0;}
        .addon-info{flex:1;min-width:0;}
        .addon-name{font-family:var(--font-head);font-size:.88rem;font-weight:700;display:block;}
        .addon-price{color:var(--teal-light);font-size:.78rem;font-weight:600;}

        /* DRIVER SELECTION PANEL */
        .driver-panel-label{font-family:var(--font-head);font-size:.78rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:var(--teal-light);margin-bottom:.7rem;grid-column:1/-1;}
        .driver-panel-sub{color:var(--grey);font-size:.76rem;font-weight:400;margin-left:.4rem;}
        .driver-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:.85rem;grid-column:1/-1;}
        .driver-card{background:rgba(26,35,50,.7);border:2px solid rgba(255,255,255,.1);border-radius:12px;padding:1.1rem;cursor:pointer;transition:all .2s;position:relative;display:flex;flex-direction:column;align-items:center;text-align:center;gap:.55rem;}
        .driver-card:hover{border-color:rgba(13,148,136,.5);background:rgba(13,148,136,.06);}
        .driver-card.driver-selected{border-color:var(--teal);background:rgba(13,148,136,.13);}
        .driver-avatar{width:52px;height:52px;border-radius:50%;background:linear-gradient(135deg,var(--teal),#0891b2);display:flex;align-items:center;justify-content:center;font-family:var(--font-head);font-size:1.1rem;font-weight:800;color:#fff;flex-shrink:0;border:2px solid rgba(13,148,136,.35);}
        .driver-avatar.auto-avatar{background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.12);color:var(--grey);font-size:1.3rem;}
        .driver-card-name{font-family:var(--font-head);font-size:.88rem;font-weight:700;line-height:1.2;}
        .driver-card-exp{font-size:.75rem;color:var(--grey);}
        .driver-card-bio{font-size:.74rem;color:rgba(255,255,255,.55);line-height:1.4;margin-top:.1rem;}
        .driver-profile-link{font-size:.72rem;color:var(--teal-light);text-decoration:none;margin-top:.2rem;display:inline-block;}
        .driver-profile-link:hover{text-decoration:underline;}
        .driver-check{position:absolute;top:.6rem;right:.6rem;width:18px;height:18px;border-radius:50%;border:2px solid rgba(255,255,255,.2);transition:all .2s;}
        .driver-card.driver-selected .driver-check{background:var(--teal);border-color:var(--teal);}
        .driver-card.driver-selected .driver-check::after{content:'\2713';display:block;text-align:center;font-size:.7rem;font-weight:800;color:#fff;line-height:18px;}
        .driver-stars{display:flex;gap:.05rem;font-size:.82rem;margin-top:.15rem;letter-spacing:.03rem;}
        .star-full{color:#fbbf24;}
        .star-half{color:#fbbf24;opacity:.6;}
        .star-empty{color:rgba(255,255,255,.2);}
        .driver-rating-num{font-size:.72rem;color:#fbbf24;font-weight:700;margin-left:.2rem;vertical-align:middle;}
        .driver-gender-badge{display:inline-block;padding:.12rem .45rem;border-radius:99px;font-size:.68rem;font-weight:700;border:1px solid;margin-right:.3rem;}
        .gender-m{background:rgba(59,130,246,.12);border-color:rgba(59,130,246,.3);color:#93c5fd;}
        .gender-f{background:rgba(236,72,153,.12);border-color:rgba(236,72,153,.3);color:#f9a8d4;}
        .gender-x{background:rgba(139,92,246,.12);border-color:rgba(139,92,246,.3);color:#c4b5fd;}
        .driver-specialty{display:inline-block;padding:.12rem .5rem;border-radius:99px;font-size:.68rem;font-weight:600;background:rgba(13,148,136,.12);border:1px solid rgba(13,148,136,.25);color:var(--teal-light);margin-top:.2rem;}

        /* Animations */
        @keyframes fadeUp{from{opacity:0;transform:translateY(18px);}to{opacity:1;transform:none;}}
        .form-card{animation:fadeUp .4s ease;}
        .ins-card{transition:border-color .2s,background .2s,transform .18s,box-shadow .18s;}
        .ins-card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(13,148,136,.18);}
        .driver-card{transition:border-color .2s,background .2s,transform .18s,box-shadow .18s;}
        .driver-card:hover{transform:translateY(-2px);box-shadow:0 6px 18px rgba(0,0,0,.25);}
        .btn-submit:active,.btn:active{transform:scale(.97);}
        input:focus,select:focus,textarea:focus{box-shadow:0 0 0 3px rgba(13,148,136,.18);}
        .addon-card{transition:border-color .2s,background .2s,transform .15s;}
        .addon-card:hover{transform:translateY(-2px);}
        .vehicle-card{transition:box-shadow .2s;}
        .vehicle-card:hover{box-shadow:0 8px 28px rgba(0,0,0,.3);}

        @media(max-width:580px){
            .form-grid,.card-row{grid-template-columns:1fr;}
            .vehicle-card img{width:80px;height:52px;}
            .progress-step:not(:last-child)::after{display:none;}
            .addon-grid{grid-template-columns:1fr;}
            .driver-grid{grid-template-columns:1fr 1fr;}
        }

        /* ── Tablet: up to 768px ── */
        @media (max-width: 768px) {
            .vehicle-card { flex-direction: column; }
            .vehicle-card img { width: 100% !important; height: 180px !important; }
            .form-grid { grid-template-columns: 1fr !important; }
            .ins-grid  { grid-template-columns: 1fr !important; }
            .addon-grid { grid-template-columns: 1fr !important; }
            .summary-box { margin-top: 1rem; }
        }

        /* ── Phone: up to 480px ── */
        @media (max-width: 480px) {
            .form-card { padding: 1rem; border-radius: 10px; }
            .progress-wrap { font-size: .6rem; gap: .3rem; }
            .step-circle { width: 26px; height: 26px; font-size: .75rem; }
            .summary-total { font-size: 1.1rem; }
            .ins-card { padding: 1rem; }
            .ins-name { font-size: .9rem; }
            .ins-price { font-size: 1rem; }
            .addon-card { padding: .85rem; }
        }

        /* ── Very small: 380px ── */
        @media (max-width: 380px) {
            .form-card { padding: .85rem; }
            .progress-wrap { display: none; }
        }
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
    <a href="BrowseFleet.aspx" class="back">← Back to Fleet</a>

    <!-- PROGRESS INDICATOR -->
    <asp:Panel ID="pnlProgress" runat="server">
        <div class="progress-wrap">
            <div class="progress-step" id="progressStep1" runat="server">
                <div class="step-circle">1</div>
                <div class="step-label">Trip Details</div>
            </div>
            <div class="progress-step" id="progressStep2" runat="server">
                <div class="step-circle">2</div>
                <div class="step-label">Insurance</div>
            </div>
            <div class="progress-step" id="progressStep3" runat="server">
                <div class="step-circle">3</div>
                <div class="step-label">Add-Ons</div>
            </div>
            <div class="progress-step" id="progressStep4" runat="server">
                <div class="step-circle">4</div>
                <div class="step-label">Payment</div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="alert alert-error"><asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <!-- VEHICLE CARD -->
    <div class="vehicle-card">
        <img src="" runat="server" id="imgVehicle" alt="Vehicle" />
        <div>
            <div class="vc-name"><asp:Literal ID="litVehicleName" runat="server" /></div>
            <div class="vc-rate">£<asp:Literal ID="litRate" runat="server" /> / day</div>
            <div class="vc-reg">Reg: <asp:Literal ID="litReg" runat="server" /></div>
        </div>
    </div>

    <!-- ===== STEP 1: TRIP DETAILS ===== -->
    <asp:Panel ID="pnlStep1" runat="server">
        <div class="page-label">Step 1 of 4</div>
        <div class="page-title">Trip Details</div>
        <div class="form-card">
            <div class="form-grid">
                <div class="section-label">Trip Type</div>
                <div class="form-group full">
                    <label for="ddlTripType">Trip Type <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlTripType" runat="server" />
                    <span class="field-error" id="errTripType">Please select a trip type.</span>
                </div>

                <hr class="divider" />
                <div class="section-label">Pickup Details</div>

                <div class="form-group full">
                    <label>Pickup Location <span class="req">*</span></label>
                    <asp:TextBox ID="txtPickupLocation" runat="server" placeholder="e.g. Niels Brock Copenhagen, Danasvej 3" MaxLength="200" />
                    <span class="field-error" id="errPickupLoc">Pickup location is required.</span>
                </div>
                <div class="form-group">
                    <label>Pickup Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtPickupDate" runat="server" TextMode="Date" />
                    <span class="field-error" id="errPickupDate">Please enter a valid future date.</span>
                </div>
                <div class="form-group">
                    <label>Pickup Time <span class="req">*</span></label>
                    <asp:TextBox ID="txtPickupTime" runat="server" TextMode="Time" />
                    <span class="field-error" id="errPickupTime">Pickup time is required.</span>
                </div>

                <hr class="divider" />
                <div class="section-label">Drop-off Details</div>

                <div class="form-group full">
                    <label>Drop-off Location <span class="req">*</span></label>
                    <asp:TextBox ID="txtDropoffLocation" runat="server" placeholder="e.g. Copenhagen Airport, Terminal 2" MaxLength="200" />
                    <span class="field-error" id="errDropoffLoc">Drop-off location is required.</span>
                </div>
                <div class="form-group">
                    <label>Drop-off Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtDropoffDate" runat="server" TextMode="Date" />
                    <span class="field-error" id="errDropoffDate">Drop-off must be after pickup.</span>
                </div>
                <div class="form-group">
                    <label>Drop-off Time <span class="req">*</span></label>
                    <asp:TextBox ID="txtDropoffTime" runat="server" TextMode="Time" />
                    <span class="field-error" id="errDropoffTime">Drop-off time is required.</span>
                </div>

                <div class="form-group full">
                    <label>Additional Notes <span style="color:var(--grey);font-weight:400;">(optional)</span></label>
                    <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" placeholder="Any special requirements, accessibility needs, or requests..." MaxLength="500" />
                </div>

                <!-- DRIVER SELECTION — shown for non-self-drive trips -->
                <asp:HiddenField ID="hdnDriverID" runat="server" Value="" />
                <div id="driverSelectionWrap" style="display:none;grid-column:1/-1;">
                    <hr class="divider" style="margin-bottom:.9rem;" />
                    <div class="driver-panel-label">Select Your Driver <span class="driver-panel-sub">(optional — leave unselected for auto-assignment)</span></div>
                    <div class="driver-grid">
                        <!-- Auto-assign option (default) -->
                        <div class="driver-card driver-auto driver-selected" id="drvAuto" onclick="selectDriver(this, '')">
                            <div class="driver-check"></div>
                            <div class="driver-avatar auto-avatar">AUTO</div>
                            <div class="driver-card-name">Any Available Driver</div>
                            <div class="driver-card-exp">Auto-assigned at booking</div>
                        </div>
                        <!-- Active drivers from DB -->
                        <asp:Repeater ID="rptDrivers" runat="server">
                            <ItemTemplate>
                                <div class="driver-card" id="drvCard_<%# Eval("DriverID") %>" onclick="selectDriver(this, '<%# Eval("DriverID") %>')">
                                    <div class="driver-check"></div>
                                    <div class="driver-avatar"><%# GetDriverInitials(Eval("FullName")) %></div>
                                    <div class="driver-card-name"><%# System.Web.HttpUtility.HtmlEncode(Eval("FullName").ToString()) %></div>
                                    <%# GetDriverStarsHtml(Eval("Rating")) %>
                                    <div style="display:flex;align-items:center;flex-wrap:wrap;gap:.15rem;justify-content:center;">
                                        <%# GetGenderBadgeHtml(Eval("Gender")) %>
                                        <%# GetSpecialtyHtml(Eval("Specialty")) %>
                                    </div>
                                    <div class="driver-card-exp"><%# GetDriverExp(Eval("JoinDate")) %></div>
                                    <%# GetDriverBioHtml(Eval("Bio")) %>
                                    <a href="DriverPublicProfile.aspx?id=<%# Eval("DriverID") %>" class="driver-profile-link" onclick="event.stopPropagation();" target="_blank">View Profile &#8599;</a>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="submit-row">
                    <button type="button" class="btn btn-ghost" onclick="history.back()">Cancel</button>
                    <asp:Button ID="btnContinue" runat="server" Text="Continue to Insurance →" CssClass="btn-submit" OnClick="btnContinue_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </asp:Panel>

    <!-- ===== STEP 2: INSURANCE ===== -->
    <asp:Panel ID="pnlStep2" runat="server" Visible="false">
        <div class="page-label">Step 2 of 4</div>
        <div class="page-title">Choose Your Insurance</div>

        <asp:HiddenField ID="hdnInsurance" runat="server" Value="basic:0" />

        <div class="ins-grid">
            <!-- Basic -->
            <div class="ins-card" id="ins-basic" onclick="selectInsurance('basic',0)">
                <div class="ins-check"></div>
                <div class="ins-tier">Basic</div>
                <div class="ins-name">Third-Party Cover</div>
                <div class="ins-price">FREE <span>/ day</span></div>
                <ul class="ins-features">
                    <li>Third-party liability only</li>
                    <li>Legal minimum cover</li>
                    <li>Driver pays all excess on damage</li>
                </ul>
            </div>
            <!-- Standard -->
            <div class="ins-card" id="ins-standard" onclick="selectInsurance('standard',10)">
                <div class="ins-check"></div>
                <div class="ins-tier">Standard</div>
                <div class="ins-name">Damage & Theft</div>
                <div class="ins-price">+£10 <span>/ day</span></div>
                <ul class="ins-features">
                    <li>Collision damage waiver</li>
                    <li>Theft protection</li>
                    <li>£500 excess applies</li>
                </ul>
            </div>
            <!-- Premium -->
            <div class="ins-card" id="ins-premium" onclick="selectInsurance('premium',20)">
                <div class="ins-check"></div>
                <div class="ins-tier">Premium</div>
                <div class="ins-name">Full Comprehensive</div>
                <div class="ins-price">+£20 <span>/ day</span></div>
                <ul class="ins-features">
                    <li>Full comprehensive cover</li>
                    <li>Zero excess guarantee</li>
                    <li>Personal accident included</li>
                </ul>
            </div>
            <!-- Elite -->
            <div class="ins-card" id="ins-elite" onclick="selectInsurance('elite',35)">
                <div class="ins-check"></div>
                <div class="ins-tier">Elite</div>
                <div class="ins-name">Ultimate Protection</div>
                <div class="ins-price">+£35 <span>/ day</span></div>
                <ul class="ins-features">
                    <li>Full comprehensive cover</li>
                    <li>Zero excess, 24/7 roadside</li>
                    <li>Replacement vehicle guarantee</li>
                </ul>
            </div>
        </div>

        <div style="display:flex;gap:1rem;margin-top:.5rem;">
            <asp:Button ID="btnBackInsurance" runat="server" Text="← Back" CssClass="btn btn-ghost" OnClick="btnBackInsurance_Click" CausesValidation="false" />
            <asp:Button ID="btnNextInsurance" runat="server" Text="Continue to Add-Ons →" CssClass="btn-submit" OnClick="btnNextInsurance_Click" CausesValidation="false" style="flex:1;padding:.85rem;font-size:1rem;font-family:var(--font-head);font-weight:700;background:var(--teal);color:#fff;border:none;border-radius:10px;cursor:pointer;" />
        </div>
    </asp:Panel>

    <!-- ===== STEP 3: ADD-ONS ===== -->
    <asp:Panel ID="pnlStep3" runat="server" Visible="false">
        <div class="page-label">Step 3 of 4</div>
        <div class="page-title">Extras &amp; Add-Ons</div>

        <div class="addon-grid">
            <label class="addon-card" for="chkGPS" onclick="toggleAddon(this)">
                <div class="addon-chk-wrap"><asp:CheckBox ID="chkGPS" runat="server" CssClass="addon-chk" /></div>
                <span class="addon-icon" style="font-size:.7rem;font-weight:700;letter-spacing:.04em;">GPS</span>
                <span class="addon-info">
                    <span class="addon-name">GPS Navigation</span>
                    <span class="addon-price">+£5/day</span>
                </span>
            </label>
            <label class="addon-card" for="chkMobileMount" onclick="toggleAddon(this)">
                <div class="addon-chk-wrap"><asp:CheckBox ID="chkMobileMount" runat="server" CssClass="addon-chk" /></div>
                <span class="addon-icon" style="font-size:.7rem;font-weight:700;letter-spacing:.04em;">MOB</span>
                <span class="addon-info">
                    <span class="addon-name">Mobile Mount &amp; Charger</span>
                    <span class="addon-price">+£3/day</span>
                </span>
            </label>
            <label class="addon-card" for="chkBabySeat" onclick="toggleAddon(this)">
                <div class="addon-chk-wrap"><asp:CheckBox ID="chkBabySeat" runat="server" CssClass="addon-chk" /></div>
                <span class="addon-icon" style="font-size:.7rem;font-weight:700;letter-spacing:.04em;">SEAT</span>
                <span class="addon-info">
                    <span class="addon-name">Baby/Child Seat (0–3 yrs)</span>
                    <span class="addon-price">+£8/day</span>
                </span>
            </label>
            <label class="addon-card" for="chkBoosterSeat" onclick="toggleAddon(this)">
                <div class="addon-chk-wrap"><asp:CheckBox ID="chkBoosterSeat" runat="server" CssClass="addon-chk" /></div>
                <span class="addon-icon" style="font-size:.7rem;font-weight:700;letter-spacing:.04em;">BST</span>
                <span class="addon-info">
                    <span class="addon-name">Booster Seat (4–11 yrs)</span>
                    <span class="addon-price">+£5/day</span>
                </span>
            </label>
            <label class="addon-card" for="chkCycleCarrier" onclick="toggleAddon(this)">
                <div class="addon-chk-wrap"><asp:CheckBox ID="chkCycleCarrier" runat="server" CssClass="addon-chk" /></div>
                <span class="addon-icon" style="font-size:.7rem;font-weight:700;letter-spacing:.04em;">BIKE</span>
                <span class="addon-info">
                    <span class="addon-name">Cycle Carrier (up to 3 bikes)</span>
                    <span class="addon-price">+£10/day</span>
                </span>
            </label>
            <label class="addon-card" for="chkRoofBox" onclick="toggleAddon(this)">
                <div class="addon-chk-wrap"><asp:CheckBox ID="chkRoofBox" runat="server" CssClass="addon-chk" /></div>
                <span class="addon-icon" style="font-size:.7rem;font-weight:700;letter-spacing:.04em;">ROOF</span>
                <span class="addon-info">
                    <span class="addon-name">Roof Box (400L)</span>
                    <span class="addon-price">+£12/day</span>
                </span>
            </label>
            <label class="addon-card" for="chkWifiHotspot" onclick="toggleAddon(this)">
                <div class="addon-chk-wrap"><asp:CheckBox ID="chkWifiHotspot" runat="server" CssClass="addon-chk" /></div>
                <span class="addon-icon" style="font-size:.7rem;font-weight:700;letter-spacing:.04em;">4G</span>
                <span class="addon-info">
                    <span class="addon-name">4G WiFi Hotspot</span>
                    <span class="addon-price">+£6/day</span>
                </span>
            </label>
            <label class="addon-card" for="chkDashcam" onclick="toggleAddon(this)">
                <div class="addon-chk-wrap"><asp:CheckBox ID="chkDashcam" runat="server" CssClass="addon-chk" /></div>
                <span class="addon-icon" style="font-size:.7rem;font-weight:700;letter-spacing:.04em;">CAM</span>
                <span class="addon-info">
                    <span class="addon-name">Dashcam (front + rear)</span>
                    <span class="addon-price">+£4/day</span>
                </span>
            </label>
        </div>

        <div style="display:flex;gap:1rem;margin-top:.5rem;">
            <asp:Button ID="btnBackAddons" runat="server" Text="← Back" CssClass="btn btn-ghost" OnClick="btnBackAddons_Click" CausesValidation="false" />
            <asp:Button ID="btnNextAddons" runat="server" Text="Continue to Payment →" CssClass="btn-submit" OnClick="btnNextAddons_Click" CausesValidation="false" style="flex:1;padding:.85rem;font-size:1rem;font-family:var(--font-head);font-weight:700;background:var(--teal);color:#fff;border:none;border-radius:10px;cursor:pointer;" />
        </div>
    </asp:Panel>

    <!-- ===== STEP 4: PAYMENT ===== -->
    <asp:Panel ID="pnlStep4" runat="server" Visible="false">
        <div class="page-label">Step 4 of 4</div>
        <div class="page-title">Secure Payment</div>

        <!-- BOOKING SUMMARY -->
        <div class="summary-box">
            <div class="summary-title">Booking Summary</div>
            <div class="summary-row"><span class="lbl">Vehicle</span><span class="val"><asp:Literal ID="litSummaryVehicle" runat="server" /></span></div>
            <div class="summary-row"><span class="lbl">Pickup</span><span class="val"><asp:Literal ID="litSummaryPickup" runat="server" /></span></div>
            <div class="summary-row"><span class="lbl">Drop-off</span><span class="val"><asp:Literal ID="litSummaryDropoff" runat="server" /></span></div>
            <div class="summary-row"><span class="lbl">Trip Type</span><span class="val"><asp:Literal ID="litSummaryTripType" runat="server" /></span></div>
            <div class="summary-row"><span class="lbl">Duration</span><span class="val"><asp:Literal ID="litSummaryDays" runat="server" /></span></div>
            <div class="summary-row"><span class="lbl">Insurance</span><span class="val"><asp:Literal ID="litSummaryInsurance" runat="server" /></span></div>
            <asp:Literal ID="litSummaryAddons" runat="server" />
            <div class="summary-row summary-total">
                <span class="lbl">Total</span>
                <span class="val summary-total"><asp:Literal ID="litSummaryTotal" runat="server" /></span>
            </div>
        </div>

        <div class="alert alert-info">
             This is a simulated payment for demonstration purposes. No real payment will be taken.
            Your card details are <strong>not stored</strong>.
        </div>

        <div class="form-card">
            <div class="payment-icons">
                <span class="pay-icon">VISA</span>
                <span class="pay-icon">MC</span>
                <span class="pay-icon">AMEX</span>
                <span class="pay-icon">PAYPAL</span>
            </div>

            <div class="form-grid">
                <div class="section-label">Card Details</div>

                <div class="form-group full">
                    <label>Cardholder Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtCardName" runat="server" placeholder="Name as it appears on your card" MaxLength="100" />
                    <span class="field-error" id="errCardName">Cardholder name is required.</span>
                </div>

                <div class="form-group full">
                    <label>Card Number <span class="req">*</span></label>
                    <asp:TextBox ID="txtCardNumber" runat="server" placeholder="1234 5678 9012 3456" MaxLength="19" />
                    <span class="card-hint">Enter 16-digit card number</span>
                    <span class="field-error" id="errCardNumber">Please enter a valid 16-digit card number.</span>
                </div>

                <div class="card-row" style="grid-column:1/-1;display:grid;grid-template-columns:1fr 1fr 1fr;gap:1rem;">
                    <div class="form-group">
                        <label>Expiry Month <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlExpiryMonth" runat="server">
                            <asp:ListItem Value="">Month</asp:ListItem>
                            <asp:ListItem Value="01">01 - Jan</asp:ListItem>
                            <asp:ListItem Value="02">02 - Feb</asp:ListItem>
                            <asp:ListItem Value="03">03 - Mar</asp:ListItem>
                            <asp:ListItem Value="04">04 - Apr</asp:ListItem>
                            <asp:ListItem Value="05">05 - May</asp:ListItem>
                            <asp:ListItem Value="06">06 - Jun</asp:ListItem>
                            <asp:ListItem Value="07">07 - Jul</asp:ListItem>
                            <asp:ListItem Value="08">08 - Aug</asp:ListItem>
                            <asp:ListItem Value="09">09 - Sep</asp:ListItem>
                            <asp:ListItem Value="10">10 - Oct</asp:ListItem>
                            <asp:ListItem Value="11">11 - Nov</asp:ListItem>
                            <asp:ListItem Value="12">12 - Dec</asp:ListItem>
                        </asp:DropDownList>
                        <span class="field-error" id="errExpiry">Please select a valid expiry date.</span>
                    </div>
                    <div class="form-group">
                        <label>Expiry Year <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlExpiryYear" runat="server">
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>CVV / CVC <span class="req">*</span></label>
                        <asp:TextBox ID="txtCVV" runat="server" placeholder="123" MaxLength="4" />
                        <span class="card-hint">3 or 4 digits on the back</span>
                        <span class="field-error" id="errCVV">CVV must be 3 or 4 digits.</span>
                    </div>
                </div>

                <div class="secure-note full">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                    Your payment information is encrypted and processed securely. DriveNow does not store card details.
                </div>

                <hr class="divider" />
                <div class="section-label">Agreement</div>

                <div class="checkbox-row">
                    <asp:CheckBox ID="chkTerms" runat="server" />
                    <label for="<%= chkTerms.ClientID %>">
                        I agree to DriveNow's <a href="#" onclick="return false;">Terms &amp; Conditions</a> and
                        <a href="#" onclick="return false;">Privacy Policy</a>. I confirm the booking details above are correct.
                        <span class="req">*</span>
                    </label>
                </div>
                <span class="field-error" id="errTerms" style="grid-column:1/-1;">You must accept the terms and conditions to proceed.</span>

                <div class="checkbox-row">
                    <asp:CheckBox ID="chkDataConsent" runat="server" />
                    <label for="<%= chkDataConsent.ClientID %>">
                        I consent to DriveNow processing my personal data for booking purposes in accordance with GDPR.
                        <span class="req">*</span>
                    </label>
                </div>
                <span class="field-error" id="errDataConsent" style="grid-column:1/-1;">GDPR consent is required to complete your booking.</span>

                <div class="submit-row">
                    <asp:Button ID="btnBack" runat="server" Text="← Back" CssClass="btn btn-ghost" OnClick="btnBack_Click" CausesValidation="false" />
                    <asp:Button ID="btnPay" runat="server" Text="Confirm &amp; Pay" CssClass="btn-submit" OnClick="btnPay_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </asp:Panel>
</div>
</form>

<script>
// Insurance card selection
function selectInsurance(code, perDay) {
    document.querySelectorAll('.ins-card').forEach(function(c) { c.classList.remove('selected'); });
    var card = document.getElementById('ins-' + code);
    if (card) card.classList.add('selected');
    var hdnField = document.querySelector('[id$="hdnInsurance"]');
    if (hdnField) hdnField.value = code + ':' + perDay;
}
// Add-on card toggle visual
function toggleAddon(label) {
    // use setTimeout so checkbox state is updated first
    setTimeout(function() {
        var chk = label.querySelector('input[type=checkbox]');
        if (chk) {
            if (chk.checked) label.classList.add('addon-selected');
            else label.classList.remove('addon-selected');
        }
    }, 0);
}
// Auto-select Basic on page load (if insurance panel is visible)
document.addEventListener('DOMContentLoaded', function () {
    var hdnField = document.querySelector('[id$="hdnInsurance"]');
    if (hdnField) {
        var parts = hdnField.value.split(':');
        if (parts.length === 2) selectInsurance(parts[0], parseInt(parts[1], 10));
        else selectInsurance('basic', 0);
    }

    // Restore addon-selected state on postback
    document.querySelectorAll('.addon-card').forEach(function(label) {
        var chk = label.querySelector('input[type=checkbox]');
        if (chk && chk.checked) label.classList.add('addon-selected');
    });

        // Auto-format card number input
    var cardInput = document.querySelector('[id$="txtCardNumber"]');
    if (cardInput) {
        cardInput.addEventListener('input', function () {
            var v = this.value.replace(/\D/g, '').substring(0, 16);
            this.value = v.replace(/(.{4})/g, '$1 ').trim();
        });
    }

    // Show driver panel based on trip type selection
    var ddlTripType = document.querySelector('[id$="ddlTripType"]');
    if (ddlTripType) {
        ddlTripType.addEventListener('change', toggleDriverPanel);
        toggleDriverPanel.call(ddlTripType); // run on load to restore postback state
    }
});

function toggleDriverPanel() {
    var wrap = document.getElementById('driverSelectionWrap');
    if (!wrap) return;
    var selected = this.options[this.selectedIndex];
    if (!selected || !selected.value) { wrap.style.display = 'none'; return; }
    var text = selected.text.toLowerCase();
    var isSelfDrive = text.indexOf('self-drive') !== -1 || text.indexOf('self drive') !== -1;
    wrap.style.display = isSelfDrive ? 'none' : 'block';
}

function selectDriver(card, driverID) {
    document.querySelectorAll('.driver-card').forEach(function(c) { c.classList.remove('driver-selected'); });
    card.classList.add('driver-selected');
    var hdnField = document.querySelector('[id$="hdnDriverID"]');
    if (hdnField) hdnField.value = driverID;
}
</script>
</body>
</html>
