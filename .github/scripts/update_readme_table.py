#!/usr/bin/env python3
import json
import os
import re
import urllib.request
from pathlib import Path

README_PATH = Path("README.md")
PKG_PATH = Path("pkgs")
START_MARKER = "<!--table:start-->"
END_MARKER = "<!--table:end-->"

# GitHub API constants
GITHUB_API_BASE = "https://api.github.com"
GITHUB_REPO = "NixOS/nixpkgs"


def find_pr_number(package_dir):
    """
    Try to find the PR number associated with the package:
    1. Check for a PR.txt file
    2. Look in default.nix for PR mentions
    3. Check for .pr file
    """
    pr_file = package_dir / "PR.txt"
    if pr_file.exists():
        pr_number = pr_file.read_text().strip()
        return pr_number

    default_nix = package_dir / "default.nix"
    if default_nix.exists():
        content = default_nix.read_text()
        pr_match = re.search(
            r"#\s*(?:nixpkgs\s*)?PR[:\s]+(\d+)", content, re.IGNORECASE
        )
        if pr_match:
            pr_number = pr_match.group(1)
            return pr_number

    pr_hidden_file = package_dir / ".pr"
    if pr_hidden_file.exists():
        pr_number = pr_hidden_file.read_text().strip()
        return pr_number

    return None


def get_pr_status(pr_number):
    """
    Fetch the PR status from GitHub API.
    Returns a tuple of (status, merged)
    """
    if not pr_number:
        return None, False

    try:
        url = f"{GITHUB_API_BASE}/repos/{GITHUB_REPO}/pulls/{pr_number}"
        req = urllib.request.Request(url, headers={"User-Agent": "NixPkgs-PR-Checker"})

        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            merged = data.get("merged", False)
            state = data.get("state", "unknown")

            if merged:
                status = "merged"
            elif state == "open":
                status = "open"
            elif state == "closed":
                status = "closed"
            else:
                status = "unknown"

            return status, merged
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return "not found", False
        elif e.code == 403:
            return "rate limited", False
        else:
            return "error", False
    except Exception:
        return "error", False


def get_pr_links_and_status(pr_number):
    """Generate PR and tracker links if PR number is available, and fetch PR status"""
    if not pr_number:
        return "", "", ""

    pr_link = f"[PR #{pr_number}][pkg-pr-{pr_number}]"
    tracker_link = f"[Tracker][pkg-tracker-{pr_number}]"

    status, merged = get_pr_status(pr_number)

    if status == "merged":
        status_text = "✅ Merged"
    elif status == "open":
        status_text = "🔄 Open"
    elif status == "closed":
        status_text = "❌ Closed"
    elif status == "not found":
        status_text = "❓ Not Found"
    elif status == "rate limited":
        status_text = "⚠️ API Limited"
    elif status == "error":
        status_text = "⚠️ API Error"
    else:
        status_text = "❓ Unknown"

    return pr_link, tracker_link, status_text


def extract_fields(file_path):
    package_dir = file_path.parent
    with open(file_path) as f:
        content = f.read()

    def extract(pattern, default="unknown"):
        match = re.search(pattern, content)
        return match.group(1).strip() if match else default

    pname = extract(r'\bpname\s*=\s*"([^"]+)"')
    version = extract(r'\bversion\s*=\s*"([^"]+)"')
    description = extract(r'description\s*=\s*"([^"]+)"')
    license_ = extract(r"license\s*=\s*licenses\.([a-zA-Z0-9_]+)")

    platforms_match1 = re.findall(
        r"platforms\s*=\s*platforms\.([a-zA-Z0-9_]+)", content
    )
    platforms_match2 = re.findall(r"platforms\s*=\s*\[(.*?)\]", content, re.DOTALL)
    platforms = (
        ", ".join(platforms_match1)
        if platforms_match1
        else (
            ", ".join(re.findall(r'"([^"]+)"', platforms_match2[0]))
            if platforms_match2
            else "unknown"
        )
    )

    homepage_url = extract(r'homepage\s*=\s*"([^"]+)"', default=None)
    changelog_url = extract(r'changelog\s*=\s*"([^"]+)"', default=None)

    pr_number = find_pr_number(package_dir)
    pr_link, tracker_link, status = get_pr_links_and_status(pr_number)

    homepage_ref = f"[homepage][pkg-homepage-{pname}]"
    changelog_ref = f"[changelog][pkg-changelog-{pname}]" if changelog_url else ""
    pr_ref = pr_link if pr_number else ""
    tracker_ref = tracker_link if pr_number else ""

    link_defs = []
    if homepage_url:
        link_defs.append(f"[pkg-homepage-{pname}]: {homepage_url}")
    if changelog_url:
        link_defs.append(f"[pkg-changelog-{pname}]: {changelog_url}")
    if pr_number:
        link_defs.append(
            f"[pkg-pr-{pname}]: https://github.com/NixOS/nixpkgs/pull/{pr_number}"
        )
        link_defs.append(
            f"[pkg-tracker-{pname}]: https://nixpkgs-tracker.ocfox.me/?pr={pr_number}"
        )

    return (
        pname,
        version,
        description,
        license_,
        platforms,
        homepage_ref,
        changelog_ref,
        pr_ref,
        tracker_ref,
        status,
        link_defs,
    )


def generate_table():
    rows = []
    link_defs = []
    print(f"Scanning packages in {PKG_PATH}")

    for default_nix in PKG_PATH.glob("*/default.nix"):
        print(f"\nProcessing package: {default_nix.parent.name}")
        fields = extract_fields(default_nix)
        (
            pname,
            version,
            description,
            license_,
            platforms,
            homepage_ref,
            changelog_ref,
            pr_ref,
            tracker_ref,
            status,
            package_link_defs,
        ) = fields
        rows.append(
            (
                pname,
                version,
                description,
                license_,
                platforms,
                homepage_ref,
                changelog_ref,
                pr_ref,
                tracker_ref,
                status,
            )
        )
        link_defs.extend(package_link_defs)

    rows.sort(key=lambda row: row[0].lower())
    print(f"\nGenerated table with {len(rows)} packages")

    lines = [START_MARKER]
    lines.append(
        "| Package | Version | Description | License | Platforms | Homepage | Changelog | PR | Tracker | Status |"
    )
    lines.append(
        "|---------|---------|-------------|---------|-----------|----------|-----------|----|---------|---------|\n"
    )

    for row in rows:
        package_line = f"| {row[0]} | {row[1]} | {row[2]} | {row[3]} | {row[4]} | {row[5]} | {row[6]} | {row[7]} | {row[8]} | {row[9]} |"
        lines.append(package_line)

    lines.append(END_MARKER)
    lines.append("")  # Empty line
    lines.extend(link_defs)

    return "\n".join(lines)


def replace_readme_section(new_table):
    content = README_PATH.read_text()

    pattern = re.compile(rf"{START_MARKER}.*?{END_MARKER}", re.DOTALL)

    new_content = pattern.sub(new_table, content)

    # Ensure proper line endings for GitHub markdown
    new_content = new_content.replace("\r\n", "\n")

    # Print a preview of what we're about to write
    print("\nPreview of updated README section:")
    table_section = pattern.search(new_content).group(0)
    print(table_section[:500] + "..." if len(table_section) > 500 else table_section)

    README_PATH.write_text(new_content)
    print(f"Updated README at {README_PATH}")


if __name__ == "__main__":
    print("Starting README table update process")
    table = generate_table()
    replace_readme_section(table)
    print("README table update completed")
