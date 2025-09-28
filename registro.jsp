<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <link rel="stylesheet" href="css/styles.css">

    <!-- fuente de google-->    
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">

    <link rel="icon" href="logo/incono.png" type="image/png"> 
    <!-- Iconos -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
</head>

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
            <a href="registro.jsp" class="modo-btn active">Registrar</a>
            <a href="eliminar.jsp" class="modo-btn">Eliminar</a>
        </div>
        
        <div class="registro">
            <h1>Registro de personal</h1>
            <form method="post">
                <label for="cedula">Cédula</label>
                <input type="text" pattern="[0-9]{1}-[0-9]{4}-[0-9]{4}" maxlength="11" id="cedula" name="cedula" placeholder="0-0000-0000" required>
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

                <label for="nombre">Nombre:</label>
                <input type="text" pattern="[^0-9]*" maxlength="20" id="nombre" name="nombre" placeholder="Escribe tu nombre" required>
                
                <label for="apellido">Apellido:</label>
                <input type="text" pattern="[^0-9]*" maxlength="20" id="apellido" name="apellido" placeholder="Escribe tu apellido" required>
                
                <label for="codigo_marcacion">Código de Marcación:</label>
                <input type="text" pattern="[0-9]+" maxlength="4" style="width: 50px" id="codigo_marcacion" name="codigo_marcacion" placeholder="0000" required>
                
                <button type="submit" class="btn btn-primary mt-2">Registrar</button>
            </form>

            
            <div class="mt-3">
                <%
                    request.setCharacterEncoding("UTF-8");
                    String cedula = request.getParameter("cedula");
                    if (cedula != null) {
                        String nombre = request.getParameter("nombre");
                        String apellido = request.getParameter("apellido");
                        String codigo_marcacion = request.getParameter("codigo_marcacion");

                        String url = "jdbc:mysql://localhost:3306/asistencia";
                        String usuario = "root";
                        String contrasena = "";

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
                %>
                                <div class="alert alert-success">Empleado registrado con éxito.</div>
                <%
                            } else {
                %>
                                <div class="alert alert-danger">Error al registrar el empleado.</div>
                <%
                            }
                        } catch (Exception e) {
                %>
                            <div class="alert alert-warning">Error: <%= e.getMessage() %></div>
                <%
                        } finally {
                            if (ps != null) try { ps.close(); } catch (Exception ex) {}
                            if (con != null) try { con.close(); } catch (Exception ex) {}
                        }
                    }
                %>
            </div>
        </div>
    </div>

<!-- animaciones -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>

<!-- Tu archivo JS -->
<script src="js/animaciones.js"></script>
</body>
</html>
