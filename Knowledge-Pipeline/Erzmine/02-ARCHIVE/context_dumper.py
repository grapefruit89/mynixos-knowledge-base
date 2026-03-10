#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ULTIMATE CONTEXT DUMPER (Python Edition)
----------------------------------------
Funktion:
1. Scannt den Ziel-Ordner rekursiv (Standard: aktueller Ordner).
2. Erkennt Binärdateien automatisch.
3. Erstellt Statistik & Baumstruktur.
4. Exportiert den KOMPLETTEN Text-Inhalt in eine einzelne Datei.
"""

import os
import sys
import argparse
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# --- KONFIGURATION ---
OUTPUT_DIR = Path("/mnt/downloadcache/Taildrop")
BASE_FILENAME = "CTX_DUMP"

def is_binary(file_path):
    """Prüft auf Binärdatei (Null-Byte Check)."""
    try:
        with open(file_path, 'rb') as f:
            chunk = f.read(1024)
            return b'\0' in chunk
    except:
        return True

def format_size(size):
    power = 2**10
    n = size
    power_labels = {0 : '', 1: 'KB', 2: 'MB', 3: 'GB'}
    count = 0
    while n > power:
        n /= power
        count += 1
    return f"{n:.2f} {power_labels.get(count, 'TB')}"

def generate_tree(dir_path, prefix=""):
    tree_str = ""
    try:
        items = sorted(dir_path.iterdir(), key=lambda x: (not x.is_dir(), x.name.lower()))
        filtered = [i for i in items if not i.name.startswith('.') and i.name != '__pycache__']
        
        for i, item in enumerate(filtered):
            is_last = (i == len(filtered) - 1)
            connector = "└── " if is_last else "├── "
            if item.is_dir():
                tree_str += f"{prefix}{connector}📁 [{item.name.upper()}]\n"
                tree_str += generate_tree(item, prefix + ("    " if is_last else "│   "))
            else:
                tree_str += f"{prefix}{connector}📄 {item.name}\n"
    except PermissionError:
        tree_str += f"{prefix}└── 🚫 [ACCESS DENIED]\n"
    return tree_str

def main():
    # Argument Parser für Flexibilität
    parser = argparse.ArgumentParser(description="Dumps folder context for LLMs.")
    parser.add_argument("path", nargs="?", default=".", help="Ordner zum Scannen (Default: Aktueller Ordner)")
    args = parser.parse_args()

    target_dir = Path(args.path).resolve()
    
    if not target_dir.exists():
        print(f"❌ Fehler: Pfad nicht gefunden: {target_dir}")
        sys.exit(1)

    # Versionierung der Ausgabedatei
    if not OUTPUT_DIR.exists():
        try:
            os.makedirs(OUTPUT_DIR)
        except:
            pass # Fallback auf lokales Verzeichnis falls Taildrop fehlt

    final_output_dir = OUTPUT_DIR if OUTPUT_DIR.exists() else target_dir
    
    counter = 0
    clean_name = "".join(x for x in target_dir.name if x.isalnum() or x in "_-")
    while True:
        outfile_name = f"{clean_name}_{BASE_FILENAME}_{counter:06d}.txt"
        outfile_path = final_output_dir / outfile_name
        if not outfile_path.exists():
            break
        counter += 1

    print(f"🚀 Starte Scan von: {target_dir}")
    print(f"📂 Ziel-Datei: {outfile_path}")

    # Daten sammeln
    all_files_data = []
    stats_extensions = defaultdict(lambda: {'count': 0, 'size': 0})
    
    for root, dirs, files in os.walk(target_dir):
        dirs[:] = [d for d in dirs if not d.startswith('.')] # Hidden Dirs ignorieren
        
        for file in files:
            if file.startswith('.'): continue
            
            full_path = Path(root) / file
            rel_path = full_path.relative_to(target_dir)
            
            try:
                size = full_path.stat().st_size
                is_bin = is_binary(full_path)
                ext = full_path.suffix.lower() if full_path.suffix else "[no ext]"
                
                stats_extensions[ext]['count'] += 1
                stats_extensions[ext]['size'] += size
                
                all_files_data.append({
                    'path': rel_path,
                    'full_path': full_path,
                    'size': size,
                    'is_binary': is_bin,
                    'ext': ext
                })
            except Exception as e:
                print(f"⚠️ Fehler bei {file}: {e}")

    # Schreiben
    with open(outfile_path, 'w', encoding='utf-8') as f:
        f.write("="*80 + "\n")
        f.write(f"AI CONTEXT EXPORT\n")
        f.write(f"Datum:   {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Quelle:  {target_dir}\n")
        f.write(f"Dateien: {len(all_files_data)}\n")
        f.write("="*80 + "\n\n")

        # Statistik
        f.write("--- STATISTIK ---\n")
        f.write(f"{'TYPE':<10} | {'COUNT':<6} | {'SIZE':<10}\n")
        f.write("-" * 30 + "\n")
        for ext, data in sorted(stats_extensions.items(), key=lambda x: x[1]['count'], reverse=True):
            f.write(f"{ext:<10} | {data['count']:<6} | {format_size(data['size']):<10}\n")
        f.write("\n")

        # Baum
        f.write("--- STRUKTUR ---\n")
        f.write(generate_tree(target_dir))
        f.write("\n")

        # Inhalte
        f.write("--- INHALTE ---\n")
        for item in all_files_data:
            if not item['is_binary']:
                try:
                    content = item['full_path'].read_text(encoding='utf-8', errors='replace')
                    f.write(f"\n--- START {item['path']} ({format_size(item['size'])}) ---\n")
                    f.write(content)
                    if not content.endswith('\n'): f.write('\n')
                    f.write(f"--- ENDE  {item['path']} ---\n")
                except:
                    pass

    print(f"✅ FERTIG! Datei gespeichert:\n👉 {outfile_path}")

if __name__ == "__main__":
    main()
