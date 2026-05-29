<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerDashboard.aspx.cs" Inherits="DriveNow.CustomerDashboard" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Customer Dashboard</title>

    <link href="Content/Site.css" rel="stylesheet" />

    <style>

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #0f172a;
            color: white;
        }

        .dashboard {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 240px;
            background: #111827;
            padding: 25px;
        }

        .logo {
            font-size: 28px;
            font-weight: bold;
            color: #14b8a6;
            margin-bottom: 40px;
        }

        .menu a {
            display: block;
            color: #cbd5e1;
            text-decoration: none;
            padding: 14px;
            border-radius: 10px;
            margin-bottom: 10px;
            transition: 0.3s;
        }

        .menu a:hover,
        .menu a.active {
            background: #14b8a6;
            color: white;
        }

        .main {
            flex: 1;
            padding: 30px;
        }

        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .welcome h1 {
            margin: 0;
            font-size: 34px;
        }

        .welcome p {
            color: #94a3b8;
        }

        .cards {
            display: grid;
            grid-template-columns: repeat(4,1fr);
            gap: 20px;
            margin-top: 35px;
        }

        .card {
            background: #1e293b;
            padding: 25px;
            border-radius: 18px;
        }

        .card h2 {
            margin: 0;
            font-size: 34px;
            color: #14b8a6;
        }

        .card p {
            margin-top: 10px;
            color: #cbd5e1;
        }

        .section {
            margin-top: 40px;
        }

        .section h2 {
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: #1e293b;
            border-radius: 16px;
            overflow: hidden;
        }

        table th {
            background: #14b8a6;
            padding: 15px;
            text-align: left;
        }

        table td {
            padding: 15px;
            border-bottom: 1px solid #334155;
        }

        .btn {
            display: inline-block;
            padding: 14px 20px;
            background: #14b8a6;
            color: white;
            text-decoration: none;
            border-radius: 10px;
            margin-right: 12px;
            font-weight: bold;
        }

    </style>

</head>

<body>

<form id="form1" runat="server">

<div class="dashboard">

    <!-- SIDEBAR -->

    <div class="sidebar">

        <div class="logo">
            DriveNow
        </div>

        <div class="menu">

            <a href="#" class="active">
                Dashboard
            </a>

            <a href="#">
                My Trips
            </a>

            <a href="#">
                Book Vehicle
            </a>

            <a href="#">
                My Profile
            </a>

            <a href="Login.aspx">
                Logout
            </a>

        </div>

    </div>

    <!-- MAIN -->

    <div class="main">

        <div class="topbar">

            <div class="welcome">

                <h1>
                    Welcome Back
                </h1>

                <p>
                    Manage your trips and bookings
                </p>

            </div>

        </div>

        <!-- CARDS -->

        <div class="cards">

            <div class="card">
                <h2>12</h2>
                <p>Total Trips</p>
            </div>

            <div class="card">
                <h2>3</h2>
                <p>Upcoming Trips</p>
            </div>

            <div class="card">
                <h2>8</h2>
                <p>Completed Trips</p>
            </div>

            <div class="card">
                <h2>1</h2>
                <p>Active Rental</p>
            </div>

        </div>

        <!-- QUICK ACTIONS -->

        <div class="section">

            <h2>
                Quick Actions
            </h2>

            <a href="#" class="btn">
                Book Vehicle
            </a>

            <a href="#" class="btn">
                View Trips
            </a>

        </div>

        <!-- PREVIOUS TRIPS -->

        <div class="section">

            <h2>
                Previous Trips
            </h2>

            <table>

                <tr>
                    <th>Trip ID</th>
                    <th>Vehicle</th>
                    <th>Date</th>
                    <th>Status</th>
                </tr>

                <tr>
                    <td>#TR102</td>
                    <td>BMW M4</td>
                    <td>12 Jun 2026</td>
                    <td>Completed</td>
                </tr>

                <tr>
                    <td>#TR099</td>
                    <td>Audi R8</td>
                    <td>04 Jun 2026</td>
                    <td>Completed</td>
                </tr>

                <tr>
                    <td>#TR088</td>
                    <td>Mercedes C200</td>
                    <td>28 May 2026</td>
                    <td>Completed</td>
                </tr>

            </table>

        </div>

    </div>

</div>

</form>

</body>
</html>