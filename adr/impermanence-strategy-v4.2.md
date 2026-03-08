# 🏗️ [ADR]: Impermanence & State-Separation (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir bauen ein "selbstreinigendes" System. Jedes Mal, wenn du neu startest, wird alles gelöscht – außer den Dingen, die wir explizit als "wichtig" markiert haben.
- **Problem:** Momentan sammeln sich mit der Zeit viele unnötige Dateien an ("Konfigurations-Müll"), die das System unvorhersehbar machen.
- **Lösung:** Das komplette System liegt im Arbeitsspeicher (RAM). Nur wichtige Dinge (wie deine E-Mails, Passwörter, Datenbanken) werden auf der Festplatte gespeichert.
- **Vorteil:** Ein System, das nach 100 Reboots immer noch so sauber ist wie am ersten Tag. Und wenn etwas kaputt geht: einfach neu starten.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation der Impermanence-Konfiguration (`00-core/impermanence.nix`).

### 📂 2.1 Kernkonzept
- **Root on tmpfs:** `/` wird als `tmpfs` gemountet (Größe: 4GB).
- **Explicit Persistence:** Nur Pfade in `environment.persistence."/data/persist"` überleben den Reboot.
- **Migration Script:** `scripts/migrate-to-impermanence.sh` führt rsync-basierte Migration der Bestandsdaten durch.

### 📜 2.2 Kritische Persistence-Liste (Auszug)
| Pfad | Grund |
|------|-------|
| `/var/lib/sops-nix/key.txt` | Einziger Key für alle Secrets. |
| `/etc/ssh/ssh_host_ed25519_key` | Verhindert "Known-Hosts" Warnungen nach Reboot. |
| `/var/lib/postgresql/` | Enthält alle App-Datenbanken. |
| `/var/lib/tailscale/` | Behält die Tailnet-Identität bei. |

```nix
# Beispiel: SSH Key persistieren
files = [ "/etc/ssh/ssh_host_ed25519_key" ];
```

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Drift-Detection:** Da alles Nicht-Deklarierte nach einem Reboot verschwindet, wird Konfigurations-Drift physisch unmöglich.
- **Security-Bonus:** Hinterlässt keine Spuren von temporären Dateien oder Log-Rückständen auf der Festplatte.
- **Disaster Recovery:** Ein Backup von `/data/persist` reicht aus, um das gesamte System auf neuer Hardware identisch wiederherzustellen.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-03 Prompt-Übernahme anfragen.md` (Conversational SRE Review 3.3.2026).
