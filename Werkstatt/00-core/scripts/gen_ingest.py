import os

base_path = "/home/Knowledge-Pipeline/raw/mynixos"
files_to_ingest = [
    "00-core/storage.nix",
    "00-core/host-q958-hardware-profile.nix",
    "10-gateway/caddy.nix",
    "40-media/media-stack.nix",
    "40-media/service-media-services-common.nix",
    "90-policy/security-assertions.nix",
    "README.md"
]

combined_markdown = "# MyNixOS Deprecated Knowledge Ingestion\n\n"

for rel_path in files_to_ingest:
    full_path = os.path.join(base_path, rel_path)
    if os.path.exists(full_path):
        with open(full_path, "r") as f:
            content = f.read()
            ext = os.path.splitext(rel_path)[1][1:] or "text"
            combined_markdown += f"## File: {rel_path}\n\n```{ext}\n{content}\n```\n\n"
    else:
        print(f"Warning: File {full_path} not found.")

with open("/root/mynixos_ingest.md", "w") as out:
    out.write(combined_markdown)

print("Markdown for ingestion successfully generated at /root/mynixos_ingest.md")
