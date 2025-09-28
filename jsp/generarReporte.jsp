<%@ page import="java.sql.*,java.time.LocalDate,java.time.LocalTime,java.time.format.DateTimeFormatter"%>
<%@ page import = "java.util.Locale,java.util.List,java.util.ArrayList, java.time.DayOfWeek, java.util.Map, java.util.HashMap, java.util.stream.Collectors, java.util.Arrays" %>
<%@ page import="java.time.LocalDateTime, java.util.Set, java.util.HashSet" %>
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
                    <a href="#" id="btnGrafico" onclick="toggleGrafico(); return false;" class="btn btn-primary">Ver Gráfico</a>
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

        // Se obtienen todos los registros, no solo min y max, para manejar turnos partidos.
        String sql = "SELECT P.nombre, P.apellido, P.codigo_marcacion, A.fecha_hora " +
                     "FROM asistencias A " +
                     "JOIN personal P ON P.codigo_marcacion = A.codigo_marcacion " +
                     "WHERE A.codigo_marcacion = ? " +
                     "AND A.fecha_hora BETWEEN ? AND ? " +
                     "ORDER BY A.fecha_hora ASC";

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

        // Agrupar todos los registros por fecha para un procesamiento más fácil.
        Map<LocalDate, List<LocalTime>> asistenciasPorFecha = new HashMap<>();
        String nombreEmpleado = "";
        String apellidoEmpleado = "";

        while (rs.next()) {
            if (nombreEmpleado.isEmpty()) {
                nombreEmpleado = rs.getString("nombre");
                apellidoEmpleado = rs.getString("apellido");
            }
            LocalDateTime fechaHora = rs.getTimestamp("fecha_hora").toLocalDateTime();
            // Reemplazo de lambda para compatibilidad con Java < 1.8
            LocalDate fecha = fechaHora.toLocalDate();
            List<LocalTime> tiempos = asistenciasPorFecha.get(fecha);
            if (tiempos == null) {
                tiempos = new ArrayList<>();
                asistenciasPorFecha.put(fecha, tiempos);
            }
            tiempos.add(fechaHora.toLocalTime());
        }

        if (nombreEmpleado.isEmpty()) {
            rs.close();
            ps.close();
            conn.close();
            out.println("<h5>No se encontró personal con el código proporcionado.</h5>");
            return;
        }
        out.println("<div style='position:sticky; top:60px; z-index:101; background-color:#212830; padding:10px; border-bottom:1px solid #39424f;'><h5 style='margin:0;'>Empleado: " + nombreEmpleado + " " + apellidoEmpleado + " | código: " + codigo_marcacion + "</h5></div>");
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
        // Horarios de trabajo. Estos podrían venir de la base de datos en un futuro.
        final LocalTime HORA_ENTRADA_AM = LocalTime.of(7, 0);
        final LocalTime HORA_ENTRADA_PM = LocalTime.of(12, 20);

        // Definir los códigos de marcación para cada turno
        final Set<String> codigosTurnoAM = new HashSet<>(Arrays.asList(
            "13", "2", "11", "7", "31", "3", "6", "8", "5", "30", "4", "9", "36", "12", "45"
        ));
        final Set<String> codigosTurnoPM = new HashSet<>(Arrays.asList(
            "41", "15", "26", "21", "22", "40", "16", "23", "18", "42", "19", "33", "44"
        ));

        // Determinar la hora de entrada correcta para el empleado actual
        LocalTime horaEntradaCorrecta;
        if (codigosTurnoAM.contains(codigo_marcacion)) {
            horaEntradaCorrecta = HORA_ENTRADA_AM;
        } else if (codigosTurnoPM.contains(codigo_marcacion)) {
            horaEntradaCorrecta = HORA_ENTRADA_PM;
        } else {
            // Si el código no está en ninguna lista, se usa la de la mañana por defecto.
            // O se podría mostrar un aviso.
            horaEntradaCorrecta = HORA_ENTRADA_AM;
        }

        LocalDate fechaInicioDate = LocalDate.parse(fechaInicio);
        LocalDate fechaFinDate = LocalDate.parse(fechaFin);
        DateTimeFormatter formatoDiaSemana = DateTimeFormatter.ofPattern("EEEE", new Locale("es", "ES"));
        DateTimeFormatter formatoFecha = DateTimeFormatter.ofPattern("dd-MM-yyyy");

        for (LocalDate fechaIteracion = fechaInicioDate; !fechaIteracion.isAfter(fechaFinDate); fechaIteracion = fechaIteracion.plusDays(1)) {
            String diaSemana = fechaIteracion.format(formatoDiaSemana);
            String fechaFormateada = fechaIteracion.format(formatoFecha);
            boolean esDomingo = fechaIteracion.getDayOfWeek() == DayOfWeek.SUNDAY;
            boolean esDiaLibre = diasLibres.contains(fechaIteracion);

            List<LocalTime> marcasDelDia = asistenciasPorFecha.get(fechaIteracion);

            if (marcasDelDia != null && !marcasDelDia.isEmpty()) {
                // El empleado asistió este día.
                LocalTime primeraMarca = marcasDelDia.get(0);
                LocalTime ultimaMarca = marcasDelDia.get(marcasDelDia.size() - 1);

                // Lógica para determinar si es tardanza.
                String tardanzaDisplay = "";
                if (primeraMarca.isAfter(horaEntradaCorrecta)) {
                    tardanzaDisplay = "Sí";
                    totalTardanzas++;
                } else {
                    totalAsistenciasPuntuales++;
                }
%>
                    <tr>
                        <td><%= fechaFormateada %></td>
                        <td><%= diaSemana %></td>
                        <td><%= primeraMarca %></td>
                        <td><%= tardanzaDisplay %></td> 
                        <td><%= (primeraMarca.equals(ultimaMarca)) ? "" : ultimaMarca.toString() %></td>
                        <td></td> 
                    </tr>
<%
            } else if (esDiaLibre) {
               // Día feriado o libre
 %>                         
                    <tr>
                        <td><%= fechaFormateada %></td>
                        <td><%= diaSemana %></td>
                        <td></td>
                        <td></td> 
                        <td></td>
                        <td>Dia Feriado/Libre</td> 
                    </tr>
<%
            } else if (esDomingo) {
%>
                        <tr>
                            <td><%= fechaFormateada %></td>
                            <td><%= diaSemana %></td>
                            <td></td>
                            <td></td> 
                            <td></td>
                            <td>Domingo</td> 
                        </tr>

<%          
            } else {
                // No asistió y no era domingo ni día libre.
                totalAusencias++;
%>
                    <tr>
                        <td><%= fechaFormateada %></td>
                        <td><%= diaSemana %></td>
                        <td></td>
                        <td></td> 
                        <td></td>
                        <td class="text-danger fw-bold">No Asistió</td> 
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

    function toggleGrafico() {
        const container = document.getElementById('graficoContainer');
        const btn = document.getElementById('btnGrafico');
        const isVisible = container.style.display === 'block';

        if (isVisible) {
            // Ocultar con animación
            anime({
                targets: container,
                opacity: [1, 0],
                translateY: [0, 20],
                duration: 500,
                easing: 'easeInExpo',
                complete: function() {
                    container.style.display = 'none';
                    btn.textContent = 'Ver Gráfico';
                }
            });
        } else {
            // Mostrar con animación
            container.style.display = 'block';
            container.style.opacity = '0'; // Empezar invisible para el fade-in
            btn.textContent = 'Ocultar Gráfico';            
            anime({
                targets: container,
                opacity: [0, 1],
                translateY: [20, 0],
                duration: 900, // Un poco más largo para un efecto más suave
                easing: 'easeOutQuint', // Una curva de animación más pronunciada
                complete: () => container.scrollIntoView({ behavior: 'smooth', block: 'start' })
            });

            // Crea el gráfico solo si no existe
            if (!miGrafico) {
                // --- MEJORA: Plugin para mostrar texto en el centro de la dona ---
                const doughnutText = {
                    id: 'doughnutText',
                    beforeDraw(chart, args, options) {
                        const { ctx, data } = chart;
                        const { width, height } = chart.chartArea;
                        
                        ctx.save();
                        ctx.font = 'bold 30px sans-serif';
                        ctx.fillStyle = '#f6f5f5';
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'middle';
                        
                        const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                        
                        // Dibuja el número total
                        ctx.fillText(total, width / 2, height / 2 - 10);
                        
                        // Dibuja la palabra "Días" debajo
                        ctx.font = '16px sans-serif';
                        ctx.fillText('Días', width / 2, height / 2 + 20);
                        ctx.restore();
                    }
                };

                const ctx = document.getElementById('graficoAsistencias').getContext('2d');
                const datos = [<%= totalAsistenciasPuntuales %>, <%= totalTardanzas %>, <%= totalAusencias %>];
                const total = datos.reduce((a, b) => a + b, 0);

                miGrafico = new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Asistencias Puntuales', 'Tardanzas', 'Ausencias'],
                        datasets: [{
                            label: 'Días',
                            data: datos,
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
                            borderWidth: 1,
                            hoverBorderWidth: 3, // Borde más grueso al pasar el mouse
                            hoverBorderColor: '#fff'
                        }]
                    },
                    options: {
                        cutout: '65%',
                        responsive: true,
                        maintainAspectRatio: false,
                        animation: {
                            animateScale: true,
                            animateRotate: true
                        },
                    },
                    plugins: [doughnutText, { // Se registran los plugins y sus configuraciones aquí
                        id: 'custom_tooltips', // ID para la configuración de plugins internos
                        beforeInit: (chart) => {
                            chart.options.plugins.legend = {
                                position: 'top',
                                labels: { color: '#f6f5f5' }
                            };
                            chart.options.plugins.title = {
                                display: true,
                                text: 'Resumen de Asistencia del Periodo',
                                color: '#f6f5f5',
                                font: { size: 18 }
                            };
                            chart.options.plugins.tooltip = {
                                callbacks: {
                                    label: function(context) {
                                        let label = context.dataset.label || '';
                                        if (label) { label += ': '; }
                                        const value = context.raw;
                                        const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                                        label += `${value} (${percentage}%)`;
                                        return label;
                                    }
                                }
                            };
                        }
                    }]
                });
            }
        }
    }
</script>

<!-- animaciones -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>

<!-- Tu archivo JS -->
<script src="../js/animaciones.js"></script>
</body>
</html>