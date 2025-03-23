function detectMiroEmbed() {
    try {
        return window.parent && window.parent !== window;
    } catch (e) {
        return true;
    }
}

function optimizeForMiro() {
    if (detectMiroEmbed()) {
        document.body.classList.add('miro-embed');
        
        const elementsToRemove = document.querySelectorAll('.nav, .footer, .instructions');
        elementsToRemove.forEach(element => {
            if (element) element.remove();
        });
        
        const mainContainers = document.querySelectorAll('.tabelle-container, .bildkarten-container, .arbeitsblatt-container');
        mainContainers.forEach(container => {
            if (container) container.classList.add('miro-container');
        });
        
        document.documentElement.style.height = '100%';
        document.body.style.height = '100%';
    }
}

document.addEventListener('DOMContentLoaded', optimizeForMiro);
