
<%@ page contentType = "text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>  m
<head>
    <meta charset="UTF-8">
    <title>Días libres</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">

    <link rel="stylesheet" href="../css/styles.css">

    <!-- fuente de google-->    
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <!-- Iconos -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet"> 
</head>

<body>
    <div class="encabezado"></div>
    <div class="ParteLogo">
        <div class="logo">
            <img src="../css/logo/iconoHorizontal.png" alt="logo">
        </div>
    </div>
    
    <nav class = "OpcLateral">
        <a href = "../registro.jsp" class = "OpcLateral-link">
            <span class = "material-icons">person_add</span>
            Registrarse
        </a>

        <a href = "../reporte.html" class =" OpcLateral-link">
            <span class = "material-icons">assignment</span>
            Reporte
        </a>
    </nav>
    
    <div class = "contenedor-central" style = "top: 48px; position: absolute;">
        
        <div class = "modo-selector">
            <a href="../reporte.html" class="modo-btn">Reportes</a>
            <a href="agregarDiasL.jsp" class="modo-btn active">Dias Libres</a>
        </div>
    

    <div class = "registro" style = "width: 100%;">
        <h1> Gestión de Dias libres</h1>
        <hr style = "color: white;">
            <form id = "FormularioDias"  method = "post">
            <div style="display: flex; gap: 10px; align-items: center;">
                <label for = "dia"> Dia: </label>
                <input type = "date" name = "dia_libre"  id = "dia_libre" placeholder="Ingrese el dia libre">
            
                <label for = "dia"> Detalles: </label>
                <input style ="width: 300px;" type = "text" name = "detalles" id = "detalles" maxlength=50 placeholder = "Ingrese detalles del dia libre">
            </div>
            <hr style = "color: white; border: 1px solid;">
            <center>
            <div>
                <button type = "submit" class="btn btn-primary" name = "accion" value = "agregar"> Agregar </button>
                <button type = "submit" class ="btn btn-secondary" name = "accion" value = "verDias"> Ver dias libres </button>   
            </div>
             </center>

            </form>   
           
        


            <script>
                document.getElementById("FormularioDias").addEventListener("submit", function (e) {
                    const accion = e.submitter.value;
                    const dia = document.getElementById("dia_libre");
                    const detalles = document.getElementById("detalles");
                    const form = e.target;

                    //Busca si ya existe una alerta en el formulario
                    let alerta = document.getElementById("mensaje-alerta");

                    if (!alerta) {
                        alerta = document.createElement("div");
                        alerta.id = "mensaje-alerta";
                        form.appendChild(alerta);
                    }
                    
                    if (accion === "verDias") {
                        form.action = "verDiasLibres.jsp";
                        form.target = "_blank"; // Abrir en una nueva pestaña
                        form.method = "post";
                    }
                    else if (accion == "agregar"){
                        if (!dia.value.trim() || !detalles.value.trim()) {
                            e.preventDefault();
                            alerta.className = "alert alert-danger";
                            alerta.textContent = "Por favor, complete todos los campos antes de enviar el formulario.";
                            dia.focus();
                        }else {
                            alerta.textContent = null; // Limpiar el mensaje de alerta si todo está bien
                            
                        }
                        
                    }
                });
            </script>
        </div>
    <%@ page import ="java.sql.*" %>
    <%
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        String dia = request.getParameter("dia_libre");
        String detalles = request.getParameter("detalles");

        if ("agregar".equals(accion) && dia != null && detalles != null) {
            String url = "jdbc:mysql://localhost:3306/asistencia";
            String usuario = "root";
            String contrasena = "";

            Connection con = null;
            PreparedStatement ps = null;

            try{
                 Class.forName("com.mysql.cj.jdbc.Driver");
                 con = DriverManager.getConnection (url, usuario, contrasena);

                 String sql = "INSERT INTO dias_libres ( fecha, detalle) VALUES (?, ?)";
                 ps = con.prepareStatement(sql);
                 ps.setString(1, dia);
                 ps.setString(2, detalles);
                
                int filas = ps.executeUpdate();
                if (filas > 0) {
                    %>
                        <div class = "alert alert-success"> Fecha registrada con éxito. </div>
                    <%
                }else {
                    %>
                        <div class = "alert alert-danger"> Error al registrar la fecha. </div>
                <%
                }

            } catch (Exception e) {
                %>
                    <div class = "alert alert-danger"> Errot: <%= e.getMessage() %></div>
                <%
            } finally {
                if (ps != null) try { ps.close();} catch (Exception ex) {}
                if (con != null) try { con.close();} catch (Exception ex) {}
            }
        }
    %>

    </div>  
    </div>

    <!-- animaciones -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>

        <!-- Tu archivo JS -->
<script src="../js/animaciones.js"></script>
</body>
</html>