<div align="center">
  <img src="./asset/icon.png" alt="Logo" width="150" height="150">
  <h3 align="center">Crunchy</h3>
</div>

<!-- RIGUARDO AL PROGETTO -->

## Riguardo al progetto

App dimostrativa per un ristorante.  
Menù con immagini, ricerca del locale più vicino, sezione notizie e recensioni con foto.

<!-- API E SENSORI -->

## API & Sensori

Nell'app **Crunchy** utilizziamo: **2 API** e **2 sensori**.

**Sensori**
1. _Geolocalizzazione (GPS)_: ottiene la posizione dell'utente per centrare la mappa e trovare il locale più vicino.
2. _Fotocamera_: scatta/allega foto nelle recensioni.

**API**
1. _Google Places / Maps API_: ricerca e visualizzazione del ristorante su Google Maps.
2. _News API_: recupera notizie/aggiornamenti su cibo e ristorazione attraverso feed pubblici (RSS/Atom o JSON).

<!-- REQUISITI -->

## Requisiti

- **Flutter** 3.22+ (Dart ≥ 3.5)  
- **Android Studio** (per emulatori Android), consigliato **Medium Phone — API 35**  
- Plugin **Flutter/Dart** per l’IDE (consigliato)

**Verifica dell'ambiente**:
```bash
flutter doctor
```

<!-- CONFIGURAZIONE -->

## Configurazione

1. Crea `secrets.json` nella root del progetto sulla base del file `secrets.example.json`.

2. Per lanciare l'app esegui:
```bash
flutter clean
flutter pub get
flutter run --dart-define-from-file=secrets.json
```

3. Per la build esegui:
```bash
flutter build apk --dart-define-from-file=secrets.json
```

### Opzionale

**VS Code**  
_È già configurato: il repo include `.vscode/settings.json` con_  
`"dart.flutterAdditionalArgs": ["--dart-define-from-file=secrets.json"]`.  
_Quindi se usi Run/Debug da VS Code, l’argomento viene passato in automatico._

**Android Studio / IntelliJ**  
_Vai su **Run → Edit Configurations…** → (seleziona la tua configurazione Flutter) e inserisci in **Additional run args** (o **Program arguments**):_
```bash
--dart-define-from-file=secrets.json
```

> **Nota**: se lanci dai tool dell’IDE **senza** quell’argomento, l’app non vedrà le chiavi (risulteranno “assenti”).

## Preparazione emulatore Android

1. Apri **Android Studio** → **More Actions** → **Virtual Device Manager**.
2. Crea un nuovo dispositivo selezionando **Medium Phone**.
3. Scegli l’immagine di sistema **API 35 (Android 15)** o compatibile e completa la creazione.
4. Avvia l’emulatore dall’**AVD Manager**.

> In alternativa, collega un dispositivo **Android** fisico via USB con **Debug USB** attivo."