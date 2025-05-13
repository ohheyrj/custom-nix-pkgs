#!/usr/bin/env python3
import re
import os
from pathlib import Path

README_PATH = Path("README.md")
PKG_PATH = Path("pkgs")
START_MARKER = "<!--table:start-->"
END_MARKER = "<!--table:end-->"


def extract_fields(file_path):
    with open(file_path) as f:
        content = f.read()

    def extract(pattern, default="unknown"):
        match = re.search(pattern, content)
        return match.group(1).strip() if match else default

    pname = extract(r'\bpname\s*=\s*"([^"]+)"')
    version = extract(r'\bversion\s*=\s*"([^"]+)"')
    description = extract(r'description\s*=\s*"([^"]+)"')
    license_ = extract(r'license\s*=\s*licenses\.([a-zA-Z0-9_]+)')

    # Platforms
    platforms_match1 = re.findall(r'platforms\s*=\s*platforms\.([a-zA-Z0-9_]+)', content)
    platforms_match2 = re.findall(r'platforms\s*=\s*\[(.*?)\]', content, re.DOTALL)
    if platforms_match1:
        platforms = ", ".join(platforms_match1)
    elif platforms_match2:
        raw_items = platforms_match2[0]
        items = re.findall(r'"([^"]+)"', raw_items)
        platforms = ", ".join(items)
    else:
        platforms = "unknown"

    # Homepage and changelog links
    homepage_url = extract(r'homepage\s*=\s*"([^"]+)"', default=None)
    changelog_url = extract(r'changelog\s*=\s*"([^"]+)"', default=None)

    homepage = f"[homepage]({homepage_url})" if homepage_url else ""
    changelog = f"[changelog]({changelog_url})" if changelog_url else ""

    return pname, version, description, license_, platforms, homepage, changelog




def generate_table():
    rows = []

    for default_nix in PKG_PATH.glob("*/default.nix"):
        fields = extract_fields(default_nix)
        rows.append(fields)

    # Sort rows by pname (case-insensitive)
    rows.sort(key=lambda row: row[0].lower())

    lines = [
        START_MARKER,
        "| Package | Version | Description | License | Platforms | Homepage | Changelog |",
        "|---------|---------|-------------|---------|-----------|----------|-----------|"
    ]

    for row in rows:
        lines.append(
            f"| {row[0]} | {row[1]} | {row[2]} | {row[3]} | {row[4]} | {row[5]} | {row[6]} |"
        )

    lines.append(END_MARKER)
    return "\n".join(lines)



def replace_readme_section(new_table):
    content = README_PATH.read_text()

    pattern = re.compile(
        rf"{START_MARKER}.*?{END_MARKER}",
        re.DOTALL
    )

    new_content = pattern.sub(new_table, content)
    README_PATH.write_text(new_content)


if __name__ == "__main__":
    table = generate_table()
    replace_readme_section(table)