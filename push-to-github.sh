#!/data/data/com.termux/files/usr/bin/bash
# =====================================================================
#  Speak First → GitHub Pages, direttamente da Termux.
#  Uso:  bash push-to-github.sh <utente-github> <nome-repo>
#  Il repo va creato prima su github.com (pubblico, vuoto).
# =====================================================================
set -e
USER="${1:?Uso: bash push-to-github.sh <utente-github> <nome-repo>}"
REPO="${2:?Uso: bash push-to-github.sh <utente-github> <nome-repo>}"
DIR="$HOME/$REPO"
SRC="$HOME/speakfirst/index.html"

command -v git >/dev/null || { echo "Installo git…"; pkg install -y git; }
[ -f "$SRC" ] || { echo "!! Non trovo $SRC"; exit 1; }

mkdir -p "$DIR" && cd "$DIR"
cp "$SRC" index.html

# --- icone + manifest ---------------------------------------------------
python - <<'PY'
import zlib,struct,json,os
BG=(0x13,0x1B,0x33); FG=(0xFF,0xB1,0x3C); H=[.28,.52,.78,1,.66,.4,.86,.55,.3]
def png(p,size):
    n=len(H); gap=size*.088; w=size*.052; x0=(size-(n*gap-(gap-w)))/2; span=[None]*size
    for i,h in enumerate(H):
        bh=size*.40*h; a=x0+i*gap
        for x in range(int(a),min(size,int(a+w))): span[x]=(size/2-bh/2,size/2+bh/2)
    bg=bytes(BG); fg=bytes(FG); raw=bytearray()
    for y in range(size):
        raw.append(0)
        for x in range(size):
            s=span[x]; raw+= fg if (s and s[0]<=y<s[1]) else bg
    def ch(t,d): return struct.pack(">I",len(d))+t+d+struct.pack(">I",zlib.crc32(t+d)&0xffffffff)
    open(p,"wb").write(b"\x89PNG\r\n\x1a\n"+ch(b"IHDR",struct.pack(">IIBBBBB",size,size,8,2,0,0,0))+ch(b"IDAT",zlib.compress(bytes(raw),9))+ch(b"IEND",b""))
png("icon-192.png",192); png("icon-512.png",512)
m={"name":"Speak First \u2014 inglese da zero","short_name":"Speak First",
 "description":"Corso di inglese parlato e scritto da zero, per italiani.",
 "start_url":"./index.html","scope":"./","display":"standalone","orientation":"portrait",
 "background_color":"#131B33","theme_color":"#131B33","lang":"it","dir":"ltr",
 "icons":[{"src":"icon-192.png","sizes":"192x192","type":"image/png","purpose":"any"},
          {"src":"icon-512.png","sizes":"512x512","type":"image/png","purpose":"any"},
          {"src":"icon-512.png","sizes":"512x512","type":"image/png","purpose":"maskable"}]}
open("manifest.json","w",encoding="utf-8").write(json.dumps(m,ensure_ascii=False,indent=2))
h=open("index.html",encoding="utf-8").read()
for a,b in [('<link id="manifest" rel="manifest">','<link id="manifest" rel="manifest" href="manifest.json">'),
            ('<link id="appleicon" rel="apple-touch-icon">','<link id="appleicon" rel="apple-touch-icon" href="icon-192.png">'),
            ('    $("#appleicon").href=i192;\n',''),
            ('    $("#manifest").href=URL.createObjectURL(new Blob([JSON.stringify(mf)],{type:"application/manifest+json"}));\n','')]:
    h=h.replace(a,b)
open("index.html","w",encoding="utf-8").write(h)
print("icone, manifest e index.html pronti")
PY

# --- service worker ------------------------------------------------------
cat > sw.js <<'SWEOF'
const VERSION = "v1";
const CACHE = "speak-first-" + VERSION;
const ASSETS = ["./", "./index.html", "./manifest.json", "./icon-192.png", "./icon-512.png"];
self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => Promise.all(ASSETS.map(u => c.add(u).catch(() => {})))).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  if (req.mode === "navigate") {
    e.respondWith(fetch(req).then(res => {
      const copy = res.clone();
      caches.open(CACHE).then(c => c.put("./index.html", copy)).catch(() => {});
      return res;
    }).catch(() => caches.match("./index.html").then(r => r || caches.match("./"))));
    return;
  }
  e.respondWith(caches.match(req).then(hit => {
    const net = fetch(req).then(res => {
      const copy = res.clone();
      caches.open(CACHE).then(c => c.put(req, copy)).catch(() => {});
      return res;
    }).catch(() => hit);
    return hit || net;
  }));
});
SWEOF

printf '# Speak First\n\nCorso di inglese da zero per italiani. PWA installabile, funziona offline.\nPubblicata con GitHub Pages.\n\nDopo ogni modifica a index.html, incrementa VERSION in sw.js.\n' > README.md

# --- git ------------------------------------------------------------------
git init -q -b main 2>/dev/null || git init -q
git add -A
git -c user.email="speakfirst@local" -c user.name="$USER" commit -qm "Speak First — PWA" || echo "(niente da committare)"
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$USER/$REPO.git"

echo
echo "──────────────────────────────────────────────"
echo " Cartella pronta: $DIR"
ls -l
echo
echo " Ora esegui:"
echo "   cd $DIR && git push -u origin main"
echo
echo " Utente: $USER"
echo " Password: il TOKEN GitHub (Settings → Developer settings →"
echo "           Personal access tokens → Fine-grained → Contents: Read+Write)"
echo
echo " Poi su github.com: Settings → Pages → Deploy from a branch"
echo "   Branch: main   Cartella: / (root)   → Save"
echo
echo " L'app sarà su:"
echo "   https://$USER.github.io/$REPO/"
echo "──────────────────────────────────────────────"
