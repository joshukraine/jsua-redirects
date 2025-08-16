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

To add a new redirect:

1. Edit the `_redirects` file
2. Add a new line with your redirect rule
3. Commit and push to GitHub
4. Cloudflare Pages will auto-deploy the changes

## Examples

- `jsua.co/dotfiles` → `https://github.com/joshukraine/dotfiles`
- `jsua.co/business` → Business website URL
- `jsua.co/contact` → Contact form or LinkedIn profile

## Technical Details

- **Platform**: Cloudflare Pages
- **DNS**: Managed through Cloudflare
- **SSL**: Automatically handled by Cloudflare
- **Analytics**: Available in Cloudflare dashboard
