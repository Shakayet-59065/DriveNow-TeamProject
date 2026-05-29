<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContributorApply.aspx.cs" Inherits="DriveNow.ContributorApply" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Apply as Contributor</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500&display=swap" rel="stylesheet" />
    <style>
        :root{--navy:#1A2332;--navy-deep:#0D1520;--teal:#0D9488;--teal-light:#14B8A6;--white:#fff;--grey:#94A3B8;--font-head:'Outfit',Arial,sans-serif;--font-body:'DM Sans',Arial,sans-serif;}
        .benefits-hero{background:linear-gradient(135deg,rgba(13,148,136,.18) 0%,rgba(13,21,32,.0) 60%);border:1px solid rgba(13,148,136,.2);border-radius:20px;padding:2.5rem 2rem;margin-bottom:2.5rem;}
        .benefits-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:1.2rem;margin:1.5rem 0;}
        @media(max-width:640px){.benefits-grid{grid-template-columns:1fr;}}
        .benefit-card{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-radius:14px;padding:1.3rem;}
        .benefit-icon{font-size:1.8rem;margin-bottom:.6rem;}
        .benefit-title{font-size:.95rem;font-weight:700;color:#fff;margin-bottom:.35rem;}
        .benefit-desc{font-size:.8rem;color:var(--grey);line-height:1.55;}
        .stats-row{display:grid;grid-template-columns:repeat(3,1fr);gap:1rem;margin-top:1.5rem;}
        @media(max-width:640px){.stats-row{grid-template-columns:1fr 1fr;}}
        .stat-box{text-align:center;background:rgba(13,148,136,.08);border:1px solid rgba(13,148,136,.15);border-radius:12px;padding:1rem;}
        .stat-val{font-size:1.7rem;font-weight:800;color:#14b8a6;line-height:1;}
        .stat-lbl{font-size:.75rem;color:var(--grey);margin-top:.3rem;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:var(--font-body);background:var(--navy-deep);color:var(--white);min-height:100vh;}
        nav{display:flex;align-items:center;justify-content:space-between;padding:1rem 2rem;background:rgba(13,21,32,.95);backdrop-filter:blur(12px);position:sticky;top:0;z-index:100;border-bottom:1px solid rgba(255,255,255,.07);}
        .nav-logo{font-family:var(--font-head);font-size:1.4rem;font-weight:800;color:var(--white);text-decoration:none;}
        .nav-logo span{color:var(--teal-light);}
        .btn{display:inline-flex;align-items:center;padding:.55rem 1.2rem;border-radius:8px;font-family:var(--font-head);font-weight:600;font-size:.85rem;text-decoration:none;border:none;cursor:pointer;transition:all .2s;}
        .btn-teal{background:var(--teal);color:var(--white);}
        .btn-ghost{background:transparent;color:var(--white);border:1.5px solid rgba(255,255,255,.2);}
        .btn-sm{padding:.4rem .9rem;font-size:.8rem;}
        .page{max-width:700px;margin:0 auto;padding:3rem 2rem 5rem;}
        .form-card{background:rgba(26,35,50,.8);border:1px solid rgba(255,255,255,.08);border-radius:16px;padding:2rem;}
        .field{margin-bottom:1.2rem;}
        .field label{display:block;font-size:.78rem;font-weight:600;text-transform:uppercase;letter-spacing:.07em;color:var(--teal-light);margin-bottom:.4rem;}
        .field input,.field select,.field textarea{width:100%;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.12);border-radius:8px;padding:.7rem .95rem;color:#fff;font-size:.9rem;font-family:var(--font-body);outline:none;transition:border-color .2s;}
        .field input:focus,.field select,.field textarea:focus{border-color:var(--teal);}
        .field textarea{resize:vertical;min-height:100px;}
        .field select option{background:#1a2332;color:#fff;}
        .type-cards{display:grid;grid-template-columns:repeat(3,1fr);gap:1rem;margin-bottom:1.5rem;}
        @media(max-width:640px){.type-cards{grid-template-columns:1fr;}}

        /* ── Tablet: 640px–899px ── */
        @media (max-width: 899px) {
            .benefits-grid { grid-template-columns: repeat(2,1fr); }
            .stats-row { grid-template-columns: repeat(3,1fr); }
            .type-cards { grid-template-columns: 1fr 1fr; }
            .page { padding: 2rem 1.2rem 4rem; }
            .form-card { padding: 1.5rem; }
        }

        /* ── Phone: up to 480px ── */
        @media (max-width: 480px) {
            .benefits-grid { grid-template-columns: 1fr; }
            .stats-row { grid-template-columns: 1fr 1fr; }
            .type-cards { grid-template-columns: 1fr; }
            .page { padding: 1.5rem 1rem 3rem; }
            .form-card { padding: 1rem; }
            /* Collapse the vehicle details 2-col grid to single column */
            #vehicleSection > div[style*="grid-template-columns"],
            #driverSection  > div[style*="grid-template-columns"] {
                display: grid !important;
                grid-template-columns: 1fr !important;
            }
            .form-btn { font-size: .9rem; padding: .75rem; }
            h1 { font-size: clamp(1.4rem, 5vw, 1.8rem) !important; }
        }

        /* ── Very small: 380px ── */
        @media (max-width: 380px) {
            .stats-row { grid-template-columns: 1fr; }
            .page { padding: 1.2rem .75rem 2.5rem; }
            .benefit-card { padding: 1rem; }
            .form-card { padding: .85rem; }
            .field input, .field select, .field textarea { font-size: .85rem; }
        }

        .type-card{border:2px solid rgba(255,255,255,.1);border-radius:12px;padding:1.2rem;cursor:pointer;transition:all .2s;}
        .type-card:hover,.type-card.selected{border-color:var(--teal);background:rgba(13,148,136,.08);}
        .type-card input{display:none;}
        .type-icon{font-size:1.8rem;margin-bottom:.5rem;}
        .type-title{font-size:.95rem;font-weight:700;color:#fff;margin-bottom:.2rem;}
        .type-desc{font-size:.78rem;color:var(--grey);}
        .vehicle-section{background:rgba(13,148,136,.07);border:1px solid rgba(13,148,136,.2);border-radius:12px;padding:1.2rem;margin-bottom:1.2rem;display:none;}
        .section-divider{border:none;border-top:1px solid rgba(255,255,255,.08);margin:1.5rem 0;}
        .form-btn{width:100%;background:var(--teal);color:#fff;border:none;border-radius:10px;padding:.85rem;font-size:1rem;font-weight:700;cursor:pointer;font-family:var(--font-head);letter-spacing:.03em;margin-top:.5rem;}
        .form-btn:hover{background:var(--teal-light);}
        .alert-success{background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.35);color:#5eead4;padding:1rem 1.2rem;border-radius:10px;margin-bottom:1.5rem;font-size:.9rem;}
        .alert-error{background:rgba(239,68,68,.12);border:1px solid rgba(239,68,68,.3);color:#fca5a5;padding:1rem 1.2rem;border-radius:10px;margin-bottom:1.5rem;font-size:.9rem;}
        .val-msg{color:#fca5a5;font-size:.78rem;margin-top:.3rem;}
        @keyframes fadeUp{from{opacity:0;transform:translateY(18px);}to{opacity:1;transform:none;}}
        .form-card{animation:fadeUp .4s ease;}
        .benefit-card{transition:transform .2s,border-color .2s,background .2s;}
        .benefit-card:hover{transform:translateY(-3px);border-color:rgba(13,148,136,.35);background:rgba(13,148,136,.07);}
        .type-card{transition:border-color .2s,background .2s,transform .18s;}
        .type-card:hover{transform:translateY(-2px);}
        .form-btn{transition:background .2s,transform .15s;}
        .form-btn:active{transform:scale(.97);}
        .btn:active{transform:scale(.97);}
        .field input:focus,.field select:focus,.field textarea:focus{box-shadow:0 0 0 3px rgba(13,148,136,.18);}
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
<form id="frmContributorApply" runat="server">

<nav>
    <a href="Default.aspx" class="nav-logo">Drive<span>Now</span></a>
    <div>
        <a href="Default.aspx" class="btn btn-ghost btn-sm">&#8592; Back to Home</a>
    </div>
</nav>

<div class="page" style="max-width:820px;">
    <div style="margin-bottom:2rem;">
        <div style="font-size:.75rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--teal-light);margin-bottom:.4rem;">Join DriveNow</div>
        <h1 style="font-family:var(--font-head);font-size:clamp(1.8rem,4vw,2.4rem);font-weight:800;margin-bottom:.6rem;">Contributor Programme</h1>
        <p style="color:var(--grey);font-size:.92rem;line-height:1.6;">Turn your vehicle or driving skill into a rewarding income stream. Join DriveNow's growing network of contributors and earn on your own terms.</p>
    </div>

    <!-- ── Benefits section ── -->
    <div class="benefits-hero">
        <div style="font-size:.75rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--teal-light);margin-bottom:.4rem;">Why Become a Contributor?</div>
        <h2 style="font-family:var(--font-head);font-size:1.55rem;font-weight:800;margin-bottom:.5rem;">Your vehicle. Your schedule. Your income.</h2>
        <p style="color:var(--grey);font-size:.9rem;line-height:1.65;max-width:600px;">
            DriveNow handles bookings, customer service, payments, and logistics — you simply provide your vehicle or your time behind the wheel and collect your earnings every month.
        </p>

        <div class="benefits-grid">
            <div class="benefit-card">
                <div class="benefit-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">£</div>
                <div class="benefit-title">Competitive Earnings</div>
                <div class="benefit-desc">Vehicle owners earn up to <strong style="color:#14b8a6;">£1,200/month</strong> on average. Drivers earn a competitive per-trip rate with weekly payouts.</div>
            </div>
            <div class="benefit-card">
                <div class="benefit-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">CAL</div>
                <div class="benefit-title">Flexible Scheduling</div>
                <div class="benefit-desc">You decide when your vehicle or time is available. No minimum hours, no mandatory shifts — full control over your calendar.</div>
            </div>
            <div class="benefit-card">
                <div class="benefit-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">INS</div>
                <div class="benefit-title">Insurance Coverage</div>
                <div class="benefit-desc">All trips handled through DriveNow are covered by our comprehensive fleet insurance policy at no extra cost to you.</div>
            </div>
            <div class="benefit-card">
                <div class="benefit-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">DASH</div>
                <div class="benefit-title">Real-Time Dashboard</div>
                <div class="benefit-desc">Track your earnings, bookings, and vehicle usage through our contributor dashboard. Full transparency, always.</div>
            </div>
            <div class="benefit-card">
                <div class="benefit-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">SUP</div>
                <div class="benefit-title">Dedicated Support</div>
                <div class="benefit-desc">Your own contributor manager available 24/7 to help with anything from onboarding to maintenance coordination.</div>
            </div>
            <div class="benefit-card">
                <div class="benefit-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">PRO</div>
                <div class="benefit-title">Premium Partner Status</div>
                <div class="benefit-desc">Top contributors earn Premium Partner status — unlocking priority listings, bonus payouts, and exclusive DriveNow merchandise.</div>
            </div>
        </div>

        <!-- Stats row -->
        <div class="stats-row">
            <div class="stat-box">
                <div class="stat-val">£1,200</div>
                <div class="stat-lbl">Avg. monthly earnings</div>
            </div>
            <div class="stat-box">
                <div class="stat-val">3 days</div>
                <div class="stat-lbl">Avg. approval time</div>
            </div>
            <div class="stat-box">
                <div class="stat-val">24/7</div>
                <div class="stat-lbl">Partner support</div>
            </div>
        </div>
    </div>

    <!-- Application form heading -->
    <div style="margin-bottom:1.5rem;">
        <div style="font-size:.75rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--teal-light);margin-bottom:.4rem;">Ready to join?</div>
        <h2 style="font-family:var(--font-head);font-size:1.4rem;font-weight:800;margin-bottom:.4rem;">Submit Your Application</h2>
        <p style="color:var(--grey);font-size:.88rem;line-height:1.6;">Our team reviews every application within 3 business days and will contact you at the email address you provide.</p>
    </div>

    <asp:Label ID="lblSuccess" runat="server" CssClass="alert-success" Visible="false" />
    <asp:Label ID="lblError"   runat="server" CssClass="alert-error"   Visible="false" />

    <asp:Panel ID="pnlForm" runat="server">
        <!-- Type selection -->
        <div style="margin-bottom:1.5rem;">
            <div style="font-size:.78rem;font-weight:600;text-transform:uppercase;letter-spacing:.07em;color:var(--teal-light);margin-bottom:.75rem;">I want to contribute as</div>
            <div class="type-cards">
                <label class="type-card" id="cardOwner" onclick="selectType('VehicleOwner')">
                    <asp:RadioButton ID="rbOwner" runat="server" GroupName="ContribType" />
                    <div class="type-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">VEH</div>
                    <div class="type-title">Vehicle Owner</div>
                    <div class="type-desc">List your vehicle and earn while it's not in use</div>
                </label>
                <label class="type-card" id="cardDriver" onclick="selectType('Driver')">
                    <asp:RadioButton ID="rbDriver" runat="server" GroupName="ContribType" />
                    <div class="type-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">DRV</div>
                    <div class="type-title">Driver</div>
                    <div class="type-desc">Drive for DriveNow on a flexible schedule</div>
                </label>
                <label class="type-card" id="cardOwnerDriver" onclick="selectType('OwnerDriver')">
                    <asp:RadioButton ID="rbOwnerDriver" runat="server" GroupName="ContribType" />
                    <div class="type-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">OWD</div>
                    <div class="type-title">Owner &amp; Driver</div>
                    <div class="type-desc">Own a vehicle AND drive for DriveNow</div>
                </label>
            </div>
            <asp:HiddenField ID="hfContribType" runat="server" Value="" />
            <asp:Label ID="lblTypeError" runat="server" CssClass="val-msg" Visible="false" Text="Please select a contributor type." />
        </div>

        <div class="form-card">
            <!-- Personal details -->
            <div class="field">
                <label>Full Name *</label>
                <asp:TextBox ID="txtFullName" runat="server" MaxLength="100" placeholder="Your full legal name" />
                <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtFullName" CssClass="val-msg" ErrorMessage="Full name is required." Display="Dynamic" />
            </div>
            <div class="field">
                <label>Email Address *</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="150" placeholder="your@email.com" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" CssClass="val-msg" ErrorMessage="Email is required." Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" CssClass="val-msg" ErrorMessage="Enter a valid email." Display="Dynamic" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" />
            </div>
            <div class="field">
                <label>Phone Number *</label>
                <asp:TextBox ID="txtPhone" runat="server" MaxLength="30" placeholder="+45 70 10 20 30" />
                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" CssClass="val-msg" ErrorMessage="Phone number is required." Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone" CssClass="val-msg"
                    ErrorMessage="Phone must start with a country code (e.g. +44 or +45) and contain 7–15 digits total."
                    Display="Dynamic"
                    ValidationExpression="^\+[1-9][0-9\s\-\(\)]{5,17}$" />
                <div style="font-size:.72rem;color:#64748b;margin-top:.25rem;">International format required: +[country code][number] &mdash; e.g. +44 7700 900001</div>
            </div>

            <!-- Vehicle details section (shown when VehicleOwner selected) -->
            <div class="vehicle-section" id="vehicleSection">
                <div style="font-size:.82rem;font-weight:700;color:var(--teal-light);margin-bottom:1rem;text-transform:uppercase;letter-spacing:.07em;">Vehicle Details</div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                    <div class="field">
                        <label>Make</label>
                        <asp:TextBox ID="txtVehicleMake" runat="server" MaxLength="50" placeholder="e.g. BMW" />
                    </div>
                    <div class="field">
                        <label>Model</label>
                        <asp:TextBox ID="txtVehicleModel" runat="server" MaxLength="50" placeholder="e.g. 5 Series" />
                    </div>
                    <div class="field">
                        <label>Year</label>
                        <asp:TextBox ID="txtVehicleYear" runat="server" MaxLength="4" placeholder="2022" TextMode="Number" />
                    </div>
                    <div class="field">
                        <label>Registration No.</label>
                        <asp:TextBox ID="txtVehicleReg" runat="server" MaxLength="20" placeholder="AB12 CDE" />
                    </div>
                    <div class="field">
                        <label>Colour</label>
                        <asp:TextBox ID="txtVehicleColour" runat="server" MaxLength="30" placeholder="e.g. Midnight Blue" />
                    </div>
                    <div class="field">
                        <label>Seats</label>
                        <asp:DropDownList ID="ddlVehicleSeats" runat="server">
                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                            <asp:ListItem Value="2">2</asp:ListItem>
                            <asp:ListItem Value="4">4</asp:ListItem>
                            <asp:ListItem Value="5" Selected="True">5</asp:ListItem>
                            <asp:ListItem Value="7">7</asp:ListItem>
                            <asp:ListItem Value="8">8</asp:ListItem>
                            <asp:ListItem Value="9">9</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="field">
                        <label>Daily Rate (&pound;/day)</label>
                        <asp:TextBox ID="txtVehicleDailyRate" runat="server" TextMode="Number" placeholder="e.g. 85.00" />
                    </div>
                </div>
                <div class="field" style="margin-top:.5rem;">
                    <label>Vehicle Photo</label>
                    <div style="border:2px dashed rgba(255,255,255,.15);border-radius:10px;padding:1.2rem;text-align:center;cursor:pointer;" onclick="document.getElementById('<%= fuVehiclePhoto.ClientID %>').click()">
                        <div id="vehiclePhotoLabel" style="font-size:.8rem;color:#94a3b8;">Click to attach vehicle photo (JPG, PNG, WebP — max 5 MB)</div>
                        <asp:FileUpload ID="fuVehiclePhoto" runat="server" accept=".jpg,.jpeg,.png,.webp" style="display:none;" onchange="updateFileLabel(this.id,'vehiclePhotoLabel')" />
                    </div>
                </div>
            </div>

            <!-- Driver-specific section (shown when Driver selected) -->
            <div class="vehicle-section" id="driverSection">
                <div style="font-size:.82rem;font-weight:700;color:var(--teal-light);margin-bottom:1rem;text-transform:uppercase;letter-spacing:.07em;">Driver Credentials</div>
                <div class="field">
                    <label>Driving Licence Number *</label>
                    <asp:TextBox ID="txtLicenceNumber" runat="server" MaxLength="50" placeholder="e.g. SMIT9701157JS9AB" />
                    <asp:Label ID="lblLicenceError" runat="server" CssClass="val-msg" Visible="false" Text="A valid driving licence number is required for Driver applicants." />
                    <asp:RegularExpressionValidator ID="revLicenceNumber" runat="server"
                        ControlToValidate="txtLicenceNumber"
                        CssClass="val-msg" Display="Dynamic"
                        ErrorMessage="Licence number must be 5–20 characters and include at least 2 letters and 2 digits (e.g. SMIT9701157JS9AB)."
                        ValidationExpression="^(?=(?:.*[A-Za-z]){2})(?=(?:.*[0-9]){2})[A-Za-z0-9\-]{5,20}$" />
                    <div style="font-size:.72rem;color:#64748b;margin-top:.25rem;">Must contain letters and digits — e.g. UK format: SMIT9701157JS9AB</div>
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                    <div class="field">
                        <label>Licence Issue Date</label>
                        <asp:TextBox ID="txtLicenceIssueDate" runat="server" TextMode="Date"
                            onchange="validateLicenceIssueDate(this.value);" />
                        <div id="licenceIssueDateMsg" class="val-msg" style="display:none;"></div>
                        <div style="font-size:.72rem;color:#64748b;margin-top:.3rem;">Must be at least 1 year ago.</div>
                    </div>
                    <div class="field">
                        <label>Licence Expiry Date</label>
                        <asp:TextBox ID="txtLicenceExpiryDate" runat="server" TextMode="Date" />
                        <div style="font-size:.72rem;color:#64748b;margin-top:.3rem;">Date the driving licence expires.</div>
                    </div>
                </div>
                <div class="field">
                    <label>Licence Document (photo / scan)</label>
                    <div style="border:2px dashed rgba(255,255,255,.15);border-radius:10px;padding:1.2rem;text-align:center;cursor:pointer;" onclick="document.getElementById('licenceFile').click()">
                        
                        <div id="licenceLabel" style="font-size:.8rem;color:#94a3b8;">Click to attach licence scan (JPG, PNG, PDF — max 5 MB)</div>
                        <input type="file" id="licenceFile" accept=".jpg,.jpeg,.png,.pdf" style="display:none;" onchange="updateFileLabel('licenceFile','licenceLabel')" />
                    </div>
                    <div style="font-size:.72rem;color:#64748b;margin-top:.35rem;">Document is stored securely and used only for identity verification.</div>
                </div>
                <div class="field">
                    <label>Date of Birth</label>
                    <asp:TextBox ID="txtDateOfBirth" runat="server" TextMode="Date"
                        onchange="validateDOB(this.value);" />
                    <div id="dobValidMsg" class="val-msg" style="display:none;"></div>
                    <div style="font-size:.72rem;color:#64748b;margin-top:.3rem;">Must be on or after 01/01/1970 and at least 18 years ago.</div>
                </div>
                <div class="field">
                    <label>Years of Driving Experience</label>
                    <asp:TextBox ID="txtDrivingYears" runat="server" MaxLength="3" placeholder="e.g. 5" TextMode="Number" />
                </div>
                <div class="field">
                    <label>Driver Profile Photo</label>
                    <div style="border:2px dashed rgba(255,255,255,.15);border-radius:10px;padding:1.2rem;text-align:center;cursor:pointer;" onclick="document.getElementById('<%= fuProfilePhoto.ClientID %>').click()">
                        <div id="profilePhotoLabel" style="font-size:.8rem;color:#94a3b8;">Click to attach profile photo (JPG, PNG — max 5 MB)</div>
                        <asp:FileUpload ID="fuProfilePhoto" runat="server" accept=".jpg,.jpeg,.png" style="display:none;" onchange="updateFileLabel(this.id,'profilePhotoLabel')" />
                    </div>
                </div>
            </div>

            <hr class="section-divider" />

            <!-- CV / Resume (all applicants) -->
            <div class="field">
                <label>CV / Resume (optional but recommended)</label>
                <div style="border:2px dashed rgba(255,255,255,.15);border-radius:10px;padding:1.2rem;text-align:center;cursor:pointer;" onclick="document.getElementById('cvFile').click()">
                    
                    <div id="cvLabel" style="font-size:.8rem;color:#94a3b8;">Click to attach your CV (PDF, DOC, DOCX — max 5 MB)</div>
                    <input type="file" id="cvFile" accept=".pdf,.doc,.docx" style="display:none;" onchange="updateFileLabel('cvFile','cvLabel')" />
                </div>
            </div>

            <div class="field">
                <label>Why do you want to join DriveNow? (optional)</label>
                <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" MaxLength="500" placeholder="Tell us a bit about yourself and why you'd like to contribute..." />
            </div>

            <hr class="section-divider" />

            <!-- Ethical / GDPR consent — REQUIRED checkboxes -->
            <div style="background:rgba(13,148,136,.07);border:1px solid rgba(13,148,136,.2);border-radius:10px;padding:1.1rem 1.2rem;margin-bottom:1.2rem;">
                <div style="font-size:.82rem;font-weight:700;color:#14b8a6;margin-bottom:.6rem;">Data Protection &amp; Ethical Consent</div>
                <div style="font-size:.78rem;color:#94a3b8;line-height:1.65;margin-bottom:.9rem;">
                    DriveNow collects your personal data (name, email, phone
                    <%-- JS will append licence info for driver --%>
                    ) and any documents you upload to evaluate your contributor application. Your data is processed under GDPR Article 6(1)(a) — consent — and Article 6(1)(b) — performance of a contract. You may withdraw your consent at any time by emailing <strong style="color:#5eead4;">privacy@drivenow.dk</strong>. Data is retained for up to 12 months if your application is unsuccessful.
                </div>

                <!-- Consent checkbox 1: Accuracy -->
                <div style="display:flex;align-items:flex-start;gap:.65rem;margin-bottom:.6rem;">
                    <asp:CheckBox ID="chkAccuracy" runat="server" />
                    <label for="<%= chkAccuracy.ClientID %>" style="font-size:.8rem;color:#e2e8f0;line-height:1.5;cursor:pointer;">
                        <strong>Accuracy declaration:</strong> I confirm that all information provided in this form is accurate, complete and truthful. I understand that providing false or misleading information may result in the rejection or withdrawal of my application. *
                    </label>
                </div>

                <!-- Consent checkbox 2: GDPR -->
                <div style="display:flex;align-items:flex-start;gap:.65rem;">
                    <asp:CheckBox ID="chkConsent" runat="server" />
                    <label for="<%= chkConsent.ClientID %>" style="font-size:.8rem;color:#e2e8f0;line-height:1.5;cursor:pointer;">
                        <strong>GDPR consent:</strong> I consent to DriveNow collecting, storing and processing my personal data (including any documents uploaded) for the purpose of assessing my contributor application, in accordance with the General Data Protection Regulation (GDPR). *
                    </label>
                </div>

                <asp:Label ID="lblConsentError" runat="server" CssClass="val-msg" Visible="false" Text="You must accept both declarations above before submitting." />
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit Application" CssClass="form-btn"
                OnClick="btnSubmit_Click"
                OnClientClick="return validateContribForm();" />
        </div>
    </asp:Panel>
</div>

</form>
<script>
    /* ── Validation helpers ───────────────────────────────────── */

    // Called onchange on the DOB input for instant feedback
    function validateDOB(val) {
        var el = document.getElementById('dobValidMsg');
        if (!val) { if (el) el.style.display = 'none'; return true; }
        var dob   = new Date(val + 'T00:00:00');
        var minDt = new Date('1970-01-01T00:00:00');
        var maxDt = new Date(); maxDt.setFullYear(maxDt.getFullYear() - 18);
        var ok = (dob >= minDt && dob <= maxDt);
        if (el) {
            el.style.display = ok ? 'none' : 'block';
            el.textContent   = ok ? '' : 'Date of birth must be between 01 Jan 1970 and 18 years before today.';
        }
        return ok;
    }

    // Called onchange on the licence issue date input
    function validateLicenceIssueDate(val) {
        var el = document.getElementById('licenceIssueDateMsg');
        if (!val) { if (el) el.style.display = 'none'; return true; }
        var issued     = new Date(val + 'T00:00:00');
        var oneYearAgo = new Date(); oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);
        var ok = (issued <= oneYearAgo);
        if (el) {
            el.style.display = ok ? 'none' : 'block';
            el.textContent   = ok ? '' : 'Driving licence must have been issued at least 1 year ago.';
        }
        return ok;
    }

    /* ── Phone country-code validator ─────────────────────────────
       Returns {ok, msg}. Matches per-country expected digit totals. */
    var PHONE_RULES = {
        '1':['US/CA',11,11],'7':['RU',11,11],'20':['EG',11,12],'27':['ZA',11,11],
        '30':['GR',12,12],'31':['NL',11,11],'32':['BE',10,11],'33':['FR',11,11],
        '34':['ES',11,11],'36':['HU',11,11],'39':['IT',10,12],'40':['RO',11,11],
        '41':['CH',11,11],'43':['AT',10,13],'44':['GB',12,12],'45':['DK',10,10],
        '46':['SE',11,13],'47':['NO',10,10],'48':['PL',11,11],'49':['DE',11,13],
        '52':['MX',12,12],'54':['AR',12,13],'55':['BR',12,13],'56':['CL',11,11],
        '57':['CO',12,12],'60':['MY',10,11],'61':['AU',11,11],'62':['ID',10,13],
        '63':['PH',12,12],'64':['NZ',10,12],'65':['SG',10,10],'66':['TH',11,11],
        '81':['JP',11,12],'82':['KR',11,12],'84':['VN',11,12],'86':['CN',13,13],
        '90':['TR',12,12],'91':['IN',12,12],'92':['PK',12,12],'94':['LK',11,11],
        '98':['IR',12,12],'212':['MA',12,12],'213':['DZ',12,12],'216':['TN',11,11],
        '234':['NG',12,13],'254':['KE',12,12],'255':['TZ',12,12],'256':['UG',12,12],
        '880':['BD',12,13],'966':['SA',12,12],'971':['AE',12,12],'972':['IL',12,12],
        '974':['QA',11,11],'977':['NP',12,12],'994':['AZ',12,12],'998':['UZ',12,12]
    };
    function validatePhoneByCountry(val) {
        if (!val) return { ok: false, msg: 'Phone number is required.' };
        if (val.charAt(0) !== '+') return { ok: false, msg: 'Phone must start with a country code, e.g. +44 7700 900000.' };
        var digits = val.replace(/[^\d]/g, '');
        if (digits.length < 7)  return { ok: false, msg: 'Phone number is too short — minimum 7 digits after the country code.' };
        if (digits.length > 15) return { ok: false, msg: 'Phone number exceeds maximum 15 digits (E.164 standard).' };
        var stripped = digits;
        for (var len = 3; len >= 1; len--) {
            var cc = stripped.substring(0, len);
            if (PHONE_RULES[cc]) {
                var r = PHONE_RULES[cc];
                if (digits.length < r[1]) return { ok: false, msg: 'Phone too short for +' + cc + ' (' + r[0] + '). Expected at least ' + r[1] + ' digits total (including country code).' };
                if (digits.length > r[2]) return { ok: false, msg: 'Phone too long for +' + cc + ' (' + r[0] + '). Maximum ' + r[2] + ' digits total (including country code).' };
                break;
            }
        }
        return { ok: true, msg: '' };
    }

    // Called from OnClientClick on the submit button
    // Returns false to block submission if any validation fails
    function validateContribForm() {
        // 1. Phone validation (always required)
        var phoneEl = document.getElementById('<%= txtPhone.ClientID %>');
        if (phoneEl) {
            var pr = validatePhoneByCountry(phoneEl.value.trim());
            if (!pr.ok) {
                // show a red hint below the phone field
                var hint = phoneEl.parentElement ? phoneEl.parentElement.querySelector('.val-msg') : null;
                if (hint) { hint.style.display = 'block'; hint.textContent = pr.msg; }
                else alert(pr.msg);
                phoneEl.focus();
                return false;
            }
        }

        // 2. Driver-specific date checks
        var type = document.getElementById('<%= hfContribType.ClientID %>').value;
        var isDriver = (type === 'Driver' || type === 'OwnerDriver');
        if (!isDriver) return true;

        var dobEl    = document.getElementById('<%= txtDateOfBirth.ClientID %>');
        var issueEl  = document.getElementById('<%= txtLicenceIssueDate.ClientID %>');
        var dobOk    = validateDOB(dobEl   ? dobEl.value   : '');
        var issueOk  = validateLicenceIssueDate(issueEl ? issueEl.value : '');
        return dobOk && issueOk;
    }

    function selectType(type) {
        document.getElementById('<%= hfContribType.ClientID %>').value = type;
        document.getElementById('cardOwner').classList.toggle('selected', type === 'VehicleOwner');
        document.getElementById('cardDriver').classList.toggle('selected', type === 'Driver');
        document.getElementById('cardOwnerDriver').classList.toggle('selected', type === 'OwnerDriver');
        var showVehicle = type === 'VehicleOwner' || type === 'OwnerDriver';
        var showDriver  = type === 'Driver'        || type === 'OwnerDriver';
        document.getElementById('vehicleSection').style.display = showVehicle ? 'block' : 'none';
        document.getElementById('driverSection').style.display  = showDriver  ? 'block' : 'none';
    }
    function updateFileLabel(inputId, labelId) {
        var input = document.getElementById(inputId);
        var label = document.getElementById(labelId);
        if (input && input.files && input.files.length > 0) {
            label.textContent = 'Attached: ' + input.files[0].name;
        }
    }
</script>
</body>
</html>
