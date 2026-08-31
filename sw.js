/* Speak First — service worker
   Alza VERSION a ogni aggiornamento dell'app: forza il rinnovo della cache. */
const VERSION = "v6";
const CACHE = "speak-first-" + VERSION;
const ASSETS = ["./", "./index.html", "./manifest.json", "./icon-192.png", "./icon-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => Promise.all(ASSETS.map(u => c.add(u).catch(() => {}))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

/* Una risposta va accettata solo se è davvero valida.
   Un 404 o un redirect di un proxy NON deve mai sovrascrivere la copia buona:
   è così che una rete che blocca github.io cancellerebbe l'app dal telefono. */
const usable = r => r && r.ok && r.status === 200 && r.type !== "opaque";

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;

  const fallback = () =>
    caches.match("./index.html").then(r => r || caches.match("./"));

  /* pagina: prima la rete, ma solo se risponde bene */
  if (req.mode === "navigate") {
    e.respondWith(
      fetch(req).then(res => {
        if (!usable(res)) return fallback().then(c => c || res);
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put("./index.html", copy)).catch(() => {});
        return res;
      }).catch(fallback)
    );
    return;
  }

  /* risorse: prima la cache, rinnovata in sottofondo */
  e.respondWith(
    caches.match(req).then(hit => {
      const net = fetch(req).then(res => {
        if (!usable(res)) return hit || res;
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put(req, copy)).catch(() => {});
        return res;
      }).catch(() => hit);
      return hit || net;
    })
  );
});
