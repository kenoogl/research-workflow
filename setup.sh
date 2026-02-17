#!/usr/bin/env bash
set -euo pipefail

cp -r framework/templates/project/* .
cp framework/templates/codexrc .codexrc
cp framework/AGENTS.md AGENTS.md

ln -sf framework/hooks/pre-commit .git/hooks/pre-commit
chmod +x framework/hooks/pre-commit

dest_dir=".codex/skills/notes-updater"
dest_file="${dest_dir}/SKILL.md"
mkdir -p "${dest_dir}"

src_file=""
if [[ -f "framework/templates/SKILLS/notes-updater/SKILL.md" ]]; then
  src_file="framework/templates/SKILLS/notes-updater/SKILL.md"
elif [[ -f "framework/templates/project/notes-updater/SKILL.md" ]]; then
  src_file="framework/templates/project/notes-updater/SKILL.md"
elif [[ -f "framework/templates/notes-updater/SKILL.md" ]]; then
  src_file="framework/templates/notes-updater/SKILL.md"
else
  echo "Error: source SKILL.md not found under framework/templates." >&2
  exit 1
fi

cp "${src_file}" "${dest_file}"

echo "Setup completed: project template copied, hooks installed, and ${dest_file} copied."
