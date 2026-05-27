<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Careers.aspx.cs" Inherits="DriveNow.Careers" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Careers</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500&display=swap" rel="stylesheet" />
    <style>
        :root{--navy:#1A2332;--navy-deep:#0D1520;--teal:#0D9488;--teal-light:#14B8A6;--white:#fff;--grey:#94A3B8;--font-head:'Outfit',Arial,sans-serif;--font-body:'DM Sans',Arial,sans-serif;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:var(--font-body);background:var(--navy-deep);color:var(--white);min-height:100vh;}
        nav{display:flex;align-items:center;justify-content:space-between;padding:1rem 2rem;background:rgba(13,21,32,.95);backdrop-filter:blur(12px);position:sticky;top:0;z-index:100;border-bottom:1px solid rgba(255,255,255,.07);}
        .nav-logo{font-family:var(--font-head);font-size:1.4rem;font-weight:800;color:var(--white);text-decoration:none;}
        .nav-logo span{color:var(--teal-light);}
        .btn{display:inline-flex;align-items:center;padding:.55rem 1.2rem;border-radius:8px;font-family:var(--font-head);font-weight:600;font-size:.85rem;text-decoration:none;border:none;cursor:pointer;transition:all .2s;}
        .btn-teal{background:var(--teal);color:var(--white);}
        .btn-ghost{background:transparent;color:var(--white);border:1.5px solid rgba(255,255,255,.2);}
        .btn-sm{padding:.4rem .9rem;font-size:.8rem;}

        /* Hero */
        .hero{padding:5rem 2rem 3rem;text-align:center;background:linear-gradient(180deg,rgba(13,148,136,.08) 0%,transparent 100%);}
        .hero-tag{font-size:.75rem;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:var(--teal-light);margin-bottom:.6rem;}
        .hero h1{font-family:var(--font-head);font-size:clamp(2rem,5vw,3rem);font-weight:800;margin-bottom:1rem;line-height:1.15;}
        .hero p{color:var(--grey);font-size:1rem;max-width:560px;margin:0 auto 2rem;line-height:1.7;}

        /* Role cards */
        .roles{max-width:900px;margin:0 auto;padding:0 2rem 3rem;}
        .roles-title{font-family:var(--font-head);font-size:1.2rem;font-weight:700;margin-bottom:1.2rem;color:var(--white);}
        .role-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:1rem;margin-bottom:3rem;}
        .role-card{background:rgba(26,35,50,.8);border:1px solid rgba(255,255,255,.08);border-radius:14px;padding:1.4rem;cursor:pointer;transition:all .2s;}
        .role-card:hover,.role-card.selected{border-color:var(--teal);background:rgba(13,148,136,.1);}
        .role-icon{font-size:1.8rem;margin-bottom:.6rem;}
        .role-title{font-size:.95rem;font-weight:700;color:#fff;margin-bottom:.3rem;}
        .role-desc{font-size:.78rem;color:var(--grey);line-height:1.5;}
        .role-badge{display:inline-block;margin-top:.6rem;background:rgba(13,148,136,.2);color:var(--teal-light);font-size:.7rem;font-weight:700;letter-spacing:.05em;padding:.2rem .55rem;border-radius:20px;}

        /* Form */
        .apply-section{max-width:700px;margin:0 auto;padding:0 2rem 5rem;}
        .form-card{background:rgba(26,35,50,.8);border:1px solid rgba(255,255,255,.08);border-radius:16px;padding:2rem;}
        .form-title{font-family:var(--font-head);font-size:1.15rem;font-weight:700;margin-bottom:1.4rem;padding-bottom:.75rem;border-bottom:1px solid rgba(255,255,255,.07);}
        .field{margin-bottom:1.2rem;}
        .field label{display:block;font-size:.78rem;font-weight:600;text-transform:uppercase;letter-spacing:.07em;color:var(--teal-light);margin-bottom:.4rem;}
        .field input,.field select,.field textarea{width:100%;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.12);border-radius:8px;padding:.7rem .95rem;color:#fff;font-size:.9rem;font-family:var(--font-body);outline:none;transition:border-color .2s;}
        .field input:focus,.field select:focus,.field textarea:focus{border-color:var(--teal);}
        .field textarea{resize:vertical;min-height:120px;}
        .field select option{background:#1a2332;color:#fff;}
        .field-row{display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
        .section-divider{border:none;border-top:1px solid rgba(255,255,255,.08);margin:1.5rem 0;}
        .cv-upload{border:2px dashed rgba(255,255,255,.15);border-radius:10px;padding:1.5rem;text-align:center;color:var(--grey);font-size:.85rem;cursor:pointer;transition:border-color .2s;}
        .cv-upload:hover{border-color:var(--teal);}
        .cv-upload input[type=file]{display:none;}
        .cv-upload-icon{font-size:1.8rem;margin-bottom:.4rem;}
        .form-btn{width:100%;background:var(--teal);color:#fff;border:none;border-radius:10px;padding:.85rem;font-size:1rem;font-weight:700;cursor:pointer;font-family:var(--font-head);letter-spacing:.03em;margin-top:.5rem;}
        .form-btn:hover{background:var(--teal-light);}
        .alert-success{background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.35);color:#5eead4;padding:1.2rem 1.4rem;border-radius:10px;margin-bottom:1.5rem;font-size:.92rem;line-height:1.6;}
        .alert-error{background:rgba(239,68,68,.12);border:1px solid rgba(239,68,68,.3);color:#fca5a5;padding:1rem 1.2rem;border-radius:10px;margin-bottom:1.5rem;font-size:.9rem;}
        .val-msg{color:#fca5a5;font-size:.78rem;margin-top:.3rem;}
        .gdpr-note{background:rgba(13,148,136,.08);border:1px solid rgba(13,148,136,.2);border-radius:10px;padding:1rem;margin-bottom:1.2rem;font-size:.8rem;color:#5eead4;line-height:1.6;}

        /* Values strip */
        .values{background:rgba(26,35,50,.5);border-top:1px solid rgba(255,255,255,.06);border-bottom:1px solid rgba(255,255,255,.06);padding:2.5rem 2rem;margin-bottom:3rem;}
        .values-inner{max-width:900px;margin:0 auto;display:grid;grid-template-columns:repeat(auto-fill,minmax(190px,1fr));gap:1.5rem;}
        .value-item{text-align:center;}
        .value-icon{font-size:1.6rem;margin-bottom:.5rem;}
        .value-name{font-size:.88rem;font-weight:700;color:#fff;margin-bottom:.2rem;}
        .value-desc{font-size:.75rem;color:var(--grey);line-height:1.4;}
        @media(max-width:600px){.field-row{grid-template-columns:1fr;}}
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
<form id="frmCareers" runat="server">

<nav>
    <a href="Default.aspx" class="nav-logo">Drive<span>Now</span></a>
    <div>
        <a href="Default.aspx" class="btn btn-ghost btn-sm">&#8592; Back to Home</a>
    </div>
</nav>

<!-- Hero -->
<div class="hero">
    <div class="hero-tag">We're hiring</div>
    <h1>Build the future of<br />urban mobility with us</h1>
    <p>Whether you want to drive, support our customers, or shape our operations — there's a place for you at DriveNow.</p>
</div>

<!-- Company values strip -->
<div class="values">
    <div class="values-inner">
        <div class="value-item">
            <div class="value-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">FLX</div>
            <div class="value-name">Flexible Hours</div>
            <div class="value-desc">Work schedules that fit your life</div>
        </div>
        <div class="value-item">
            <div class="value-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">GRW</div>
            <div class="value-name">Growth</div>
            <div class="value-desc">Clear paths to senior roles</div>
        </div>
        <div class="value-item">
            <div class="value-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">TEAM</div>
            <div class="value-name">Great Team</div>
            <div class="value-desc">Collaborative, inclusive culture</div>
        </div>
        <div class="value-item">
            <div class="value-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">PAY</div>
            <div class="value-name">Competitive Pay</div>
            <div class="value-desc">Market-rate compensation</div>
        </div>
    </div>
</div>

<!-- Open roles -->
<div class="roles">
    <div class="roles-title">Open positions</div>
    <div class="role-grid">
        <div class="role-card" onclick="pickRole('Driver')">
            <div class="role-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">DRV</div>
            <div class="role-title">Driver</div>
            <div class="role-desc">Chauffeur our customers across Copenhagen and beyond. Flexible shifts, competitive per-trip pay.</div>
            <div class="role-badge">Full-time / Part-time</div>
        </div>
        <div class="role-card" onclick="pickRole('Customer Support')">
            <div class="role-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">SUP</div>
            <div class="role-title">Customer Support</div>
            <div class="role-desc">Help customers with bookings, questions and complaints via chat, email and phone.</div>
            <div class="role-badge">Full-time</div>
        </div>
        <div class="role-card" onclick="pickRole('Fleet Operations')">
            <div class="role-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">OPS</div>
            <div class="role-title">Fleet Operations</div>
            <div class="role-desc">Coordinate vehicle availability, inspections and maintenance scheduling.</div>
            <div class="role-badge">Full-time</div>
        </div>
        <div class="role-card" onclick="pickRole('Marketing & Growth')">
            <div class="role-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">MKT</div>
            <div class="role-title">Marketing &amp; Growth</div>
            <div class="role-desc">Drive brand awareness and customer acquisition through digital campaigns.</div>
            <div class="role-badge">Full-time</div>
        </div>
        <div class="role-card" onclick="pickRole('Software Developer')">
            <div class="role-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">DEV</div>
            <div class="role-title">Software Developer</div>
            <div class="role-desc">Build and maintain the DriveNow platform. .NET, SQL, and cloud tech stack.</div>
            <div class="role-badge">Full-time</div>
        </div>
        <div class="role-card" onclick="pickRole('Other / Open Application')">
            <div class="role-icon" style="font-size:.65rem;font-weight:800;letter-spacing:.06em;">GEN</div>
            <div class="role-title">Open Application</div>
            <div class="role-desc">Don't see your role? Send an open application and we'll find the right fit.</div>
            <div class="role-badge">Any</div>
        </div>
    </div>
</div>

<!-- Application form -->
<div class="apply-section">
    <asp:Label ID="lblSuccess" runat="server" CssClass="alert-success" Visible="false" />
    <asp:Label ID="lblError"   runat="server" CssClass="alert-error"   Visible="false" />

    <asp:Panel ID="pnlForm" runat="server">
        <div class="form-card">
            <div class="form-title">Submit Your Application</div>

            <!-- Personal details -->
            <div class="field-row">
                <div class="field">
                    <label>First Name *</label>
                    <asp:TextBox ID="txtFirstName" runat="server" MaxLength="60" placeholder="Jane" />
                    <asp:RequiredFieldValidator ID="rfvFirst" runat="server" ControlToValidate="txtFirstName" CssClass="val-msg" ErrorMessage="First name is required." Display="Dynamic" />
                </div>
                <div class="field">
                    <label>Last Name *</label>
                    <asp:TextBox ID="txtLastName" runat="server" MaxLength="60" placeholder="Doe" />
                    <asp:RequiredFieldValidator ID="rfvLast" runat="server" ControlToValidate="txtLastName" CssClass="val-msg" ErrorMessage="Last name is required." Display="Dynamic" />
                </div>
            </div>
            <div class="field">
                <label>Email Address *</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="150" placeholder="jane@email.com" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" CssClass="val-msg" ErrorMessage="Email is required." Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" CssClass="val-msg" ErrorMessage="Enter a valid email." Display="Dynamic" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" />
            </div>
            <div class="field">
                <label>Phone Number *</label>
                <asp:TextBox ID="txtPhone" runat="server" MaxLength="30" placeholder="+45 70 10 20 30" />
                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" CssClass="val-msg" ErrorMessage="Phone is required." Display="Dynamic" />
            </div>

            <hr class="section-divider" />

            <div class="field">
                <label>Position of Interest *</label>
                <asp:DropDownList ID="ddlRole" runat="server">
                    <asp:ListItem Value="" Text="-- Select a position --" />
                    <asp:ListItem Value="Driver" Text="Driver" />
                    <asp:ListItem Value="Customer Support" Text="Customer Support" />
                    <asp:ListItem Value="Fleet Operations" Text="Fleet Operations" />
                    <asp:ListItem Value="Marketing & Growth" Text="Marketing &amp; Growth" />
                    <asp:ListItem Value="Software Developer" Text="Software Developer" />
                    <asp:ListItem Value="Other / Open Application" Text="Open Application" />
                </asp:DropDownList>
                <asp:RequiredFieldValidator ID="rfvRole" runat="server" ControlToValidate="ddlRole" CssClass="val-msg" InitialValue="" ErrorMessage="Please select a position." Display="Dynamic" />
                <asp:Label ID="lblRoleError" runat="server" CssClass="val-msg" Visible="false" />
            </div>
            <div class="field">
                <label>Availability *</label>
                <asp:DropDownList ID="ddlAvailability" runat="server">
                    <asp:ListItem Value="" Text="-- Select availability --" />
                    <asp:ListItem Value="Full-time" Text="Full-time (37+ hrs/week)" />
                    <asp:ListItem Value="Part-time" Text="Part-time (under 37 hrs/week)" />
                    <asp:ListItem Value="Flexible" Text="Flexible / Freelance" />
                    <asp:ListItem Value="Weekends" Text="Weekends only" />
                </asp:DropDownList>
                <asp:RequiredFieldValidator ID="rfvAvail" runat="server" ControlToValidate="ddlAvailability" CssClass="val-msg" InitialValue="" ErrorMessage="Please select your availability." Display="Dynamic" />
            </div>

            <hr class="section-divider" />

            <!-- Driver licence section — shown only when Driver role selected -->
            <div id="licenceSection" style="display:none;background:rgba(13,148,136,.07);border:1px solid rgba(13,148,136,.2);border-radius:12px;padding:1.2rem;margin-bottom:1.2rem;">
                <div style="font-size:.78rem;font-weight:700;color:var(--teal-light);text-transform:uppercase;letter-spacing:.07em;margin-bottom:.9rem;">Driver Credentials</div>
                <div class="field">
                    <label>Driving Licence Number *</label>
                    <asp:TextBox ID="txtLicenceNumber" runat="server" MaxLength="50" placeholder="e.g. SMIT9701157JS9A" />
                    <asp:Label ID="lblLicenceError" runat="server" CssClass="val-msg" Visible="false" Text="Driving licence number is required for the Driver position." />
                </div>
                <div class="field">
                    <label>Licence Document (photo or scan)</label>
                    <div class="cv-upload" onclick="document.getElementById('licenceFile').click()">
                        <div class="cv-upload-icon"></div>
                        <div id="licenceLabel">Click to attach licence scan (JPG, PNG, PDF — max 5 MB)</div>
                        <input type="file" id="licenceFile" accept=".jpg,.jpeg,.png,.pdf" onchange="updateFileLabel('licenceFile','licenceLabel')" />
                    </div>
                    <div style="font-size:.72rem;color:var(--grey);margin-top:.35rem;">Stored securely for identity verification purposes only.</div>
                </div>
                <div class="field-row">
                    <div class="field">
                        <label>Years of Driving Experience</label>
                        <asp:TextBox ID="txtDrivingYears" runat="server" MaxLength="3" placeholder="e.g. 5" TextMode="Number" />
                    </div>
                    <div class="field">
                        <label>Licence Country of Issue</label>
                        <asp:TextBox ID="txtLicenceCountry" runat="server" MaxLength="60" placeholder="e.g. Denmark" />
                    </div>
                </div>
            </div>

            <!-- CV Upload -->
            <div class="field">
                <label>CV / Resume *</label>
                <div class="cv-upload" onclick="document.getElementById('cvFile').click()">
                    <div class="cv-upload-icon"></div>
                    <div id="cvLabel">Click to attach your CV (PDF, DOC, DOCX — max 5 MB)</div>
                    <input type="file" id="cvFile" accept=".pdf,.doc,.docx" onchange="updateFileLabel('cvFile','cvLabel')" />
                </div>
            </div>

            <div class="field">
                <label>Cover Letter / Tell us about yourself *</label>
                <asp:TextBox ID="txtCoverLetter" runat="server" TextMode="MultiLine" MaxLength="1000" placeholder="Tell us why you want to work at DriveNow, any relevant experience, and what makes you a great fit..." />
                <asp:RequiredFieldValidator ID="rfvCover" runat="server" ControlToValidate="txtCoverLetter" CssClass="val-msg" ErrorMessage="Please provide a short cover letter." Display="Dynamic" />
            </div>

            <div class="field">
                <label>LinkedIn or Portfolio URL (optional)</label>
                <asp:TextBox ID="txtLinkedIn" runat="server" MaxLength="250" placeholder="https://linkedin.com/in/yourprofile" />
            </div>

            <hr class="section-divider" />

            <!-- Ethical / GDPR consent — REQUIRED -->
            <div class="gdpr-note" style="background:rgba(13,148,136,.07);border:1px solid rgba(13,148,136,.2);border-radius:10px;padding:1.1rem 1.2rem;margin-bottom:1.2rem;">
                <strong>Data Protection &amp; Ethical Consent</strong><br /><br />
                DriveNow collects your personal data (name, email, phone, position interest, cover letter) and any documents you upload solely to evaluate your job application. Your data is processed under GDPR Article 6(1)(a) — consent — and Article 6(1)(b) — performance of a contract. Driving licence scans are used for identity verification only. You may withdraw consent at any time by emailing <strong>privacy@drivenow.dk</strong>. Unsuccessful applications are retained for up to 6 months then securely deleted.<br /><br />

                <div style="display:flex;align-items:flex-start;gap:.65rem;margin-bottom:.6rem;">
                    <asp:CheckBox ID="chkAccuracy" runat="server" />
                    <label for="<%= chkAccuracy.ClientID %>" style="font-size:.8rem;color:#e2e8f0;line-height:1.5;cursor:pointer;">
                        <strong>Accuracy declaration:</strong> I confirm that all information and documents provided are accurate, genuine and truthful. I understand that misrepresentation may result in the rejection or withdrawal of my application. *
                    </label>
                </div>

                <div style="display:flex;align-items:flex-start;gap:.65rem;">
                    <asp:CheckBox ID="chkConsent" runat="server" />
                    <label for="<%= chkConsent.ClientID %>" style="font-size:.8rem;color:#e2e8f0;line-height:1.5;cursor:pointer;">
                        <strong>GDPR consent:</strong> I consent to DriveNow collecting, storing and processing my personal data and any uploaded documents for the purpose of assessing my job application, in accordance with GDPR. *
                    </label>
                </div>

                <asp:Label ID="lblConsentError" runat="server" CssClass="val-msg" Visible="false" Text="You must accept both declarations above before submitting your application." />
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit Application" CssClass="form-btn" OnClick="btnSubmit_Click" />
        </div>
    </asp:Panel>
</div>

</form>
<script>
    // Pre-fill role dropdown when a role card is clicked
    function pickRole(role) {
        var dd = document.getElementById('<%= ddlRole.ClientID %>');
        for (var i = 0; i < dd.options.length; i++) {
            if (dd.options[i].value === role) {
                dd.selectedIndex = i;
                break;
            }
        }
        // Show/hide driver licence section
        document.getElementById('licenceSection').style.display = (role === 'Driver') ? 'block' : 'none';
        // Highlight selected card
        var cards = document.querySelectorAll('.role-card');
        cards.forEach(function(c) {
            c.classList.remove('selected');
            if (c.getAttribute('onclick') === "pickRole('" + role + "')") {
                c.classList.add('selected');
            }
        });
        // Scroll to form
        document.querySelector('.apply-section').scrollIntoView({behavior:'smooth', block:'start'});
    }

    // Also toggle licence section when dropdown changes directly
    document.getElementById('<%= ddlRole.ClientID %>').addEventListener('change', function() {
        document.getElementById('licenceSection').style.display = (this.value === 'Driver') ? 'block' : 'none';
    });

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
