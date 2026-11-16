# Tools and how the agents reach them

One card per tool. Every session looks here first before using a tool. Update the card when something changes, and
write a lesson for anything learned the hard way.

## <Tool name>

| | |
|---|---|
| What it's for | <in the owner's words> |
| Version | <version, checked date> |
| Way in | <CLI / MCP server / API script / files / browser / computer use> and why that one |
| Where it runs | <Docker image name, or on the computer at <path>> |
| Files | <where inputs and outputs live; never in Git if large or private> |
| Account | <whose account; plan name only if the owner wants it recorded> |
| Sign-in and secrets | <where the credential lives (tool's own store / env var name / git-ignored .env); who types it> |
| Costs and limits | <per-use costs, credit limits, the stop rule> |
| Free to do | <read, list, draft, export previews, ...> |
| Needs the owner's go each time | <publish, send, delete, spend, change live settings, ...> |
| Never | <...> |
| Who drives it | <Claude / Codex / either with a claim in the exchange file> |
| How to check it works | <command or small task> |
| Proof run | <date, evidence path, test_execution row> |
| Traps | <known problems and fixes; links to lessons> |
| Decisions | <D-numbers> |

<!-- Copy the block above for each tool. -->
