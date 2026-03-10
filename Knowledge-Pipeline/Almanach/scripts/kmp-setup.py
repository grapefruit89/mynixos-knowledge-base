#!/usr/bin/env python3
"""
KMP - Knowledge Management Pipeline Setup Tool
"""

import os
import sys
import json
import zipfile
import hashlib
from pathlib import Path
from datetime import datetime
import urllib.request
import urllib.error

R   = "\033[0m"
B   = "\033[1m"
DIM = "\033[2m"
C   = "\033[36m"
G   = "\033[32m"
Y   = "\033[33m"
RD  = "\033[31m"
M   = "\033[35m"
BL  = "\033[34m"

def cls():
    os.system("clear" if os.name != "nt" else "cls")

def hr(w=60): return "─" * w

def header():
    cls()
    print(f"\n{C}{B}")
    print("  ╔═══════════════════════════════════════════════════╗")
    print("  ║      KMP · Knowledge Management Pipeline         ║")
    print("  ║      Setup & Struktur-Generator                  ║")
    print("  ╚═══════════════════════════════════════════════════╝")
    print(f"{R}")

def step(n, t, title):
    print(f"\n{DIM}{hr()}{R}")
    print(f"  {C}{B}Schritt {n}/{t}{R}  {B}{title}{R}")
    print(f"{DIM}{hr()}{R}\n")

def ok(m):   print(f"  {G}✓{R}  {m}")
def info(m): print(f"  {C}→{R}  {m}")
def warn(m): print(f"  {Y}⚠{R}  {m}")
def err(m):  print(f"  {RD}✗{R}  {m}")
def ask(m):  return input(f"\n  {M}?{R}  {B}{m}{R}  › ").strip()
def ask_yn(m, d="j"):
    h = f"[{B}J{R}/n]" if d=="j" else f"[j/{B}N{R}]"
    r = input(f"\n  {M}?{R}  {B}{m}{R} {h}  › ").strip().lower()
    if not r: return d=="j"
    return r in ("j","ja","y","yes")

# Explizite Ordnerliste – kein rekursiver Dict-Chaos
ORDNER = [
    "raw/chats",
    "raw/notes",
    "raw/scripts",
    "raw/repos/adr",
    "raw/repos/services",
    "raw/repos/_zips",
    "raw/_duplikate",
    "docs/ADRs",
    "docs/services",
    "docs/learnings",
    "docs/snippets",
    "docs/chats",
    "docs/notes",
    "index",
]

READMES = {
    "raw/chats/README.md": "# Chats\n\nClaude/ChatGPT Exports ablegen.\nclaude.ai → Settings → Export Data → JSON\n",
    "raw/notes/README.md": "# Notizen\n\nJot-Logs, Markdown-Notizen, Textdateien.\n",
    "raw/scripts/README.md": "# Scripts\n\nEigene .py, .sh, .nix Dateien.\n",
    "raw/repos/adr/README.md": "# ADR-Repositories\n\nArchitektur-Referenz-Repos:\n- nixpkgs, nixarr, nixflix, pms-wiki\n",
    "raw/repos/services/README.md": "# Service-Repositories\n\nService-Repos:\n- audiobookshelf, jellyfin, vaultwarden, pocket-id\n",
    "raw/_duplikate/README.md": "# Duplikate-Quarantäne\n\nNIE löschen – nur verschieben!\nFormat: DATEINAME.HASH.dup\n",
    "docs/ADRs/README.md": "# Architecture Decision Records\n\nFormat: ADR-NNN-titel.md\n\n## Felder\n- Kontext\n- Entscheidung\n- Begründung\n- Verworfene Alternativen\n- Quellen\n",
    "docs/learnings/README.md": "# Negative Erfahrungen\n\nWas nicht funktioniert hat und warum.\n",
    "docs/services/README.md": "# Service-Dokumentation\n\nPro-Service eine Datei:\nservice-name.md mit API, Einstellungen, Nix-Options.\n",
}

CHUNK_SCRIPT = '''#!/usr/bin/env python3
"""KMP Chunk-Processor: raw/ → docs/"""

import re, json, hashlib
from pathlib import Path
from datetime import datetime
from collections import Counter

BASIS = Path(__file__).parent
RAW   = BASIS / "raw"
DOCS  = BASIS / "docs"
DUPS  = RAW / "_duplikate"

STOPWORDS = {
    "der","die","das","ein","eine","und","oder","aber","ist","sind",
    "war","wird","hat","haben","ich","du","er","sie","es","wir","mit",
    "von","zu","in","an","auf","bei","nach","the","and","for","that",
    "this","with","from","are","was","have","been","will","not","but",
}

def tokenize(t):
    t = re.sub(r"[^a-z0-9äöüß]", " ", t.lower())
    return [w for w in t.split() if len(w)>3 and w not in STOPWORDS]

def label(text, n=3):
    freq = Counter(tokenize(text))
    top  = [w for w,_ in freq.most_common(n)]
    return "_".join(top) if top else "unknown"

_hashes = set()
def ist_dup(text):
    h = hashlib.sha256(text.encode()).hexdigest()[:10]
    if h in _hashes: return True, h
    _hashes.add(h); return False, h

def schreibe(text, quelle, kat, idx=0):
    dup, h = ist_dup(text)
    if dup:
        (DUPS / f"{Path(quelle).stem}_{h}.dup.md").write_text(text)
        return False
    name = f"{datetime.now().strftime('%Y-%m-%d')}_{label(text)}_{h}.md"
    ziel = DOCS / kat
    ziel.mkdir(parents=True, exist_ok=True)
    header = f"---\\nquelle: {quelle}\\nhash: {h}\\n---\\n\\n"
    (ziel / name).write_text(header + text)
    return True

def prozess_chat(pfad):
    try: data = json.loads(pfad.read_text(encoding="utf-8"))
    except: return 0
    n = 0
    msgs = []
    if isinstance(data, list):
        for conv in data:
            for msg in conv.get("chat_messages", []):
                t = msg.get("text","")
                if len(t)>50: msgs.append(t)
    for t in msgs:
        if schreibe(t, str(pfad), "chats"): n+=1
    return n

def prozess_md(pfad, kat):
    text = pfad.read_text(encoding="utf-8", errors="ignore")
    if len(text)<500:
        return 1 if schreibe(text, str(pfad), kat) else 0
    teile = re.split(r"^#{1,3} .+", text, flags=re.MULTILINE)
    n = 0
    for i,t in enumerate(teile):
        if len(t.strip())>50:
            if schreibe(t.strip(), str(pfad), kat, i): n+=1
    return n

def prozess_code(pfad):
    text = pfad.read_text(encoding="utf-8", errors="ignore")
    return 1 if schreibe(text, str(pfad), "snippets") else 0

def prozess_repo(repo_dir, kat):
    n = 0
    for p in repo_dir.rglob("*"):
        if not p.is_file(): continue
        s = p.suffix.lower()
        if s in (".md",".txt"): n += prozess_md(p, kat)
        elif s in (".nix",".py",".sh",".yaml",".yml"): n += prozess_code(p)
    return n

def main():
    print("\\n  KMP Chunk-Processor")
    print("  " + "─"*40)
    gesamt = 0

    print("\\n  → Chats…")
    for p in (RAW/"chats").rglob("*.json"): gesamt += prozess_chat(p)
    for p in (RAW/"chats").rglob("*.md"):   gesamt += prozess_md(p,"chats")

    print("  → Notizen…")
    for p in (RAW/"notes").rglob("*"):
        if p.is_file() and p.suffix in (".md",".txt"):
            gesamt += prozess_md(p,"notes")

    print("  → Scripts…")
    for p in (RAW/"scripts").rglob("*"):
        if p.is_file() and p.suffix in (".py",".sh",".nix",".yaml"):
            gesamt += prozess_code(p)

    print("  → ADR-Repos…")
    for d in (RAW/"repos"/"adr").iterdir():
        if d.is_dir():
            c = prozess_repo(d,"ADRs")
            print(f"    {d.name}: {c} Chunks")
            gesamt += c

    print("  → Service-Repos…")
    for d in (RAW/"repos"/"services").iterdir():
        if d.is_dir():
            c = prozess_repo(d,"services")
            print(f"    {d.name}: {c} Chunks")
            gesamt += c

    print(f"\\n  ✓ {gesamt} Chunks → docs/")
    print(f"  Suche: python search.py \\"dein begriff\\"\\n")

if __name__ == "__main__": main()
'''

SEARCH_SCRIPT = '''#!/usr/bin/env python3
"""KMP Suche"""

import sys
from pathlib import Path
from collections import Counter

BASIS = Path(__file__).parent
DOCS  = BASIS / "docs"

def suche(query):
    begriffe = query.lower().split()
    treffer  = []
    for pfad in DOCS.rglob("*.md"):
        text  = pfad.read_text(encoding="utf-8", errors="ignore")
        tl    = text.lower()
        score = sum(tl.count(b) for b in begriffe)
        if score > 0:
            zeilen   = [z.strip() for z in text.split("\\n") if z.strip()]
            vorschau = next(
                (z for z in zeilen if any(b in z.lower() for b in begriffe) and len(z)>20),
                zeilen[0] if zeilen else ""
            )
            treffer.append((score, pfad, vorschau[:120]))
    return sorted(treffer, reverse=True)[:15]

if __name__ == "__main__":
    if len(sys.argv)<2:
        print("Verwendung: python search.py <begriffe>"); sys.exit(1)
    q       = " ".join(sys.argv[1:])
    treffer = suche(q)
    print(f"\\n  Suche: \\033[1m{q}\\033[0m  →  {len(treffer)} Treffer\\n")
    for score, pfad, vor in treffer:
        rel = pfad.relative_to(BASIS)
        print(f"  \\033[36m{rel}\\033[0m  \\033[2m[{score}]\\033[0m")
        print(f"  \\033[2m{vor}…\\033[0m\\n")
'''

def parse_github(url):
    url   = url.strip().rstrip("/")
    parts = url.replace("https://github.com/","").split("/")
    return (parts[0], parts[1]) if len(parts)>=2 else None

def download_repo(owner, repo, projekt_dir, kat):
    zip_dir = projekt_dir / "raw" / "repos" / "_zips"
    zip_dir.mkdir(parents=True, exist_ok=True)
    zip_pfad = zip_dir / f"{owner}_{repo}.zip"

    info(f"Lade {C}{owner}/{repo}{R}…")
    heruntergeladen = False
    for branch in ["main","master"]:
        url = f"https://github.com/{owner}/{repo}/archive/refs/heads/{branch}.zip"
        try:
            req = urllib.request.Request(url, headers={"User-Agent":"KMP/1.0"})
            with urllib.request.urlopen(req, timeout=30) as r:
                zip_pfad.write_bytes(r.read())
            heruntergeladen = True
            break
        except urllib.error.HTTPError as e:
            if e.code==404: continue
            err(f"HTTP {e.code}"); return False
        except Exception as e:
            err(str(e)); return False

    if not heruntergeladen:
        err(f"Nicht gefunden: {owner}/{repo}"); return False

    INKL = ["README","readme",".md",".nix",".txt",".yaml",".yml",
            "docs/","doc/","api/","config/","modules/","lib/",
            "swagger","openapi","CHANGELOG"]
    EXKL = ["node_modules/","dist/","build/",".github/","test/",
            "tests/","spec/","__pycache__/",".min.js",".min.css",
            "package-lock.json","yarn.lock",".png",".jpg",".gif",
            ".woff",".ttf",".zip",".tar"]

    ziel = projekt_dir / "raw" / "repos" / kat / f"{owner}_{repo}"
    ziel.mkdir(parents=True, exist_ok=True)

    try:
        with zipfile.ZipFile(zip_pfad) as zf:
            gefiltert = [
                n for n in zf.namelist()
                if not any(x in n for x in EXKL)
                and any(x in n for x in INKL)
            ]
            for f in gefiltert:
                try: zf.extract(f, ziel)
                except: pass
        zip_pfad.unlink()
        ok(f"{owner}/{repo} → raw/repos/{kat}/")
        return True
    except zipfile.BadZipFile:
        err("Ungültige ZIP"); return False

def repo_wizard(projekt_dir):
    print(f"\n  {DIM}GitHub-URLs eingeben (leer = fertig){R}")
    print(f"  {DIM}Bsp: https://github.com/rasmus-kirk/nixarr{R}\n")
    adr, srv = [], []
    while True:
        url = input(f"  {BL}URL{R}  › ").strip()
        if not url: break
        parsed = parse_github(url)
        if not parsed:
            warn("Ungültige URL – Format: https://github.com/owner/repo")
            continue
        owner, repo = parsed
        print(f"\n  Repo: {C}{B}{owner}/{repo}{R}")
        print(f"  {DIM}[1]{R} ADR-Referenz  {DIM}(nixarr, nixpkgs, pms-wiki…){R}")
        print(f"  {DIM}[2]{R} Service-Repo  {DIM}(audiobookshelf, jellyfin…){R}")
        w = input(f"\n  {M}?{R}  [1/2]  › ").strip()
        if w=="2":
            srv.append((owner,repo))
            info(f"Service: {owner}/{repo}")
        else:
            adr.append((owner,repo))
            info(f"ADR-Ref: {owner}/{repo}")
    return adr, srv

def main():
    header()

    # ── 1. Projektname ──────────────────────────────────────────
    step(1,4,"Projektname & Speicherort")
    name = ask("Projektname") or "mein-wissen"
    std  = str(Path.home() / name)
    pfad = ask(f"Speicherort  [{std}]") or std
    projekt_dir = Path(pfad).expanduser().resolve()

    if projekt_dir.exists():
        warn(f"Existiert bereits: {projekt_dir}")
        if not ask_yn("Trotzdem fortfahren?"): sys.exit(0)

    # ── 2. Ordnerstruktur ───────────────────────────────────────
    step(2,4,"Ordnerstruktur erstellen")
    info(f"Erstelle: {C}{projekt_dir}{R}\n")

    for ordner in ORDNER:
        (projekt_dir / ordner).mkdir(parents=True, exist_ok=True)
        ok(ordner)

    for rel, inhalt in READMES.items():
        ziel = projekt_dir / rel
        if not ziel.exists():
            ziel.write_text(inhalt)

    (projekt_dir / "chunk.py").write_text(CHUNK_SCRIPT)
    (projekt_dir / "chunk.py").chmod(0o755)
    ok("chunk.py")

    (projekt_dir / "search.py").write_text(SEARCH_SCRIPT)
    (projekt_dir / "search.py").chmod(0o755)
    ok("search.py")

    readme = f"""# {name}

Knowledge Management Pipeline

## Verwendung
```bash
# 1. Rohmaterial ablegen
#    Chats  → raw/chats/
#    Notizen → raw/notes/
#    Scripts → raw/scripts/

# 2. Verarbeiten
python chunk.py

# 3. Suchen
python search.py "nixarr jellyfin"
rg "sabnzbd" docs/
```

## Struktur
```
raw/          Rohmaterial (niemals bearbeiten)
docs/         Verarbeitete Chunks (durchsuchbar)
index/        Meilisearch / Vector Store
```
Erstellt: {datetime.now().strftime('%Y-%m-%d %H:%M')}
"""
    (projekt_dir / "README.md").write_text(readme)
    ok("README.md")

    # ── 3. GitHub Repos ─────────────────────────────────────────
    step(3,4,"GitHub Repositories")
    print(f"  {DIM}Jetzt hinzufügen oder später manuell.{R}")

    if ask_yn("Repositories jetzt herunterladen?"):
        adr, srv = repo_wizard(projekt_dir)
        total = len(adr)+len(srv)
        if total:
            print(f"\n  {B}Lade {total} Repo(s)…{R}\n")
            for o,r in adr: download_repo(o,r,projekt_dir,"adr")
            for o,r in srv: download_repo(o,r,projekt_dir,"services")
        else:
            info("Keine URLs – übersprungen")
    else:
        info("Übersprungen")

    # ── 4. Fertig ───────────────────────────────────────────────
    step(4,4,"Fertig!")
    ok(f"Projekt: {C}{B}{projekt_dir}{R}")
    print(f"""
  {DIM}1.{R} Chat-Export:  {C}claude.ai → Settings → Export Data{R}
         → {projekt_dir}/raw/chats/

  {DIM}2.{R} Verarbeiten:  {C}cd {projekt_dir} && python chunk.py{R}

  {DIM}3.{R} Suchen:       {C}python search.py "dein begriff"{R}

  {DIM}{hr()}{R}
  {G}{B}Viel Erfolg!{R}
""")

if __name__=="__main__":
    try: main()
    except KeyboardInterrupt:
        print(f"\n\n  {Y}Abgebrochen.{R}\n"); sys.exit(0)
