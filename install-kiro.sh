#!/usr/bin/env bash
set -euo pipefail

# frontend-god-mode installer for Kiro
# Installs the skill into ~/.kiro/skills/frontend-god-mode (global, default)
# or ./.kiro/skills/frontend-god-mode (workspace, with --project)

SKILL_NAME="frontend-god-mode"
REPO_URL="https://github.com/quinnjr/frontend-god-mode"
SCOPE="global"

for arg in "$@"; do
  case "${arg}" in
    --project) SCOPE="project" ;;
    --global)  SCOPE="global" ;;
    -h|--help)
      echo "Usage: install-kiro.sh [--global | --project]"
      echo "  --global   Install to ~/.kiro/skills/ (default; every workspace, Kiro IDE only)"
      echo "  --project  Install to ./.kiro/skills/ (this workspace; works in Kiro IDE and Kiro CLI)"
      exit 0
      ;;
    *) echo "✗ Unknown option: ${arg} (try --help)"; exit 1 ;;
  esac
done

if [ "${SCOPE}" = "project" ]; then
  TARGET_DIR="$(pwd)/.kiro/skills/${SKILL_NAME}"
else
  TARGET_DIR="${HOME}/.kiro/skills/${SKILL_NAME}"
fi

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Installing frontend-god-mode for Kiro → ${TARGET_DIR}"
echo "═══════════════════════════════════════════════════"
echo ""

# If running from a checkout of the repo, copy from here; otherwise clone
if [ -f "./frontend-god-mode/SKILL.md" ]; then
  SOURCE_DIR="./frontend-god-mode"
elif command -v git >/dev/null 2>&1; then
  git clone --depth 1 "${REPO_URL}.git" "${TEMP_DIR}/repo" >/dev/null 2>&1 || {
    echo "✗ git clone failed. Clone ${REPO_URL} manually and run this script from the repo root."
    exit 1
  }
  SOURCE_DIR="${TEMP_DIR}/repo/frontend-god-mode"
else
  echo "✗ git not found. Clone ${REPO_URL} manually and run this script from the repo root."
  exit 1
fi

if [ ! -f "${SOURCE_DIR}/SKILL.md" ]; then
  echo "✗ Could not find skill source at ${SOURCE_DIR}"
  exit 1
fi

# Backup existing install
if [ -d "${TARGET_DIR}" ]; then
  BACKUP="${TARGET_DIR}.backup.$(date +%s)"
  echo "→ Existing install found. Backing up to ${BACKUP}"
  mv "${TARGET_DIR}" "${BACKUP}"
fi

mkdir -p "${TARGET_DIR}"
cp -R "${SOURCE_DIR}/." "${TARGET_DIR}/"

echo ""
echo "✓ Installed to ${TARGET_DIR}"
echo ""
echo "Next steps:"
echo "  1. If the skill doesn't appear in Kiro, reload the window"
echo "  2. Try: \"build me a landing page for a small-batch coffee roaster\""
echo "  3. Or run the setup wizard: \"use the frontend-god-mode skill to set up my project\""
echo ""
if [ "${SCOPE}" = "global" ]; then
  echo "Note: Kiro loads global skills in the IDE only. For Kiro CLI, re-run with"
  echo "--project from your workspace root."
  echo ""
fi
echo "Custom agents don't load skills automatically. Add this to the agent's"
echo "\"resources\" array to enable it there:"
if [ "${SCOPE}" = "project" ]; then
  echo "  \"skill://.kiro/skills/${SKILL_NAME}/SKILL.md\""
else
  echo "  \"skill://~/.kiro/skills/${SKILL_NAME}/SKILL.md\""
fi
echo ""
echo "Optional integrations (install when needed):"
echo "  • Motion:         <pm> add motion   (React, Svelte, Angular)"
echo "  • React Bits:     npx shadcn@latest add @react-bits/<Component>   (React)"
echo ""
