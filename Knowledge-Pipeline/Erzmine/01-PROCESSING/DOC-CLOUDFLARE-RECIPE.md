# [NUGGET] Cloudflare API Token Recipe (v14.2)
# Status: Stage 2 (Nugget) | Version: 1.1
# [META] ID: NIXH-KNOW-CLOUDFLARE-TOKEN | REQ_REFS: [v14.2]

## 1. ZWECK
Dieser Token dient der automatisierten Verwaltung der Infrastruktur (DNS, Tunnel, Zonen) durch Gemini CLI oder NixOS, ohne den gefährlichen "Global API Key" zu verwenden.

## 2. DAS REZEPT (Cloudflare Dashboard)
Falls du diesen Token jemals manuell neu erstellen musst:
1. Gehe zu: **User Profile -> API Tokens -> Create Token**.
2. Wähle: **Custom Token**.
3. **Name:** `Git-NixOS`
4. **Permissions:**
    - [Zone] [DNS] [Edit]
    - [Zone] [Zone] [Read]
    - [Account] [Cloudflare Tunnel] [Edit]
5. **Resources:**
    - [Include] [All zones]
    - [Include] [All accounts]

## 3. SPEICHERORT (GitHub)
Der Token wird NIEMALS im Code gespeichert. Er gehört in die **GitHub Actions Secrets**:
- Repository: `grapefruit89/mynixos-knowledge-base`
- Name: `CLOUDFLARE_API_TOKEN`

## 4. SICHERHEITSHINWEIS
Alle anderen Tokens bei Cloudflare sollten nun gelöscht werden. Der globale API-Key sollte im Dashboard geändert werden.
