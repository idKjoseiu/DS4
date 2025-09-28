<%@ page import="java.sql.*" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Eliminar Registro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="icon" href="logo/incono.png" type="image/png">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
</head>
<style>
    body {
        display: flex;
        flex-direction: column;
        align-items: center;
    }
</style>
<body>
    <div class="encabezado"></div>
    <div class="ParteLogo">
        <div class="logo">
            <img src="css/logo/iconoHorizontal.png" alt="logo">
        </div>
    </div>

    <nav class="OpcLateral">
        <a href="registro.jsp" class="OpcLateral-link">
            <span class="material-icons">person_add</span>
            Registrarse
        </a>
        <a href="reporte.html" class="OpcLateral-link">
            <span class="material-icons-outlined">assignment</span>
            Reporte
        </a>
    </nav>

    <div class="contenedor-central">
        <div class="modo-selector">
            <a href="registro.jsp" class="modo-btn">Registrar</a>
            <a href="eliminar.jsp" class="modo-btn active">Eliminar</a>
        </div>

        <div class="registro" style="margin-bottom: 30px;">
            <h1>Búsqueda de Personal</h1>
            <form action="eliminar.jsp" method="post">
                <label for="cedula">Cédula</label>
                <input type="text" pattern="[0-9-]*" maxlength="15" id="cedula" name="cedula" placeholder="0-0000-0000" required oninput="this.value = this.value.replace(/[^0-9-]/g, '')">
               
                <button type="submit" class="btn btn-primary mt-3">Buscar</button>
            </form>
        </div>
    </div>

    <div id="resultados-container" style="width:100%; max-width:700px; margin:0 auto; margin-top:-120px; height:350px; overflow-y:auto;">
        
        <%
        request.setCharacterEncoding("UTF-8");
        String cedula = request.getParameter("cedula");
        String accion = request.getParameter("accion");
        
        if ("eliminar".equals(accion)) {
            String cedulaEliminar = request.getParameter("cedula");
            Connection conn = null;
            PreparedStatement psDel = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/asistencia", "root", "");
                String sqlDelete = "DELETE FROM personal WHERE cedula=?";
                psDel = conn.prepareStatement(sqlDelete);
                psDel.setString(1, cedulaEliminar);
                int filas = psDel.executeUpdate();
                if (filas > 0) {
                    out.println("<div class='alert alert-success'>Registro eliminado correctamente.</div>");
                } else {
                    out.println("<div class='alert alert-warning'>No se encontró el registro para eliminar.</div>");
                }
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error al eliminar: " + e.getMessage() + "</div>");
            } finally {
                if (psDel != null) try { psDel.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        } // fin eliminar
        
        if ("Guardar".equals(accion)) {
            String cedulaOriginal = request.getParameter("cedulaOriginal");
            String Nuevacedula = request.getParameter("Nuevacedula");
            String nombre = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String codigo = request.getParameter("codigo_marcacion");

            Connection conn = null;
            PreparedStatement psAC = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/asistencia", "root", "");
                String sqlUpdate = "UPDATE personal SET cedula=?, nombre=?, apellido=?, codigo_marcacion=? WHERE cedula=?";
                psAC = conn.prepareStatement(sqlUpdate);
                psAC.setString(1, Nuevacedula);
                psAC.setString(2, nombre);
                psAC.setString(3, apellido);
                psAC.setString(4, codigo);
                psAC.setString(5, cedulaOriginal);

                int filas = psAC.executeUpdate();
                if (filas > 0) {
                    out.println("<div class='alert alert-success'>Registro actualizado correctamente.</div>");
                } else {
                    out.println("<div class='alert alert-danger'>No se pudo actualizar el registro.</div>");
                }
            } catch (SQLException e) {
                out.println("<div class='alert alert-danger'>Error al actualizar: " + e.getMessage() + "</div>");
            } finally {
                if (psAC != null) try { psAC.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }

            //busca el registro
        } else if (cedula != null && !cedula.trim().isEmpty()) {
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
            <hr style="border-color: #f6f5f5;">
            <h2 style="color: #ffffff; text-align: center;">Resultados de la Búsqueda</h2>
        <%
                if (rs.next()) {
        %>
            <div class="table-responsive">
                <table class="table table-striped table-dark rounded-3 overflow-hidden">
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
                                        <button style="height: 38px;" type="submit" name="accion" value="editar" class="btn btn-warning">Editar</button>
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
                    if ("editar".equals(accion)) {
                        String cedulaOriginal = request.getParameter("cedula");
        %>            
                        <div class="border border-secondary rounded p-3 bg-dark text-white">
                            <h6>Ingrese sus nuevos datos</h6>
                            <form id="actualizarFORM" method="post" action="eliminar.jsp">
                                <div class="d-flex align-items-center gap-3">
                                    <input type="hidden" name="cedulaOriginal" value="<%= cedulaOriginal %>">
                                    <label for="Nuevacedula">Cédula</label>
                                    <input style="width: 100px;" type="text" pattern="[0-9-]*" maxlength="15" id="Nuevacedula" name="Nuevacedula" value="<%= rs.getString("cedula") %>" oninput="this.value = this.value.replace(/[^0-9-]/g, '')">

                                    <label for="nombre">Nombre</label>
                                    <input style="width: 150px;" type="text" pattern="[a-zA-Z\s]*" maxlength="20" id="nombre" name="nombre" value="<%= rs.getString("nombre") %>" oninput="this.value = this.value.replace(/[^a-zA-Z\s]/g, '')">
                                </div>

                                <div class="d-flex align-items-center gap-3">
                                    <label for="apellido">Apellido</label>
                                    <input style="width: 150px;" type="text" pattern="[a-zA-Z\s]*" maxlength="20" id="apellido" name="apellido" value="<%= rs.getString("apellido") %>" oninput="this.value = this.value.replace(/[^a-zA-Z\s]/g, '')">

                                    <label for="codigo_marcacion">Código</label>
                                    <input type="text" pattern="[0-9]*" maxlength="4" style="width: 50px" id="codigo_marcacion" name="codigo_marcacion" value="<%= rs.getString("codigo_marcacion") %>" oninput="this.value = this.value.replace(/[^0-9]/g, '')">

                                    <button type="submit" class="btn btn-success btn-lg" name="accion" value="Guardar">Guardar</button>
                                </div>
                            </form>
                        </div>
        <%
                    } // fin editar
                } else {
                    out.println("<div class='alert alert-warning'>No se encontró personal con la cédula: " + cedula + "</div>");
                }
                rs.close();
                ps.close();
                conn.close();
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error en búsqueda: " + e.getMessage() + "</div>");
            }
        } // fin else if cedula
        %>
    </div>
<!-- animaciones -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>

        <!-- Tu archivo JS -->
<script src="js/animaciones.js"></script>

</body>
</html>
