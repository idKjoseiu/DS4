<%@ page import="java.sql.*,java.time.LocalDate,java.time.LocalTime,java.time.format.DateTimeFormatter"%>
<%@ page import = "java.util.Locale,java.util.List,java.util.ArrayList, java.time.DayOfWeek " %>

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
            <h2>Resultados del Reporte</h2>
            <div>
                    <a href="#" onclick="window.close(); return false;" class="btn btn-secondary">Volver</a>
                    <a href="#" onclick="mostrarGrafico();" class="btn btn-primary">Ver Gráfico</a>
            </div>        
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

    
    int totalAusencias = 0;
    int totalTardanzas = 0;
    int totalAsistenciasPuntuales = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, usuario, contrasena);

        try (Statement stmt = conn.createStatement()) {
            stmt.execute("SET lc_time_names = 'es_ES'");
        }

        String sql = "SELECT " +
                        "P.nombre, P.apellido, P.codigo_marcacion, " +
                        "DATE(A.fecha_hora) AS fecha, " +
                        "DATE_FORMAT(A.fecha_hora, '%d-%m-%Y') AS fecha_formateada, " +
                        "DATE_FORMAT(A.fecha_hora, '%W') AS dia_semana, " +
                        "MIN(TIME(A.fecha_hora)) AS entrada, " +
                        "MAX(TIME(A.fecha_hora)) AS salida " +
                        "FROM asistencias A " +
                        "JOIN personal P ON P.codigo_marcacion = A.codigo_marcacion " +
                        "WHERE A.codigo_marcacion = ? " +
                        "AND A.fecha_hora BETWEEN ? AND ? " +
                        "GROUP BY P.nombre, P.apellido, P.codigo_marcacion, DATE(A.fecha_hora) " +
                        "ORDER BY fecha ASC";
        ps = conn.prepareStatement(sql);
        ps.setString(1, codigo_marcacion);
        ps.setString(2, fechaInicio);
        ps.setString(3, fechaFinAjustada);
        
        //lists de dis libres
        String sqlDiasLibres = "SELECT fecha FROM dias_libres WHERE fecha BETWEEN ? AND ?";
        List<LocalDate> diasLibres = new ArrayList<>();

        PreparedStatement psDiasLibres = conn.prepareStatement(sqlDiasLibres);
       

        psDiasLibres.setString(1, fechaInicio);
        psDiasLibres.setString(2, fechaFin);

        ResultSet rsDiasLibres = psDiasLibres.executeQuery();
        while (rsDiasLibres.next()) {
            diasLibres.add(rsDiasLibres.getDate("fecha").toLocalDate());
        }
        rsDiasLibres.close();
        psDiasLibres.close();

       

        rs = ps.executeQuery();

        if (rs.next()) {
            out.println("<div style='position:sticky; top:60px; z-index:101; background-color:#212830; padding:10px; border-bottom:1px solid #39424f;'><h5 style='margin:0;'>Empleado: " + rs.getString("nombre") + " " + rs.getString("apellido") + " | código: " + rs.getString("codigo_marcacion") + "</h5></div>");
        } else {
            rs.close();
            ps.close();
            conn.close();
            out.println("<h5>No se encontró personal con el código proporcionado.</h5>");
            return;
        } 
%>
        <div class="table-responsive">
            <table class="table table-striped table-dark rounded-3 overflow-hidden">
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
            boolean esDomingo = fechaIteracion.getDayOfWeek() == DayOfWeek.SUNDAY;

            if (hayMasResultados && fechaIteracion.equals(fechaResultado)) {
                //asistió
                String entradaStr = rs.getString("entrada");
                String tardanzaDisplay = "";

                if (entradaStr != null) {
                    LocalTime horaEntradaMarcada = LocalTime.parse(entradaStr);
                    if (horaEntradaMarcada.isAfter(HORA_ENTRADA_OFICIAL)) {
                        tardanzaDisplay = "Sí";
                        totalTardanzas++;
                    } else {
                        totalAsistenciasPuntuales++;
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
            } else if (diasLibres.contains(fechaIteracion)){
               //dia feriado
 %>                         
                    <tr>
                        <td><%= fechaIteracion.format(formatoFecha) %></td>
                        <td><%= fechaIteracion.format(formatoDiaSemana) %></td>
                        <td></td>
                        <td></td> 
                        <td></td>
                        <td>Dia Feriado/Libre</td> 
                    </tr>
<%
            } else if ( esDomingo == true){
%>
                        <tr>
                            <td><%= fechaIteracion.format(formatoFecha) %></td>
                            <td><%= fechaIteracion.format(formatoDiaSemana) %></td>
                            <td></td>
                            <td></td> 
                            <td></td>
                            <td>Domingo</td> 
                        </tr>

<%
            }else {
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

        <div>
            <h4>Resumen de Cumplimientos</h4>
            <p><strong>Total de Ausencias:</strong> <%= totalAusencias %></p>
            <p><strong>Total de Tardanzas:</strong> <%= totalTardanzas %></p>
            <p><strong>Total de Asistencias Puntuales:</strong> <%= totalAsistenciasPuntuales %></p>
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

    <div id="graficoContainer" style="position: relative; width: 80vw; max-width: 600px; height: 400px; display:none; margin: 30px auto 0 auto;">
            <canvas id="graficoAsistencias"></canvas>
    </div>

    
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    let miGrafico = null;

    function mostrarGrafico() {
        const container = document.getElementById('graficoContainer');
        container.style.display = 'block';

        // Desplaza cuadno se da a ver grafico
        container.scrollIntoView({ behavior: 'smooth', block: 'start' });

        // Si el gráfico ya existe, no hacer nada más.
        if (miGrafico) {
            return;
        }

        const ctx = document.getElementById('graficoAsistencias').getContext('2d');
        
        miGrafico = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Asistencias Puntuales', 'Tardanzas', 'Ausencias'],
                datasets: [{
                    label: 'Resumen de Asistencia',
                    data: [<%= totalAsistenciasPuntuales %>, <%= totalTardanzas %>, <%= totalAusencias %>],
                    backgroundColor: [
                        'rgba(40, 167, 69, 0.7)',  // Verde para puntuales
                        'rgba(255, 193, 7, 0.7)',   // Amarillo para tardanzas
                        'rgba(220, 53, 69, 0.7)'    // Rojo para ausencias
                    ],
                    borderColor: [
                        'rgba(40, 167, 69, 1)',
                        'rgba(255, 193, 7, 1)',
                        'rgba(220, 53, 69, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {
                            color: '#f6f5f5' // Color del texto de la leyenda
                        }
                    },
                    title: {
                        display: true,
                        text: 'Resumen de Asistencia del Periodo',
                        color: '#f6f5f5', // Color del título
                        font: { size: 18 }
                    }
                }
            }
        });
    }
</script>


</body>
</html>