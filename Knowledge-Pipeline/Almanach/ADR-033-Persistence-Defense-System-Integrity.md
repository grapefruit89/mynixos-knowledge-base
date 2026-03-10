# [ADR-033]: Persistence Defense & System Integrity
# ID: [ADR-033] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir gehen davon aus, dass Angreifer versuchen werden, sich dauerhaft auf dem System einzunisten. Unser Ziel ist es, dem System "Demenz" beizubringen: Alles, was nicht explizit erlaubt ist, wird bei jedem Neustart vergessen.

## 2. Technical Layer (Spezifikation)
- **Root-on-tmpfs:** Die Root-Partition lebt im RAM. Nur `/nix`, `/persist` und `/boot` sind auf der SSD.
- **Boot Integrity:** Einsatz von `Lanzaboote` für UEFI Secure Boot mit User-Keys.
- **Audit-Routine:** Integration von `osquery` in die SRE-Shell, um Fremddateien und fremde systemd-Units zu identifizieren.
- **Binary-Only Policy:** Keine Ausführung von Binaries außerhalb des Nix-Stores (`/nix/store`).

## 3. Reasoning Layer (ADR)
- **Warum?** Klassische Antiviren-Software versagt bei gezielten Angriffen. Architektur-Eigenschaften wie "Statelessness" sind ein passiver, unüberwindbarer Schutzwall.
- **Vorteil:** Ein kompromittiertes System wird durch einen einfachen Stromzyklus (Reboot) wieder in den sauberen Zielzustand versetzt.

---
> [SOURCE]: Awesome Malware Persistence Audit (10.03.2026)
