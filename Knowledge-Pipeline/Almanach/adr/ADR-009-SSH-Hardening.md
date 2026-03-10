# [ADR-009]: Aviation-Grade SSH-Hardening
# ID: [NUGGET-SSH-001] | Status: PROPOSED | Stand: 10.03.2026

## 1. Context (User Layer)
SSH ist die einzige Tür zu unserem Server. Standard-Konfigurationen lassen oft veraltete Verschlüsselungen zu, die theoretisch knackbar sind (Legacy). Wir wollen ein "Paranoia-Level", das nur modernste Kryptografie erlaubt.

## 2. Decision (Technical Layer)
Wir schränken die Algorithmen auf das absolute Minimum ein. Nur Ed25519 und Curve25519 sind erlaubt. Keine Passwörter, keine Root-Logins.

### 2.1 Empfohlene NixOS Konfiguration (Werkstatt)
```nix
services.openssh = {
  enable = true;
  settings = {
    # 🛡️ Algorithmus-Härtung (SSH-Audit Standard)
    KexAlgorithms = [
      "curve25519-sha256@libssh.org"
      "curve25519-sha256"
    ];
    Ciphers = [
      "chacha20-poly1305@openssh.com"
      "aes256-gcm@openssh.com"
      "aes128-gcm@openssh.com"
    ];
    Macs = [
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
    ];

    # 🛡️ General Hardening
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
    MaxAuthTries = 3;
    LoginGraceTime = 20;
  };
};
```

## 3. Reasoning (Reasoning Layer)
- **Warum diese Ciphers?** AES-GCM und ChaCha20 sind modern, schnell und gegen viele Seitenkanalangriffe immun.
- **Warum kein SHA-1?** Veraltet und unsicher (Kollisionsangriffe).
- **Abgelehnt (Rejected):** RSA-Keys < 4096 Bit. Wir erzwingen Ed25519 (Goldstandard).

---
> [SOURCE]: https://github.com/arthepsy/ssh-audit
> [CONVERSION]: Veredelt aus Erzmine/03-RESOURCES/external-sources/MANIFEST_NEW_SOURCES.md
