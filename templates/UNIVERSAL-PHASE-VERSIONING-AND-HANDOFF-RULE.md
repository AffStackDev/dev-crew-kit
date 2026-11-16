# Universal phase, versioning and handoff rule

User instruction · 15 September 2026 · Applies across projects and kinds of work unless the user explicitly supersedes it.

Handoff-frequency clarification added 16 September 2026.

## Work in substantial phases

Group changes that form a useful, coherent outcome. A phase should include its related implementation, interface, documentation and focused verification. Do not turn every one or two small tasks into another phase. Keep each completed phase usable and reviewable.

## Release identity

Use `x.x.x.P` for main phase P. Preserve the project's existing identity and baseline; do not reset one product to another product's version.

| Kind | Example |
|---|---|
| Main phase | `x.x.x.2` |
| Issue fork of that phase | `x.x.x.2a` through `x.x.x.2z` |
| Sub-fork beneath a letter | `x.x.x.2a1` through `x.x.x.2a99` |
| Next main phase | `x.x.x.3` |

If no fork is needed, advance directly to the next main phase. Keep a fork tied to the problem and parent it corrects. Do not silently relabel unrelated work as a bug fix. Record parent, scope, status and whether a fork has been incorporated into the next main phase. Routine edits to an unpublished phase do not require delivering a new archive for every edit; an independently handed-off or released issue track has its own suffix.

Example: with an accepted baseline of `0.3.1`, the first new phase is `0.3.1.1`, its first fix is `0.3.1.1a`, and its first nested fix is `0.3.1.1a1`. The next main phase is `0.3.1.2`.

## Native updater ordering

Some platforms treat a suffix such as `a` as an alpha prerelease and therefore sort it before the unsuffixed release. Do not assume lexical comparison, a generic semantic-version library or PHP version_compare implements this workflow.

Where required, retain the user-facing release identity above and provide a separate numeric update version. Map the phase, letter index (a=1 through z=26) and sub-fork into numeric components, for example `0.3.1.2a3` → `0.3.1.2.1.3`. Main phase 2 uses `0.3.1.2`; phase 3 uses `0.3.1.3`. Keep the human release label in the manifest, documentation, package names and UI. Verify actual update ordering and signing/catalog contracts before shipping a suffix release. Never rewrite a signed artifact to change its identity.

## Create handoffs only when another instance needs an update

Create or update a worker handoff only when that receiving instance needs information or action that has changed since its last update, or when the user explicitly asks for a handoff. Completing a phase or changing a version alone does not justify another handoff. Keep normal source, release records and customer/technical documentation current without automatically regenerating or resending worker handoffs.

When a handoff is needed, identify its recipient, the relevant changes since that worker's last known update, the action or information needed and any changed contract or dependency. Reuse the existing handoff where appropriate. Do not assume that a prepared or saved handoff has reached another instance unless delivery is established. Compare incoming material with the existing baseline; a duplicated instruction document is not evidence of implemented work or a reason to replace newer source.

## Every handoff must propagate this rule

Include this rule file with every project or worker handoff, and include this instruction in the handoff itself:

> Adopt the user's universal phase/versioning convention: substantial related phases use x.x.x.P; issue forks use x.x.x.Pa–z; nested forks use x.x.x.Pa1–99. Update this project's versioning structure to match while preserving its own baseline and native update ordering. Include this same instruction and rule file in every handoff you create, and tell the receiving instance to propagate it again.

Every handoff also names the actual latest installer/source baseline, current phase/fork, completed work, remaining work, known issues, executed checks and unverified behavior. Carry forward established feature ownership, permissions and user decisions. Do not replace them with guesses or claim a specification is implemented.

## Persistence boundary

This is a reusable user instruction to carry between projects. Keep a copy in each project's docs and release packs. Other conversations must receive or load the rule; this file alone does not change an account-wide system setting.
