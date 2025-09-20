<%@ page import="java.sql.*" %>
<%@ page language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    String fechaInicio = request.getParameter("fechaInicio");
    String fechaFin = request.getParameter("fechaFin");
    String codigo = request.getParameter("codigo_marcacion");

    if (fechaInicio == null || fechaFin == null || codigo == null) {
        out.println("<h2>Faltan datos para la búsqueda.</h2>");
        return;
    }

    String url = "jdbc:mysql://localhost:3306/asistencia?useSSL=false&serverTimezone=UTC";
    String usuario = "root";
    String contrasena = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, usuario, contrasena);
        PreparedStatement ps = conn.prepareStatement(
            "SELECT * FROM asistencias WHERE codigo_marcacion = ? AND fecha_hora BETWEEN ? AND ?"
        );
        ps.setString(1, codigo);
        ps.setString(2, fechaInicio);
        ps.setString(3, fechaFin);

        ResultSet rs = ps.executeQuery();

        out.println("<h2>Resultados de la búsqueda:</h2>");
        out.println("<table border='1'><tr><th>Código</th><th>Fecha y Hora</th></tr>");
        while (rs.next()) {
            out.println("<tr><td>" + rs.getString("codigo_marcacion") + "</td><td>" + rs.getString("fecha_hora") + "</td></tr>");
        }
        out.println("</table>");

        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        out.println("<h2>Error al buscar asistencias: " + e.getMessage() + "</h2>");
    }
%>