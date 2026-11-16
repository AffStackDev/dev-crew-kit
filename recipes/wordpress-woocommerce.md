# WordPress and WooCommerce

The workflow this kit comes from was built running a live WooCommerce store with custom plugins and a custom theme.
This recipe is that experience, generalized.

## What it's for in this workflow

- The user's **own code** (theme, child theme, plugins) in Git, exactly as live runs it.
- A **private offline copy of the live site** in Docker for rehearsing every change on real data before live.
- A **clean test site** (and, for plugin authors, throwaway test sites per check) for clean installs, Plugin Check and
  automated tests.
- **Releases** to live only through a rehearsed, backed-up, dry-run-first job.

## Way in

| Need | Way |
|---|---|
| Read/change the site from the command line | **WP-CLI**: in the local copy always; on live only read-only, over SSH, if the host allows it |
| The site's own actions from Claude/Codex | An MCP server or connector plugin on the site, if the user has one (prefer one that stages changes for the owner's approval in wp-admin) |
| Look at pages and screens | The desktop app's browser pane on the local copy; Playwright in Docker for repeatable checks |
| Releases | A job over SSH (or the host's deploy mechanism), from a GitHub workflow that runs on the PC runner |

## Install

All in Docker; nothing PHP on the computer.

1. **Read the facts from live** (read only, with the user's OK): WordPress, WooCommerce, PHP and database versions,
   table prefix, active theme, plugins with versions, must-use plugins and drop-ins, sizes. With SSH and WP-CLI:
   `wp core version`, `wp plugin list`, `wp theme list`, `wp db prefix`, `wp option get siteurl`. Without SSH: the
   user can paste wp-admin → Tools → Site Health → Info → "Copy site info to clipboard". Record it all with the date
   in the project's `docs/LOCAL-COPY.md`. Note the **command-line** PHP and the **web** PHP can differ on managed
   hosts; record both if you can see both, and say which you couldn't check.
2. **Their code into Git** exactly as live runs it, committed and tagged ("as live on <date>"): the baseline.
3. **The test runner image** (`local/runner/Dockerfile`): add PHP at live's version with the extensions WordPress and
   the plugins need (Ubuntu's `ondrej/php` archive is the common source for exact PHP versions, and is what GitHub's
   Ubuntu runners use), the MySQL client, WP-CLI (download the release `.phar` once, record its SHA-256, keep it in
   the work volume's cache), Composer if the project uses it, Node if the theme builds assets. If live has Imagick,
   install Imagick too: image handling differs measurably between GD and Imagick.
4. **One database per slot** (MySQL or MariaDB at live's version) as a service in the slot's compose file.

## The local copy of the live site

Each copy needs the user's OK (it brings customer data onto the PC). It lives in `Dev-local\<project>\site-copy\<UTC
stamp>\` and in Docker volumes. Never in Git, GitHub, a workflow artifact or a synced folder.

**Getting the data.** Copy the database and `wp-content` read-only. Never copy `wp-config.php`. Options:

- SSH with WP-CLI on the host: `wp db export` on the server into a temp file, download, delete the temp file;
  `tar` of `wp-content` (excluding caches and backup folders).
- The host's own backup download, if it offers one.
- If the host's SSH login needs a password every time (some managed hosts give key-only access only to a "deploy"
  user tied to their Git or CI integration), a GitHub workflow running on the **PC runner** (step 9) can use that
  deploy key from GitHub's secrets and write the copy straight into the local-data folder, so nothing passes through
  GitHub's logs or artifacts. The original workflow does exactly this.

Before copying: count users, orders and subscribers (numbers only) and tell the user.

**Building it.** WordPress at live's version in Docker; import; `wp search-replace '<live URL>' 'http://localhost:<port>' --skip-columns=guid`;
install the copy guard (below) as a must-use plugin; switch off tracking, marketing and outside-service plugins (ad
pixels, feeds, SMTP senders, backup plugins); leave out host-only must-use plugins and drop-ins (object cache,
advanced cache); flush caches. Set `WP_ENVIRONMENT_TYPE` to `local`, cron off, auto-updates off.

Compose sketch (one copy per project; give each its own Compose project name and port):

```yaml
name: <project>-copy
x-wp-env: &wp-env
  WORDPRESS_DB_HOST: db
  WORDPRESS_DB_USER: root
  WORDPRESS_DB_PASSWORD: root          # throwaway local container; its port is not published
  WORDPRESS_DB_NAME: site
  WORDPRESS_TABLE_PREFIX: ${SITE_PREFIX:?set by the helper from the copy's site.txt}
  WORDPRESS_CONFIG_EXTRA: |
    define( 'WP_ENVIRONMENT_TYPE', 'local' );
    define( 'WP_HOME', 'http://localhost:8081' );
    define( 'WP_SITEURL', 'http://localhost:8081' );
    define( 'DISABLE_WP_CRON', true );
    define( 'AUTOMATIC_UPDATER_DISABLED', true );
    define( 'WP_DEBUG_DISPLAY', false );
    define( 'WP_DEBUG_LOG', '/var/www/copy-out/debug.log' );
    define( 'COPY_OUT', '/var/www/copy-out' );
  WORDPRESS_DEBUG: "1"
services:
  db:
    image: mysql:<live major.minor>     # or mariadb:<version>, as live runs
    mem_limit: 2g
    memswap_limit: 2g
    environment: { MYSQL_ROOT_PASSWORD: root, MYSQL_DATABASE: site }
    volumes: [ "copy-db:/var/lib/mysql" ]
  web:
    image: wordpress:<wp version>-php<php version>-apache
    mem_limit: 2g
    memswap_limit: 2g
    depends_on: [ db ]
    ports: [ "127.0.0.1:8081:80" ]      # this PC only
    environment: *wp-env
    volumes: [ "copy-html:/var/www/html", "copy-out:/var/www/copy-out" ]
  cli:
    image: wordpress:cli-php<php version>
    profiles: [ "tools" ]
    user: "33:33"
    mem_limit: 1g
    environment: *wp-env
    volumes: [ "copy-html:/var/www/html", "copy-out:/var/www/copy-out" ]
volumes: { copy-db: {}, copy-html: {}, copy-out: {} }
```

If WordPress or WooCommerce needs to call its own address from inside the container (loopback requests, REST calls
to itself), make the site answer on the same port inside the container as outside (an extra Apache `Listen` on that
port), or the site's self-calls fail.

**The copy guard** (`mu-plugins/copy-guard.php`, only in the copy):

```php
<?php
/**
 * Plugin Name: Copy guard (local copy only)
 * Description: Blocks outbound HTTP so no payment, tracking, licence or update call leaves the PC; writes mail to
 * files instead of sending it; holds the live store's queued background tasks. Never put this on a live site.
 */
defined( 'ABSPATH' ) || exit;
if ( ! defined( 'COPY_OUT' ) ) {
	return; // Inert anywhere but the local copy.
}
add_filter( 'pre_http_request', static function ( $pre, $args, $url ) {
	$host = strtolower( (string) wp_parse_url( $url, PHP_URL_HOST ) );
	if ( in_array( $host, array( 'localhost', '127.0.0.1', '::1' ), true ) ) {
		return $pre;
	}
	error_log( gmdate( 'c' ) . " blocked {$host}\n", 3, COPY_OUT . '/http-blocked.log' );
	return new WP_Error( 'copy_offline', 'The local copy does not reach the internet.' );
}, PHP_INT_MAX, 3 );
add_filter( 'pre_wp_mail', static function ( $return, $atts ) {
	$dir = COPY_OUT . '/mail';
	wp_mkdir_p( $dir );
	$to = is_array( $atts['to'] ) ? implode( ', ', $atts['to'] ) : (string) $atts['to'];
	file_put_contents( $dir . '/' . gmdate( 'Ymd-His' ) . '-' . uniqid() . '.txt', "To: {$to}\nSubject: {$atts['subject']}\n\n{$atts['message']}\n" );
	return true;
}, PHP_INT_MAX, 2 );
add_filter( 'action_scheduler_allow_async_request_runner', '__return_false', PHP_INT_MAX );
add_filter( 'action_scheduler_queue_runner_concurrent_batches', '__return_zero', PHP_INT_MAX );
```

The guard blocks the server's HTTP calls. Tracking scripts run in the visitor's browser, so switch those plugins off
in the copy too. Verify and report: outbound HTTP blocked (the guard's log), mail lands in files, cron off, the store
loads in the browser pane. The user signs in with their own admin login (typed by them), or, with their OK, you make a
local-only admin with WP-CLI and keep its password in a file under `Dev-local`, never in Git or chat.

A helper script (`scripts/copy.cmd build | up | stop | reset | wp ARGS`) saves typing long Docker commands.

**What the copy can't test:** anything that needs the internet (payment gateways' real calls, licence servers,
shipping rates, AI services), and anything that needs HTTPS if it runs on plain HTTP (some licensing and payment
plugins refuse non-HTTPS addresses). A self-signed HTTPS front on localhost covers the second. Write both lists in
`docs/LOCAL-COPY.md`.

## Checks to add to scripts/check.sh

| Check | Tool | Notes |
|---|---|---|
| PHP syntax | `php -l` on changed files | At live's PHP version. |
| Coding standards | PHPCS with WordPress Coding Standards (Composer, in the image) | Escaping, nonces, sanitizing, prepared SQL. Fix real findings; don't blanket-ignore. |
| Plugin Check | The official Plugin Check plugin in a throwaway test site: `wp plugin check <slug>` | For the user's plugins (and themes where it applies). Keep it clean. Run it before long suites: it's fast and catches a lot. |
| Static analysis | PHPStan with WordPress stubs (optional) | Calls to missing functions, type mistakes. |
| Tests | The project's PHPUnit or other tests | Don't skip failing ones. |
| Upgrade rehearsal | In the copy: install the new build the way the release does (`wp plugin install <zip> --force`) | On real data; then click through. |
| Click-through | Browser on the copy | Home, shop, product, cart, checkout with a test payment, My Account, every admin screen the change touches. Read page text. |
| Logs | `debug.log` in the copy; browser console | No new PHP notices, warnings or errors; no new JS errors. |
| WooCommerce's own end-to-end tests | WooCommerce's Playwright suite against a clean test site | Optional, heavy; catches checkout regressions. |

## Releases

The pattern the original workflow uses for every live change:

1. Rehearse on the copy, from the exact set live runs.
2. A GitHub workflow, started by a tag in a commit **subject**, running on the PC runner, with the SSH deploy key
   only in GitHub's secrets:
   - **identity gate**: confirm it's talking to the right site (pinned host key; site URL read back);
   - **version preflight**: live runs exactly the versions expected (refuse if someone changed live since);
   - **backup** on the server first;
   - install one component at a time; health check after each (home page, wp-admin, a REST read);
   - **stop and restore** from the backup on any failure;
   - a plain summary for the user.
3. `[<name>-dry]` first: every gate, no change. Then the real run only on the user's go.
4. Afterwards: read live back, tag the release, record it, refresh the copy.

Build the job from the copy's helper so the **job itself** can be rehearsed against the copy (a `--local` switch that
swaps SSH for the copy's containers). Rehearsing only the PHP isn't enough; the job's own scripts have bugs too.

## Traps

- **WP-CLI `eval-file` runs the file inside a function**: code that expects global scope needs its globals declared.
- **`cmd /c` with PHP inline**: `>` and `->` become redirects. Put PHP in a file, copy it into the container, `wp eval-file` it.
- **Opcache serves old code** for about 2 seconds after files change (and forever if unzipped files keep a 1980
  timestamp, as many release ZIPs store): wait 3 seconds after swapping files in a test, and `touch` unzipped files
  (or install through WordPress's upgrader). Check a version string the page prints, not just the file on disk.
- **Action Scheduler** (WooCommerce's queue): on a fresh test site, or after any plugin deactivation, a group-limited
  run (`wp action-scheduler run --group=...`) can say the group doesn't exist. `wp action-scheduler migrate` puts the
  flag back, or run the store's own runner: `wp cron event run action_scheduler_run_queue`.
- **Printing options with a LIKE pattern can print stored credentials.** Select option names explicitly; exclude
  `%secret%`, `%token%`, `%key%`, `%credential%`.
- **A new WooCommerce test store** sends the first admin visit to the setup wizard (delete the
  `_wc_activation_redirect` transient) and has no payment method on (enable a test one in the fixture).
- **Coupon and sale end dates** are in the site's time zone; managed hosts often run WordPress on UTC while the
  business works in local time. Show the last valid day correctly.
- **Block names**: namespace new blocks and shortcodes by plugin slug; the first plugin to register a name wins
  silently.
- **Plugin updates can invalidate pending approvals** in plugins that stage changes for review. Don't deploy plugin
  updates while proposals wait.

## Checked against

WordPress and WooCommerce developer docs, WP-CLI handbook, the official `wordpress` Docker images, Plugin Check's
readme. Versions change often: record the versions used with the date in `docs/LOCAL-COPY.md`.
