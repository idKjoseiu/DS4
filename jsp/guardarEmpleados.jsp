<%@ page import="java.sql.*" %>
<%
    // Datos de conexión
    String url = "jdbc:mysql://localhost:3306/Asistencia";
    String usuario = "root";
    String contrasena = "";

    // Datos recibidos del formulario
    String cedula = request.getParameter("cedula");
    String nombre = request.getParameter("nombre");
    String apellido = request.getParameter("apellido");
    String codigo_marcacion = request.getParameter("codigo_marcacion");

    Connection con = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, usuario, contrasena);

        String sql = "INSERT INTO personal (cedula, nombre, apellido, codigo_marcacion) VALUES (?, ?, ?, ?)";
        ps = con.prepareStatement(sql);
        ps.setString(1, cedula);
        ps.setString(2, nombre);
        ps.setString(3, apellido);
        ps.setString(4, codigo_marcacion);

        int filas = ps.executeUpdate();

        if (filas > 0) {
            out.println("Empleado guardado correctamente");
        } else {
            out.println("No se pudo guardar el empleado");
        }

    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>
