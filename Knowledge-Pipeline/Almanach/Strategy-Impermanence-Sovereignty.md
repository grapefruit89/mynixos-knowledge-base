# [STRATEGY]: Impermanence & Sovereign Persistence
# ID: [NUGGET-SRE-013] | Status: PLANNED | Stand: 10.03.2026

## 1. Das Prinzip (Root-on-tmpfs)
Wir machen die Root-Partition (`/`) flüchtig. Bei jedem Neustart wird sie gelöscht. Nur Daten, die wir explizit in `/persist` deklarieren, überleben.

## 2. Die "Sovereign" Mounts (Überlebenskünstler)
Folgende Pfade müssen zwingend auf die `/persist` Partition (SSD):

### 🛡️ System-Ebene
- `/persist/secrets/age.key`: Unser Master-Key zur Entschlüsselung (ADR-032).
- `/persist/etc/ssh/`: SSH-Host-Keys, damit deine Identität stabil bleibt.
- `/persist/var/lib/tailscale/`: Damit der Server im Mesh-Netz bleibt.

### 🧠 App-Ebene
- `/persist/var/lib/postgresql/`: Deine Datenbanken.
- `/persist/var/lib/paperless/`: Deine Dokumente.
- `/persist/var/lib/jellyfin/`: Deine Metadaten.

## 3. Umsetzungspfad (Meilenstein 3)
1. **Phase 1:** Definition aller Mounts in `modules/00-core/storage.nix`.
2. **Phase 2:** Umzug der `age.key` (bereits in `secrets.nix` vorbereitet) ✅.
3. **Phase 3:** Reboot-Test und Validierung der System-Purity.

---
> [SOURCE]: Architektur-Review & SRE Mandat (10.03.2026)
