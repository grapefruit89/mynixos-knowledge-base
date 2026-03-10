# [GUIDE]: Sops-Nix Initialisierung (Meilenstein 1)
# ID: [NUGGET-SRE-018] | Status: ACTIVE | Stand: 10.03.2026

## 1. Die Mission
Wir führen den Umzug von manuellen Secrets zu SOPS durch. Dies ist die Voraussetzung für unsere API-Key-Fabrik im Media-Vault.

## 2. Der manuelle Akt (Deine Aufgabe)
Da ich deinen privaten Schlüssel nicht kenne, musst du die Datei initialisieren:

1. **Age-Key sicherstellen:**
   ```bash
   mkdir -p /persist/secrets
   # Falls noch kein Key existiert:
   age-keygen -o /persist/secrets/age.key
   ```
2. **Secrets editieren:**
   ```bash
   cd /home/Werkstatt/secrets
   sops secrets.yaml
   ```
3. **Wahrheit einfüllen:** Füge dort die API-Keys für Sonarr, Radarr und Prowlarr ein (siehe ADR-034).

## 3. Die Automatisierung (Meine Aufgabe)
Sobald die Datei existiert, übernimmt mein `api-injection-factory` Modul den Rest und verteilt die Keys in die Container.

---
> [ARCHITECT-NOTE]: Ohne diesen Schritt bleibt der Media-Vault im "Warte-Modus".
