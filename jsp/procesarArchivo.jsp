<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.io.*, java.sql.*, java.util.*, java.text.*, java.util.regex.*, javax.servlet.http.Part" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Buscar Asistencia</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">
    <link rel="stylesheet" href="../css/styles.css">

    <!-- fuente de google-->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">

    <!-- iconos-->
    <link rel="icon" href="css/logo/incono.png" type="image/png">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined&display=swap" rel="stylesheet">
</head>
<body>

    <!-- Encabezado y logo, reutilizando la estructura de tus otras páginas -->
    <div class="encabezado"></div>
    <div class="ParteLogo">
        <div class="logo">
            <img src="../css/logo/iconoHorizontal.png" alt="logo">
        </div>
    </div>

    <!-- Menú lateral -->
    <nav class="OpcLateral">
        <a href="../registro.jsp" class="OpcLateral-link">
            <span class="material-icons-outlined">person_add</span>
            Registrarse
        </a>
        <a href="../reporte.html" class="OpcLateral-link">
            <span class="material-icons">assignment</span>
            Reporte
        </a>
    </nav>

    <!-- Contenedor para el resultado -->
    <div class="registro">
<%
    request.setCharacterEncoding("UTF-8");

    // Obtenemos el archivo directamente del formulario HTML usando su 'name'
    Part filePart = request.getPart("archivo");
    if (filePart == null || filePart.getSize() == 0) {
        out.println("<div class='alert alert-warning'><h4>Atención</h4><p>No se seleccionó ningún archivo o el archivo está vacío.</p></div>");
        return;
    }


    // Configuración de la base de datos
    
    String url = "jdbc:mysql://localhost:3306/asistencia?useSSL=false&serverTimezone=UTC&rewriteBatchedStatements=true";
    String usuario = "root";
    String contrasena = "";

    int contador = 0;
    int batchSize = 500;

    
    Pattern pattern = Pattern.compile("^(\\S+)\\s+(\\d{4}-\\d{2}-\\d{2}\\s+\\d{2}:\\d{2}:\\d{2})");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.println("<div class='alert alert-danger'><h4>Error Crítico: Driver de MySQL no encontrado.</h4>");
        out.println("<p>Asegúrate de que el archivo del conector de MySQL ('.jar') esté en la carpeta <strong>WEB-INF/lib</strong> de tu proyecto.</p></div>");
        e.printStackTrace(new PrintWriter(out));
        return;
    }

    // MEJORADO: Usar try-with-resources para el manejo automático y seguro de recursos
    try (Connection conn = DriverManager.getConnection(url, usuario, contrasena);
         PreparedStatement ps = conn.prepareStatement("INSERT INTO asistencias (codigo_marcacion, fecha_hora) VALUES (?, ?)");
         BufferedReader br = new BufferedReader(new InputStreamReader(filePart.getInputStream(), "UTF-8"))) {

        conn.setAutoCommit(false); // Desactivar autocommit para operaciones en lote, mejora el rendimiento

        String linea;
        while ((linea = br.readLine()) != null) {
            Matcher matcher = pattern.matcher(linea.trim());
            
            if (matcher.find()) {
                String codigo_marcacion = matcher.group(1);
                String fecha_hora = matcher.group(2);

                ps.setString(1, codigo_marcacion);
                ps.setString(2, fecha_hora);
                ps.addBatch();
                contador++;

                if (contador % batchSize == 0) {
                    ps.executeBatch();
                }
            }
        }

        ps.executeBatch(); // Ejecutar el lote restante
        conn.commit(); // Confirmar la transacción completa

        out.println("<div class='alert alert-success'><h4>¡Éxito!</h4><p>Archivo procesado correctamente. Se insertaron <strong>" + contador + "</strong> registros.</p></div>");

    } catch (BatchUpdateException bue) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.println("<div class='alert alert-danger'><h4>Error en la Base de Datos</h4><p>Ocurrió un error durante la inserción en lote. No se guardó ningún registro.</p>");
        out.println("<p><strong>Causa probable:</strong> Un registro en el archivo ya existe en la base de datos o tiene un formato inválido.</p>");
        out.println("<p><strong>Mensaje técnico:</strong> " + bue.getMessage() + "</p></div>");
        out.println("<pre>");
        bue.printStackTrace(new PrintWriter(out));
        out.println("</pre>");
    } catch (Throwable t) { // MEJORADO: Capturar Throwable para errores graves (ej. OutOfMemoryError)
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.println("<div class='alert alert-danger'><h4>Error Crítico al Procesar</h4><p><strong>Error:</strong> " + t.getClass().getName() + "</p>");
        out.println("<p><strong>Mensaje:</strong> " + t.getMessage() + "</p></div>");
        out.println("<pre>");
        t.printStackTrace(new PrintWriter(out));
        out.println("</pre>");
    }
%>
        <div class="text-center mt-3">
            <a href="../reporte.html" class="btn btn-primary">Volver a Reportes</a>
        </div>
    </div>

    <!-- Scripts para animaciones -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>
    <script src="../js/animaciones.js"></script>

</body>
</html>
