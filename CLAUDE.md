# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a URL redirect management repository for the `jsua.co` domain using Cloudflare Pages. The repository contains only configuration files - no build process or programming code.

## Key Files

- `redirects.yaml` - Source configuration for redirects (edit this file)
- `generate_redirects.rb` - Ruby script that generates `_redirects` from YAML
- `_redirects` - The generated configuration file for Cloudflare Pages
- `README.md` - User documentation explaining the redirect system

## Redirect Configuration

The `_redirects` file uses the following format:

```text
/short-path https://full-destination-url.com 301
```

- Path must start with `/`
- Use `301` for permanent redirects (most common)
- Use `302` for temporary redirects
- Comments start with `#`
- One redirect per line

## Deployment

Changes are automatically deployed by Cloudflare Pages:

- Push to main branch triggers deployment
- Changes go live within 30 seconds
- No build commands or CI/CD configuration needed

## Common Tasks

### Adding a new redirect (recommended)

1. Edit `redirects.yaml` file
2. Add new entry with path, url, and optional description/category
3. Run `ruby generate_redirects.rb` to regenerate `_redirects`
4. Commit both files with message like: "Add redirect for /example"
5. Push to main branch

### Adding a new redirect (manual/quick fix)

1. Edit `_redirects` file directly
2. Add trailing slash redirect: `/path/ /path 301`
3. Add actual redirect: `/path https://url.com 301`
4. Commit with message like: "Add redirect for /example to <https://example.com>"
5. Push to main branch

### Testing redirects

After deployment, test by visiting `https://jsua.co/your-path` in a browser or using curl:

```bash
curl -I https://jsua.co/your-path
```

## Important Notes

- This is a configuration-only repository - no tests or build process exists
- Edit `redirects.yaml` and run `ruby generate_redirects.rb` to maintain redirects
- The generator automatically handles trailing slash redirects
- All redirects should use HTTPS destination URLs when possible
- Keep redirect paths short and memorable (this is the main purpose)
- Use the `category: business` field in YAML to categorize business redirects
