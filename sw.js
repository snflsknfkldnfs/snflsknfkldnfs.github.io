// Service Worker für LAA Unterrichtsmaterialien
// Optimiert für iPad-Classroom und Offline-Nutzung

const CACHE_NAME = 'laa-materials-v2.0.0';
const OFFLINE_URL = '/404.html';

// Kritische Ressourcen für Offline-Verfügbarkeit
const CRITICAL_RESOURCES = [
  '/',
  '/css/style.css',
  '/404.html',
  '/manifest.json',
  
  // Sport-Bereich (Featured Content)
  '/unterricht/Sport/',
  '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/volleyball-ue3-buv.html',
  
  // Alle 6 Stationskarten (Priorität für iPad-Nutzung)
  '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-01-ring-drill.html',
  '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-02-hand-eye.html',
  '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-03-positioning.html',
  '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-04-legs-catching.html',
  '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-05-wall-bagging.html',
  '/unterricht/Sport/Sm8ab/Sm8ab_LB4_4_Volleyball/artifacts/stations/station-06-wall-bagging-alt.html',
  
  // GPG-Materialien
  '/unterricht/GPG_Arbeitsweisen_LAA_Training/',
  '/unterricht/GPG_Arbeitsweisen_LAA_Training/fallanalyse-schweinfurt.html'
];

// Ressourcen die beim ersten Besuch gecacht werden sollen
const PRECACHE_RESOURCES = [
  // Fonts und kritische Assets
  '/assets/fonts/inter-var.woff2',
  '/assets/icons/icon-192x192.png',
  '/assets/icons/icon-512x512.png',
  
  // Tools
  '/generator.html',
  '/reflexion.html'
];

// Installation: Cache kritische Ressourcen
self.addEventListener('install', (event) => {
  console.log('🚀 Service Worker: Installing...');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('📦 Service Worker: Caching critical resources');
        return cache.addAll(CRITICAL_RESOURCES);
      })
      .then(() => {
        console.log('✅ Service Worker: Installation complete');
        return self.skipWaiting(); // Aktiviere sofort
      })
      .catch((error) => {
        console.error('❌ Service Worker: Installation failed', error);
      })
  );
});

// Aktivierung: Lösche alte Caches
self.addEventListener('activate', (event) => {
  console.log('🔄 Service Worker: Activating...');
  
  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== CACHE_NAME) {
              console.log('🗑️ Service Worker: Deleting old cache', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        console.log('✅ Service Worker: Activation complete');
        return self.clients.claim(); // Übernehme Kontrolle über alle Clients
      })
  );
});

// Fetch: Intelligente Caching-Strategie
self.addEventListener('fetch', (event) => {
  // Nur GET-Requests verarbeiten
  if (event.request.method !== 'GET') return;
  
  // Ignore Chrome extension and other non-HTTP requests
  if (!event.request.url.startsWith('http')) return;
  
  event.respondWith(
    caches.match(event.request)
      .then((cachedResponse) => {
        // Cache-Hit: Serviere aus Cache
        if (cachedResponse) {
          console.log('📦 Cache hit:', event.request.url);
          
          // Für kritische Stationskarten: Cache first, dann Background-Update
          if (isStationskarte(event.request.url)) {
            // Background-Update für Stationskarten
            fetch(event.request)
              .then((response) => {
                if (response && response.status === 200) {
                  const responseClone = response.clone();
                  caches.open(CACHE_NAME)
                    .then((cache) => cache.put(event.request, responseClone));
                }
              })
              .catch(() => {}); // Ignore background errors
            
            return cachedResponse;
          }
          
          return cachedResponse;
        }
        
        // Cache-Miss: Hole aus Netzwerk
        return fetch(event.request)
          .then((response) => {
            // Nur erfolgreiche Responses cachen
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            
            // Clone für Cache
            const responseToCache = response.clone();
            
            caches.open(CACHE_NAME)
              .then((cache) => {
                // Intelligentes Caching basierend auf URL
                if (shouldCache(event.request.url)) {
                  console.log('💾 Caching:', event.request.url);
                  cache.put(event.request, responseToCache);
                }
              });
            
            return response;
          })
          .catch(() => {
            // Netzwerk-Fehler: Offline-Fallback
            console.log('🔌 Offline - serving fallback for:', event.request.url);
            
            // Für HTML-Seiten: 404-Seite
            if (event.request.destination === 'document') {
              return caches.match(OFFLINE_URL);
            }
            
            // Für Bilder: Placeholder-Icon
            if (event.request.destination === 'image') {
              return caches.match('/assets/icons/icon-192x192.png');
            }
            
            // Für andere Ressourcen: Service nicht verfügbar
            return new Response('Service temporarily unavailable', {
              status: 503,
              statusText: 'Service Unavailable',
              headers: new Headers({
                'Content-Type': 'text/plain',
              }),
            });
          });
      })
  );
});

// Background Sync für zukünftige Features
self.addEventListener('sync', (event) => {
  if (event.tag === 'background-sync') {
    console.log('🔄 Background sync triggered');
    event.waitUntil(doBackgroundSync());
  }
});

// Push Notifications für Updates (zukünftige Implementierung)
self.addEventListener('push', (event) => {
  if (event.data) {
    const data = event.data.json();
    console.log('📬 Push notification received:', data);
    
    const options = {
      body: data.body || 'Neue Unterrichtsmaterialien verfügbar!',
      icon: '/assets/icons/icon-192x192.png',
      badge: '/assets/icons/badge-72x72.png',
      vibrate: [100, 50, 100],
      data: {
        dateOfArrival: Date.now(),
        primaryKey: data.primaryKey || 'default'
      },
      actions: [
        {
          action: 'explore',
          title: 'Materialien ansehen',
          icon: '/assets/icons/action-explore.png'
        },
        {
          action: 'close',
          title: 'Schließen',
          icon: '/assets/icons/action-close.png'
        }
      ]
    };
    
    event.waitUntil(
      self.registration.showNotification(data.title || 'LAA Materialien', options)
    );
  }
});

// Notification Click Handler
self.addEventListener('notificationclick', (event) => {
  console.log('🔔 Notification clicked:', event.action);
  
  event.notification.close();
  
  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/unterricht/Sport/')
    );
  }
});

// Helper Functions
function isStationskarte(url) {
  return url.includes('/artifacts/stations/') && url.endsWith('.html');
}

function isBUV(url) {
  return url.includes('volleyball-ue3-buv.html');
}

function shouldCache(url) {
  // Cache alle LAA-Materialien
  if (url.includes('/unterricht/')) return true;
  
  // Cache CSS und wichtige Assets
  if (url.includes('/css/') || url.includes('/assets/')) return true;
  
  // Cache Tools
  if (url.includes('/generator.html') || url.includes('/reflexion.html')) return true;
  
  // Cache Hauptseiten
  if (url.endsWith('/') || url.includes('index.html')) return true;
  
  // Nicht cachen: Externe Ressourcen, Analytics, etc.
  return false;
}

async function doBackgroundSync() {
  try {
    // Prüfe auf Updates zu kritischen Ressourcen
    const cache = await caches.open(CACHE_NAME);
    
    for (const resource of CRITICAL_RESOURCES) {
      try {
        const response = await fetch(resource);
        if (response && response.status === 200) {
          await cache.put(resource, response);
          console.log('🔄 Background sync updated:', resource);
        }
      } catch (error) {
        console.log('⚠️ Background sync failed for:', resource);
      }
    }
  } catch (error) {
    console.error('❌ Background sync error:', error);
  }
}

// Cleanup: Entferne alte oder große Cache-Einträge
async function cleanupCache() {
  const cache = await caches.open(CACHE_NAME);
  const requests = await cache.keys();
  
  // Lösche Einträge älter als 7 Tage
  const oneWeekAgo = Date.now() - (7 * 24 * 60 * 60 * 1000);
  
  for (const request of requests) {
    const response = await cache.match(request);
    if (response) {
      const dateHeader = response.headers.get('date');
      if (dateHeader) {
        const responseDate = new Date(dateHeader).getTime();
        if (responseDate < oneWeekAgo) {
          await cache.delete(request);
          console.log('🗑️ Cleaned up old cache entry:', request.url);
        }
      }
    }
  }
}

// Führe Cleanup alle 24 Stunden durch
setInterval(cleanupCache, 24 * 60 * 60 * 1000);

// Debugging: Service Worker Status
console.log('🎯 LAA Materials Service Worker loaded');
console.log('📦 Cache name:', CACHE_NAME);
console.log('🎮 Critical resources:', CRITICAL_RESOURCES.length);
console.log('📱 Optimized for iPad-Classroom usage');