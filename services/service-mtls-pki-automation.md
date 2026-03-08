# Service: mTLS PKI Automation (Zero-Touch Certs)

## 1. User Layer (KISS)
Dieses Dokument beschreibt dein privates "Zertifikats-Amt". Wenn du ein neues Handy oder einen neuen Laptop hast und auf deinen Server zugreifen willst, führst du ein kurzes Kommando aus. Der Server erstellt sofort ein digitales Ausweis-Zertifikat und gibt dir einen Download-Link. Sobald du das Zertifikat auf deinem Gerät installiert hast, lässt dich der Server ohne Passwort rein – alle anderen ohne Zertifikat sehen nicht einmal die Login-Seite.

## 2. Technical Layer (Aviation-Grade)

### PKI-Struktur & Automatisierung
*   **Root-CA:** 4096-bit RSA (Gültigkeit: 10 Jahre). Gespeichert unter `/etc/nixos/secrets/mtls/`.
*   **Client-Zertifikate:** 2048-bit RSA (Gültigkeit: 1 Jahr).
*   **Export-Format:** PKCS#12 (`.p12`) – enthält Client-Key, Client-Cert und CA-Chain.

### Operativer Workflow (`mtls-generator.sh`)
1.  **Aufruf:** `bash mtls-generator.sh my-iphone`
2.  **Bereitstellung:** Das Skript verschiebt die `.p12` Datei nach `/var/www/landing-zone/certs/`.
3.  **Download:** Abruf via `https://nix.m7c5.de/certs/my-iphone.p12`.
4.  **Sicherung:** Der Zugriff auf das Certs-Verzeichnis sollte im Caddy-Proxy auf lokale IPs beschränkt sein.

### Integration in Caddy (M1 Abrams Snippet)
```caddy
(mtls_auth) {
    tls {
        client_auth {
            mode require_and_verify
            trust_pool file /etc/nixos/secrets/mtls/ca.crt
        }
    }
}
```

## 3. Reasoning Layer (History)

### [ADR-020] Custom OpenSSL PKI vs. Step-CA
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Eine vollwertige CA (wie Smallstep) benötigt einen permanent laufenden Daemon und signifikante Ressourcen.
*   **Entscheidung:** Nutzung eines minimalistischen Bash-Wrappers um OpenSSL.
*   **Vorteile:** Null Overhead, keine zusätzliche Angriffsfläche durch laufende Dienste, volle Kontrolle über die CA-Keys im Dateisystem.
*   **Verbesserungspotenzial:** Zukünftige Migration auf **Ed25519** Kurven zur Performance-Steigerung und Verkürzung der Schlüssellängen.

---
**Sources:**
*   `00-core/scripts/mtls-generator.sh`
*   `10-gateway/caddy.nix`
