#!/bin/bash
# Works on macOS (tested on bash 3.2+ and zsh), no GNU dependencies required
set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🔍 Dry run mode enabled — no changes will be written"
fi

rewrite_commit_message() {
  local msg="$1"
  msg="$(echo "$msg" | sed "s/^[[:space:]]*//" | sed "s/[[:space:]]*$//")"

  # Detect conventional commit pattern
  if [[ "$msg" =~ ^(feat|fix|ci|docs|chore|refactor)(\([^)]*\))?:[[:space:]] ]]; then
    echo "$msg"
    return
  fi

  # Init commit
  if [[ "$msg" =~ ^[Ii]nit[[:space:]]commit$ ]]; then
    echo "chore: initial commit"
    return
  fi

  # Pattern: something: message
  if [[ "$msg" =~ ^([a-zA-Z0-9._-]+):[[:space:]](.+) ]]; then
    component="${BASH_REMATCH[1]}"
    rest="${BASH_REMATCH[2]}"
    type="chore"

    if echo "$rest" | grep -iqE "fix|correct|tidy"; then
      type="fix"
    elif echo "$rest" | grep -iqE "init|add|new"; then
      type="feat"
    fi

    echo "$type($component): $rest"
    return
  fi

  # Fallbacks
  if echo "$msg" | grep -q README; then
    echo "docs: $msg"
  elif echo "$msg" | grep -q .gitignore; then
    echo "chore: update .gitignore"
  elif echo "$msg" | grep -q "^update"; then
    echo "chore: $msg"
  else
    echo "chore: $msg"
  fi
}

if $DRY_RUN; then
  echo "📜 Preview of rewritten commit messages:"
  git log --reverse --pretty=format:'%H|%s' | while IFS='|' read -r hash message; do
    new_msg=$(rewrite_commit_message "$message")
    if [[ "$message" != "$new_msg" ]]; then
      printf "🔁 %s\n➡️  %s\n\n" "$message" "$new_msg"
    else
      printf "✅ %s (unchanged)\n\n" "$message"
    fi
  done
else
  echo "🛠 Rewriting commit history (will require force push)..."

  git filter-branch --msg-filter '
    read msg
    msg="$(echo "$msg" | sed "s/^[[:space:]]*//" | sed "s/[[:space:]]*$//")"

    if echo "$msg" | grep -Eq "^(feat|fix|ci|docs|chore|refactor)(\([^)]*\))?:[[:space:]]"; then
      echo "$msg"
      exit
    fi

    if echo "$msg" | grep -iq "^init commit$"; then
      echo "chore: initial commit"
      exit
    fi

    if echo "$msg" | grep -Eq "^([a-zA-Z0-9._-]+): "; then
      component=$(echo "$msg" | cut -d: -f1)
      rest=$(echo "$msg" | cut -d: -f2- | sed "s/^ //")

      if echo "$rest" | grep -iqE "fix|correct|tidy"; then
        type="fix"
      elif echo "$rest" | grep -iqE "init|add|new"; then
        type="feat"
      else
        type="chore"
      fi

      echo "$type($component): $rest"
      exit
    fi

    if echo "$msg" | grep -q README; then
      echo "docs: $msg"
    elif echo "$msg" | grep -q .gitignore; then
      echo "chore: update .gitignore"
    elif echo "$msg" | grep -q "^update"; then
      echo "chore: $msg"
    else
      echo "chore: $msg"
    fi
  ' -- --all

  echo "✅ Rewrite complete — don't forget to: git push --force"
fi
