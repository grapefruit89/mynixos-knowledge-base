---
title: 🖥️ Windows to Nix SSH (Cross-Platform SRE)
category: architecture/administration
status: [ACTIVE-SSoT]
capabilities: [ssh-config, windows-openssh, ease-of-use]
sources: [OpenSSH Documentation, Internal SRE Standard]
---

# 🖥️ Windows to Nix: Der nahtlose Admin-Zugang

In mynixos nutzen wir die native OpenSSH Integration von Windows, um den Tower komfortabel zu steuern.

## 📁 Speicherort der Konfiguration
Die Konfigurationsdatei befindet sich unter:
\`%USERPROFILE%\.ssh\config\`

## 🧩 Inhalt der Datei
Um den Alias \`ssh nix\` zu aktivieren, muss folgender Block in die Datei:

\`\`\`text
Host nix
    HostName 192.168.2.250
    User root
    Port 53844
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
\`\`\`

## 🚀 Der SRE-Vorteil
- **Einheitlichkeit:** Egal ob du von Windows, Linux oder Mac arbeitest – der Befehl ist immer \`ssh nix\`.
- **Geschwindigkeit:** Keine Eingabe von Passwörtern, Ports oder IPs nötig.
- **Sicherheit:** Der SSH-Key (\`id_ed25519\`) bleibt dein einziger, sicherer Zugangsschlüssel.