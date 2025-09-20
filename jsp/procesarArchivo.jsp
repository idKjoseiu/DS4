<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.io.*, java.sql.*, java.util.*, java.text.*, java.util.regex.*, javax.servlet.http.Part" %>
<%
    request.setCharacterEncoding("UTF-8");

    // Obtenemos el archivo directamente del formulario HTML usando su 'name'
    Part filePart = request.getPart("archivo");
    if (filePart == null || filePart.getSize() == 0) {
        out.println("<h2>No se recibió contenido del archivo.</h2>");
        return;
    }


    // Configuración de la base de datos
    // AÑADIDO: rewriteBatchedStatements=true para un rendimiento de inserción masivamente mejorado en MySQL
    String url = "jdbc:mysql://localhost:3306/asistencia?useSSL=false&serverTimezone=UTC&rewriteBatchedStatements=true";
    String usuario = "root";
    String contrasena = "";

    int contador = 0;
    int batchSize = 500;

    // Regex to find: (group 1: code) followed by (group 2: full timestamp)
    Pattern pattern = Pattern.compile("^(\\S+)\\s+(\\d{4}-\\d{2}-\\d{2}\\s+\\d{2}:\\d{2}:\\d{2})");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.println("<h2>Error Crítico: Driver de MySQL no encontrado.</h2>");
        out.println("<p>Asegúrate de que el archivo 'mysql-connector-java-x.x.x.jar' esté en la carpeta <strong>WEB-INF/lib</strong> de tu proyecto o en la carpeta <strong>lib</strong> de Tomcat.</p>");
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

        out.println("<h2>Archivo procesado correctamente. Registros insertados: " + contador + "</h2>");

    } catch (BatchUpdateException bue) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.println("<h2>Error durante la inserción en lote. No se guardó ningún registro.</h2>");
        out.println("<p><strong>Mensaje:</strong> " + bue.getMessage() + "</p>");
        out.println("<p>Esto suele ocurrir por un dato duplicado o un formato incorrecto que viola una regla de la base de datos.</p>");
        out.println("<pre>");
        bue.printStackTrace(new PrintWriter(out));
        out.println("</pre>");
    } catch (Throwable t) { // MEJORADO: Capturar Throwable para errores graves (ej. OutOfMemoryError)
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.println("<h2>Error crítico al procesar el archivo: " + t.getClass().getName() + "</h2>");
        out.println("<p><strong>Mensaje:</strong> " + t.getMessage() + "</p>");
        out.println("<pre>");
        t.printStackTrace(new PrintWriter(out));
        out.println("</pre>");
    }
%>
