# Recipes: connecting the tools people actually use

A recipe is a worked starting point for one kind of tool or stack: how the agents reach it, what goes in Docker and
what stays on the computer, how to prove it works, the guardrails worth setting, and the traps people hit. Claude
reads the matching recipe in step 12, then checks the tool's **current official docs** for anything version-specific.

## The method, condensed (full version: playbook step 12)

1. **Existing first.** Does something already installed do it? Test that before building anything.
2. **Pick the way in**, most reliable first: official CLI/SDK → official MCP server/connector → official API + script
   → files in/out → browser automation → computer use.
3. **Headless parts in Docker** (build tools, CLIs, converters), desktop-only apps on the computer.
4. **The user signs in.** Secrets in the tool's own store, an environment variable, or a git-ignored `.env`.
5. **Guardrails, written down:** what's free to do, what needs a go each time, what's never done, money/credit limits,
   who drives the tool.
6. **Prove it** with one small real task end to end; keep the evidence; add a `test_execution.csv` row.
7. **Write it in:** tool card in `crew-home/TOOLS.md`, project `CLAUDE.md`/`AGENTS.md`, decisions, lessons.

## Writing a new recipe

When a user connects a tool no recipe covers, offer to write one from what was learned, so the next person has it.
Use this outline, keep it to what's useful, and leave out anything personal (names, paths with names, accounts,
URLs of private sites):

```markdown
# <Tool or stack>

## What it's for in this workflow
## Way in (and why this one)
## Install (official source; what goes in Docker, what stays on the computer)
## Sign-in and secrets
## Guardrails worth setting
## Prove it (one small real task)
## Checks to add to scripts/check.sh
## Traps (what went wrong, and the fix)
## Checked against (docs pages and versions, with the date)
```

Recipes are plain Markdown in this folder. If the user wants to share one back to the kit's maintainer, that's their
call.
