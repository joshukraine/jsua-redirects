# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a URL redirect management repository for the `jsua.co` domain using Cloudflare Pages. The repository contains only configuration files - no build process or programming code.

## Key Files

- `redirects.yaml` - Source configuration for redirects (edit this file)
- `generate_redirects.rb` - Ruby script that generates `_redirects` from YAML
- `lib/redirect_generator.rb` - Core logic for generating redirects
- `_redirects` - The generated configuration file for Cloudflare Pages
- `test/test_redirect_generator.rb` - Test suite for the generator
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

### Testing redirects

After deployment, test by visiting `https://jsua.co/your-path` in a browser or using curl:

```bash
curl -I https://jsua.co/your-path
```

### Running tests

```bash
# Install dependencies first
bundle install

# Run the test suite
bundle exec rake test
```

## Important Notes

- **NEVER edit `_redirects` directly** - it's auto-generated
- Always edit `redirects.yaml` and run `ruby generate_redirects.rb`
- The generator automatically handles trailing slash redirects
- Run `bundle exec rake test` to verify the generator is working correctly
- All redirects should use HTTPS destination URLs when possible
- Keep redirect paths short and memorable (this is the main purpose)
- Use the `category` field in YAML to categorize redirects (personal, developer, ministry, third_party)
