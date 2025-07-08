/**
 * HIERARCHICAL NAVIGATION SYSTEM
 * Zoomende Navigation für LAA Unterrichtsmaterialien
 * Repository-Struktur basierte Organisation
 */

class HierarchicalNavigation {
    constructor() {
        this.currentLevel = 1;
        this.navigationStack = [];
        this.favorites = this.loadFavorites();
        this.repositoryStructure = this.initializeStructure();
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadNavigationState();
        this.renderCurrentLevel();
        this.updateSidebar();
    }

    // Repository Structure Mapping
    initializeStructure() {
        return {
            level1: {
                sport: {
                    title: "🏃‍♂️ Sport",
                    description: "Innovative Sportunterrichtsmaterialien mit iPad-Integration",
                    status: "active",
                    classes: ["Sm8ab"],
                    path: "unterricht/Sport",
                    sequences: 3,
                    completed: 1
                },
                gpg: {
                    title: "🏛️ GPG",
                    description: "Systemtheoretische Politikdidaktik nach Sybille Reinhardt",
                    status: "active",
                    classes: ["5b", "5c"],
                    path: "unterricht/GPG_Arbeitsweisen_LAA_Training",
                    sequences: 2,
                    completed: 1
                },
                tools: {
                    title: "🛠️ Tools & Ressourcen",
                    description: "Generatoren, Templates und Organisationstools",
                    status: "completed",
                    path: "tools",
                    items: 4
                }
            },
            sport: {
                sequences: {
                    volleyball: {
                        title: "🏐 Volleyball",
                        class: "Sm8ab",
                        students: 16,
                        duration: "KW 20-30",
                        lernbereich: "LB 4.3 - Spielen und Wetteifern",
                        ues: 6,
                        completed: 3,
                        status: "active",
                        path: "unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball"
                    },
                    basketball: {
                        title: "🏀 Basketball",
                        class: "Sm8ab",
                        status: "planned",
                        ues: 5
                    },
                    fussball: {
                        title: "⚽ Fußball",
                        class: "Sm8ab",
                        status: "planned",
                        ues: 4
                    }
                }
            },
            volleyball: {
                ues: {
                    ue1: {
                        title: "UE 1: Oberes Zuspiel - Wiederholung",
                        date: "KW 20",
                        status: "completed",
                        competencies: ["Ballgewöhnung", "Pritschen-Grundlagen"],
                        materials: 2
                    },
                    ue2: {
                        title: "UE 2: Oberes Zuspiel - Vertiefung",
                        date: "KW 22",
                        status: "completed",
                        competencies: ["Präzision", "Stationentraining"],
                        materials: 3
                    },
                    ue3: {
                        title: "UE 3: Unteres Zuspiel (Baggern) - BUV",
                        date: "09.07.2025",
                        status: "completed",
                        type: "BUV",
                        competencies: ["Stoppschritt", "Spielbrett", "Hüfthöhe", "Kooperation"],
                        materials: 8,
                        stations: 6,
                        path: "unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball",
                        featured: true
                    },
                    ue4: {
                        title: "UE 4: Kombiniertes Spiel",
                        status: "planned",
                        competencies: ["Technik-Kombination", "Situationsspiel"]
                    },
                    ue5: {
                        title: "UE 5: Spielformen 2v2/3v3",
                        status: "planned",
                        competencies: ["Taktik", "Gruppendynamik"]
                    },
                    ue6: {
                        title: "UE 6: Mini-Turnier",
                        status: "planned",
                        competencies: ["Wettkampf", "Fairplay"]
                    }
                }
            },
            ue3: {
                materials: {
                    buv: {
                        title: "📋 BUV-Dokumentation",
                        type: "documentation",
                        standard: "Marc Kunz",
                        path: "volleyball-ue3-buv.html",
                        preview: true
                    },
                    stations: {
                        title: "🎮 6 Interaktive Stationskarten",
                        type: "interactive",
                        count: 6,
                        technology: "HTML5 + iPad",
                        items: [
                            {
                                id: "station-01",
                                title: "Station 1: Ring-Drill",
                                focus: "Spielbrett-Bildung",
                                path: "artifacts/stations/station-01-ring-drill.html",
                                preview: true
                            },
                            {
                                id: "station-02",
                                title: "Station 2: Hand-Auge-Koordination",
                                focus: "Ballgefühl + Konzentration",
                                path: "artifacts/stations/station-02-hand-eye.html",
                                preview: true
                            },
                            {
                                id: "station-03",
                                title: "Station 3: Positionierung am Netz",
                                focus: "Stoppschritt zum Ball",
                                path: "artifacts/stations/station-03-positioning.html",
                                preview: true
                            },
                            {
                                id: "station-04",
                                title: "Station 4: Ball-Beinen-fangen",
                                focus: "Hüfthöhe-Simulation",
                                path: "artifacts/stations/station-04-legs-catching.html",
                                preview: true
                            },
                            {
                                id: "station-05",
                                title: "Station 5: Wandbaggern",
                                focus: "Technik-Anwendung",
                                path: "artifacts/stations/station-05-wall-bagging.html",
                                preview: true
                            },
                            {
                                id: "station-06",
                                title: "Station 6: Wandbaggern Alternative",
                                focus: "Variation & Zusatz",
                                path: "artifacts/stations/station-06-wall-bagging-alt.html",
                                preview: true
                            }
                        ]
                    },
                    materials: {
                        title: "📄 Lernhilfen & Wortkarten",
                        type: "downloads",
                        items: [
                            { name: "Wortkarte Stoppschritt", path: "artifacts/materials/wortkarte-stoppschritt.pdf" },
                            { name: "Wortkarte Spielbrett", path: "artifacts/materials/wortkarte-spielbrett.pdf" },
                            { name: "Wortkarte Hüfthöhe", path: "artifacts/materials/wortkarte-huefthoehe.pdf" }
                        ]
                    },
                    qr: {
                        title: "📱 QR-Code Generator",
                        type: "tool",
                        path: "/qr-generator.html",
                        description: "Für iPad-Classroom Integration"
                    }
                }
            }
        };
    }

    // Navigation State Management
    navigateTo(level, data = {}) {
        // Add current state to navigation stack
        if (this.currentLevel < level) {
            this.navigationStack.push({
                level: this.currentLevel,
                data: this.currentData || {}
            });
        } else if (this.currentLevel > level) {
            // Going back - pop from stack
            this.navigationStack = this.navigationStack.slice(0, level - 1);
        }

        this.currentLevel = level;
        this.currentData = data;
        
        this.saveNavigationState();
        this.renderCurrentLevel();
        this.updateBreadcrumb();
        this.updateSidebar();
        
        // Add zoom animation
        document.querySelector('.main-content').classList.add('zoom-enter');
        setTimeout(() => {
            document.querySelector('.main-content').classList.remove('zoom-enter');
        }, 300);
    }

    goBack() {
        if (this.navigationStack.length > 0) {
            const previousState = this.navigationStack.pop();
            this.currentLevel = previousState.level;
            this.currentData = previousState.data;
            
            this.saveNavigationState();
            this.renderCurrentLevel();
            this.updateBreadcrumb();
            this.updateSidebar();
        }
    }

    // Rendering Functions
    renderCurrentLevel() {
        const container = document.querySelector('.main-content');
        if (!container) return;

        switch (this.currentLevel) {
            case 1:
                this.renderDashboard(container);
                break;
            case 2:
                this.renderSequenceOverview(container);
                break;
            case 3:
                this.renderUEOverview(container);
                break;
            case 4:
                this.renderMaterialDetails(container);
                break;
        }
    }

    renderDashboard(container) {
        const data = this.repositoryStructure.level1;
        
        container.innerHTML = `
            <div class="search-bar">
                <input type="text" class="search-input" placeholder="🔍 Suche in allen Materialien..." id="globalSearch">
                <span class="search-icon">🔍</span>
            </div>
            
            <div class="filter-tabs">
                <button class="filter-tab active" data-filter="all">Alle Fächer</button>
                <button class="filter-tab" data-filter="active">Aktiv</button>
                <button class="filter-tab" data-filter="completed">Abgeschlossen</button>
                <button class="filter-tab" data-filter="planned">Geplant</button>
            </div>

            <h1>📚 LAA Unterrichtsmaterialien - Dashboard</h1>
            <p style="font-size: 1.1rem; color: #718096; margin-bottom: 2rem;">
                Hierarchische Navigation durch alle Unterrichtsmaterialien • Repository-Struktur-basiert
            </p>

            <div class="sequence-stats">
                <div class="stat-item">
                    <div class="stat-number">3</div>
                    <div class="stat-label">Aktive Fächer</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">6</div>
                    <div class="stat-label">Unterrichtssequenzen</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">12</div>
                    <div class="stat-label">Materialsammlungen</div>
                </div>
            </div>

            <div class="hierarchy-grid" id="dashboardGrid">
                ${Object.entries(data).map(([key, item]) => `
                    <div class="hierarchy-card level-1" onclick="nav.navigateTo(2, {subject: '${key}'})">
                        <div class="card-header">
                            <div style="display: flex; align-items: center;">
                                <span class="card-icon">${item.title.split(' ')[0]}</span>
                                <h3 class="card-title">${item.title.substring(item.title.indexOf(' ') + 1)}</h3>
                            </div>
                            <span class="card-status status-${item.status}">${this.getStatusText(item.status)}</span>
                        </div>
                        
                        <div class="card-meta">
                            ${item.classes ? `<span>📚 Klassen: ${item.classes.join(', ')}</span>` : ''}
                            ${item.sequences ? `<span>📋 ${item.sequences} Sequenzen</span>` : ''}
                            ${item.items ? `<span>🛠️ ${item.items} Tools</span>` : ''}
                        </div>
                        
                        <p class="card-description">${item.description}</p>
                        
                        ${item.sequences ? `
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: ${(item.completed / item.sequences) * 100}%"></div>
                            </div>
                            <small style="color: #718096;">${item.completed}/${item.sequences} Sequenzen abgeschlossen</small>
                        ` : ''}
                        
                        <div class="card-actions">
                            <button class="card-btn btn-primary">📖 Öffnen</button>
                            <button class="card-btn btn-secondary" onclick="event.stopPropagation(); nav.toggleFavorite('${key}')">
                                ${this.favorites.includes(key) ? '⭐' : '☆'} Favorit
                            </button>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;

        this.setupDashboardListeners();
    }

    renderSequenceOverview(container) {
        const subject = this.currentData.subject;
        const data = this.repositoryStructure[subject];
        
        container.innerHTML = `
            <h1>${this.getSubjectTitle(subject)} - Sequenz-Übersicht</h1>
            <p style="color: #718096; margin-bottom: 2rem;">
                Detaillierte Übersicht aller Unterrichtssequenzen mit Status und Materialien
            </p>

            <div class="hierarchy-grid">
                ${Object.entries(data.sequences || {}).map(([key, sequence]) => `
                    <div class="hierarchy-card level-2" onclick="nav.navigateTo(3, {subject: '${subject}', sequence: '${key}'})">
                        <div class="card-header">
                            <div style="display: flex; align-items: center;">
                                <span class="card-icon">${sequence.title.split(' ')[0]}</span>
                                <h3 class="card-title">${sequence.title.substring(sequence.title.indexOf(' ') + 1)}</h3>
                            </div>
                            <span class="card-status status-${sequence.status}">${this.getStatusText(sequence.status)}</span>
                        </div>
                        
                        <div class="card-meta">
                            ${sequence.class ? `<span>👥 Klasse: ${sequence.class}</span>` : ''}
                            ${sequence.students ? `<span>🧑‍🎓 ${sequence.students} SuS</span>` : ''}
                            ${sequence.duration ? `<span>📅 ${sequence.duration}</span>` : ''}
                            ${sequence.ues ? `<span>📚 ${sequence.ues} UE</span>` : ''}
                        </div>
                        
                        ${sequence.lernbereich ? `
                            <p style="color: #4a5568; font-weight: 500; margin-bottom: 1rem;">
                                ${sequence.lernbereich}
                            </p>
                        ` : ''}
                        
                        ${sequence.ues && sequence.completed ? `
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: ${(sequence.completed / sequence.ues) * 100}%"></div>
                            </div>
                            <small style="color: #718096;">${sequence.completed}/${sequence.ues} UE abgeschlossen</small>
                        ` : ''}
                        
                        <div class="card-actions">
                            <button class="card-btn btn-primary">📋 UE-Übersicht</button>
                            ${sequence.status === 'completed' || sequence.status === 'active' ? 
                                `<button class="card-btn btn-secondary" onclick="event.stopPropagation(); window.open('${sequence.path}', '_blank')">📄 Materialien</button>` 
                                : ''
                            }
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    }

    // ... rest of the methods continue in part 2
    renderUEOverview(container) {
        const { subject, sequence } = this.currentData;
        const data = this.repositoryStructure[sequence];
        
        container.innerHTML = `
            <h1>${this.getSequenceTitle(subject, sequence)} - Unterrichtseinheiten</h1>
            <p style="color: #718096; margin-bottom: 2rem;">
                Detaillierte Übersicht aller UE mit Materialien und Status-Tracking
            </p>

            <div class="hierarchy-grid">
                ${Object.entries(data.ues || {}).map(([key, ue]) => `
                    <div class="hierarchy-card level-3 ${ue.featured ? 'featured' : ''}" 
                         onclick="nav.navigateTo(4, {subject: '${subject}', sequence: '${sequence}', ue: '${key}'})">
                        <div class="card-header">
                            <h3 class="card-title">${ue.title}</h3>
                            <span class="card-status status-${ue.status}">${this.getStatusText(ue.status)}</span>
                        </div>
                        
                        <div class="card-meta">
                            ${ue.date ? `<span>📅 ${ue.date}</span>` : ''}
                            ${ue.type ? `<span>📋 ${ue.type}</span>` : ''}
                            ${ue.materials ? `<span>📦 ${ue.materials} Materialien</span>` : ''}
                            ${ue.stations ? `<span>🎮 ${ue.stations} Stationen</span>` : ''}
                        </div>
                        
                        ${ue.competencies ? `
                            <div style="margin: 1rem 0;">
                                <strong style="color: #4a5568; font-size: 0.9rem;">Kompetenzen:</strong>
                                <div style="display: flex; flex-wrap: wrap; gap: 0.5rem; margin-top: 0.5rem;">
                                    ${ue.competencies.map(comp => `
                                        <span style="background: #e2e8f0; color: #4a5568; padding: 0.2rem 0.6rem; border-radius: 12px; font-size: 0.8rem;">
                                            ${comp}
                                        </span>
                                    `).join('')}
                                </div>
                            </div>
                        ` : ''}
                        
                        ${ue.featured ? `
                            <div style="background: linear-gradient(135deg, #667eea, #764ba2); color: white; padding: 1rem; border-radius: 8px; margin: 1rem 0;">
                                <strong>🚀 Innovation-Highlight</strong><br>
                                <small>iPad-Integration mit 6 interaktiven Stationskarten</small>
                            </div>
                        ` : ''}
                        
                        <div class="card-actions">
                            <button class="card-btn btn-primary">📖 Materialien anzeigen</button>
                            ${ue.status === 'completed' ? 
                                `<button class="card-btn btn-secondary" onclick="event.stopPropagation(); window.open('${ue.path}/volleyball-ue3-buv.html', '_blank')">📋 BUV</button>` 
                                : ''
                            }
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    }

    renderMaterialDetails(container) {
        const { subject, sequence, ue } = this.currentData;
        const data = this.repositoryStructure[ue];
        
        container.innerHTML = `
            <h1>${this.getUETitle(subject, sequence, ue)} - Materialien</h1>
            <p style="color: #718096; margin-bottom: 2rem;">
                Alle Materialien, Stationskarten und Ressourcen für diese Unterrichtseinheit
            </p>

            <div class="hierarchy-grid">
                ${Object.entries(data.materials || {}).map(([key, material]) => {
                    if (material.type === 'interactive' && material.items) {
                        return `
                            <div class="hierarchy-card level-4" style="grid-column: 1 / -1;">
                                <div class="card-header">
                                    <h3 class="card-title">${material.title}</h3>
                                    <span class="card-status status-completed">✅ ${material.count} Stationen</span>
                                </div>
                                
                                <p style="color: #4a5568; margin-bottom: 1.5rem;">
                                    Interaktive HTML5-Stationskarten optimiert für iPad-Integration mit 3-Level-Differenzierung
                                </p>
                                
                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1rem;">
                                    ${material.items.map(station => `
                                        <div style="border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
                                            <div style="background: #f7fafc; padding: 0.75rem; border-bottom: 1px solid #e2e8f0;">
                                                <strong style="color: #2d3748; font-size: 0.9rem;">${station.title}</strong>
                                                <br><small style="color: #718096;">${station.focus}</small>
                                            </div>
                                            <div class="card-preview">
                                                <iframe src="${this.getBasePath()}/${sequence}/${station.path}" 
                                                        title="${station.title} Vorschau"></iframe>
                                            </div>
                                            <div style="padding: 0.75rem; display: flex; gap: 0.5rem;">
                                                <button class="card-btn btn-primary" style="flex: 1; font-size: 0.8rem;"
                                                        onclick="window.open('${this.getBasePath()}/${sequence}/${station.path}', '_blank')">
                                                    🎮 Öffnen
                                                </button>
                                                <button class="card-btn btn-secondary" style="font-size: 0.8rem;"
                                                        onclick="nav.generateQR('${this.getFullURL()}/${sequence}/${station.path}', '${station.title}')">
                                                    📱 QR
                                                </button>
                                            </div>
                                        </div>
                                    `).join('')}
                                </div>
                            </div>
                        `;
                    } else {
                        return `
                            <div class="hierarchy-card level-4">
                                <div class="card-header">
                                    <h3 class="card-title">${material.title}</h3>
                                    ${material.standard ? `<span class="card-status status-completed">${material.standard}</span>` : ''}
                                </div>
                                
                                <p style="color: #4a5568; margin-bottom: 1rem;">${material.description || ''}</p>
                                
                                ${material.preview && material.path ? `
                                    <div class="card-preview">
                                        <iframe src="${this.getBasePath()}/${sequence}/${material.path}" 
                                                title="${material.title} Vorschau"></iframe>
                                    </div>
                                ` : ''}
                                
                                ${material.items ? `
                                    <div style="margin: 1rem 0;">
                                        ${material.items.map(item => `
                                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.5rem 0; border-bottom: 1px solid #f7fafc;">
                                                <span style="font-size: 0.9rem;">${item.name}</span>
                                                <button class="card-btn btn-secondary" style="font-size: 0.8rem;"
                                                        onclick="window.open('${this.getBasePath()}/${sequence}/${item.path}', '_blank')">
                                                    📄 Download
                                                </button>
                                            </div>
                                        `).join('')}
                                    </div>
                                ` : ''}
                                
                                <div class="card-actions">
                                    ${material.path ? `
                                        <button class="card-btn btn-primary"
                                                onclick="window.open('${material.path.startsWith('/') ? material.path : this.getBasePath() + '/' + sequence + '/' + material.path}', '_blank')">
                                            📖 Öffnen
                                        </button>
                                    ` : ''}
                                    <button class="card-btn btn-secondary" onclick="nav.toggleFavorite('${key}')">
                                        ${this.favorites.includes(key) ? '⭐' : '☆'} Favorit
                                    </button>
                                </div>
                            </div>
                        `;
                    }
                }).join('')}
            </div>
        `;
    }

    // Breadcrumb Management
    updateBreadcrumb() {
        const breadcrumb = document.querySelector('.breadcrumb');
        if (!breadcrumb) return;

        const items = [];
        
        // Always start with Dashboard
        items.push(`<a href="#" class="breadcrumb-item ${this.currentLevel === 1 ? 'active' : ''}" onclick="nav.navigateTo(1)">📚 Dashboard</a>`);
        
        if (this.currentLevel >= 2 && this.currentData.subject) {
            items.push(`<span class="breadcrumb-separator">→</span>`);
            items.push(`<a href="#" class="breadcrumb-item ${this.currentLevel === 2 ? 'active' : ''}" onclick="nav.navigateTo(2, {subject: '${this.currentData.subject}'})">${this.getSubjectTitle(this.currentData.subject)}</a>`);
        }
        
        if (this.currentLevel >= 3 && this.currentData.sequence) {
            items.push(`<span class="breadcrumb-separator">→</span>`);
            items.push(`<a href="#" class="breadcrumb-item ${this.currentLevel === 3 ? 'active' : ''}" onclick="nav.navigateTo(3, {subject: '${this.currentData.subject}', sequence: '${this.currentData.sequence}'})">${this.getSequenceTitle(this.currentData.subject, this.currentData.sequence)}</a>`);
        }
        
        if (this.currentLevel >= 4 && this.currentData.ue) {
            items.push(`<span class="breadcrumb-separator">→</span>`);
            items.push(`<span class="breadcrumb-item active">Materialien</span>`);
        }

        breadcrumb.innerHTML = items.join(' ');
    }

    // Sidebar Management
    updateSidebar() {
        const sidebar = document.querySelector('.sidebar-nav');
        if (!sidebar) return;

        let sidebarContent = '';

        // Quick Access Section
        sidebarContent += `
            <div class="nav-section">
                <div class="nav-section-title">Quick Access</div>
                <ul class="nav-items">
                    <li class="nav-item">
                        <a href="#" class="nav-link ${this.currentLevel === 1 ? 'active' : ''}" onclick="nav.navigateTo(1)">
                            📚 Dashboard <span class="nav-badge">Home</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#" class="nav-link" onclick="nav.navigateTo(4, {subject: 'sport', sequence: 'volleyball', ue: 'ue3'})">
                            🏐 Volleyball BUV <span class="nav-badge">Featured</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="/qr-generator.html" class="nav-link" target="_blank">
                            📱 QR-Generator <span class="nav-badge">Tool</span>
                        </a>
                    </li>
                </ul>
            </div>
        `;

        // Favorites Section
        if (this.favorites.length > 0) {
            sidebarContent += `
                <div class="nav-section">
                    <div class="nav-section-title">Favoriten</div>
                    <ul class="nav-items">
                        ${this.favorites.map(fav => `
                            <li class="nav-item">
                                <a href="#" class="nav-link" onclick="nav.navigateToFavorite('${fav}')">
                                    ⭐ ${fav} <button onclick="event.stopPropagation(); nav.toggleFavorite('${fav}')" style="background: none; border: none; color: #a0aec0; cursor: pointer;">✕</button>
                                </a>
                            </li>
                        `).join('')}
                    </ul>
                </div>
            `;
        }

        // Current Context Section
        if (this.currentLevel > 1) {
            sidebarContent += `
                <div class="nav-section">
                    <div class="nav-section-title">Aktueller Kontext</div>
                    <ul class="nav-items">
                        ${this.currentData.subject ? `
                            <li class="nav-item">
                                <a href="#" class="nav-link" onclick="nav.navigateTo(2, {subject: '${this.currentData.subject}'})">
                                    🎯 ${this.getSubjectTitle(this.currentData.subject)}
                                </a>
                            </li>
                        ` : ''}
                        ${this.currentData.sequence ? `
                            <li class="nav-item">
                                <a href="#" class="nav-link" onclick="nav.navigateTo(3, {subject: '${this.currentData.subject}', sequence: '${this.currentData.sequence}'})">
                                    📋 ${this.getSequenceTitle(this.currentData.subject, this.currentData.sequence)}
                                </a>
                            </li>
                        ` : ''}
                    </ul>
                </div>
            `;
        }

        sidebar.innerHTML = sidebarContent;
    }

    // Utility Functions
    getStatusText(status) {
        const statusMap = {
            'completed': 'Abgeschlossen',
            'active': 'Aktiv',
            'planned': 'Geplant'
        };
        return statusMap[status] || status;
    }

    getSubjectTitle(subject) {
        const titles = {
            'sport': '🏃‍♂️ Sport',
            'gpg': '🏛️ GPG',
            'tools': '🛠️ Tools'
        };
        return titles[subject] || subject;
    }

    getSequenceTitle(subject, sequence) {
        if (subject === 'sport' && sequence === 'volleyball') return '🏐 Volleyball';
        if (subject === 'sport' && sequence === 'basketball') return '🏀 Basketball';
        if (subject === 'sport' && sequence === 'fussball') return '⚽ Fußball';
        return sequence;
    }

    getUETitle(subject, sequence, ue) {
        if (ue === 'ue3') return 'UE 3: Unteres Zuspiel (BUV)';
        return ue;
    }

    getBasePath() {
        return 'unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball';
    }

    getFullURL() {
        return window.location.origin + window.location.pathname.replace(/\/[^\/]*$/, '') + '/' + this.getBasePath();
    }

    // QR Code Generation
    generateQR(url, title) {
        // Open QR generator with pre-filled URL
        window.open(`/qr-generator.html?url=${encodeURIComponent(url)}&title=${encodeURIComponent(title)}`, '_blank');
    }

    // Favorites Management
    toggleFavorite(item) {
        const index = this.favorites.indexOf(item);
        if (index > -1) {
            this.favorites.splice(index, 1);
        } else {
            this.favorites.push(item);
        }
        this.saveFavorites();
        this.updateSidebar();
    }

    loadFavorites() {
        try {
            return JSON.parse(localStorage.getItem('laa-favorites') || '[]');
        } catch {
            return [];
        }
    }

    saveFavorites() {
        try {
            localStorage.setItem('laa-favorites', JSON.stringify(this.favorites));
        } catch {
            console.warn('Could not save favorites to localStorage');
        }
    }

    // Navigation State Persistence
    saveNavigationState() {
        try {
            localStorage.setItem('laa-nav-state', JSON.stringify({
                level: this.currentLevel,
                data: this.currentData,
                stack: this.navigationStack
            }));
        } catch {
            console.warn('Could not save navigation state');
        }
    }

    loadNavigationState() {
        try {
            const state = JSON.parse(localStorage.getItem('laa-nav-state') || '{}');
            if (state.level) {
                this.currentLevel = state.level;
                this.currentData = state.data || {};
                this.navigationStack = state.stack || [];
            }
        } catch {
            console.warn('Could not load navigation state');
        }
    }

    // Event Listeners
    setupEventListeners() {
        // Global search
        document.addEventListener('input', (e) => {
            if (e.target.id === 'globalSearch') {
                this.handleSearch(e.target.value);
            }
        });

        // Filter tabs
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('filter-tab')) {
                document.querySelectorAll('.filter-tab').forEach(tab => tab.classList.remove('active'));
                e.target.classList.add('active');
                this.handleFilter(e.target.dataset.filter);
            }
        });

        // Mobile menu toggle
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('mobile-menu-toggle')) {
                document.querySelector('.sidebar-nav').classList.toggle('open');
            }
        });

        // Back button
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('back-button')) {
                this.goBack();
            }
        });
    }

    setupDashboardListeners() {
        // Setup any additional dashboard-specific listeners
    }

    handleSearch(query) {
        // Implement global search functionality
        console.log('Searching for:', query);
    }

    handleFilter(filter) {
        // Implement filtering functionality
        console.log('Filtering by:', filter);
    }
}

// Initialize navigation when DOM is loaded
let nav;
document.addEventListener('DOMContentLoaded', () => {
    nav = new HierarchicalNavigation();
});

// Export for global access
window.nav = nav;
