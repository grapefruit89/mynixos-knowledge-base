---
title: Strategy-Future-of-Nix-Determinate-Systems (Aviation-Grade Nugget)
category: architecture/legacy-import
capabilities: [archived-knowledge, traceability-fix]
sources: [https://github.com/mightyiam/best-of-nix]
---

# Strategy: Future of Nix & Hermetic Computing (Determinate Systems)

## 1. User Layer (KISS)
Dieses Dokument fasst die wichtigsten technologischen Sprünge bei Nix zusammen, die von Determinate Systems (den Machern des modernen Nix-Installers) vorangetrieben werden. Es geht darum, wie Nix in Zukunft noch einfacher, schneller und sicherer wird – insbesondere durch die Integration von WebAssembly (Wasm) und eine bessere Verzahnung mit Cloud-Systemen. Für dich bedeutet das: Dein NixOS-Setup wird durch diese Standards noch langlebiger und robuster gegen externe Änderungen.

## 2. Technical Layer (Aviation-Grade)

### WebAssembly (Wasm) in Nix Builtins
Nix integriert Wasm direkt in die Sprache (`builtins.wasm`).
*   **Problem:** Bisher waren Nix-Funktionen oft langsam oder erforderten komplexe Plugins für spezialisierte Aufgaben.
*   **Lösung:** Hochperformante Logik (z.B. Parser, Kryptographie) kann in Sprachen wie Rust geschrieben, zu Wasm kompiliert und direkt in Nix-Files ausgeführt werden.
*   **Vorteil für mynixos:** Zukünftige Module für Identitätsprüfung oder Hardware-Validierung können als Wasm-Blobs direkt im Flake mitgeliefert werden, ohne dass der Server Compiler-Tools vorhalten muss (passt perfekt zu deinem **Binary-only** Prinzip).

### Die Determinate Nix Strategie
Determinate Systems treibt eine stabilere, weniger fragmentierte Version von Nix voran:
*   **Hermeticity:** Nix soll noch stärker garantieren, dass ein Build *überall* exakt gleich ist, unabhängig von Umgebungsvariablen oder dem Host-System.
*   **Flake-First:** Flakes werden nicht mehr als "experimental" gesehen, sondern als der einzige Standard für moderne Distributionen.
*   **Zero-Config Install:** Der Installer automatisiert die Einrichtung von Caches und SSL-Zertifikaten, was die "Henne-Ei"-Problematik bei der Erstinstallation (Bootstrap) entschärft.

## 3. Reasoning Layer (History)

### [ADR-005] Adoption of Hermetic Principles
*   **Status:** Beobachtung / Strategische Ausrichtung.
*   **Kontext:** NixOS entwickelt sich weg von einer "Bastel-Distro" hin zu einem industrietauglichen Framework für deklarative Infrastruktur.
*   **Entscheidung:** Wir richten das **mynixos-Projekt** konsequent an den Standards von Determinate Systems aus (Flake-basiert, Binary-only, keine lokalen Side-Effects).
*   **Konsequenzen:** Wir priorisieren Lösungen, die ohne lokale Kompilierung auskommen. Die Wasm-Entwicklung wird beobachtet, um sie für zukünftige Identity-Module (z.B. FIDO2-Validierung in Nix) einzusetzen.

---
**Sources:**
*   `https://determinate.systems/blog/determinate-nix-future/`
*   `https://determinate.systems/blog/builtins-wasm/`
