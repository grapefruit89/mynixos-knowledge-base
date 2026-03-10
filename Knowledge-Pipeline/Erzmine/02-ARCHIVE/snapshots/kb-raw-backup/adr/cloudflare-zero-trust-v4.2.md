# 🏗️ [ADR]: Cloudflare Zero Trust & Access Architektur (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir bauen eine Sicherheitsschleuse vor deine Programme im Internet. Bevor jemand deine Apps (wie dein Dashboard) überhaupt sehen kann, muss er sich bei Cloudflare ausweisen.
- **Problem:** Wenn du Dienste im Internet freigibst, kann jeder Hacker versuchen, dein Passwort zu raten.
- **Lösung:** Wir nutzen "Cloudflare Access". Das ist wie ein Türsteher, der nur Leute mit dem richtigen digitalen Ausweis (z.B. dein Google-Login oder ein Einmal-Code per E-Mail) durchlässt.
- **Vorteil:** Deine Programme sind für Fremde komplett unsichtbar. Nur du und deine Familie kommen rein – ohne VPN-Gefummel.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation der mehrschichtigen Absicherung.

### 🛡️ 2.1 Schichten-Modell
1.  **Layer 1: Cloudflare Proxy (Orange Cloud):** WAF, Bot Fight Mode und Länder-Blockierung für alle Standard-Webdienste.
2.  **Layer 2: Cloudflare Access (Zero Trust):** SSO-Schranke vor sensitiven Subdomains. Unterstützung für OIDC (PocketID), Google IdP und E-Mail OTP.
3.  **Layer 3: mTLS (Client-Zertifikate):** Hardcore-Absicherung für Admin-APIs. Ohne installiertes Zertifikat im Browser ist der Dienst technisch nicht erreichbar (403).
4.  **Layer 4: DNS-only (Grau) + WireGuard:** Für bandbreitenintensive Dienste (Jellyfin), die direkt über die IP laufen, aber durch einen VPN-Namespace geschützt sind.

### 🕸️ 2.2 Routing-Strategie
- **Subdomains bevorzugt:** `service.domain.tld` statt Pfad-Routing (`domain.tld/service`), um CORS- und Cookie-Probleme zu vermeiden.
- **Reverse Proxy:** Caddy oder Traefik empfangen den Traffic von Cloudflare und leiten ihn intern weiter.

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Komfort vs. Sicherheit:** Cloudflare Access bietet die beste Balance für Familienmitglieder (Login via FaceID/Passkey), während mTLS maximale Sicherheit für Admin-Zustände garantiert.
- **Identity Provider:** PocketID dient als lokaler OIDC-Provider, der via Cloudflare Access als "Generic OIDC" eingebunden wird, um die Souveränität über die Benutzerdaten zu behalten.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-02 Homeserver mit Cloudflare sicher einrichten.md` (6.3.2026).
