<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Asistencia</title>
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
    <div class="container">
        <div class="superior">
            <h1>Resultados del Reporte General</h1>
            
            <a href="#" onclick="window.close(); return false;" class="btn btn-secondary">Volver</a>
        </div>
<%
    // Obtener datos del formulario
    String fechaInicio = request.getParameter("fechaInicio");
    String fechaFin = request.getParameter("fechaFin");

    // Para asegurar que la consulta incluye todo el día de la fecha final
    String fechaFinAjustada = fechaFin + " 23:59:59";

    String url = "jdbc:mysql://localhost:3306/asistencia";
    String usuario = "root";
    String contrasena = "";

    Connection conn = null;
    ResultSet rs = null;
    PreparedStatement ps = null;
    boolean hasResults = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, usuario, contrasena);

        // --- SOLUCIÓN ---
        // Se establece el idioma a español para la sesión actual de la base de datos.
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("SET lc_time_names = 'es_ES'");
        }

        String sql = "SELECT " +
                     "codigo_marcacion, " +
                     "DATE(fecha_hora) AS fecha, " +
                     "DATE_FORMAT(fecha_hora, '%W') AS dia_semana, " +
                     "MIN(TIME(fecha_hora)) AS entrada, " +
                     "MAX(TIME(fecha_hora)) AS salida " +
                     "FROM asistencias " +
                     "WHERE fecha_hora BETWEEN ? AND ? " +
                     "GROUP BY codigo_marcacion, DATE(fecha_hora) " +
                     "ORDER BY codigo_marcacion, fecha ASC";

        ps = conn.prepareStatement(sql);
        ps.setString(1, fechaInicio);
        ps.setString(2, fechaFinAjustada);

        rs = ps.executeQuery();
%>
        <div class="table-responsive">
            <table class="table table-striped table-dark">
                <thead>
                    <tr>
                        <th>Codigo</th>
                        <th>Fecha</th>
                        <th>Día</th>
                        <th>Entrada</th>
                        <th>Tardanza</th>
                        <th>Salida</th>
                        <th>Observaciones</th>
                    </tr>
                </thead>
                <tbody>
<%
        while (rs.next()) {
            hasResults = true;
            
%>
                    <tr>
                        <td><%= rs.getString("codigo_marcacion") %></td>
                        <td><%= rs.getString("fecha") %></td>
                        <td><%= rs.getString("dia_semana") %></td>
                        <td><%= rs.getString("entrada") %></td>
                        <td></td> 
                        <td><%= rs.getString("salida") %></td>
                        <td></td> 
                    </tr>
<%
        }
%>
                </tbody>
            </table>
        </div>
<%
        if (!hasResults) {
            out.println("<div class='alert alert-info'>No se encontraron registros para los criterios seleccionados.</div>");
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error al generar el reporte: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignorado */ }
        if (ps != null) try { ps.close(); } catch (SQLException e) { /* ignorado */ }
        if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignorado */ }
    }
%>
    </div>
</body>
</html>