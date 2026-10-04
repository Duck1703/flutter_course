#!/usr/bin/env python3
"""Append staged AI Local sections to learner lessons (idempotent)."""
import os, sys, json

ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(ROOT, "..", "..", ".."))
DOCS = os.path.join(REPO, "web", "src", "content", "docs")
SECT = os.path.join(ROOT, "sections")
MARK = "\n## 🤖 AI Local — Kiểm tra project sau bài này"

def main():
    only = set(sys.argv[1:])  # optional milestone filter e.g. m01
    applied, missing = [], []
    for m in sorted(os.listdir(SECT)):
        if not os.path.isdir(os.path.join(SECT, m)): continue
        if only and m not in only: continue
        for f in sorted(os.listdir(os.path.join(SECT, m))):
            if not f.endswith(".md"): continue
            lesson = os.path.join(DOCS, m, f)
            sect = os.path.join(SECT, m, f)
            if not os.path.exists(lesson):
                missing.append(f"{m}/{f}"); continue
            body = open(lesson, encoding="utf-8").read()
            if MARK in body:  # strip prior section for idempotent re-apply
                body = body[:body.index(MARK)]
            section = open(sect, encoding="utf-8").read().strip("\n")
            new = body.rstrip("\n") + "\n\n" + section + "\n"
            open(lesson, "w", encoding="utf-8", newline="\n").write(new)
            applied.append(f"{m}/{f}")
    print(f"applied={len(applied)} missing={len(missing)}")
    for x in missing: print("  MISSING:", x)

if __name__ == "__main__":
    main()
