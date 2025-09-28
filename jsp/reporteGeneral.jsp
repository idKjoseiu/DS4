<%@ page import="java.sql.*, java.time.LocalDate, java.time.LocalTime, java.time.format.DateTimeFormatter, java.util.*" %>
<%@ page import="java.time.DayOfWeek" %>
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
        .nav-tabs .nav-link {
            background-color: #39424f;
            border-color: #495057;
            color: #f6f5f5;
        }
        .nav-tabs .nav-link.active {
            background-color: #212830;
            border-color: #495057 #495057 #212830;
            color: #fff;
            font-weight: bold;
        }
        .tab-content {
            border: 1px solid #39424f;
            border-top: 0;
            padding: 20px;
            background-color: #2c343c;
            border-radius: 0 0 0.25rem 0.25rem;
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
    String fechaInicio = request.getParameter("fechaInicio");
    String fechaFin = request.getParameter("fechaFin");
    String fechaFinAjustada = fechaFin + " 23:59:59";

    String url = "jdbc:mysql://localhost:3306/asistencia";
    String usuario = "root";
    String contrasena = "";

    try (Connection conn = DriverManager.getConnection(url, usuario, contrasena)) {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("SET lc_time_names = 'es_ES'");
        }

        // 1. Obtener todos los empleados
        String sqlPersonal = "SELECT codigo_marcacion, nombre, apellido FROM personal ORDER BY apellido, nombre";
        List<String[]> personalList = new ArrayList<>();
        try (Statement stmtPersonal = conn.createStatement();
             ResultSet rsPersonal = stmtPersonal.executeQuery(sqlPersonal)) {
            while (rsPersonal.next()) {
                personalList.add(new String[]{
                    rsPersonal.getString("codigo_marcacion"),
                    rsPersonal.getString("nombre"),
                    rsPersonal.getString("apellido")
                });
            }
        }

        if (personalList.isEmpty()) {
            out.println("<div class='alert alert-info mt-3'>No hay personal registrado en la base de datos.</div>");
            return;
        }

        // 2. Obtener días libres una sola vez
        String sqlDiasLibres = "SELECT fecha FROM dias_libres WHERE fecha BETWEEN ? AND ?";
        List<LocalDate> diasLibres = new ArrayList<>();
        try (PreparedStatement psDiasLibres = conn.prepareStatement(sqlDiasLibres)) {
            psDiasLibres.setString(1, fechaInicio);
            psDiasLibres.setString(2, fechaFin);
            try (ResultSet rsDiasLibres = psDiasLibres.executeQuery()) {
                while (rsDiasLibres.next()) {
                    diasLibres.add(rsDiasLibres.getDate("fecha").toLocalDate());
                }
            }
        }

        // 3. Preparar la consulta de asistencia para reutilizarla
        String sqlAsistencia = "SELECT DATE(fecha_hora) AS fecha, " +
                               "DATE_FORMAT(fecha_hora, '%d-%m-%Y') AS fecha_formateada, " +
                               "DATE_FORMAT(fecha_hora, '%W') AS dia_semana, " +
                               "MIN(TIME(fecha_hora)) AS entrada, " +
                               "MAX(TIME(fecha_hora)) AS salida " +
                               "FROM asistencias " +
                               "WHERE codigo_marcacion = ? AND fecha_hora BETWEEN ? AND ? " +
                               "GROUP BY DATE(fecha_hora) ORDER BY fecha ASC";
        PreparedStatement psAsistencia = conn.prepareStatement(sqlAsistencia, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

        // 4. Crear la estructura de pestañas
%>
        <ul class="nav nav-tabs mt-3" id="empleadosTabs" role="tablist">
            <% for (int i = 0; i < personalList.size(); i++) {
                String[] empleado = personalList.get(i);
                String codigo = empleado[0];
                String nombreCompleto = empleado[1] + " " + empleado[2];
            %>
            <li class="nav-item" role="presentation">
                <button class="nav-link <%= i == 0 ? "active" : "" %>" id="tab-btn-<%= codigo %>" data-bs-toggle="tab" data-bs-target="#tab-pane-<%= codigo %>" type="button" role="tab"><%= nombreCompleto %></button>
            </li>
            <% } %>
        </ul>

        <div class="tab-content" id="empleadosTabsContent">
            <%
            final LocalTime HORA_ENTRADA_AM = LocalTime.of(7, 0);
            final LocalTime HORA_ENTRADA_PM = LocalTime.of(12, 20);

            // Definir los códigos de marcación para cada turno
            final Set<String> codigosTurnoAM = new HashSet<>(Arrays.asList(
                "13", "2", "11", "7", "31", "3", "6", "8", "5", "30", "4", "9", "36", "12", "45"
            ));
            final Set<String> codigosTurnoPM = new HashSet<>(Arrays.asList(
                "41", "15", "26", "21", "22", "40", "16", "23", "18", "42", "19", "33", "44"
            ));


            LocalDate fechaInicioDate = LocalDate.parse(fechaInicio);
            LocalDate fechaFinDate = LocalDate.parse(fechaFin);
            DateTimeFormatter formatoDiaSemana = DateTimeFormatter.ofPattern("EEEE", new Locale("es", "ES"));
            DateTimeFormatter formatoFecha = DateTimeFormatter.ofPattern("dd-MM-yyyy");

            for (int i = 0; i < personalList.size(); i++) {
                String[] empleado = personalList.get(i);
                String codigo_marcacion = empleado[0];
                String nombreCompleto = empleado[1] + " " + empleado[2];

                // Determinar la hora de entrada correcta para el empleado actual
                LocalTime horaEntradaCorrecta;
                if (codigosTurnoAM.contains(codigo_marcacion)) {
                    horaEntradaCorrecta = HORA_ENTRADA_AM;
                } else if (codigosTurnoPM.contains(codigo_marcacion)) {
                    horaEntradaCorrecta = HORA_ENTRADA_PM;
                } else {
                    // Por defecto, se usa la de la mañana si el código no está en ninguna lista.
                    horaEntradaCorrecta = HORA_ENTRADA_AM;
                }
                int totalTardanzas = 0;
                int totalAusencias = 0;

                psAsistencia.setString(1, codigo_marcacion);
                psAsistencia.setString(2, fechaInicio);
                psAsistencia.setString(3, fechaFinAjustada);

                ResultSet rs = psAsistencia.executeQuery();
                boolean hayMasResultados = rs.next();
            %>
            <div class="tab-pane fade <%= i == 0 ? "show active" : "" %>" id="tab-pane-<%= codigo_marcacion %>" role="tabpanel">
                <h5>Empleado: <%= nombreCompleto %> | Código: <%= codigo_marcacion %></h5>
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

                        for (LocalDate fechaIteracion = fechaInicioDate; !fechaIteracion.isAfter(fechaFinDate); fechaIteracion = fechaIteracion.plusDays(1)) {
                            LocalDate fechaResultado = null;
                            if (hayMasResultados) {
                                fechaResultado = rs.getDate("fecha").toLocalDate();
                            }

                            boolean esDomingo = fechaIteracion.getDayOfWeek() == DayOfWeek.SUNDAY;

                            if (hayMasResultados && fechaIteracion.equals(fechaResultado)) {
                                String entradaStr = rs.getString("entrada");
                                String tardanzaDisplay = "";
                                if (entradaStr != null) {
                                    LocalTime horaEntradaMarcada = LocalTime.parse(entradaStr);
                                    if (horaEntradaMarcada.isAfter(horaEntradaCorrecta)) {
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
                                hayMasResultados = rs.next();
                            } else if (diasLibres.contains(fechaIteracion)) {
                        %>
                            <tr>
                                <td><%= fechaIteracion.format(formatoFecha) %></td>
                                <td><%= fechaIteracion.format(formatoDiaSemana) %></td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td>Día Feriado/Libre</td>
                            </tr>
                        <%
                            } else if (esDomingo) {
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
                            } else {
                                totalAusencias++;
                        %>
                            <tr>
                                <td><%= fechaIteracion.format(formatoFecha) %></td>
                                <td><%= fechaIteracion.format(formatoDiaSemana) %></td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td class="text-danger fw-bold">No Asistió</td>
                            </tr>
                        <%
                            }
                        }
                        rs.close();
                        %>
                        </tbody>
                    </table>
                </div>
                <div class="mt-3 p-3 bg-dark rounded">
                    <h6>Resumen del Empleado:</h6>
                    <p class="mb-1"><strong>Total de Tardanzas:</strong> <%= totalTardanzas %></p>
                    <p class="mb-0"><strong>Total de Ausencias:</strong> <%= totalAusencias %></p>
                </div>
            </div>
            <%
            } // Fin del bucle de empleados
            psAsistencia.close();
            %>
        </div>

        <div class="d-flex justify-content-between mt-3">
            <button class="btn btn-info" id="prevTab">Anterior</button>
            <button class="btn btn-info" id="nextTab">Siguiente</button>
        </div>
<%
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error al generar el reporte: " + e.getMessage() + "</div>");
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const prevBtn = document.getElementById('prevTab');
            const nextBtn = document.getElementById('nextTab');
            const tabs = document.querySelectorAll('#empleadosTabs .nav-link');

            function getActiveTabIndex() {
                for (let i = 0; i < tabs.length; i++) {
                    if (tabs[i].classList.contains('active')) {
                        return i;
                    }
                }
                return -1;
            }

            prevBtn.addEventListener('click', function () {
                let activeIndex = getActiveTabIndex();
                if (activeIndex > 0) {
                    const tabToActivate = new bootstrap.Tab(tabs[activeIndex - 1]);
                    tabToActivate.show();
                }
            });

            nextBtn.addEventListener('click', function () {
                let activeIndex = getActiveTabIndex();
                if (activeIndex < tabs.length - 1) {
                    const tabToActivate = new bootstrap.Tab(tabs[activeIndex + 1]);
                    tabToActivate.show();
                }
            });
        });
    </script>
    <!-- animaciones -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>

        <!-- Tu archivo JS -->
<script src="../js/animaciones.js"></script>
</body>
</html>