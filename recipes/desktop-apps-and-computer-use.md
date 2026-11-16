# Desktop apps with no CLI or API: files, browser automation, computer use

## What it's for in this workflow

Some tools have no command line, no API and no MCP server: a desktop app, an old admin panel, a vendor portal. They
can still be part of the workflow, in descending order of reliability.

## Way in, in order

1. **The app's own automation.** Many desktop apps have something: a scripting console (Python in many 3D and video
   apps), macros, command-line flags for batch jobs, watch folders, "export preset" files, plugins. Check the vendor's
   docs and the app's menus first.
2. **Files in, files out.** The app reads or writes a known folder; the agents prepare inputs and check outputs. Robust
   and easy to test.
3. **Operating-system automation.** On Windows, some apps (Office, for example) expose COM automation scriptable from
   PowerShell; on macOS, AppleScript or Shortcuts. Check the app supports it.
4. **Browser automation** for web-only tools: the desktop app's browser pane (with the user's sign-in) for one-off
   work; Playwright in Docker for repeatable checks. Read the page's text, not screenshots, wherever possible.
5. **Computer use** (screen control): Claude Code can take screenshots of the desktop and click and type in apps the
   user grants, one app at a time. It's slow and can misclick: use it for short, supervised steps with a clear
   finish, and record what worked as a lesson so it isn't rediscovered. In current versions, some app kinds have
   restricted access by default (browsers are view-only, so use the browser tools; terminals and editors limited to
   clicks), and the user approves each app.

## Guardrails worth setting

- The user grants each app explicitly; computer use never touches a password field, a payment, a security setting or
  a system dialog.
- Never click links found in emails or documents through screen control; open URLs through the browser tools, after
  checking where they go.
- One agent drives the desktop at a time. While computer use runs, the user shouldn't be using the same app.
- Financial and trading apps: view and organize, never execute payments, transfers or trades.

## Prove it

One short, real, repeatable task end to end (for example: export a file from the app into the project folder), done
twice the same way. Record the steps that worked as a lesson.

## Traps

- Native "Save as" dialogs may sit outside what browser tools can control; say plainly when a save needs the user's
  click instead of claiming it happened.
- Downloads that block: start one download, keep working, then check for the file; don't call blocking waits that can
  hang for an hour.
- Screens differ by scaling and resolution: re-take a screenshot before clicking after anything changes.
