# [PATTERN]: Sovereign API-Key Injection
# ID: [NUGGET-SRE-015] | Status: ACTIVE | Stand: 10.03.2026

## 1. Das Problem: "Stateful Roulette"
Apps wie Sonarr/Radarr generieren beim ersten Start einen zufälligen API-Key. Dies bricht unsere automatisierte Kommunikationskette, da wir den Key vorher nicht kennen können.

## 2. Die Lösung: Pre-Flight Injection
Anstatt auf die App zu reagieren, injizieren wir den gewünschten Key direkt aus unseren **SOPS-Secrets** in die Konfigurationsdatei, *bevor* der Dienst startet.

### Der Ablauf:
1. **Source:** Der Key wird in `sops-nix` definiert (z.B. `sonarr_api_key`).
2. **Injection:** Über `systemd.services.<name>.preStart` wird ein Skript ausgeführt.
3. **Manipulation:** Das Skript nutzt `xmlstarlet`, um den Key in der `config.xml` zu setzen oder die Datei initial mit dem richtigen Key zu erstellen.
4. **Consistency:** Da Prowlarr denselben SOPS-Key nutzt, passen die "Stecker" sofort zusammen.

## 3. Vorteile (Aviation-Grade)
- **Deterministisch:** Wir wissen schon vor dem ersten Boot, wie die Keys lauten.
- **Wartbar:** Nur ein einziger Ort für alle Keys (`secrets.yaml`).
- **Resilient:** Selbst wenn ein User den Key im Web-UI ändert, setzt das System ihn beim nächsten Neustart hart zurück.

---
> [SOURCE]: Architektur-Diskussion "API-Key Injection" (10.03.2026)
