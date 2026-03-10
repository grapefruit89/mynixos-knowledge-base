#!/usr/bin/env python3
import os
import re
import json

# [ADR-030] Metadata-Tagging Standard (Agent-Only Tool)
# ID: [NUGGET-SRE-010] | Status: ACTIVE | Stand: 10.03.2026

INBOX_PATH = "/home/Knowledge-Pipeline/Erzmine/00-INBOX/"
ALMANACH_PATH = "/home/Knowledge-Pipeline/Almanach/"

def scan_for_tags(content):
    """Sucht nach IDs wie [NUGGET-XXX-001] oder ADR-IDs."""
    tags = re.findall(r'\[(NUGGET-[A-Z]+-\d+)\]', content)
    adrs = re.findall(r'ADR-\d+', content)
    return list(set(tags + adrs))

def generate_yaml_header(filename, tags):
    """Erstellt einen YAML-Header für die Veredelung."""
    header = "---\n"
    header += f"title: {filename}\n"
    header += f"tags: {json.dumps(tags)}\n"
    header += f"processed_by: Gemini-Agent\n"
    header += f"date: 2026-03-10\n"
    header += "---\n\n"
    return header

def process_inbox():
    print(f"⛏️ Schürfe in {INBOX_PATH}...")
    for root, dirs, files in os.walk(INBOX_PATH):
        for file in files:
            if file.endswith(".md"):
                file_path = os.path.join(root, file)
                with open(file_path, 'r') as f:
                    content = f.read()
                
                tags = scan_for_tags(content)
                if tags:
                    print(f"💎 Nugget gefunden in {file}: {tags}")
                    # Hier würde die Veredelung stattfinden
                else:
                    print(f"🟤 Rohdaten ohne Tags: {file}")

if __name__ == "__main__":
    process_inbox()
