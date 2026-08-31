# Speak First

Corso di inglese parlato e scritto da zero, per italiani. App web installabile
(PWA), un solo file, nessuna dipendenza esterna, funziona offline.

- 36 lezioni in 3 fasi: sopravvivenza → conversazione → inglese al lavoro (IT)
- 288 parole, 216 frasi, ripetizione dilazionata a 7 livelli
- Esercizi: scelta, ascolto, ricostruzione della frase, scrittura, pronuncia col microfono
- Schede: pronuncia per italiani, falsi amici, 30 verbi irregolari

## Pubblicare su GitHub Pages

1. Crea un repository (pubblico) e carica tutti i file di questa cartella nella radice.
2. Settings → Pages → Source: **Deploy from a branch** → Branch: `main`, cartella `/ (root)` → Save.
3. Dopo un minuto l'app è su `https://<utente>.github.io/<repo>/`.
4. Apri quell'indirizzo in Chrome → menù ⋮ → **Installa app**.

Tutti i percorsi sono relativi, quindi funziona sia in un repo di progetto
(`/<repo>/`) sia in un dominio dedicato.

## Aggiornare l'app

Dopo aver modificato `index.html`, incrementa `VERSION` in `sw.js`
(`"v1"` → `"v2"`). Senza questo passaggio i dispositivi già installati
continuano a usare la copia in cache.

## File

| file | ruolo |
|---|---|
| `index.html` | l'app intera: contenuti, motore, interfaccia |
| `manifest.json` | nome, icone, avvio a schermo intero |
| `sw.js` | cache offline |
| `icon-192.png`, `icon-512.png` | icone di installazione |

## Dati e privacy

Progressi, impostazioni e stato dei ripassi restano nel `localStorage` del
browser. Nessun dato lascia il dispositivo, nessuna chiamata di rete.
Per azzerare tutto: **Io → Azzera i progressi**.

## Requisiti

Serve un contesto sicuro (HTTPS o `localhost`) per service worker e microfono.
Il riconoscimento vocale funziona su Chrome Android; su iOS Safari resta
la sola voce in uscita e l'esercizio di pronuncia si può saltare.
