<%@ page import="java.sql.*, java.util.*, org.json.JSONArray, org.json.JSONObject" %>
<%
    boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

    String dbURL = "jdbc:oracle:thin:@localhost:1521:XE";
    String dbUser = "system";
    String dbPass = "root123"; 
    Connection conn = null;
    PreparedStatement ps = null;

    try {
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sql = "SELECT server_name, ip_address, filesystem, usage_percentage " +
                     "FROM filesystem_usage " +
                     "ORDER BY server_name, ip_address";
        ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        JSONArray jsonArray = new JSONArray();
        while (rs.next()) {
            JSONObject json = new JSONObject();
            json.put("serverName", rs.getString("server_name"));
            json.put("ipAddress", rs.getString("ip_address"));
            json.put("filesystem", rs.getString("filesystem"));
            json.put("usage", rs.getString("usage_percentage"));
            jsonArray.put(json);
        }

        if (isAjax) {
            response.setContentType("application/json");
            response.getWriter().write(jsonArray.toString());
        } else {
            request.setAttribute("stats", jsonArray.toString());
        }
    } catch (SQLException e) {
        e.printStackTrace();
        if (isAjax) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Database error: " + e.getMessage() + "\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
    } catch (Exception e) {
        e.printStackTrace();
        if (isAjax) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Server error: " + e.getMessage() + "\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "Server error: " + e.getMessage());
        }
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
<% if (!isAjax) { %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Filesystem Monitoring</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        h1 {
            text-align: center;
            margin-bottom: 20px;
        }
        table {
            width: 80%;
            border-collapse: collapse;
            margin: 0 auto;
            background-color: #fff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border: 3px solid white;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        audio {
            display: none;
        }
    </style>
    <script>
        let serverData = {};

        function updateStats() {
            fetch('webapp.jsp', {
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
            .then(response => response.json())
            .then(data => {
                data.forEach(function(stat) {
                    serverData[stat.ipAddress] = stat;

                    let table = document.getElementById("statsTable");
                    let row = document.getElementById(stat.ipAddress);
                    if (!row) {
                        row = table.insertRow();
                        row.id = stat.ipAddress;
                        row.insertCell(0).innerText = stat.serverName;
                        row.insertCell(1).innerText = stat.ipAddress;
                        row.insertCell(2).innerText = stat.filesystem;
                        row.insertCell(3).innerText = stat.usage;
                    } else {
                        row.cells[0].innerText = stat.serverName;
                        row.cells[1].innerText = stat.ipAddress;
                        row.cells[2].innerText = stat.filesystem;
                        row.cells[3].innerText = stat.usage;
                    }

                    let usagePercentage = parseFloat(stat.usage.replace('%', ''));
                    if (usagePercentage > 90) {
                        row.style.color = 'red';
                        document.getElementById('alertSound').play();

                        fetch('emailAlert.jsp', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({
                                serverName: stat.serverName,
                                filesystem: stat.filesystem,
                                usage: stat.usage
                            })
                        }).catch(error => console.error('Error sending email alert:', error));
                    } else {
                        row.style.color = 'black';
                    }
                });
            })
            .catch(error => console.error('Error fetching data:', error));
        }

        function startAutoUpdate() {
            updateStats();
            setInterval(updateStats, 5000);
        }

        document.addEventListener('DOMContentLoaded', function() {
            startAutoUpdate();
        });
    </script>
</head>
<body>
    <div>
        <h1>Filesystem Monitoring</h1>
        <table id="statsTable" border="1">
            <tr>
                <th>Server Name</th>
                <th>IP Address</th>
                <th>Filesystem</th>
                <th>Usage (%)</th>
            </tr>
        </table>
        <audio id="alertSound" src="beep.wav"></audio>
    </div>
</body>
</html>
<% } %>
