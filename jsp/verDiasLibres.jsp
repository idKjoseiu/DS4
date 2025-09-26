<%@ page contentType = "text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #212830;
            color: #f6f5f5;
        }
        .container {
            padding-top: 20px;
            padding-bottom: 20px;
        }
        .table {
            margin-top: 20px;
        }
        .superior {
            position: sticky;
            top: 0;
            z-index: 100; 
            
 
            background-color: #212830; 
            padding: 1rem 0; 
            border-bottom: 1px solid #39424f; 

            display: flex;
            justify-content: space-between;
            align-items: center;
        }
    </style>
</head>
<body>
    <div class ="container">
        <div class= "superior">
            <h1> Dias libres registrados</h1>
            <div>
                    <a href="#" onclick="window.close(); return false;" class="btn btn-secondary">Volver</a>
            </div>
        </div>
        <%@ page import = "java.sql.*" %>    
        <%
            //conecion
            String url = "jdbc:mysql://localhost:3306/asistencia";
            String usuario = "root";
            String contrasena = "";


            Connection conn = null;
            ResultSet rs = null;
            PreparedStatement ps = null;

            String dia = null;
            String detalles = null;

            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, usuario, contrasena);

                String sql = "SELECT fecha, detalle FROM dias_libres ORDER BY fecha DESC";
                ps = conn.prepareStatement(sql);

                rs = ps.executeQuery();
        %>
            <div class="table-responsive">
                <table class="table table-striped table-dark">
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Detalles</th>
                        </tr>
                    </thead>
                    <tbody>
        <%
                while (rs.next()){
                    dia = rs.getString("fecha");
                    detalles = rs.getString("detalle");
        %>
                        <tr>
                            <td><%= dia %></td>
                            <td><%= detalles %></td>
                        </tr>
        <%
                }
        %>
                    </tbody>
                </table>
            </div>

        <%
            } catch (SQLException e){
                out.println("<div class='alert alert-danger'>Error al generar el reporte: " + e.getMessage() + "</div>");
            }finally {
                if (rs != null) try { rs.close();} catch (Exception ex) {}
                if (ps != null) try { ps.close();} catch (Exception ex) {}
                if (conn != null) try { conn.close();} catch (Exception ex) {}
            }
        %>
    </div> 
</body>
</html>