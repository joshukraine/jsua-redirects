# CLAUDE.md

Project-specific guidance for Claude Code. Global conventions (Conventional Commits, branch naming, lint policy, etc.) live in `~/.claude/CLAUDE.md` and apply here too.

## Repository Purpose

URL redirect management for the `jsua.co` domain, served by Cloudflare Pages. A Ruby script reads `redirects.yaml` and generates both the Cloudflare `_redirects` file and a public landing page at `/links`.

## Key Files

- `redirects.yaml` — Source of truth. **This is the only file to edit when adding/changing redirects.**
- `generate_redirects.rb` — Entry point script. Runs `RedirectGenerator#generate`.
- `lib/redirect_generator.rb` — Reads YAML, writes `_redirects` and `links/index.html`.
- `lib/html_template.rb` — HTML/CSS/JS for the landing page (heredoc-rendered).
- `_redirects` — Generated. Cloudflare Pages reads this. **Never edit by hand.**
- `links/index.html` — Generated landing page (click-to-copy short URL directory).
- `404.html` — Static fallback page served by Cloudflare when no redirect matches.
- `test/test_redirect_generator.rb` — Minitest suite.
- `.github/workflows/ci.yml` — Tests + lint + drift check (fails if `_redirects` is stale).

## Workflow: Adding or Changing a Redirect

1. Edit `redirects.yaml` — add/modify entries under the appropriate category (`personal`, `developer`, `ministry`, `third_party`).
2. Run `ruby generate_redirects.rb` to regenerate `_redirects` and `links/index.html`.
3. Commit **all three** files together (`redirects.yaml`, `_redirects`, `links/index.html`) — CI will fail if any are out of sync.
4. Push to `main`. Cloudflare Pages deploys within ~30 seconds.

### YAML entry format

```yaml
- path: example                 # required, no leading slash
  url: https://example.com      # required, prefer HTTPS
  status: 302                   # optional, defaults to 302 (use 301 only for truly permanent destinations)
  description: Example redirect # optional, shown on /links page
```

**Why 302 by default:** This repo is a redirect-management service whose purpose is to provide a stable short URL over a destination that may evolve. A 302 response tells clients/caches not to pin the redirect, so when we change `url:` later (e.g., flipping a placeholder to a permanent site), every existing QR code or printed link starts following the new destination on the next request. Use `status: 301` only when you're confident the destination will never need to move.

## Commands

```bash
bundle install               # install gems (Ruby 4.0.5, pinned via .ruby-version)
ruby generate_redirects.rb   # regenerate _redirects and links/index.html
bundle exec rake test        # run the test suite
bundle exec standardrb       # lint (use --fix to auto-fix)
```

## Important Constraints

- **Never edit `_redirects` or `links/index.html` directly** — they're generated and CI will reject drift.
- The generator emits trailing-slash redirects automatically; don't add them manually in YAML.
- Prefer HTTPS destinations.
- Use `302` for time-bound or temporary destinations so browsers/caches don't pin them permanently.

## Testing a Live Redirect

```bash
curl -I https://jsua.co/your-path
```
