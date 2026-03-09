import os

def generate_toc():
    docs_dir = "."
    guides_dir = os.path.join(docs_dir, "guides")
    adr_dir = os.path.join(docs_dir, "adr")
    output_file = os.path.join(docs_dir, "00_GOLDEN_HANDBOOK_Dendritic_NixOS.md")

    if not os.path.exists(output_file):
        with open(output_file, 'w') as f: f.write("# Temp")

    content = "# 📜 Das Goldene Handbuch: Dendritic NixOS\n\n"
    content += "Auto-generiert am: 2026-03-09\n\n"

    content += "## 🏛️ Architektur-Entscheidungen (ADRs)\n"
    if os.path.exists(adr_dir):
        adrs = sorted([f for f in os.listdir(adr_dir) if f.endswith(".md")])
        for i, adr in enumerate(adrs, 1):
            content += f"{i}. [**{adr.replace('.md', '').replace('-', ' ')}**](./adr/{adr})\n"

    content += "\n## 📚 Guides & Master-Configs\n"
    if os.path.exists(guides_dir):
        guides = sorted([f for f in os.listdir(guides_dir) if f.endswith(".md")])
        for i, guide in enumerate(guides, 1):
            content += f"{i}. [**{guide.replace('.md', '').replace('GUIDE-', '').replace('-', ' ')}**](./guides/{guide})\n"

    with open(output_file, "w") as f:
        f.write(content)

if __name__ == "__main__":
    generate_toc()
