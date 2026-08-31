# Speak First

Corso di inglese parlato e scritto da zero, per italiani. App web installabile
(PWA), un solo file, nessuna dipendenza esterna, funziona offline.

- 48 lezioni in 4 fasi: sopravvivenza → conversazione → inglese al lavoro (IT) → sfumature
- 384 parole, 288 frasi, ripetizione dilazionata a 7 livelli
- Esercizi: scelta, ascolto, dettato, ricostruzione della frase, scrittura, pronuncia col microfono
- Dialoghi a bivi: chiamata del cliente, standup, colloquio, riunione, small talk
- Sfida lampo: 60 secondi a cronometro, per allenare la velocità di richiamo
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

## Blocco con codice

All'avvio l'app chiede un codice numerico. Quello predefinito è `2026`.
Si cambia dall'app: **Io → Cambia codice**, e resta salvato su quel dispositivo.
Si può disattivare da **Io → Disattiva il blocco con codice**.

Non è una misura di sicurezza: il codice è verificato nel browser e questo
repository è pubblico. Serve a evitare che l'app venga aperta per caso da chi
ha in mano il telefono, niente di più. Nessun dato sensibile è coinvolto:
i progressi restano nel browser del dispositivo.

## Dati e privacy

Progressi, impostazioni e stato dei ripassi restano nel `localStorage` del
browser. Nessun dato lascia il dispositivo, nessuna chiamata di rete.
Per azzerare tutto: **Io → Azzera i progressi**.

## Requisiti

Serve un contesto sicuro (HTTPS o `localhost`) per service worker e microfono.
Il riconoscimento vocale funziona su Chrome Android; su iOS Safari resta
la sola voce in uscita e l'esercizio di pronuncia si può saltare.
