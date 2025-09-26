<%@ page import ="java.sql.*" %>
<%@ page contentType = "text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
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
    
    <div class = "contenedor-central" style = "top: -98px; position: relative;">
        
        <div class = "modo-selector">
            <a href="../reporte.html" class="modo-btn">Reportes</a>
            <a href="agregarDiasL.jsp" class="modo-btn active">Dias Libres</a>
        </div>
    

    <div class = "registro" style = "width: 100%;">
        <h1> Gestión de Dias libres</h1>
        <hr style = "color: white;">
            <form  methon = "post">
            <div style="display: flex; gap: 10px; align-items: center;">
                <label for = "dia"> Dia: </label>
                <input type = "date" name = "dia_libre"  id = "dia_libre" placeholder="Ingrese el dia libre" required>
            
                <label for = "dia"> Detalles: </label>
                <input style ="width: 300px;" type = "text" name = "detalles" id = "detalles" maxlength=50 placeholder = "Ingrese detalles del dia libre" required>
            </div>
            <br>
            <div>
                <button type = "submit" class="btn btn-primary" name = "accion" value = "agregar"> Agregar </button>
                <button type = "submit" class ="btn btn-secondary" name = "accion" value = "verDias"> Ver dias libres </button>   
            </div>
            
            </form>   
            <hr style = "color: white; border: 2px solid;">
        

    </div>
    </div>
</body>
</html>