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
    # Option 1: Check for PR.txt
    pr_file = package_dir / "PR.txt"
    if pr_file.exists():
        pr_number = pr_file.read_text().strip()
        print(f"Found PR number {pr_number} in PR.txt for {package_dir.name}")
        return pr_number

    # Option 2: Look in default.nix
    default_nix = package_dir / "default.nix"
    if default_nix.exists():
        content = default_nix.read_text()
        # Look for common PR mentions in comments like "# PR: 123456" or "# nixpkgs PR: 123456"
        pr_match = re.search(
            r"#\s*(?:nixpkgs\s*)?PR[:\s]+(\d+)", content, re.IGNORECASE
        )
        if pr_match:
            pr_number = pr_match.group(1)
            print(
                f"Found PR number {pr_number} in default.nix comments for {package_dir.name}"
            )
            return pr_number

    # Option 3: Check for .pr file
    pr_hidden_file = package_dir / ".pr"
    if pr_hidden_file.exists():
        pr_number = pr_hidden_file.read_text().strip()
        print(f"Found PR number {pr_number} in .pr file for {package_dir.name}")
        return pr_number

    print(f"No PR number found for {package_dir.name}")
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
        # Create a request with a user agent to avoid GitHub API limitations
        req = urllib.request.Request(url, headers={"User-Agent": "NixPkgs-PR-Checker"})

        # Print debug info
        print(f"Fetching PR status for #{pr_number} from {url}")

        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())

            # Debug: Print the response
            print(
                f"API Response for PR #{pr_number}: {json.dumps(data, indent=2)[:500]}..."
            )

            # Check if PR is merged
            merged = data.get("merged", False)

            # Get the current state (open, closed)
            state = data.get("state", "unknown")

            # Determine status text
            if merged:
                status = "merged"
            elif state == "open":
                status = "open"
            elif state == "closed":
                status = "closed"
            else:
                status = "unknown"

            print(f"PR #{pr_number} status: {status}, merged: {merged}")
            return status, merged
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"PR #{pr_number} not found (404)")
            return "not found", False
        elif e.code == 403:
            print(f"Rate limit exceeded when checking PR #{pr_number}")
            return "rate limited", False
        else:
            print(f"HTTP Error {e.code} fetching PR #{pr_number}: {e}")
            return "error", False
    except Exception as e:
        print(f"Error fetching PR status for #{pr_number}: {e}")
        return "error", False


def get_pr_links_and_status(pr_number):
    """Generate PR and tracker links if PR number is available, and fetch PR status"""
    if not pr_number:
        return "", "", ""

    pr_link = f"[PR #{pr_number}](https://github.com/NixOS/nixpkgs/pull/{pr_number})"
    tracker_link = f"[Tracker](https://nixpkgs-tracker.ocfox.me/?pr={pr_number})"

    # Get PR status
    status, merged = get_pr_status(pr_number)

    # Create status text with emoji
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

    print(f"Final status for PR #{pr_number}: {status_text}")
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

    # Platforms
    platforms_match1 = re.findall(
        r"platforms\s*=\s*platforms\.([a-zA-Z0-9_]+)", content
    )
    platforms_match2 = re.findall(r"platforms\s*=\s*\[(.*?)\]", content, re.DOTALL)
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

    # Find PR number and create links
    pr_number = find_pr_number(package_dir)
    pr_link, tracker_link, status = get_pr_links_and_status(pr_number)

    return (
        pname,
        version,
        description,
        license_,
        platforms,
        homepage,
        changelog,
        pr_link,
        tracker_link,
        status,
    )


def generate_table():
    rows = []
    print(f"Scanning packages in {PKG_PATH}")

    for default_nix in PKG_PATH.glob("*/default.nix"):
        print(f"\nProcessing package: {default_nix.parent.name}")
        fields = extract_fields(default_nix)
        rows.append(fields)

    # Sort rows by pname (case-insensitive)
    rows.sort(key=lambda row: row[0].lower())
    print(f"\nGenerated table with {len(rows)} packages")

    # Start with the marker
    lines = [START_MARKER]

    # Add the header row with proper formatting
    lines.append(
        "| Package | Version | Description | License | Platforms | Homepage | Changelog | PR | Tracker | Status |"
    )
    lines.append(
        "|---------|---------|-------------|---------|-----------|----------|-----------|----|---------|---------|\n"
    )

    # Add each package row with proper newlines between rows
    for row in rows:
        package_line = f"| {row[0]} | {row[1]} | {row[2]} | {row[3]} | {row[4]} | {row[5]} | {row[6]} | {row[7]} | {row[8]} | {row[9]} |"
        lines.append(package_line)

    # End with the marker
    lines.append(END_MARKER)

    # Join with newlines to ensure proper markdown table formatting
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

    # Write the updated content
    README_PATH.write_text(new_content)
    print(f"Updated README at {README_PATH}")


if __name__ == "__main__":
    print("Starting README table update process")
    table = generate_table()
    replace_readme_section(table)
    print("README table update completed")
