# [NUGGET-STORAGE-FINAL] Capped RAM & Smart Indexing (v14.2)
# Status: Stage 3 (Gold) | Version: 1.0
# [META] ID: NIXH-KNOW-STORAGE-FINAL | REQ_REFS: [ADR-012, v14.2]

## 1. USER LAYER (KISS)
Wir haben das System so eingestellt, dass es extrem sparsam mit dem Arbeitsspeicher umgeht, aber die Festplatten trotzdem maximal schont. Externe USB-Festplatten werden wie ein "Gästebuch" behandelt: Kurz reinschauen, alles aufschreiben, und dann die Platte wieder schlafen legen.

## 2. TECHNICAL LAYER (SPECIFICATION)

### RAM Configuration
- **Root Tmpfs:** Hard-capped at 1GB. Sufficient for OS structure and symlinks.
- **Write Cache:** `vm.dirty_bytes = 512MB`. Limits the amount of data waiting to be written to SSD, protecting against RAM exhaustion while still batching small writes.

### Smart USB Indexing
- **Service:** `nixh-usb-indexer@.service`.
- **Database:** SQLite `/persist/metadata/usb.db`.
- **Cache:** Valkey (In-Memory) for instant path resolution.
- **Trigger:** udev action on USB bus addition.

## 3. REASONING LAYER (ADR)
- **Why 512MB?** 512MB is the "Aviation-Grade" sweet spot. It can buffer several minutes of standard logs or a short burst of high-speed download without impacting system responsiveness on a 16GB RAM machine.
- **Why SQLite + Valkey?** SQLite provides persistence across reboots, while Valkey provides microsecond response times for file search tools.
