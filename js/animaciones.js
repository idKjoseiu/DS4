// animaciones.js

// 1. Animar formularios al cargar
document.addEventListener("DOMContentLoaded", () => {
    anime({
        targets: '.registro form, #FormularioDias',
        translateY: [-50, 0],
        opacity: [0, 1],
        duration: 1200,
        easing: 'easeOutExpo'
    });

    // 2. Animar botones al pasar el mouse
    const botones = document.querySelectorAll(".btn-primary, .btn-success, .btn-secondary, .btn-warning, .btn-danger");
    botones.forEach(btn => {
        btn.addEventListener("mouseenter", () => {
            anime({
                targets: btn,
                scale: 1.08,
                boxShadow: '0 8px 20px rgba(0,0,0,0.3)',
                duration: 400,
                easing: "easeOutQuad"
            });
        });
        btn.addEventListener("mouseleave", () => {
            anime({
                targets: btn,
                scale: 1,
                boxShadow: '0 2px 6px rgba(0,0,0,0.2)',
                duration: 400,
                easing: "easeOutQuad"
            });
        });
    });

    // 3. Animar alertas cuando aparecen
    const alertas = document.querySelectorAll(".alert");
    if (alertas.length > 0) {
        anime({
            targets: alertas,
            translateX: [-100, 0],
            opacity: [0, 1],
            duration: 800,
            easing: "easeOutBack"
        });
    }

    // 4. Animar tablas suavemente al aparecer (sin parpadeos ni resplandores)
    const tablas = document.querySelectorAll(".table");
    tablas.forEach(tabla => {
        anime({
            targets: tabla,
            opacity: [0, 1],
            translateY: [20, 0],
            duration: 1000,
            delay: 200,
            easing: "easeOutQuad"
        });
    });

    // 5. Animación para abrir el contenedor de gráficos
    const graficoContainer = document.getElementById('graficoContainer');
    if (graficoContainer) {
        graficoContainer.style.opacity = 0;
        const observer = new MutationObserver(() => {
            if (graficoContainer.style.display !== 'none') {
                anime({
                    targets: graficoContainer,
                    opacity: [0, 1],
                    translateY: [20, 0],
                    duration: 800,
                    easing: "easeOutExpo"
                });
            }
        });
        observer.observe(graficoContainer, { attributes: true, attributeFilter: ['style'] });
    }
});
