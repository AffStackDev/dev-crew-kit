# Hosted stores and site builders (Shopify, BigCommerce, Webflow, Wix, Squarespace)

## What it's for in this workflow

Hosted platforms can't run on the computer. What can be in Git and tested locally is the code they allow: a theme,
an app, custom scripts. The rest is tested on a development or sandbox store before it reaches the live one.

## Way in

| Platform | Way in |
|---|---|
| Shopify | Shopify CLI (themes and apps), the Admin API, a connector/MCP server if the user has one |
| BigCommerce | Stencil CLI for themes, its API, a sandbox store |
| Webflow, Wix, Squarespace | Their APIs and code-export features where they exist; otherwise browser work in the editor, with the user |

## Shopify, in detail

Checked against shopify.dev on 30 October 2026; re-check, since Shopify's CLI changes often.

- **Install:** Node.js LTS and the Shopify CLI (`npm install -g @shopify/cli@latest`) on the computer, or in the
  runner image. The user signs in through the browser.
- **Workspace:** the theme in `theme/` (Shopify's layout: `assets`, `blocks`, `config`, `layout`, `locales`,
  `sections`, `snippets`, `templates`), an app in `app/`.
- **Baseline:** `shopify theme pull --store <store>.myshopify.com` (pick the live theme), commit and tag ("as live on
  <date>"). Record `shopify theme list` in STATUS.
- **Dev store:** the user creates one in Shopify's Dev Dashboard, or `shopify store create dev` where the CLI has it,
  with their yes. Dev stores can't take real payments.
- **Daily work:** `shopify theme dev --store <store>.myshopify.com` for a local preview with hot reload (a hidden
  development theme; live untouched); `shopify theme check` as the linter.
- **Store owners edit in the theme editor.** Those edits land in `config/settings_data.json` and `templates/*.json`
  (and section groups). Pull before starting, and keep them out of a release push unless the change is meant to
  touch them: `shopify theme push --unpublished --strict --ignore "config/settings_data.json" --ignore "templates/*.json"`.
- **Release** (at the user's go): pull live and compare with the last tag (if live changed, stop and tell the user);
  duplicate the live theme in the admin as the backup; push to a new unpublished theme; the user checks the preview
  link; they publish it, or you run `shopify theme publish` at their explicit go. Tag and record. Rollback = publish
  the previous theme.
- **Apps:** `shopify app init`, `shopify app dev` against the dev store, tests, then `shopify app deploy` at the
  user's go. App secrets and Admin API tokens in a git-ignored `.env` the user fills in.
- **Shopify's GitHub integration:** if the store uses it, the connected branch receives admin edits. Treat it as the
  store's branch; work on other branches and merge in deliberately.

## Guardrails worth setting

- Never edit the live theme in the admin code editor, and never push to the live theme.
- A dev store for anything risky (checkout scripts, apps, payment-related code).
- Release only from a branch that contains what live runs; compare before every release.

## Prove it

Pull the live theme, run `shopify theme check`, start `shopify theme dev` and open the preview in the browser pane.

## Checks to add

`shopify theme check` (and `--strict` on push); a click-through of home, collection, product, cart and search at
desktop and phone widths on the preview; the browser console clean.

## Other platforms

Read the platform's current developer docs first. BigCommerce's Stencil follows Shopify's pattern with a sandbox
store. Closed builders: put the code they allow (custom code embeds, exported code) under Git, and treat the editor as
the user's: agents prepare changes, the user applies or approves them.
