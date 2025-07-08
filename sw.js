// Service Worker für LAA Unterrichtsmaterialien
// Offline-Funktionalität für iPad-Classroom Integration

const CACHE_NAME = 'laa-materials-v2.0';
const STATIC_CACHE = 'laa-static-v2.0';
const DYNAMIC_CACHE = 'laa-dynamic-v2.0';

// Static files to cache immediately
const STATIC_FILES = [
    '/',
    '/index.html',
    '/css/style.css',
    '/css/hierarchy.css',
    '/js/navigation.js',
    '/qr-generator.html',
    '/manifest.json',
    '/favicon.ico'
];

// Volleyball BUV critical files
const VOLLEYBALL_FILES = [
    '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/volleyball-ue3-buv.html',
    '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-01-ring-drill.html',
    '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-02-hand-eye.html',
    '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-03-positioning.html',
    '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-04-legs-catching.html',
    '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-05-wall-bagging.html',
    '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-06-wall-bagging-alt.html'
];

// Install Event - Cache static files
self.addEventListener('install', event => {
    console.log('Service Worker: Installing...');
    
    event.waitUntil(
        Promise.all([
            // Cache static files
            caches.open(STATIC_CACHE).then(cache => {
                console.log('Service Worker: Caching static files');
                return cache.addAll(STATIC_FILES);
            }),
            // Cache volleyball files for offline classroom use
            caches.open(VOLLEYBALL_CACHE).then(cache => {
                console.log('Service Worker: Caching Volleyball BUV files');
                return cache.addAll(VOLLEYBALL_FILES);
            })
        ]).then(() => {
            console.log('Service Worker: Installation complete');
            return self.skipWaiting();
        })
    );
});

// Activate Event - Clean up old caches
self.addEventListener('activate', event => {
    console.log('Service Worker: Activating...');
    
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (cacheName !== STATIC_CACHE && 
                        cacheName !== DYNAMIC_CACHE && 
                        cacheName !== VOLLEYBALL_CACHE) {
                        console.log('Service Worker: Deleting old cache:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        }).then(() => {
            console.log('Service Worker: Activation complete');
            return self.clients.claim();
        })
    );
});

// Fetch Event - Serve cached content when offline
self.addEventListener('fetch', event => {
    const { request } = event;
    const url = new URL(request.url);

    // Skip non-GET requests
    if (request.method !== 'GET') {
        return;
    }

    // Skip external requests
    if (url.origin !== location.origin) {
        return;
    }

    event.respondWith(
        cacheFirst(request)
            .catch(() => networkFirst(request))
            .catch(() => offlineFallback(request))
    );
});

// Cache First Strategy (for static files)
async function cacheFirst(request) {
    const cachedResponse = await caches.match(request);
    
    if (cachedResponse) {
        // Update cache in background for next time
        updateCache(request);
        return cachedResponse;
    }
    
    throw new Error('Not in cache');
}

// Network First Strategy (for dynamic content)
async function networkFirst(request) {
    try {
        const networkResponse = await fetch(request);
        
        if (networkResponse.ok) {
            // Cache successful responses
            const cache = await caches.open(DYNAMIC_CACHE);
            cache.put(request, networkResponse.clone());
        }
        
        return networkResponse;
    } catch (error) {
        // Network failed, try cache
        const cachedResponse = await caches.match(request);
        if (cachedResponse) {
            return cachedResponse;
        }
        throw error;
    }
}

// Update cache in background
async function updateCache(request) {
    try {
        const networkResponse = await fetch(request);
        if (networkResponse.ok) {
            const cache = await caches.open(STATIC_CACHE);
            cache.put(request, networkResponse);
        }
    } catch (error) {
        console.log('Background cache update failed:', error);
    }
}

// Offline Fallback
async function offlineFallback(request) {
    const url = new URL(request.url);
    
    // For HTML requests, serve offline page
    if (request.headers.get('accept').includes('text/html')) {
        return new Response(`
            <!DOCTYPE html>
            <html lang="de">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Offline - LAA Unterrichtsmaterialien</title>
                <style>
                    body { 
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
                        background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);
                        margin: 0; 
                        padding: 2rem; 
                        text-align: center; 
                        min-height: 100vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }
                    .offline-container {
                        background: white;
                        padding: 3rem;
                        border-radius: 12px;
                        box-shadow: 0 8px 25px rgba(0,0,0,0.1);
                        max-width: 500px;
                    }
                    .icon { font-size: 4rem; margin-bottom: 1rem; }
                    .title { color: #2d3748; font-size: 1.8rem; font-weight: 600; margin-bottom: 1rem; }
                    .description { color: #718096; line-height: 1.6; margin-bottom: 2rem; }
                    .cached-links { 
                        display: flex; 
                        flex-direction: column; 
                        gap: 1rem; 
                        margin-top: 2rem; 
                    }
                    .btn {
                        padding: 0.75rem 1.5rem;
                        border: none;
                        border-radius: 8px;
                        background: #3182ce;
                        color: white;
                        text-decoration: none;
                        font-weight: 500;
                        transition: background 0.2s;
                    }
                    .btn:hover { background: #2c5282; }
                    .btn-secondary {
                        background: #f7fafc;
                        color: #4a5568;
                        border: 1px solid #e2e8f0;
                    }
                </style>
            </head>
            <body>
                <div class="offline-container">
                    <div class="icon">📱</div>
                    <h1 class="title">Offline-Modus</h1>
                    <p class="description">
                        Sie sind aktuell offline. Die wichtigsten Volleyball-Materialien sind jedoch 
                        im Cache verfügbar und können weiterhin genutzt werden.
                    </p>
                    
                    <div class="cached-links">
                        <a href="/" class="btn">🏠 Dashboard</a>
                        <a href="/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-01-ring-drill.html" class="btn">🎯 Station 1: Ring-Drill</a>
                        <a href="/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/volleyball-ue3-buv.html" class="btn">📋 Volleyball BUV</a>
                        <button onclick="window.location.reload()" class="btn btn-secondary">🔄 Erneut versuchen</button>
                    </div>
                    
                    <p style="font-size: 0.9rem; color: #a0aec0; margin-top: 2rem;">
                        💡 Tipp: Im iPad-Classroom funktionieren alle gecachten Stationskarten auch offline.
                    </p>
                </div>
            </body>
            </html>
        `, {
            headers: {
                'Content-Type': 'text/html',
                'Cache-Control': 'no-cache'
            }
        });
    }
    
    // For other requests, return a generic offline response
    return new Response('Offline - Content not available', {
        status: 503,
        statusText: 'Service Unavailable',
        headers: { 'Content-Type': 'text/plain' }
    });
}

// Background Sync for offline actions
self.addEventListener('sync', event => {
    if (event.tag === 'background-sync') {
        event.waitUntil(doBackgroundSync());
    }
});

async function doBackgroundSync() {
    console.log('Service Worker: Background sync triggered');
    // Implement background synchronization logic here
}

// Push notifications (for future feature)
self.addEventListener('push', event => {
    if (event.data) {
        const options = {
            body: event.data.text(),
            icon: '/favicon.ico',
            badge: '/favicon.ico',
            actions: [
                { action: 'open', title: 'Öffnen' },
                { action: 'dismiss', title: 'Verwerfen' }
            ]
        };
        
        event.waitUntil(
            self.registration.showNotification('LAA Unterrichtsmaterialien', options)
        );
    }
});

// Notification click handler
self.addEventListener('notificationclick', event => {
    event.notification.close();
    
    if (event.action === 'open' || !event.action) {
        event.waitUntil(
            clients.openWindow('/')
        );
    }
});

// Message handler for cache updates
self.addEventListener('message', event => {
    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }
    
    if (event.data && event.data.type === 'CACHE_URL') {
        event.waitUntil(
            caches.open(DYNAMIC_CACHE).then(cache => {
                return cache.add(event.data.url);
            })
        );
    }
});

console.log('Service Worker: Script loaded');
