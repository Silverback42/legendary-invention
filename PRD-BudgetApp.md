# Schlicht – Minimalistische Budget-App für den DACH-Raum

> **Version:** 2.0 | **Datum:** 15.03.2026 | **Autor:** [Name] | **Status:** Draft (CEO-Review integriert)

---

## Problem

Budget-App-Nutzer im DACH-Raum stehen vor einem Dilemma: Premium-Tools wie YNAB ($109/Jahr) und Monarch Money ($99,99/Jahr) sind komplex, teuer und setzen Finanzwissen voraus. Einfache Tracker wie Monefy oder 1Money wirken visuell veraltet und bieten kaum Mehrwert über eine Tabellenkalkulation hinaus. Die einzige design-getriebene Alternative – Buddy – ist ausschließlich auf iOS verfügbar und kostet $49,99/Jahr.

**Für wen?** Budget-Einsteiger (25–45 Jahre), die ihre Ausgaben kontrollieren wollen, ohne eine Finanzmethodik zu erlernen. Paare und Familien, die geteilte Budgets ohne Premium-Preise suchen. Datenschutz-bewusste Nutzer im DACH-Raum, die keine Bankverbindung erzwingen wollen.

**Warum jetzt?**
- Der Mint-Shutdown hat 3,6 Mio. Nutzer freigesetzt, Subscription-Fatigue treibt Nutzer von etablierten Playern weg.
- Apples „Liquid Glass"-Designsprache (WWDC 2025) hat Glassmorphism zur Plattform-Norm gemacht – eine neue App kann von Tag 1 nativ wirken.
- Die European Accessibility Act (EAA) ist seit Juni 2025 in Kraft und macht barrierefreies Design zur Pflicht – und zum Qualitätssiegel.
- Im DACH-Raum gibt es keinen Anbieter, der den „Simple Middle" (einfach, schön, bezahlbar, cross-platform, deutschsprachig) überzeugend bedient.

---

## Ziel

Ein cross-platform Budget-Tool schaffen, das durch herausragendes Design, bewusste Einfachheit und faire Preisgestaltung die größte unterversorgte Nutzergruppe im Budget-App-Markt gewinnt: Menschen, die Budgeting hassen, aber ihre Finanzen im Griff haben wollen.

| Metrik | Ist-Wert | Ziel-Wert (Jahr 1) |
|--------|----------|---------------------|
| Downloads (iOS + Android) | 0 | 10.000 |
| Download-to-Active-User Rate | – | ≥ 30 % |
| Aktive Nutzer (Monat 12) | 0 | 3.000–3.500 |
| Freemium → Premium Conversion (aktive Nutzer) | – | ≥ 3 % |
| Trial-to-Paid Rate (14-Tage Reverse Trial) | – | ≥ 20 % |
| App-Store-Rating | – | ≥ 4,6 Sterne |
| DAU/MAU-Ratio | – | ≥ 25 % |
| Durchschnittl. Session-Dauer | – | ≤ 45 Sekunden (schneller Wert) |
| Day-30-Retention | – | ≥ 15 % |
| Year-1-Revenue (Abo + Affiliate) | €0 | €5.000–€10.000 |
| Churn Rate (monatlich, Premium) | – | < 5 % |
| Marketing-Budget Year 1 | €0 | €10.000–€15.000 |

### Korrigierter Conversion-Funnel

```
10.000 Downloads
  → 30 % werden aktive Nutzer = 3.000
    → 50 % starten Reverse Trial = 1.500
      → 3–5 % konvertieren zu Premium = 45–75 zahlende Nutzer
        → Ø €22/Jahr = €990–€1.650 Abo-Revenue

+ Affiliate-Revenue (Phase 2+): €2.000–€5.000
+ Lifetime-Deals (Launch/Black Friday): €1.500–€3.000
= Year-1-Revenue: €4.490–€9.650
```

> **Hinweis:** Das reine B2C-Abo-Modell allein reicht nicht für Break-Even. Alternative Revenue-Streams (Affiliate, B2B-Whitelabel) sind ab Phase 2 überlebensnotwendig. Siehe Abschnitt „Monetarisierung & Revenue-Diversifikation".

---

## Nutzer

### Primäre Personas

**1. Lisa (29) – Die Budget-Einsteigerin**
Berufseinsteigerin, nutzt bisher eine Excel-Tabelle oder gar nichts. Will wissen, wohin ihr Geld fließt, ohne sich in Kategorien-Systeme einzuarbeiten. Erwartet eine App, die so schön ist wie ihre Lieblings-Apps (Instagram, Spotify). Maximale Nutzungsdauer: 30 Sekunden pro Tag.

**2. Markus & Jana (33/31) – Das Paar mit geteilten Kosten**
Teilen sich Miete, Einkäufe und Urlaub. Brauchen ein gemeinsames Budget ohne $15/Monat-Preisschild. Wollen schnell sehen, wer was bezahlt hat, ohne Tabellen hin- und herzuschicken.

**3. Thomas (58) – Der Datenschutz-Bewusste**
Möchte seine Ausgaben digital erfassen, aber keine Bankdaten an Dritte geben. Braucht größere Schrift, klare Navigation, keine überladenen Dashboards. Deutsche Sprache ist Pflicht.

### Sekundäre Personas

**4. Sophie (24) – Gen-Z-Sparerin**
Von Finfluencern auf TikTok motiviert, will „endlich sparen". Erwartet Gamification, Dark Mode, schnelle Micro-Interactions. Wechselt die App, wenn das Design nicht stimmt.

**5. Familien-Account (Phase 2+)**
Eltern mit Kindern, die Taschengeld und Familienausgaben zentral verwalten wollen.

---

## Anforderungen

### Phase 1 – MVP: Manuelles Tracking + Design-Exzellenz

#### Must-have

| ID | User Story | Akzeptanzkriterien |
|----|------------|--------------------|
| R-001 | Als Nutzer möchte ich eine Ausgabe in unter 5 Sekunden erfassen, damit ich die App täglich nutze, ohne Zeit zu verlieren. | Quick-Entry-Screen mit Betrag, Kategorie (max. 8 im Free-Tier), optionaler Notiz. Eingabe in ≤ 3 Taps abgeschlossen. |
| R-002 | Als Nutzer möchte ich meine monatlichen Ausgaben nach Kategorie visualisiert sehen, damit ich sofort erkenne, wohin mein Geld fließt. | Donut-/Balkendiagramm auf dem Hauptscreen. Kategorien farbcodiert. Drill-Down auf Einzelposten. |
| R-003 | Als Nutzer möchte ich ein monatliches Budget pro Kategorie setzen, damit ich meine Ausgabenlimits im Blick behalte. | Fortschrittsbalken pro Kategorie. Visueller Hinweis (Farbwechsel, nicht aggressive Warnung), wenn 80 % erreicht sind. |
| R-004 | Als Nutzer möchte ich ein modernes, minimalistisches Interface erleben, das sich wie eine native App anfühlt. | Clean-Modern-Design mit großzügigem Whitespace, max. 2 Akzentfarben. Light-Theme als Standard. WCAG 2.1 AA-konform (4,5:1 Kontrast, 44×44px Touch-Targets). *(Dark Mode als Post-Launch-Update in Phase 1.5)* |
| R-005 | Als Nutzer möchte ich meine Daten lokal auf dem Gerät gespeichert haben, damit ich die App auch offline nutzen kann. | Offline-First-Architektur mit lokaler Drift-DB. Alle Kernfunktionen ohne Internetverbindung verfügbar. |
| R-006 | Als Nutzer möchte ich die App auf Deutsch und Englisch nutzen, damit sie im DACH-Raum und international funktioniert. | Vollständige deutsche Lokalisierung inkl. Währungsformat (€), Datumsformat (DD.MM.YYYY), Dezimaltrennung (Komma). Englische Lokalisierung ab Launch (verdreifacht adressierbaren Markt bei minimalem Mehraufwand dank Flutter-i18n). |
| R-007 | Als Nutzer möchte ich ein sauberes, modernes Interface mit Bento-Grid-Dashboard erleben, das Finanzdaten klar und übersichtlich darstellt. | Bento-Grid-Dashboard, Clean-Modern-Karten, exaggerated Minimalism (großzügiger Whitespace, max. 2 Akzentfarben). Optionale subtile Glassmorphism-Akzente (nur wo performant). WCAG 2.1 AA-konform (4,5:1 Kontrast, 44×44px Touch-Targets). Performance-Budget: 60fps auf iPhone SE / Budget-Android. |
| R-008 | Als Nutzer möchte ich einen 14-tägigen Reverse Trial erleben, damit ich alle Premium-Features testen kann, bevor ich mich entscheide. | Premium-Features sofort aktiv. Paywall erscheint während Onboarding. Nach 14 Tagen automatischer Downgrade auf Free-Tier ohne Kreditkartenangabe. |
| R-009 | Als Nutzer möchte ich die letzten 3 Monate meiner Ausgabenhistorie einsehen (Free) bzw. 12 Monate (Premium). | Historische Daten scrollbar. Monat-zu-Monat-Vergleich sichtbar. |
| R-010 | Als Nutzer möchte ich beim Onboarding Budget-Vorlagen nach Lebenssituation wählen (Student, Berufseinsteiger, Familie, Paar), damit ich sofort sinnvolle Kategorien und Budget-Richtwerte habe. | 4–6 vorkonfigurierte Templates. Kategorien und Richtwerte anpassbar. Kein leerer Startbildschirm. |
| R-011 | Als Nutzer möchte ich eine schön designte Monatsübersicht teilen können (Instagram Story, WhatsApp), damit ich meinen Fortschritt zeige und Freunde inspiriere. | Teilbare Grafik mit Kategorie-Verteilung (Prozent, keine Beträge). Schlicht-Branding + App-Store-Link. Optimiert für Instagram Stories (9:16) und WhatsApp. |
| R-012 | Als Nutzer möchte ich ein einfaches Homescreen-Widget sehen (verbleibendes Budget), damit ich die App nicht öffnen muss. | iOS (WidgetKit) und Android (Glance) Widget. Zeigt verbleibendes Budget des Monats. Aktualisierung mindestens alle 15 Minuten. |

#### Should-have

| ID | User Story | Akzeptanzkriterien |
|----|------------|--------------------|
| R-013 | Als Nutzer möchte ich wiederkehrende Ausgaben (Miete, Abos) einmalig anlegen, damit sie automatisch jeden Monat erfasst werden. | Wiederkehrende Transaktionen mit wählbarem Intervall (wöchentlich, monatlich, jährlich). Bearbeitbar und löschbar. |
| R-014 | Als Nutzer möchte ich ermutigende Microcopy statt Schuldgefühle, damit ich motiviert bleibe. | Positive Formulierungen bei Budgetüberschreitung (z. B. „Fast geschafft!" statt „Budget überschritten!"). Kein roter Warnton als Standard. |
| R-015 | Als Nutzer möchte ich ein Onboarding durchlaufen, das mir in max. 3 Screens erklärt, wie die App funktioniert. | Progressive Disclosure: Nur Kernfunktionen im Onboarding. Kein Tutorial länger als 60 Sekunden. Nahtloser Übergang zur Budget-Vorlagen-Auswahl (R-010). |
| R-016 | Als Nutzer möchte ich ein Foto eines Kassenbons an eine Transaktion anhängen, damit ich Belege digital aufbewahren kann. | Kamera-Integration. Foto wird lokal gespeichert und der Transaktion zugeordnet. *(Kein OCR in Phase 1 – dient als Trainingsdaten für Phase 3 ML.)* |
| R-017 | Als Nutzer möchte ich wöchentliche Zusammenfassungen als Push-Notification erhalten, damit ich meinen Fortschritt sehe. | Wöchentlicher Digest: „Diese Woche: €X ausgegeben, €Y unter/über Budget." Abschaltbar. Positive Tonalität. |
| R-018 | Als Nutzer möchte ich Dark Mode nutzen, damit die App zu meiner Systemeinstellung passt. | Automatische Erkennung der Systemeinstellung. Manuelle Umschaltung möglich. |

#### Nice-to-have

| ID | User Story | Akzeptanzkriterien |
|----|------------|--------------------|
| R-019 | Als Nutzer möchte ich Micro-Interactions und Animationen erleben (Konfetti bei Sparzielen, Haptic Feedback), damit Budgeting sich positiv anfühlt. | Animationen bei Zielerreichung, sanftes Haptic Feedback bei Bestätigungen, Skeleton Screens statt Ladekreisel. Abschaltbar in Einstellungen. |
| R-020 | Als Nutzer möchte ich Streaks sehen (z. B. „7 Tage in Folge Ausgaben erfasst"), damit ich eine tägliche Gewohnheit aufbaue. | Streak-Counter auf dem Dashboard. Streak bricht nach 48h ohne Eingabe ab. *(Erst nach Datenanalyse der Nutzerverhaltensmuster priorisieren.)* |
| R-021 | Als Nutzer möchte ich Sparziele anlegen (z. B. „Urlaub: €2.000"), damit ich auf etwas Konkretes hinarbeite. | Visueller Fortschrittsbalken. Manuelle Einzahlung auf Ziel. |
| R-022 | Als Nutzer möchte ich meine Daten als CSV exportieren, damit ich sie in Excel/Sheets weiterverarbeiten kann. | Export-Funktion für alle Transaktionen. Filter nach Zeitraum und Kategorie. *(Kostenlos für alle Nutzer – kein Premium-Gate.)* |

---

### Phase 2 – Bankverbindung & Shared Budgets

#### Must-have

| ID | User Story | Akzeptanzkriterien |
|----|------------|--------------------|
| R-100 | Als Nutzer möchte ich optional mein Bankkonto verbinden, damit Transaktionen automatisch importiert werden. | Integration über finAPI. 3.000+ Banken in DE/EU. PSD2-konform. Opt-in, kein Zwang. Klare Datenschutz-Erklärung vor Verbindung. |
| R-101 | Als Nutzer möchte ich automatisch kategorisierte Transaktionen sehen, damit ich weniger manuell nacharbeiten muss. | finAPI-ML-Kategorisierung als Vorschlag. Nutzer kann korrigieren. Korrekturen verbessern zukünftige Vorschläge (On-Device-ML). |
| R-102 | Als Paar möchte ich ein geteiltes Budget erstellen, damit wir gemeinsame Ausgaben verwalten können. | Einladung per Link/QR-Code. Echtzeit-Sync. Individuelle + gemeinsame Ansicht. Berechtigungen: Beide können hinzufügen, Budget-Änderungen nur Ersteller. |
| R-103 | Als Nutzer möchte ich Cloud-Sync aktivieren, damit meine Daten auf mehreren Geräten verfügbar sind. | Supabase-Backend auf EU-Servern. End-to-End-Verschlüsselung für Finanzdaten. Sync-Status sichtbar. Konfliktlösung bei Offline-Edits. |

#### Should-have

| ID | User Story | Akzeptanzkriterien |
|----|------------|--------------------|
| R-104 | Als Paar möchte ich sehen, wer wie viel zu gemeinsamen Ausgaben beigetragen hat, damit die Aufteilung fair bleibt. | Split-Ansicht pro Person. Saldo-Berechnung (wer schuldet wem wie viel). |
| R-105 | Als Premium-Nutzer möchte ich unbegrenzte Konten verwalten (Girokonto, Kreditkarte, Bargeld), damit ich einen Gesamtüberblick habe. | Multi-Konto-Dashboard mit Gesamtsumme. Transfers zwischen Konten trackbar. |
| R-106 | Als Nutzer möchte ich Kategorie-Mapping für deutsche Steuerausgaben sehen (Werbungskosten, Sonderausgaben), damit ich Steuererklärungen vorbereiten kann. | Vordefinierte Steuer-Kategorien nach deutschem Recht. Jahresexport mit Steuer-relevanter Zusammenfassung. |

#### Nice-to-have

| ID | User Story | Akzeptanzkriterien |
|----|------------|--------------------|
| R-107 | Als Familie möchte ich Taschengeld-Budgets für Kinder anlegen, damit der Nachwuchs Finanzmanagement lernt. | Unter-Budgets pro Familienmitglied. Vereinfachte Ansicht für Kinder (keine sensiblen Familiendaten). |

---

### Phase 3 – KI-Insights & Erweiterungen

#### Must-have

| ID | User Story | Akzeptanzkriterien |
|----|------------|--------------------|
| R-200 | Als Nutzer möchte ich KI-basierte Ausgaben-Insights erhalten (z. B. „Deine Restaurantausgaben sind 30 % höher als letzten Monat"), damit ich Muster erkenne. | On-Device-ML (Google ML Kit / TFLite). Keine Finanzdaten an externe Server. Insights als Karten im Dashboard, nicht als Push-Spam. |
| R-201 | Als Nutzer möchte ich Belege per Kamera scannen und automatisch als Ausgabe erfassen, damit ich Kassenzettel digitalisieren kann. | OCR via Google ML Kit (On-Device). Betrag, Datum und Händler werden erkannt. Nutzer bestätigt vor Speicherung. *(Baut auf Kassenbon-Fotos aus Phase 1 auf – Trainingsdaten bereits vorhanden.)* |
| R-202 | Als Nutzer möchte ich erweiterte Homescreen-Widgets sehen (Top-Kategorie, Streak-Counter, Monatsvergleich). | Erweiterung des Phase-1-Basis-Widgets um zusätzliche Widget-Varianten. |

#### Should-have

| ID | User Story | Akzeptanzkriterien |
|----|------------|--------------------|
| R-203 | Als Nutzer möchte ich intelligente Benachrichtigungen erhalten, die mich an ungewöhnliche Ausgaben erinnern, ohne mich zu nerven. | Max. 3 Push-Notifications pro Woche. Nutzer kann Frequenz und Typen einstellen. Kein Guilt-Messaging. |
| R-204 | Als Nutzer möchte ich Ausgabenprognosen für den Restmonat sehen, damit ich frühzeitig gegensteuern kann. | Prognose basierend auf bisherigem Monatsverlauf + historischem Muster. Konfidenzbereich anzeigen. |
| R-205 | Als Nutzer möchte ich Finanzprodukt-Empfehlungen sehen, die zu meinem Profil passen (Affiliate), damit ich bessere Konditionen finde. | Transparente Kennzeichnung als Werbung/Affiliate. Opt-in. Keine Weitergabe von Finanzdaten an Partner. Revenue Share: €20–100 pro Abschluss. |

#### Nice-to-have

| ID | User Story | Akzeptanzkriterien |
|----|------------|--------------------|
| R-206 | Als Nutzer möchte ich einen Chatbot-Assistenten nutzen, der meine Finanzen in natürlicher Sprache erklärt. | Einfache Fragen beantwortbar (z. B. „Wie viel habe ich diesen Monat für Essen ausgegeben?"). On-Device oder EU-Server. |
| R-207 | Als Nutzer möchte ich meine Daten mit WISO Steuer oder ähnlichen Tools teilen können. | Export im kompatiblen Format. Deep-Link oder Datei-Übergabe. |

---

## Go-to-Market-Strategie

### Positionierung

**Claim:** „Schlicht – Privat. Einfach. Ehrlich." / „Budgeting, schlicht und einfach."

**Kernversprechen:** Budget-Tracking in unter 30 Sekunden am Tag – ohne Bankverbindung, ohne Finanzmethodik, ohne Schuldgefühle.

**Differenzierung:** Privacy-by-Default als Markenidentität, nicht als Feature. Jeder App-Store-Text, jeder Screenshot, jede Pressemitteilung führt mit Datenschutz.

### Launch-Strategie

| Phase | Zeitraum | Kanal | Budget | Ziel |
|-------|----------|-------|--------|------|
| Pre-Launch | 8 Wochen vor Launch | TestFlight/Open Beta mit 200–500 Nutzern | €0 | Retention validieren, Bugs finden, Community aufbauen |
| Launch Woche 1 | Tag 1–7 | ProductHunt, Hacker News, r/Finanzen, r/budgeting | €500 | Initiale Downloads + Reviews |
| Launch Monat 1 | Woche 1–4 | Apple Search Ads (Keywords: „Haushaltsbuch", „Ausgaben tracken", „Geld sparen App") | €2.000 | 1.500–2.500 Downloads |
| Monat 2–6 | Laufend | Content-Marketing (TikTok/Instagram Reels, Blog) | €1.000/Monat | Organisches Wachstum |
| Monat 3–12 | Laufend | Influencer-Kooperationen (Finanzfluss, Madame Moneypenny, kleinere Finanz-Creator) | €3.000–5.000 | 5.000+ Downloads |

**Gesamtes Marketing-Budget Year 1:** €10.000–15.000

### App Store Optimization (ASO)

- **Primäre Keywords (DE):** Haushaltsbuch, Ausgaben tracken, Budget App, Geld sparen, Finanzübersicht
- **Sekundäre Keywords:** Budgetplaner, Kostentracker, Ausgabenkontrolle, Sparrechner
- **Screenshots:** 5 Screenshots mit deutschem Text, Privacy-Badge prominent, Dark/Light-Vergleich
- **Bewertungsstrategie:** In-App-Review-Prompt nach 3. erfolgreicher Budget-Woche (nicht beim Onboarding)

### Virale Mechanismen

1. **Teilbare Monatsübersicht:** Schön designte Grafik der Monatszusammenfassung, optimiert für Instagram Stories und WhatsApp. Branded mit Schlicht-Logo + App-Store-Link. Keine sensiblen Beträge sichtbar (nur Prozent-Verteilung nach Kategorie).
2. **Spar-Challenges:** „30-Tage No-Spend-Challenge" als teilbares Feature. Einladung von Freunden per Link.
3. **Referral:** Premium-Monat geschenkt für jede erfolgreiche Empfehlung (ab Phase 1.5).

### Plattform-Reihenfolge

**iOS-First-Launch**, Android 4–6 Wochen später.
- iOS-Nutzer haben höheren ARPU und stärkere Affinität zu Design-Apps
- Erzeugt FOMO bei Android-Nutzern und liefert einen zweiten Launch-Moment
- Flutter ermöglicht schnelle Android-Nachzügler-Version mit minimalem Mehraufwand

---

## Out of Scope

- **Investment-Tracking und Wertpapier-Portfolio:** Kein Depot-Management, keine Aktienkurse, kein Krypto-Tracking.
- **Kreditvergabe oder Schuldenmanagement-Tools:** Keine Kredit-Score-Anzeige, kein Tilgungsplan-Rechner.
- **Vollständige Buchhaltungsfunktionen:** Keine Rechnungserstellung, keine USt-Berechnung für Selbstständige.
- **Eigene Neobank-Funktionen:** Kein eigenes Konto, keine Karten, keine Zahlungsabwicklung.
- **Native Apps (Swift/Kotlin):** Ausschließlich Flutter-basierte Cross-Platform-Entwicklung.
- **Märkte außerhalb DACH + EN (Phase 1):** Deutsch und Englisch ab Launch. Weitere Sprachen erst ab Phase 2.

---

## Competitive Moat

> **Problem:** „Schönes Design + günstig + deutsch" ist kein nachhaltiger Burggraben. Buddy (2,5 Mio. Nutzer, VC-funded) kann jederzeit Android launchen.

### Moat-Strategie (in Reihenfolge der Umsetzbarkeit)

| Moat-Typ | Beschreibung | Phase | Verteidigungsstärke |
|----------|--------------|-------|---------------------|
| **DACH-Tiefe** | Deutsche Steuerkategorien, DSGVO-Compliance als Feature, finAPI-Integration, deutsche Banklandschaft. Kein US-Produkt kann das kurzfristig replizieren. | Phase 1–2 | Mittel |
| **Daten-Netzwerkeffekt** | Anonymisierte, aggregierte Ausgabendaten: „Andere Schlicht-Nutzer in München geben Ø €420/Monat für Miete aus." Wird wertvoller mit jedem Nutzer. | Phase 2–3 | Hoch |
| **Community & Social** | Spar-Challenges mit Freunden, gamifizierte Gruppen-Sparziele, teilbare Monatsübersichten als viraler Loop. | Phase 1–2 | Mittel-Hoch |
| **Lokale Partnerschaften** | Integration mit Payback, DeutschlandCard, regionalen Vergleichsportalen. B2B-Deals mit Sparkassen/Volksbanken. | Phase 2–3 | Hoch |

---

## Retention-Strategie

> **Kernrisiko:** 80 % der Budget-App-Nutzer hören nach 2–3 Wochen auf zu tracken. Streaks allein lösen das nicht.

### Retention-Mechanismen nach Phase

| Mechanismus | Beschreibung | Trigger | Phase |
|-------------|--------------|---------|-------|
| **Teilbare Monatsübersicht** | Schön designte Grafik zum Monatsende. Social Sharing = Retention + Akquise gleichzeitig. | Monatsende, automatisch generiert | 1 |
| **Wöchentlicher Digest** | Push-Notification: „Diese Woche: €X ausgegeben, €Y unter Budget. Weiter so!" Positive Tonalität. | Sonntag, 10:00 Uhr | 1 |
| **Budget-Vorlagen** | Kein leerer Startbildschirm. Sofort sinnvolle Kategorien und Richtwerte nach Lebenssituation. | Onboarding | 1 |
| **Widget als täglicher Touchpoint** | Verbleibendes Budget auf dem Homescreen sichtbar, ohne App zu öffnen. | Permanent | 1 |
| **Kassenbon-Foto** | „Foto jetzt, Details später" – reduziert Hemmschwelle bei spontanen Ausgaben. | Bei jeder Transaktion | 1 |
| **Monatsend-Ritual** | Automatische Zusammenfassung + Vergleich zum Vormonat. Feier bei Zielerreichung. | Monatsende | 1 |
| **Peer-Vergleich** | „Du sparst 15 % mehr als der Durchschnitt deiner Altersgruppe." Anonymisiert, motivierend. | Ab 1.000+ Nutzern | 2 |
| **Smart Notifications** | Kontextbasierte Erinnerungen statt generischem „Hast du getrackt?". Basierend auf Nutzungsmuster. | Individuell | 2 |
| **Spar-Challenges** | 30-Tage-Challenges, einladbar per Link. Social Accountability. | Monatlich | 2 |

### Retention-Ziele

| Metrik | Ziel Phase 1 | Benchmark |
|--------|--------------|-----------|
| Day-7 Retention | ≥ 40 % | Finance-Apps Ø: 25–35 % |
| Day-30 Retention | ≥ 15 % | Finance-Apps Ø: 10–15 % |
| Day-90 Retention | ≥ 8 % | Finance-Apps Ø: 5–8 % |

---

## Risiko-Registry

| # | Risiko | Wahrsch. | Impact | Mitigation |
|---|--------|----------|--------|------------|
| 1 | Buddy launcht Android innerhalb 12 Monaten | 70 % | Kritisch | Speed-to-market (MVP in 10–12 Wochen). DACH-spezifische Features als Differentiator. Community aufbauen, bevor Buddy kommt. |
| 2 | Akquisitions-Stall (< 2.000 Downloads in 6 Monaten) | 60 % | Hoch | €10–15K Marketing-Budget. Virale Mechanismen (teilbare Übersichten). Content-Marketing ab Tag 1. Influencer-Partnerschaften. |
| 3 | Retention-Krise nach Woche 3 (Day-30 < 10 %) | 80 % | Hoch | Passive Touchpoints (Widget, Digest). Social Sharing. 4-Wochen-Beta mit 50 Testnutzern vor Launch zur Validierung. |
| 4 | finAPI-Abhängigkeit (Preiserhöhung, Übernahme, PSD2-UX) | 40 % | Hoch | Phase 1 muss ohne Bank-API vollwertig sein. Alternative APIs evaluieren (Tink, Nordigen/GoCardless). PSD2-UX als eigenes Design-Projekt. |
| 5 | Performance-Probleme / App Store Rejection | 30 % | Mittel | Glassmorphism nur als Akzent, nicht global. Performance-Testing auf iPhone SE + Budget-Android ab Tag 1. Fallback-Design ohne Blur. |

---

## Technische Rahmenbedingungen

### Tech-Stack

| Schicht | Technologie | Begründung |
|---------|-------------|------------|
| Framework | Flutter 3.38+ (Dart) | ~46 % Cross-Platform-Marktanteil. Impeller-Engine (60–120fps). Pixelgenaue Design-Kontrolle für Clean-Modern-UI. MVP in 10–12 Wochen realisierbar (reduzierter Scope). |
| Lokale Datenbank | Drift (SQLite) | Type-Safe SQL, ACID-Transaktionen, Offline-First als Source of Truth. |
| Backend | Supabase (EU-Region oder Self-Hosted auf Hetzner/AWS Frankfurt) | Open-Source, PostgreSQL-basiert. Vorhersehbare Kosten: ab $25/Monat für bis zu 100.000 Nutzer. DSGVO-konform. |
| Bank-API | finAPI (Phase 2) | BaFin-lizenziert, 3.000+ Banken in 9 EU-Ländern, eingebaute ML-Kategorisierung. |
| ML/KI | Google ML Kit + TensorFlow Lite (Phase 3) | On-Device-OCR und Kategorisierung. Kostenlos, offline-fähig, keine Daten an Dritte. |
| Push-Notifications | Firebase Cloud Messaging | Kostenlos, zuverlässig, backend-agnostisch. |
| Charts | fl_chart | Anpassbare Finanz-Visualisierungen für Flutter. |
| Payments | RevenueCat | Subscription-Management für iOS + Android. Trial-Tracking. |

### Architektur-Prinzipien

- **Offline-First:** Lokale Drift-DB ist Source of Truth. Background-Sync zu Supabase bei Verbindung.
- **Privacy-by-Design:** Kernfunktionen ohne Bankverbindung. Keine Finanzdaten an externe ML-Server. Supabase auf EU-Servern.
- **Progressive Disclosure:** Komplexität wird schrittweise freigeschaltet, nie auf einmal angezeigt.
- **EAA-Compliance:** WCAG 2.1 AA ab Tag 1 (4,5:1 Kontrast, 44×44px Touch-Targets, Dynamic Type, Screen-Reader-Support).
- **i18n-Ready:** Flutter-i18n-Architektur ab Tag 1. Deutsch + Englisch zum Launch, weitere Sprachen ab Phase 2.
- **Performance-First:** 60fps auf iPhone SE und Budget-Android-Geräten. Glassmorphism nur als Akzent-Element, nie global. Fallback-Design ohne Blur für Low-End-Devices.

### Datenmodell (Kern)

```
Nutzer → Konten → Transaktionen → Kategorien
                                 → Budgets (pro Kategorie, pro Monat)
                                 → Sparziele
Nutzer → Shared Budgets (Phase 2) → Mitglieder
```

### Kosten-Schätzung

| Posten | Schätzung | Anmerkung |
|--------|-----------|-----------|
| MVP-Entwicklung (Phase 1, reduzierter Scope) | €45.000–€55.000 | 10–12 Wochen bei €800/Tag Freelancer-Rate. €30K nur realistisch bei Eigenentwicklung ohne externen Designer. |
| UI/UX-Design | €8.000–€12.000 | Inkl. in MVP-Schätzung oben. Clean-Modern-Design (ein Theme). |
| Rechtliches (DSGVO, AGB, Datenschutzerklärung) | €3.000–€5.000 | Juristischer Review für Finanz-App Pflicht. |
| Marketing Year 1 | €10.000–€15.000 | Siehe Go-to-Market-Strategie. |
| Infrastruktur (Jahr 1) | < €300/Monat | Supabase, FCM, Analytics. |
| finAPI-Integration (Phase 2) | Individuelles Pricing | Typisch €0,05–0,30 pro API-Call. |
| App-Store-Gebühren | €99/Jahr (Apple) + €25 einmalig (Google) | |
| **Gesamt Year 1 (inkl. Marketing)** | **€65.000–€85.000** | |

### Monetarisierung & Revenue-Diversifikation

#### Abo-Tiers

| Tier | Preis | Inhalte |
|------|-------|---------|
| Free | €0 | Unbegrenzte manuelle Eingabe, 8 Kategorien, Monats-Chart, 1 Konto, 3 Monate Historie, CSV-Export, Widget. Minimale Banner-Werbung. |
| Premium | €3,99/Monat oder €24,99/Jahr | Unbegrenzte Kategorien & Konten, Bankverbindung (Phase 2), erweiterte Analysen, Cloud-Sync, Dark Mode, werbefrei, 12 Monate Historie, Kassenbon-Fotos. |
| Premium Family (Phase 2) | €49,99/Jahr | Shared Budgets für 2+ Nutzer, Familien-Insights, unbegrenzte Historie. |
| Lifetime-Deal (Launch/Black Friday) | €79,99 | Alle Premium-Features dauerhaft. |

#### Alternative Revenue-Streams (ab Phase 2)

| Stream | Geschätzter Revenue/Jahr | Priorität |
|--------|--------------------------|-----------|
| **Affiliate-Partnerschaften:** Versicherungs-, Tagesgeld-, ETF-Vergleiche basierend auf Ausgabenprofil. „Du gibst €200/Monat für Versicherungen aus – hier sind günstigere Alternativen." Revenue Share: €20–100 pro Abschluss. | €2.000–€5.000 (Year 1) | Hoch |
| **B2B-Whitelabel:** Schlicht als Whitelabel-Lösung für Sparkassen, Volksbanken oder Neobanken. Ein einzelner Deal kann das gesamte Jahresbudget finanzieren. | €50.000–€200.000 pro Deal | Mittel (ab Phase 2) |
| **Anonymisierte Marktdaten:** Aggregierte, DSGVO-konforme Ausgabendaten für den DACH-Raum an Marktforscher. Nur bei ausreichender Nutzerbasis (>10.000 aktive Nutzer). | €5.000–€20.000 | Niedrig (ab Phase 3) |

> **Strategische Erkenntnis:** Das reine B2C-Abo-Modell erreicht bei 10.000 Downloads und 3 % Conversion nur ~€1.000–€1.650 Jahresrevenue. Affiliate und B2B-Whitelabel sind nicht „nice-to-have", sondern überlebensnotwendig für einen nachhaltigen Break-Even.

---

## Offene Fragen

### Produkt & Design

| # | Frage | Verantwortlich | Frist |
|---|-------|----------------|-------|
| 1 | Finaler Produktname und Brand-Identity (Farben, Logo, Tonalität)? „Privacy-by-Default" als Markenkern integrieren. | Product / Design | Vor MVP-Start |
| 2 | Apple App Store Review: Risiko einer Ablehnung wegen Design-Ähnlichkeit zu iOS-26-Systemelementen? | Design / Tech | Vor Submission |
| 3 | Performance-Budget definieren: 60fps auf welchen Mindest-Devices (iPhone SE 2? Samsung Galaxy A14?)? | Tech | Vor MVP-Start |

### Business & Finanzen

| # | Frage | Verantwortlich | Frist |
|---|-------|----------------|-------|
| 4 | Validierung: 4-Wochen-Prototyp mit 50 Testnutzern – wenn <60 % nach 2 Wochen noch aktiv tracken, Pivot-Kriterien definieren. | Product | Vor Vollinvestment |
| 5 | Marketing-Budget Freigabe: €10–15K Year 1 – woher kommt das Kapital? Bootstrapping, Angel, Savings? | Business | Vor MVP-Start |
| 6 | B2B-Whitelabel: Erste Gespräche mit regionalen Banken (Sparkasse, Volksbank) – ist Interesse vorhanden? | Business | Phase-1-Ende |
| 7 | finAPI-Konditionen und Vertrag für Phase 2 – ab welchem Nutzervolumen lohnt sich die Integration? | Tech / Business | Phase-1-Ende |
| 8 | Affiliate-Modell (Finanzprodukt-Empfehlungen) ab Phase 2: Rechtliche Prüfung für DACH-Markt nötig? | Legal / Business | Phase-1-Ende |

### Technik & Infrastruktur

| # | Frage | Verantwortlich | Frist |
|---|-------|----------------|-------|
| 9 | Self-Hosted Supabase (Hetzner) vs. Supabase Cloud EU – was ist wartbarer für ein 1–3-Personen-Team? | Tech | Vor MVP-Start |
| 10 | PSD2-Re-Authentifizierung UX-Lösung definieren (Phase 2). | Design / Tech | Phase-2-Start |
| 11 | Genauer Umfang der Steuer-Kategorien (R-106): Abstimmung mit Steuerberater für deutsche Relevanz? | Product / External | Phase-2-Start |
| 12 | Team-Kapazität: 1–3 Personen für 5 Technologie-Stacks (Flutter, Drift, Supabase, finAPI, ML Kit) – realistisch? Externe Unterstützung für Design einplanen? | Tech / Business | Vor MVP-Start |
