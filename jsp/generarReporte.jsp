<%@ page import="java.sql.*" %>

<%
    // Obtener datos del formulario
    String codigo_marcacion = request.getParameter("codigo_marcacion");
    String fechaInicio = request.getParameter("fechaInicio");
    String fechaFin = request.getParameter("fechaFin");
    
    String url = "jdbc:mysql://localhost:3306/asistencia";
    String usuario = "root";
    String contrasena = "";

    Connection conn = null;
    ResultSet rs = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, usuario, contrasena);

        String sql = "SELECT " +
                     "DATE(fecha_hora) AS fecha, " +
                     "DATE_FORMAT(fecha_hora, '%W') AS dia_semana, " +
                     "MIN(TIME(fecha_hora)) AS entrada, " +
                     "MAX(TIME(fecha_hora)) AS salida " +
                     "FROM asistencias " +
                     "WHERE fecha_hora BETWEEN ? AND ? AND codigo_marcacion = ? " +
                     "GROUP BY DATE(fecha_hora) " +
                     "ORDER BY fecha_hora ASC";

        ps = conn.prepareStatement(sql);
        ps.setString(1, fechaInicio);
        ps.setString(2, fechaFin);
        ps.setString(3, codigo_marcacion);

        rs = ps.executeQuery();

        // Mostrar los resultados en una tabla
%>
        <table border="1">
            <tr>
                <th>Fecha</th>
                <th>Día</th>
                <th>Entrada</th>
                <th>Salida</th>
            </tr>
<%
        while (rs.next()) {
%>
            <tr>
                <td><%= rs.getString("fecha") %></td>
                <td><%= rs.getString("dia_semana") %></td>
                <td><%= rs.getString("entrada") %></td>
                <td><%= rs.getString("salida") %></td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
%>
        </table>