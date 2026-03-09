---
title: ADR-008: Admin Access Standard (SSH & ProxyJump)
status: [ACCEPTED]
category: architecture/administration
capabilities: [ed25519-keys, bastion-host, proxyjump, ssh-abstraction]
sources: [https://blog.ktz.me/ssh-tips-and-why-proxyjump-is-awesome/]
---

# 🏛️ ADR-008: Aviation-Grade SSH Management

## Kontext
Wir benötigen einen sicheren und bequemen Administrationszugang zum Tower, der dem Zero-Trust Prinzip folgt.

## Entscheidung
Wir implementieren den **SSH Abstraktions-Standard**:
1.  **Key-Type:** Ausschließlich **ED25519** Keys.
2.  **SSH Config:** Alle Host-Parameter (IP, Port, Identity) werden in \`~/.ssh/config\` abstrahiert.
3.  **ProxyJump:** Für Fernwartung von außerhalb des Tailnets nutzen wir das ProxyJump Pattern über einen dedizierten Bastion-Host.

## Begründung
- **Sicherheit:** Reduziert die Angriffsfläche am Router auf einen einzigen Punkt.
- **Ergonomie:** Vereinfacht komplexe Befehlsketten zu einem Wort (\`ssh tower\`).
- **Wartbarkeit:** Änderungen an Ports oder IPs müssen nur an einer Stelle (der Config) nachgeführt werden.

## Konsequenz
In \`modules/00-core/ssh.nix\` wird der SSH-Dienst auf dem Tower so konfiguriert, dass er Password-Auth verbietet und nur Keys akzeptiert.
