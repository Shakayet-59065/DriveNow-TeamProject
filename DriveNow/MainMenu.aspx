<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MainMenu.aspx.cs" Inherits="DriveNow.MainMenu" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Main Menu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background-color: #f4f5f7; }

        .navbar {
            background-color: #1a1a2e;
            color: white;
            padding: 14px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .navbar .brand { font-size: 20px; font-weight: bold; }
        .navbar .user { font-size: 13px; opacity: 0.8; }
        .navbar a {
            color: white;
            text-decoration: none;
            font-size: 13px;
            background: rgba(255,255,255,0.15);
            padding: 6px 14px;
            border-radius: 4px;
        }
        .navbar a:hover { background: rgba(255,255,255,0.25); }

        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; }

        h1 { font-size: 22px; color: #1a1a2e; margin-bottom: 6px; }
        .subtitle { color: #666; font-size: 14px; margin-bottom: 30px; }

        .section-title {
            font-size: 13px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #888;
            margin-bottom: 12px;
            margin-top: 30px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 14px;
            margin-bottom: 10px;
        }

        .card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            border-top: 4px solid #1a1a2e;
            text-decoration: none;
            color: #1a1a2e;
            display: block;
            transition: transform 0.15s, box-shadow 0.15s;
        }
        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.12);
        }
        .card .icon { font-size: 28px; margin-bottom: 10px; }
        .card .title { font-size: 14px; font-weight: bold; }
        .card .desc { font-size: 12px; color: #888; margin-top: 4px; }

        .card.blue  { border-top-color: #3b82f6; }
        .card.green { border-top-color: #10b981; }
        .card.amber { border-top-color: #f59e0b; }
        .card.purple{ border-top-color: #8b5cf6; }
        .card.red   { border-top-color: #ef4444; }

        .footer {
            text-align: center;
            color: #aaa;
            font-size: 12px;
            margin-top: 50px;
            padding-bottom: 30px;
        }
    </style>
</head>
<body>
    <form id="frmMainMenu" runat="server">

        <div class="navbar">
            <div class="brand">DriveNow</div>
            <div class="user">
                Logged in as: <strong><asp:Label ID="lblUsername" runat="server" /></strong>
            </div>
            <a href="Login.aspx">Logout</a>
        </div>

        <div class="container">
            <h1>Admin Main Menu</h1>
            <p class="subtitle">Select a component to manage.</p>

            <!-- TRIP RECORDS -->
            <div class="section-title">Trip Records — Musanna</div>
            <div class="grid">
                <a href="TripList.aspx" class="card blue">
                    <div class="icon">📋</div>
                    <div class="title">List Trips</div>
                    <div class="desc">View all trip records</div>
                </a>
                <a href="TripAdd.aspx" class="card blue">
                    <div class="icon">➕</div>
                    <div class="title">Add Trip</div>
                    <div class="desc">Create a new trip</div>
                </a>
                <a href="TripFind.aspx" class="card blue">
                    <div class="icon">🔍</div>
                    <div class="title">Find Trip</div>
                    <div class="desc">Search by Trip ID</div>
                </a>
                <a href="TripFilter.aspx" class="card blue">
                    <div class="icon">🔧</div>
                    <div class="title">Filter Trips</div>
                    <div class="desc">Filter by type or date</div>
                </a>
            </div>

            <!-- TRIP TYPE CATALOGUE -->
            <div class="section-title">Trip Type Catalogue — Musanna</div>
            <div class="grid">
                <a href="TripTypeList.aspx" class="card green">
                    <div class="icon">📋</div>
                    <div class="title">List Trip Types</div>
                    <div class="desc">View all service types</div>
                </a>
                <a href="TripTypeAdd.aspx" class="card green">
                    <div class="icon">➕</div>
                    <div class="title">Add Trip Type</div>
                    <div class="desc">Create a new service type</div>
                </a>
            </div>

            <!-- CUSTOMER MANAGEMENT -->
            <div class="section-title">Customer Management — Tahmid</div>
            <div class="grid">
                <a href="#" class="card amber">
                    <div class="icon">👥</div>
                    <div class="title">List Customers</div>
                    <div class="desc">View all customers</div>
                </a>
                <a href="#" class="card amber">
                    <div class="icon">➕</div>
                    <div class="title">Add Customer</div>
                    <div class="desc">Register a new customer</div>
                </a>
            </div>

            <!-- DRIVER MANAGEMENT -->
            <div class="section-title">Driver Management — Redoy</div>
            <div class="grid">
                <a href="#" class="card purple">
                    <div class="icon">🚗</div>
                    <div class="title">List Drivers</div>
                    <div class="desc">View all drivers</div>
                </a>
                <a href="#" class="card purple">
                    <div class="icon">➕</div>
                    <div class="title">Add Driver</div>
                    <div class="desc">Register a new driver</div>
                </a>
            </div>

            <!-- VEHICLE INVENTORY -->
            <div class="section-title">Vehicle Inventory — Prodip</div>
            <div class="grid">
                <a href="#" class="card red">
                    <div class="icon">🚙</div>
                    <div class="title">List Vehicles</div>
                    <div class="desc">View all vehicles</div>
                </a>
                <a href="#" class="card red">
                    <div class="icon">➕</div>
                    <div class="title">Add Vehicle</div>
                    <div class="desc">Add a new vehicle</div>
                </a>
            </div>

            <!-- CONTRIBUTOR APPLICATIONS -->
            <div class="section-title">Contributor Applications — Ushna</div>
            <div class="grid">
                <a href="#" class="card">
                    <div class="icon">📝</div>
                    <div class="title">List Applications</div>
                    <div class="desc">View all contributor applications</div>
                </a>
                <a href="#" class="card">
                    <div class="icon">➕</div>
                    <div class="title">Add Application</div>
                    <div class="desc">Register a new contributor</div>
                </a>
            </div>

        </div>

        <div class="footer">
            DriveNow Admin System &nbsp;|&nbsp; CTEC2713N &nbsp;|&nbsp; Niels Brock Copenhagen
        </div>

    </form>
</body>
</html>
