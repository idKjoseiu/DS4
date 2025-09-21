<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Eliminar Registro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">
    <link rel="stylesheet" href="css/styles.css">
    <!-- fuente de google-->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">

    <link rel="icon" href="logo/incono.png" type="image/png">

    <!-- Iconos -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
</head>
<style>
    body{
        display: flex;
        flex-direction: column;
        align-items: center;
    }
</style>
<body>
    <div class="encabezado"></div>
    <div class="ParteLogo">
        <div class="logo">
            <img src="css\logo\iconoHorizontal.png" alt="logo">
        </div>
    </div>

    <nav class="OpcLateral">
        <a href="registro.html" class="OpcLateral-link">
            <span class="material-icons-outlined">person_add</span>
            Registrarse
        </a>
        <a href="reporte.html" class="OpcLateral-link">
            <span class="material-icons-outlined">assignment</span>
            Reporte
        </a>
    </nav>

    <div class="contenedor-central">
        <div class="modo-selector">
            <a href="registro.html" class="modo-btn">Registrar</a>
            <a href="eliminar.html" class="modo-btn active">Eliminar</a>
        </div>

        <div class="registro">
            <h1>Búsqueda de Personal</h1>
            <form action="eliminar.jsp" method="post">
                <label for="cedula">Cédula</label>
                <input type="text" pattern="[0-9]{1}-[0-9]{4}-[0-9]{4}" title="Formato: 1-2345-6789" maxlength="11" id="cedula" name="cedula" placeholder="0-0000-0000" required>
                 <script>
                    
                    const cedula = document.getElementById("cedula");
                    cedula.addEventListener("input", function () {
                        let valor = this.value.replace(/\D/g, "");
                        
                        if (valor.length > 1 && valor.length <= 5) {
                            valor = valor.slice(0, 1) + "-" + valor.slice(1);
                        } else if (valor.length > 5) {
                            valor = valor.slice(0, 1) + "-" + valor.slice(1, 5) + "-" + valor.slice(5, 9);
                        }
                        this.value = valor;
                    });
                </script>
                <button type="submit" class="btn btn-primary mt-3">Buscar</button>
            </form>
        </div>
    </div>

    <%@ page import="java.sql.*" pageEncoding="UTF-8" %>

<%

    String cedula = request.getParameter("cedula");
    if (cedula != null && !cedula.trim().isEmpty()) {

        String url = "jdbc:mysql://localhost:3306/asistencia";
        String usuario = "root";
        String contrasena = "";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, usuario, contrasena);

            String sql = "SELECT cedula, nombre, apellido, codigo_marcacion FROM personal WHERE cedula = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, cedula);

            rs = ps.executeQuery();
%>
    <div class="contenedor-central" style="margin-top: 20px;">
        <hr style="border-color: #f6f5f5;">
        <h2 style="color: #ffffff; text-align: center;">Resultados de la Búsqueda</h2>
<%
            if (rs.next()) {
%>
        <div class="table-responsive">
            <table class="table table-striped table-dark">
                <thead>
                    <tr>
                        <th>Cédula</th>
                        <th>Nombre</th>
                        <th>Apellido</th>
                        <th>Código</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><%= rs.getString("cedula") %></td>
                        <td><%= rs.getString("nombre") %></td>
                        <td><%= rs.getString("apellido") %></td>
                        <td><%= rs.getString("codigo_marcacion") %></td>
                        <td>
                            <div class="d-flex gap-2">
                                <form method="post" action="eliminar.jsp">
                                    <input type="hidden" name="cedula" value="<%= rs.getString("cedula") %>">
                                    <button style="height: 38px;" type ="submit" name="accion" value="editar" class="btn btn-warning"action="Editar">Editar</button>
                                    
                                </form>
                                <form method="post" action="eliminar.jsp" onsubmit="return confirm('¿Estás seguro de eliminar este registro?');" class="d-inline">
                                    <input type="hidden" name="cedula" value="<%= rs.getString("cedula") %>">
                                    <button style="height: 38px;" type="submit" name="accion" value="eliminar" class="btn btn-sm btn-danger">Eliminar</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
<%

            String accion = request.getParameter("accion");
            

            if ("editar".equals(accion)){
%>
                <form method="post" action="eliminar.jsp">
                    out.println("<div class='alert alert-success'>Disponible pronto.</div>");
                </form>
<%
                if ("actualizar".equals(accion)) {
                    String nombre = request.getParameter("nombre");
                    String apellido = request.getParameter("apellido");
                    String codigo = request.getParameter("codigo_marcacion");
                    
                    try {
                        String sqlUpdate = "UPDATE personal SET nombre=?, apellido=?, codigo_marcacion=? WHERE cedula=?";
                        ps = conn.prepareStatement(sqlUpdate);
                        ps.setString(1, nombre);
                        ps.setString(2, apellido);
                        ps.setString(3, codigo);
                        ps.setString(4, cedula);

                        int filas = ps.executeUpdate();
                        if (filas > 0) {
                            out.println("<div class='alert alert-success'>Registro actualizado correctamente.</div>");
                        } else {
                            out.println("<div class='alert alert-danger'>No se pudo actualizar el registro.</div>");
                        }
                    } catch (SQLException e) {
                        out.println("<div class='alert alert-danger'>Error al actualizar el registro: " + e.getMessage());
                    }

                }

            }else if ("eliminar".equals(accion)){
                try {
                    String eliminarSql =" DELETE FROM personal WHERE cedula = ?";
                    ps = conn.prepareStatement(eliminarSql);
                    ps.setString(1, cedula);
                    int filas = ps.executeUpdate();
                    if (filas > 0) {
                            out.println("<div class='alert alert-success'>Registro eliminado correctamente.</div>");
                        } else {
                            out.println("<div class='alert alert-danger'>No se pudo eliminar el registro.</div>");
                        }

                }catch (SQLException e) {
                    out.println("<div class='alert alert-danger'>Error al eliminar el registro: " + e.getMessage());
                }    
            }


            } else {
                out.println("<div><p class='text-center text-warning'>No se encontró personal con la cédula proporcionada.</p></div>");
            }
        } catch (Exception e) {
            // Imprimir el error en un formato visible
            out.println("<div class='contenedor-central'><div class='alert alert-danger'>Error al buscar el registro: " + e.getMessage() + "</div></div>");
            e.printStackTrace(new java.io.PrintWriter(out));
        } finally {
            // Bloque finally para asegurar el cierre de recursos
            if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignorado */ }
            if (ps != null) try { ps.close(); } catch (SQLException e) { /* ignorado */ }
            if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignorado */ }
        }
    } // fin del if (cedula != null)
%>
</body>
</html>