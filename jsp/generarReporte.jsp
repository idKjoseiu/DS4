<%@ page import="java.sql.*, java.time.LocalDate, java.time.LocalTime, java.time.format.DateTimeFormatter, java.util.Locale" %>
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
            <h1>Resultados del Reporte</h1>
            
            <a href="#" onclick="window.close(); return false;" class="btn btn-secondary">Volver</a>
        </div>
        
<%
    //datos de la busqueda
    String codigo_marcacion = request.getParameter("codigo_marcacion");
    String fechaInicio = request.getParameter("fechaInicio");
    String fechaFin = request.getParameter("fechaFin");

    //todo el dia de la fecha final
    String fechaFinAjustada = fechaFin + " 23:59:59";

    String url = "jdbc:mysql://localhost:3306/asistencia";
    String usuario = "root";
    String contrasena = "";

    Connection conn = null;
    ResultSet rs = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, usuario, contrasena);

        try (Statement stmt = conn.createStatement()) {
            stmt.execute("SET lc_time_names = 'es_ES'");
        }

        // Consulta SQL mejorada
        String sql = "SELECT " +
                     "DATE(fecha_hora) AS fecha, " +
                     "DATE_FORMAT(fecha_hora, '%d-%m-%Y') AS fecha_formateada, " +
                     "DATE_FORMAT(fecha_hora, '%W') AS dia_semana, " + 
                     "MIN(TIME(fecha_hora)) AS entrada, " +
                     "MAX(TIME(fecha_hora)) AS salida " +
                     "FROM asistencias " +
                     "WHERE codigo_marcacion = ? AND fecha_hora BETWEEN ? AND ? " +
                     "GROUP BY DATE(fecha_hora) " +
                     "ORDER BY fecha ASC";

        ps = conn.prepareStatement(sql);
        ps.setString(1, codigo_marcacion);
        ps.setString(2, fechaInicio);
        ps.setString(3, fechaFinAjustada);

        rs = ps.executeQuery();
%>
        <div class="table-responsive">
            <table class="table table-striped table-dark">
                <thead>
                    <tr>
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
        
        // tadanzas y ausencias
        int totalAusencias = 0;
        int totalTardanzas = 0;
        final LocalTime HORA_ENTRADA_OFICIAL = LocalTime.of(7, 0);

        LocalDate fechaInicioDate = LocalDate.parse(fechaInicio);
        LocalDate fechaFinDate = LocalDate.parse(fechaFin);
        DateTimeFormatter formatoDiaSemana = DateTimeFormatter.ofPattern("EEEE", new Locale("es", "ES"));
        DateTimeFormatter formatoFecha = DateTimeFormatter.ofPattern("dd-MM-yyyy");

        boolean hayMasResultados = rs.next();

        for (LocalDate fechaIteracion = fechaInicioDate; !fechaIteracion.isAfter(fechaFinDate); fechaIteracion = fechaIteracion.plusDays(1)) {
            LocalDate fechaResultado = null;
            if (hayMasResultados) {
                fechaResultado = rs.getDate("fecha").toLocalDate();
            }

            if (hayMasResultados && fechaIteracion.equals(fechaResultado)) {
                //asistió
                String entradaStr = rs.getString("entrada");
                String tardanzaDisplay = "";

                if (entradaStr != null) {
                    LocalTime horaEntradaMarcada = LocalTime.parse(entradaStr);
                    if (horaEntradaMarcada.isAfter(HORA_ENTRADA_OFICIAL)) {
                        tardanzaDisplay = "Sí";
                        totalTardanzas++;
                    }
                }
%>
                    <tr>
                        <td><%= rs.getString("fecha_formateada") %></td>
                        <td><%= rs.getString("dia_semana") %></td>
                        <td><%= entradaStr %></td>
                        <td><%= tardanzaDisplay %></td> 
                        <td><%= rs.getString("salida") %></td>
                        <td></td> 
                    </tr>
<%
                hayMasResultados = rs.next(); // Mover al siguiente registro
            } else {
                //no asistió
                totalAusencias++;
%>
                    <tr>
                        <td><%= fechaIteracion.format(formatoFecha)+" * " %></td>
                        <td><%= fechaIteracion.format(formatoDiaSemana) %></td>
                        <td></td>
                        <td></td> 
                        <td></td>
                        <td>No Asistió</td> 
                    </tr>
<%
            }
        }
%>
                </tbody>
            </table>
        </div>
        <div class>  
            <h4>Resumen de Cumplimientos</h4>
            <p><strong>Total de Ausencias:</strong> <%= totalAusencias %></p>
            <p><strong>Total de Tardanzas:</strong> <%= totalTardanzas %></p>
        </div>
<%
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