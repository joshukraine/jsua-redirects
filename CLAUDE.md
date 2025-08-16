# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a URL redirect management repository for the `jsua.co` domain using Cloudflare Pages. The repository contains only configuration files - no build process or programming code.

## Key Files

- `_redirects` - The main configuration file containing all URL redirect rules
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

### Adding a new redirect

1. Edit `_redirects` file
2. Add new line following the format above
3. Commit with message like: "Add redirect for /example to <https://example.com>"
4. Push to main branch

### Testing redirects

After deployment, test by visiting `https://jsua.co/your-path` in a browser or using curl:

```bash
curl -I https://jsua.co/your-path
```

## Important Notes

- This is a configuration-only repository - no tests or build process exists
- All redirects should use HTTPS destination URLs when possible
- Keep redirect paths short and memorable (this is the main purpose)
- Document the purpose of business/professional redirects with comments
