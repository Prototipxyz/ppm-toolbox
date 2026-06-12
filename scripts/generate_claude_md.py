#!/usr/bin/env python3
"""
generate_claude_md.py
Regenerates CLAUDE.md from KB files.
Currently: validates KB files exist and updates the "last updated" timestamp.
Future: can extract key sections automatically from KB files.
"""

import os
import re
from datetime import datetime, timezone

KB_DIR = "kb"
CLAUDE_MD = "CLAUDE.md"

required_kb_files = [
    "vision.md", "architecture.md", "entities.md", "permissions.md",
    "workflows.md", "features.md", "users.md", "decisions.md",
    "open_questions.md", "tooling_strategy.md", "stirg_document_brand.md"
]

def validate_kb():
    missing = []
    for f in required_kb_files:
        path = os.path.join(KB_DIR, f)
        if not os.path.exists(path):
            missing.append(f)
    if missing:
        print(f"WARNING: Missing KB files: {missing}")
    else:
        print(f"✓ All {len(required_kb_files)} KB files present")

def update_timestamp():
    if not os.path.exists(CLAUDE_MD):
        print(f"ERROR: {CLAUDE_MD} not found")
        return

    with open(CLAUDE_MD, "r") as f:
        content = f.read()

    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    timestamp_line = f"> Last updated: {now}\n"

    if "> Last updated:" in content:
        content = re.sub(r"> Last updated:.*\n", timestamp_line, content)
    else:
        # Insert after first line
        lines = content.split("\n", 1)
        content = lines[0] + "\n" + timestamp_line + (lines[1] if len(lines) > 1 else "")

    with open(CLAUDE_MD, "w") as f:
        f.write(content)

    print(f"✓ CLAUDE.md timestamp updated: {now}")

if __name__ == "__main__":
    validate_kb()
    update_timestamp()
    print("Done.")
