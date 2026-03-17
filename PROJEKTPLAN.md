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
- [x] Quick-Entry-Screen: Betrag-Eingabe mit Nummernpad
- [x] Kategorie-Auswahl (max. 8 Icons als Grid)
- [x] Optionales Notiz-Feld
- [x] Datum-Auswahl (Standard: heute)
- [x] Speichern-Button -- Transaktion in Drift-DB schreiben
- [x] Eingabe in ≤ 3 Taps abschließbar
- [x] Validierung: Betrag > 0, Kategorie ausgewählt

### Monatssummen-Eingabe (User-Wunsch)
- [x] Alternativer Eingabe-Modus: Gesamtsumme pro Kategorie fuer einen Monat
- [x] Screen: Kategorie-Liste mit Eingabefeld pro Kategorie
- [x] Monat/Jahr-Auswahl
- [x] Speichern erstellt eine Sammel-Transaktion pro Kategorie
- [x] Umschaltbar zwischen Einzel- und Monatseingabe in Einstellungen

### Transaktions-Liste
- [x] Listenansicht aller Transaktionen (gruppiert nach Tag)
- [x] Anzeige: Betrag, Kategorie-Icon + Name, Notiz, Datum
- [x] Swipe-to-Delete oder Long-Press-Menue
- [x] Transaktion bearbeiten (Tap oeffnet Edit-Screen)
- [x] Filtern nach Monat (Vor/Zurueck-Navigation)

### Einfaches Dashboard (Minimal-Version)
- [x] Hauptscreen mit:
  - Aktueller Monat + verbleibendes Budget (wenn gesetzt)
  - Gesamtausgaben des Monats
  - Liste der letzten 5 Transaktionen
- [x] Bottom-Navigation: Dashboard | Transaktionen | Eingabe (+) | Einstellungen
- [x] FAB (Floating Action Button) fuer schnelle Eingabe

### Einstellungen (Basis)
- [x] Waehrung waehlen (EUR Standard, CHF als Option)
- [x] Sprache waehlen (DE/EN)
- [x] Eingabe-Modus waehlen (Einzeltransaktion / Monatssummen)
- [x] Daten loeschen (mit Bestaetigung)
- [x] App-Version anzeigen

---

## Phase 1b: Visualisierung & Budgets (Woche 4-5)
> **Ziel: Der Nutzer sieht, wohin sein Geld fliesst, und kann Limits setzen.**

### Kategorie-Visualisierung (R-002)
- [x] Donut-Chart auf dem Dashboard (fl_chart) -- Ausgaben nach Kategorie
- [x] Farbcodierung pro Kategorie
- [x] Tap auf Segment zeigt Kategorie-Detail (Drill-Down auf Einzelposten)
- [x] Balkendiagramm als Alternative (umschaltbar)

### Monats-Budget pro Kategorie (R-003)
- [x] Budget-Setup-Screen: Betrag pro Kategorie festlegen
- [x] Fortschrittsbalken pro Kategorie auf Dashboard
- [x] Farbwechsel bei 80 % (Orange) und 100 % (Rot, aber sanft)
- [x] Verbleibendes Gesamtbudget prominent auf Dashboard
- [x] Ermutigende Microcopy bei Budgetüberschreitung (R-014): "Fast geschafft!" statt "Budget überschritten!"

### Historien-Ansicht (R-009)
- [x] Monatsweise Navigation (3 Monate zurueck fuer Free-Tier)
- [x] Monat-zu-Monat-Vergleich: Balkendiagramm oder Zahl mit Trend-Pfeil
- [x] Leerer Zustand huebsch gestalten ("Noch keine Daten fuer diesen Monat")

### Dashboard aufwerten
- [x] Bento-Grid-Layout (R-007): Karten fuer Budget, Top-Kategorie, Monatsvergleich
- [x] Clean-Modern-Design umsetzen: Whitespace, 2 Akzentfarben, klare Typografie
- [x] WCAG 2.1 AA prüfen (4,5:1 Kontrast, 44x44px Touch-Targets)

---

## Phase 1c: Onboarding, Vorlagen & Polish (Woche 6-7)
> **Ziel: Erstnutzer-Erlebnis perfektionieren. App fuehlt sich "fertig" an.**

### Budget-Vorlagen-Onboarding (R-010)
- [x] Welcome-Screen mit App-Intro (max. 3 Screens, R-015)
- [x] Lebenssituation waehlen: Student / Berufseinsteiger / Familie / Paar / Individuell
- [x] Template laedt vorkonfigurierte Kategorien + Budget-Richtwerte
- [x] Nutzer kann anpassen vor Bestaetigung
- [x] Kein leerer Startbildschirm nach Onboarding

### Kategorien verwalten
- [x] Kategorien umbenennen
- [x] Kategorien-Reihenfolge ändern (Drag & Drop)
- [x] Eigene Kategorien hinzufügen (Premium, max. 8 im Free-Tier)
- [x] Kategorie-Icons aus vordefinierter Auswahl

### Design-Polish
- [x] Übergangs-Animationen zwischen Screens
- [x] Skeleton-Screens statt Ladekreisel
- [x] Leere Zustände hübsch gestalten (Illustrationen oder motivierende Texte)
- [x] Splash-Screen mit Logo
- [x] App-Icon designen und einbinden

### Offline-First verifizieren (R-005)
- [x] Alle Features ohne Internet testen
- [x] Keine Netzwerk-Abhängigkeiten in Phase 1
- [x] Drift-DB als alleinige Source of Truth bestätigen

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
- [x] Dark-Theme-Farbpalette definieren
- [x] Theme-Switching implementieren (System-automatisch + manuell)
- [ ] Alle Screens in Dark Mode testen
- [ ] Als Marketing-Moment kommunizieren: "Dark Mode ist da!"

### Wiederkehrende Ausgaben (R-013)
- [x] Frequenz-Auswahl: wöchentlich / monatlich / jährlich
- [x] Automatische Buchung am gewählten Tag
- [x] Bearbeiten / Löschen (nur zukünftige / alle)
- [x] Übersicht aller wiederkehrenden Ausgaben in Einstellungen

### Kassenbon-Foto (R-016)
- [x] Kamera-Integration (image_picker)
- [x] Foto an Transaktion anhaengen (lokal gespeichert)
- [x] Foto in Transaktions-Detail anzeigen
- [x] "Foto jetzt, Details spaeter"-Workflow

### CSV-Export (R-022)
- [x] Export aller Transaktionen als CSV
- [x] Filter: Zeitraum, Kategorie
- [x] Share-Sheet zum Versenden
- [x] Kostenlos fuer alle Nutzer

### Referral-System
- [x] Einladungs-Link generieren
- [x] Premium-Monat geschenkt fuer Einlader bei erfolgreicher Empfehlung
- [x] Tracking ueber Deep Links

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
| Phase 1a: Manuelle Eingabe (Kern-MVP) | **Abgeschlossen** | Woche 2-3 |
| Phase 1b: Visualisierung & Budgets | **Abgeschlossen** | Woche 4-5 |
| Phase 1c: Onboarding & Polish | **Abgeschlossen** | Woche 6-7 |
| Phase 1d: Launch-Features | Offen | Woche 8-10 |
| Phase 1.5: Post-Launch Quick Wins | Offen | Woche 11-14 |
| Phase 2: Cloud & Shared Budgets | Offen | Monat 4-6 |
| Phase 3: KI & Erweiterungen | Offen | Monat 7-12 |
