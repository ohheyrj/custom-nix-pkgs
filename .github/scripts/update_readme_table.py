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
    platforms = ", ".join(re.findall(r'platforms\s*=\s*platforms\.([a-zA-Z0-9_]+)', content))

    return pname, version, description, license_, platforms or "unknown"


def generate_table():
    rows = []

    for default_nix in PKG_PATH.glob("*/default.nix"):
        pname, version, description, license_, platforms = extract_fields(default_nix)
        rows.append((pname, version, description, license_, platforms))

    # Sort rows by pname (case-insensitive)
    rows.sort(key=lambda row: row[0].lower())

    lines = [
        START_MARKER,
        "| Package | Version | Description | License | Platforms |",
        "|---------|---------|-------------|---------|-----------|"
    ]

    for row in rows:
        lines.append(f"| {row[0]} | {row[1]} | {row[2]} | {row[3]} | {row[4]} |")

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