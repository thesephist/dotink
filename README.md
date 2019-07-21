# .ink (dotink)

dotink is the Ink programming language's blog, and my general technical blog.

## Development + Deploy

Working on dotink requires two tools: [Hugo](https://gohugo.io) for building the static site, and optionally [Ink](https://github.com/thesephist/ink) for deploying / serving the site.

To **write on the site**, run `hugo server -D` and Hugo will start a live-reloading server for the site at `localhost:1313`.

To **build the site for release**, run `hugo` and Hugo will generate all files needed for the full site deployment to `public/`.

To server the site with Ink, ensure you have Ink installed, then run `ink src/fileserver.ink`. You can also optionally run this as a systemd service on Linux - the service definition file is `dotink.service`.
