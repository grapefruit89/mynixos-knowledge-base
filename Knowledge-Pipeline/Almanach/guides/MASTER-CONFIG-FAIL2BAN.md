---
title: 📚 Fail2ban MASTER-CONFIG-REFERENCE (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [https://github.com/fail2ban/fail2ban]
---

# 📚 Fail2ban: Die totale Kontrolle

Diese Liste enthält alle extrahierten Parameter aus den offiziellen Konfigurationsdateien.

## ⚙️ SRE-Anwendung
In NixOS steuern wir Fail2ban über \`services.fail2ban\`. Jede dieser Variablen kann in den \`jails\` oder \`extraContents\` genutzt werden.

### Extrahierte Parameter (Auszug):
/tmp/fail2ban/config/action.d/abuseipdb.conf:abuseipdb_apikey
/tmp/fail2ban/config/action.d/abuseipdb.conf:actionban
/tmp/fail2ban/config/action.d/abuseipdb.conf:actioncheck
/tmp/fail2ban/config/action.d/abuseipdb.conf:actionstart
/tmp/fail2ban/config/action.d/abuseipdb.conf:actionstop
/tmp/fail2ban/config/action.d/abuseipdb.conf:actionunban
/tmp/fail2ban/config/action.d/abuseipdb.conf:norestored
/tmp/fail2ban/config/action.d/apf.conf:actionban
/tmp/fail2ban/config/action.d/apf.conf:actioncheck
/tmp/fail2ban/config/action.d/apf.conf:actionstart
/tmp/fail2ban/config/action.d/apf.conf:actionstop
/tmp/fail2ban/config/action.d/apf.conf:actionunban
/tmp/fail2ban/config/action.d/apf.conf:name
/tmp/fail2ban/config/action.d/apprise.conf:actionban
/tmp/fail2ban/config/action.d/apprise.conf:actioncheck
/tmp/fail2ban/config/action.d/apprise.conf:actionstart
/tmp/fail2ban/config/action.d/apprise.conf:actionstop
/tmp/fail2ban/config/action.d/apprise.conf:actionunban
/tmp/fail2ban/config/action.d/apprise.conf:apprise
/tmp/fail2ban/config/action.d/apprise.conf:args
/tmp/fail2ban/config/action.d/apprise.conf:config
/tmp/fail2ban/config/action.d/blocklist_de.conf:actionban
/tmp/fail2ban/config/action.d/blocklist_de.conf:actioncheck
/tmp/fail2ban/config/action.d/blocklist_de.conf:actionstart
/tmp/fail2ban/config/action.d/blocklist_de.conf:actionstop
/tmp/fail2ban/config/action.d/blocklist_de.conf:actionunban
/tmp/fail2ban/config/action.d/blocklist_de.conf:norestored
/tmp/fail2ban/config/action.d/bsd-ipfw.conf:actionban
/tmp/fail2ban/config/action.d/bsd-ipfw.conf:actioncheck
/tmp/fail2ban/config/action.d/bsd-ipfw.conf:actionstart
/tmp/fail2ban/config/action.d/bsd-ipfw.conf:actionstop
/tmp/fail2ban/config/action.d/bsd-ipfw.conf:actionunban
/tmp/fail2ban/config/action.d/bsd-ipfw.conf:block
/tmp/fail2ban/config/action.d/bsd-ipfw.conf:blocktype
/tmp/fail2ban/config/action.d/bsd-ipfw.conf:lowest_rule_num
/tmp/fail2ban/config/action.d/bsd-ipfw.conf:port
/tmp/fail2ban/config/action.d/bsd-ipf... (Gekürzt für Handbuch-Übersicht)