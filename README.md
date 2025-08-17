# jsua.co URL Redirects

This repository manages URL redirects for the `jsua.co` domain using Cloudflare Pages.

## What This Does

This repo contains a simple `_redirects` file that powers short URL forwarding for `jsua.co`. When someone visits a short URL like `jsua.co/dotfiles`, they get redirected to the full destination URL.

## Use Cases

- **QR codes** on business cards that redirect to websites
- **Short links** for sharing long GitHub URLs
- **Branded links** for social media and marketing
- **Memorable URLs** for frequently accessed resources

## How It Works

1. The `_redirects` file contains simple mappings in the format:

   ```text
   /short-path https://full-destination-url.com 301
   ```

2. Cloudflare Pages automatically deploys changes when this repo is updated

3. Changes go live within 30 seconds of pushing to the main branch

## Adding New Redirects

**Important**: The `_redirects` file is auto-generated. Never edit it directly!

To add a new redirect:

1. Edit the `redirects.yaml` file
2. Add your redirect under the appropriate section
3. Run `ruby generate_redirects.rb` to regenerate the `_redirects` file
4. Commit both files and push to GitHub
5. Cloudflare Pages will auto-deploy the changes

Example YAML entry:
```yaml
redirects:
  developer:
    - path: example
      url: https://example.com
      description: Example redirect
  
  personal:
    - path: my-link
      url: https://mywebsite.com
      description: Personal website
```

## Examples

- `jsua.co/dotfiles` → `https://github.com/joshukraine/dotfiles`
- `jsua.co/business` → Business website URL
- `jsua.co/contact` → Contact form or LinkedIn profile

## Development

### Setup

First, install the dependencies:

```bash
bundle install
```

### Running Tests

The redirect generator includes a test suite using Minitest with colored output:

```bash
# Run all tests
bundle exec rake test

# Run a specific test file
bundle exec ruby test/test_redirect_generator.rb
```

### Code Quality

The project uses StandardRB for Ruby style enforcement:

```bash
# Check code style
bundle exec standardrb

# Auto-fix style issues
bundle exec standardrb --fix
```

## Technical Details

- **Platform**: Cloudflare Pages
- **DNS**: Managed through Cloudflare
- **SSL**: Automatically handled by Cloudflare
- **Analytics**: Available in Cloudflare dashboard
