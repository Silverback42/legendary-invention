# Schlicht – Projekt-Implementierungsplan

## Context

Umfassender Implementierungsplan für Schlicht basierend auf PRD v2.0. Greenfield-Projekt – kein Code vorhanden. Der Plan ist so strukturiert, dass die erste Version nur manuelle Eingabe unterstützt (Einzeltransaktionen oder Monatssummen). Danach kommen schrittweise Features dazu. Jede Phase baut auf der vorherigen auf und ist eigenständig nutzbar.

## Betroffene Dateien

- `PRD-BudgetApp.md` – Anforderungsquelle
- `Marktanalyse.md` – Markt-Kontext
- Alle neuen Dateien werden im Flutter-Projekt erstellt

---

## Phase 0: Projekt-Setup & Architektur (Woche 1)

### Flutter-Projekt initialisieren
- [x] Flutter-Projekt erstellen (`flutter create --org com.schlichtapp schlicht`) – Projektstruktur manuell angelegt (Flutter CLI nicht verfügbar)
- [x] Minimale `pubspec.yaml` mit Kern-Dependencies (drift, fl_chart, riverpod, flutter_localizations)
- [x] Ordnerstruktur anlegen (lib/features/, lib/core/, lib/shared/)
- [x] .gitignore für Flutter einrichten
- [x] Linting-Regeln definieren (analysis_options.yaml)

### Architektur-Grundgerüst
- [x] State-Management-Ansatz festlegen und einrichten (Riverpod – flutter_riverpod + riverpod_annotation)
- [x] Feature-basierte Ordnerstruktur anlegen:
  ```
  lib/
    core/           # DB, Theme, Routing, i18n
    features/
      transactions/ # Eingabe + Liste
      dashboard/    # Hauptscreen
      budgets/      # Budget-Verwaltung
      categories/   # Kategorien
      settings/     # Einstellungen
    shared/         # Widgets, Utils, Extensions
  ```
- [x] Routing einrichten (go_router) – lib/core/routing/app_router.dart
- [x] Theme-System aufsetzen (Farben, Typografie, Spacing – ein Light-Theme) – lib/core/theme/app_theme.dart

### Datenbank-Grundlage
- [x] Drift-Setup (SQLite) mit erstem Schema:
  - Tabelle `categories` (id, name, icon, color, sort_order, is_default)
  - Tabelle `transactions` (id, amount, category_id, note, date, created_at)
  - Tabelle `budgets` (id, category_id, amount, month, year)
  - Tabelle `accounts` (id, name, type, is_default)
- [x] Drift-Codegenerierung konfigurieren (build_runner) – in pubspec.yaml unter dev_dependencies
- [x] Datenbank-Service/Repository-Pattern implementieren – lib/core/db/database.dart
- [x] Standard-Kategorien als Seed-Daten (8 Stück: Lebensmittel, Wohnen, Transport, Freizeit, Gesundheit, Shopping, Essen gehen, Sonstiges) – lib/core/db/seed_data.dart

### Lokalisierung
- [x] Flutter-i18n-Setup (flutter_localizations + intl)
- [x] Erste Strings auf Deutsch + Englisch (App-Name, Navigations-Labels, Kategorien) – lib/l10n/app_de.arb + app_en.arb

---

## Phase 1a: Kern-MVP -- Manuelle Eingabe (Woche 2-3)
> **Ziel: Eine nutzbare App, in der man Transaktionen erfassen und einsehen kann.**
> **Das ist die "erste Version" -- funktional, aber noch kein Design-Polishing.**

### Quick-Entry (R-001)
- [ ] Quick-Entry-Screen: Betrag-Eingabe mit Nummernpad
- [ ] Kategorie-Auswahl (max. 8 Icons als Grid)
- [ ] Optionales Notiz-Feld
- [ ] Datum-Auswahl (Standard: heute)
- [ ] Speichern-Button -- Transaktion in Drift-DB schreiben
- [ ] Eingabe in ≤ 3 Taps abschließbar
- [ ] Validierung: Betrag > 0, Kategorie ausgewählt

### Monatssummen-Eingabe (User-Wunsch)
- [ ] Alternativer Eingabe-Modus: Gesamtsumme pro Kategorie fuer einen Monat
- [ ] Screen: Kategorie-Liste mit Eingabefeld pro Kategorie
- [ ] Monat/Jahr-Auswahl
- [ ] Speichern erstellt eine Sammel-Transaktion pro Kategorie
- [ ] Umschaltbar zwischen Einzel- und Monatseingabe in Einstellungen

### Transaktions-Liste
- [ ] Listenansicht aller Transaktionen (gruppiert nach Tag)
- [ ] Anzeige: Betrag, Kategorie-Icon + Name, Notiz, Datum
- [ ] Swipe-to-Delete oder Long-Press-Menue
- [ ] Transaktion bearbeiten (Tap oeffnet Edit-Screen)
- [ ] Filtern nach Monat (Vor/Zurueck-Navigation)

### Einfaches Dashboard (Minimal-Version)
- [ ] Hauptscreen mit:
  - Aktueller Monat + verbleibendes Budget (wenn gesetzt)
  - Gesamtausgaben des Monats
  - Liste der letzten 5 Transaktionen
- [ ] Bottom-Navigation: Dashboard | Transaktionen | Eingabe (+) | Einstellungen
- [ ] FAB (Floating Action Button) fuer schnelle Eingabe

### Einstellungen (Basis)
- [ ] Waehrung waehlen (EUR Standard, CHF als Option)
- [ ] Sprache waehlen (DE/EN)
- [ ] Eingabe-Modus waehlen (Einzeltransaktion / Monatssummen)
- [ ] Daten loeschen (mit Bestaetigung)
- [ ] App-Version anzeigen

---

## Phase 1b: Visualisierung & Budgets (Woche 4-5)
> **Ziel: Der Nutzer sieht, wohin sein Geld fliesst, und kann Limits setzen.**

### Kategorie-Visualisierung (R-002)
- [ ] Donut-Chart auf dem Dashboard (fl_chart) -- Ausgaben nach Kategorie
- [ ] Farbcodierung pro Kategorie
- [ ] Tap auf Segment zeigt Kategorie-Detail (Drill-Down auf Einzelposten)
- [ ] Balkendiagramm als Alternative (umschaltbar)

### Monats-Budget pro Kategorie (R-003)
- [ ] Budget-Setup-Screen: Betrag pro Kategorie festlegen
- [ ] Fortschrittsbalken pro Kategorie auf Dashboard
- [ ] Farbwechsel bei 80 % (Orange) und 100 % (Rot, aber sanft)
- [ ] Verbleibendes Gesamtbudget prominent auf Dashboard
- [ ] Ermutigende Microcopy bei Budgetüberschreitung (R-014): "Fast geschafft!" statt "Budget überschritten!"

### Historien-Ansicht (R-009)
- [ ] Monatsweise Navigation (3 Monate zurueck fuer Free-Tier)
- [ ] Monat-zu-Monat-Vergleich: Balkendiagramm oder Zahl mit Trend-Pfeil
- [ ] Leerer Zustand huebsch gestalten ("Noch keine Daten fuer diesen Monat")

### Dashboard aufwerten
- [ ] Bento-Grid-Layout (R-007): Karten fuer Budget, Top-Kategorie, Monatsvergleich
- [ ] Clean-Modern-Design umsetzen: Whitespace, 2 Akzentfarben, klare Typografie
- [ ] WCAG 2.1 AA prüfen (4,5:1 Kontrast, 44x44px Touch-Targets)

---

## Phase 1c: Onboarding, Vorlagen & Polish (Woche 6-7)
> **Ziel: Erstnutzer-Erlebnis perfektionieren. App fuehlt sich "fertig" an.**

### Budget-Vorlagen-Onboarding (R-010)
- [ ] Welcome-Screen mit App-Intro (max. 3 Screens, R-015)
- [ ] Lebenssituation waehlen: Student / Berufseinsteiger / Familie / Paar / Individuell
- [ ] Template laedt vorkonfigurierte Kategorien + Budget-Richtwerte
- [ ] Nutzer kann anpassen vor Bestaetigung
- [ ] Kein leerer Startbildschirm nach Onboarding

### Kategorien verwalten
- [ ] Kategorien umbenennen
- [ ] Kategorien-Reihenfolge ändern (Drag & Drop)
- [ ] Eigene Kategorien hinzufügen (Premium, max. 8 im Free-Tier)
- [ ] Kategorie-Icons aus vordefinierter Auswahl

### Design-Polish
- [ ] Übergangs-Animationen zwischen Screens
- [ ] Skeleton-Screens statt Ladekreisel
- [ ] Leere Zustände hübsch gestalten (Illustrationen oder motivierende Texte)
- [ ] Splash-Screen mit Logo
- [ ] App-Icon designen und einbinden

### Offline-First verifizieren (R-005)
- [ ] Alle Features ohne Internet testen
- [ ] Keine Netzwerk-Abhaengigkeiten in Phase 1
- [ ] Drift-DB als alleinige Source of Truth bestätigen

---

## Phase 1d: Launch-Features (Woche 8-10)
> **Ziel: Features, die fuer Akquise und Retention kritisch sind, vor dem Launch einbauen.**

### Teilbare Monatsuebersicht (R-011)
- [ ] Generierung einer Grafik (9:16 fuer Stories, 1:1 fuer WhatsApp)
- [ ] Inhalt: Kategorie-Verteilung in Prozent (keine Betraege!)
- [ ] Schlicht-Branding + App-Store-Link
- [ ] Share-Sheet oeffnen (Flutter share_plus)
- [ ] Button auf Dashboard: "Monat teilen"

### Homescreen-Widget (R-012)
- [ ] iOS: WidgetKit-Integration (home_widget Package)
- [ ] Android: Glance/AppWidget-Integration
- [ ] Anzeige: Verbleibendes Budget des aktuellen Monats
- [ ] Aktualisierung alle 15 Minuten

### Reverse Trial (R-008)
- [ ] RevenueCat-Integration (Subscription-Management)
- [ ] 14-Tage-Trial: Alle Premium-Features sofort aktiv
- [ ] Paywall-Screen im Onboarding (nach Vorlagen-Auswahl)
- [ ] Automatischer Downgrade nach 14 Tagen (kein Kreditkarten-Zwang)
- [ ] Premium-Badge in UI fuer Features die nach Trial wegfallen
- [ ] Restore-Purchase-Funktion

### Wöchentlicher Digest (R-017)
- [ ] Firebase Cloud Messaging Setup
- [ ] Lokale Notification-Logik: Sonntag 10:00 Uhr
- [ ] Inhalt: "Diese Woche: €X ausgegeben, €Y unter/ueber Budget"
- [ ] Positive Tonalitaet, abschaltbar in Einstellungen
- [ ] Notification-Permissions abfragen (iOS)

### App-Store-Vorbereitung
- [ ] App-Store-Texte (DE + EN) schreiben
- [ ] 5 Screenshots erstellen (DE)
- [ ] Privacy-Policy + AGB erstellen (DSGVO-konform)
- [ ] App-Store-Kategorie: Finanzen
- [ ] TestFlight / Google Play Internal Testing einrichten
- [ ] Beta mit 50-200 Nutzern (4 Wochen vor Launch)

### Launch
- [ ] iOS-Build erstellen und an Apple submitten
- [ ] Android-Build 4-6 Wochen spaeter
- [ ] ProductHunt-Launch vorbereiten
- [ ] r/Finanzen + r/budgeting Posts vorbereiten

---

## Phase 1.5: Post-Launch Quick Wins (Woche 11-14)
> **Ziel: Schnelle Verbesserungen basierend auf ersten Nutzer-Daten.**

### Dark Mode (R-018)
- [ ] Dark-Theme-Farbpalette definieren
- [ ] Theme-Switching implementieren (System-automatisch + manuell)
- [ ] Alle Screens in Dark Mode testen
- [ ] Als Marketing-Moment kommunizieren: "Dark Mode ist da!"

### Wiederkehrende Ausgaben (R-013)
- [ ] Frequenz-Auswahl: wöchentlich / monatlich / jährlich
- [ ] Automatische Buchung am gewählten Tag
- [ ] Bearbeiten / Löschen (nur zukünftige / alle)
- [ ] Übersicht aller wiederkehrenden Ausgaben in Einstellungen

### Kassenbon-Foto (R-016)
- [ ] Kamera-Integration (image_picker)
- [ ] Foto an Transaktion anhaengen (lokal gespeichert)
- [ ] Foto in Transaktions-Detail anzeigen
- [ ] "Foto jetzt, Details spaeter"-Workflow

### CSV-Export (R-022)
- [ ] Export aller Transaktionen als CSV
- [ ] Filter: Zeitraum, Kategorie
- [ ] Share-Sheet zum Versenden
- [ ] Kostenlos fuer alle Nutzer

### Referral-System
- [ ] Einladungs-Link generieren
- [ ] Premium-Monat geschenkt fuer Einlader bei erfolgreicher Empfehlung
- [ ] Tracking ueber Deep Links

---

## Phase 2: Cloud-Sync & Shared Budgets (Monat 4-6)
> **Ziel: Multi-Device-Support und Paar-/Familien-Features.**

### Supabase-Backend (R-103)
- [ ] Supabase-Projekt auf EU-Server aufsetzen (Hetzner oder Supabase Cloud EU)
- [ ] Auth-System: Email/Passwort + Apple Sign-In + Google Sign-In
- [ ] Datenbank-Schema auf Supabase spiegeln (PostgreSQL)
- [ ] Sync-Logik: Lokale Drift-DB ↔ Supabase (Conflict Resolution)
- [ ] End-to-End-Verschlüsselung für Finanzdaten
- [ ] Sync-Status-Anzeige in App
- [ ] Offline-Edits korrekt synchronisieren

### Bankverbindung -- finAPI (R-100, R-101)
- [ ] finAPI-Vertrag und Integration
- [ ] Bank-Auswahl-Screen (3.000+ Banken)
- [ ] PSD2-Consent-Flow mit klarer Datenschutz-Erklaerung
- [ ] Automatischer Transaktions-Import
- [ ] ML-Kategorisierung als Vorschlag (Nutzer bestaetigt)
- [ ] Re-Authentifizierung-UX (alle 90 Tage)

### Shared Budgets (R-102, R-104)
- [ ] Einladung per Link / QR-Code
- [ ] Echtzeit-Sync zwischen Partnern
- [ ] Individuelle + gemeinsame Budget-Ansicht
- [ ] Berechtigungen: Beide hinzufügen, Budget-Änderung nur Ersteller
- [ ] Split-Ansicht: Wer hat wie viel beigetragen
- [ ] Saldo-Berechnung (wer schuldet wem)

### Multi-Konto (R-105)
- [ ] Mehrere Konten verwalten (Giro, Kreditkarte, Bargeld)
- [ ] Dashboard mit Gesamtsumme
- [ ] Transfers zwischen Konten trackbar

### Affiliate-Revenue (R-205)
- [ ] Finanzprodukt-Empfehlungen basierend auf Ausgabenprofil
- [ ] Transparente Kennzeichnung als Werbung
- [ ] Opt-in, keine Weitergabe von Finanzdaten
- [ ] Tracking-Setup fuer Revenue Share

---

## Phase 3: KI-Insights & Erweiterungen (Monat 7-12)
> **Ziel: Intelligente Features, die Nutzer langfristig binden.**

### KI-Ausgaben-Insights (R-200)
- [ ] Google ML Kit / TFLite On-Device-Modell
- [ ] Muster-Erkennung: "Restaurantausgaben 30% höher als letzten Monat"
- [ ] Insight-Karten auf Dashboard
- [ ] Keine Finanzdaten an externe Server

### Beleg-Scanner OCR (R-201)
- [ ] Google ML Kit OCR On-Device
- [ ] Betrag, Datum, Haendler automatisch erkennen
- [ ] Nutzer bestaetigt vor Speicherung
- [ ] Baut auf Kassenbon-Fotos aus Phase 1.5 auf

### Erweiterte Widgets (R-202)
- [ ] Zusaetzliche Widget-Varianten: Top-Kategorie, Monatsvergleich
- [ ] Streak-Counter im Widget

### Ausgabenprognosen (R-204)
- [ ] Restmonats-Prognose basierend auf bisherigem Verlauf + Historie
- [ ] Konfidenzbereich anzeigen

### Steuer-Kategorien (R-106)
- [ ] Vordefinierte Kategorien nach deutschem Steuerrecht
- [ ] Jahresexport mit Steuer-relevanter Zusammenfassung

### Smart Notifications (R-203)
- [ ] Max. 3 Push-Notifications pro Woche
- [ ] Kontextbasierte Erinnerungen
- [ ] Frequenz und Typen einstellbar

---

## Laufend: Qualität & Operations

### Testing
- [ ] Unit-Tests fuer DB-Operationen und Business-Logik
- [ ] Widget-Tests fuer kritische Screens (Quick-Entry, Dashboard)
- [ ] Integration-Tests fuer Kern-Flows (Transaktion anlegen → auf Dashboard sehen)
- [ ] Performance-Tests auf iPhone SE + Budget-Android

### Analytics & Monitoring
- [ ] Anonyme Nutzungsanalyse (Mixpanel/Amplitude oder self-hosted)
- [ ] Crash-Reporting (Sentry oder Firebase Crashlytics)
- [ ] Retention-Metriken tracken (Day-7, Day-30, Day-90)

### Rechtliches
- [ ] DSGVO-konforme Datenschutzerklärung
- [ ] AGB / Nutzungsbedingungen
- [ ] Impressum (Pflicht in DE)
- [ ] Cookie-/Tracking-Consent (falls Analytics)

---

## Fortschritts-Uebersicht

| Phase | Status | Zeitrahmen |
|-------|--------|------------|
| Phase 0: Setup & Architektur | **Abgeschlossen** | Woche 1 |
| Phase 1a: Manuelle Eingabe (Kern-MVP) | Offen | Woche 2-3 |
| Phase 1b: Visualisierung & Budgets | Offen | Woche 4-5 |
| Phase 1c: Onboarding & Polish | Offen | Woche 6-7 |
| Phase 1d: Launch-Features | Offen | Woche 8-10 |
| Phase 1.5: Post-Launch Quick Wins | Offen | Woche 11-14 |
| Phase 2: Cloud & Shared Budgets | Offen | Monat 4-6 |
| Phase 3: KI & Erweiterungen | Offen | Monat 7-12 |
