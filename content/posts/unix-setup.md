---
title: "How I set up my servers"
date: 2020-06-21T11:44:30-04:00
toc: true
---

Many of my [projects](https://thesephist.com/projects) include a web server, usually written in Go, Node.js, or Ink. I deploy these servers to Linux VMs running on [DigitalOcean](https://m.do.co/c/e5c53932f7c5), and I set them all up very similarly. I currently have 17 separate web servers / projects running across two $5/month servers.

In the name of reducing and documenting repetitive tasks, I thought I'd write down and share my process for setting up a new Ubuntu web server, and deploying applications to it the way I usually do. As much as a way for me to share my process, this is also a reminder for my future self on how to set up and provision new servers the way I've done before.

## Operating system and environment

### Users

DigitalOcean, like most VM providers, sets you up with a single `root` user. I usually create a separate user under which to run my applications, usually `thesephist`. In most Linux distributions you can do this with `adduser`:

```
# create user
adduser thesephist

# add user to sudoers
usermod -aG sudo thesephist
```

### Firewall

After this, I'll remote login to the server exclusively from the `thesephist` user. Before we can make changes to the SSH configuration to enforce these rules, we need to set up the firewall. On Ubuntu, the firewall is controlled with `ufw`.

By default, `ufw` doesn't let any inbound connections through. I usually keep ports open on my servers for ssh (22), http (80), and https (443).

```
# enable service ports
ufw allow ssh
ufw allow http
ufw allow https

# start firewall and enable it forever
ufw enable

# check firewall status
ufw status; to check
```

### SSH and shell

When I provision a new server, I usually modify my local SSH configuration (`~/.ssh/config`) on my development machine to add a new alias:

```
Host my-app
    Port 22
    User thesephist
    Hostname my-app.thesephist.com
```

After this, I can connect to my server with `ssh my-app`.

New SSH installations these days come with good defaults. I usually only change a few settings under `/etc/ssh/sshd_config`:

- `PermitRootLogin no` ensures that the root user cannot login via SSH. Since we've created a non-root user, setting this adds a layer of security.
- `PermitEmptyPasswords no` should be set if password authentication is on
- `PubkeyAuthentication yes` is the default and allows authentication via SSH public keys, but if it isn't set, I set it
- `X11Forwarding no` turns off [X forwarding](https://wiki.archlinux.org/index.php/OpenSSH#X11_forwarding). Since I never use X forwarding over SSH, keeping this on is a best-practice.

I use zsh and fish shells, depending on the environment I'm setting up. For new servers, I run `chsh` with _no arguments_ to start an interactive program to set the current user's shell.

## Language-specific installations

I deploy most of my services as systemd services / daemons. Systemd gives me a declarative way to define services with a single file. For examples of service definitions for my apps, check out `*.service` files on GitHub under more recent projects.

- [draw.service](https://github.com/thesephist/draw/blob/master/draw.service)
- [cornelia.service](https://github.com/thesephist/cornelia/blob/master/cornelia.service)
- [dotink.service](https://github.com/thesephist/dotink/blob/master/dotink.service)

### Go

Most of my backend services these days are written in Go. Go is fast (enough for my use cases), has a great standard library of networking building blocks, compiles to a static binary that's easy to distribute, and was easy for me to pick up, coming from dynamic languages. Compared to JavaScript and Node.js, my previous tool of choice, Go is also lighter on resources, which ends up saving me money in the long run.

I usually deploy Go applications by bundling all necessary assets into a single binary and `scp`-ing it to the server, then restarting the service. If I do need a local installation of Go, here's a three-liner to get Go set up on a new Linux server.

```
# Download the latest build of Go
# (available from https://golang.org/dl/)
wget 'https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz' -O .

# Un-tar contents into /usr/local
sudo tar -C /usr/local -xzf go1.14.4.linux-amd64.tar.gz

# Add Go binary paths to $PATH
echo 'PATH=$PATH:/usr/local/go/bin' >> ~/.profile
```

<a href="https://github.com/thesephist/plume" class="button">Example: Plume.chat &rarr;</a>

### Node.js

My older projects up to 2019 are mostly written in Node.js. Node and JavaScript allows for isomorphic code and Node.js in particular has excellent networking primitives and asynchronous programming capabilities through V8 and [libuv](https://github.com/libuv/libuv). I also enjoy the rapid prototyping that a fast, dynamic language like JavaScript makes possible.

That said, these days I write most of my servers and backend services in Go and my scripts in Ink, because I find that Go codebases age better over time, and I enjoy writing Ink code.

I used to deploy new Node.js projects with [PM2](https://pm2.keymetrics.io), which is an easy-to-use process manager for Node, and handles much of the responsibilities that systemd handles for my Go projects -- logging, monitoring, auto-restarting, and so on. I still have legacy applications running under PM2, but if I were to deploy new Node.js services today, I'd probably write a systemd service instead, for consistency's sake with the other languages I use.

Running a Node application requires installing the Node runtime and standard libraries. [Nodesource](https://github.com/nodesource/distributions/blob/master/README.md) offers a short shell script to install and pull from the appropriate third-party repositories to install Node.js:

```
# For Ubuntu
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs
```

<a href="https://github.com/thesephist/codeframe" class="button">Example: Codeframe &rarr;</a>

### Ink

The Ink interpreter is a [single small, static Go binary](https://github.com/thesephist/ink/releases), so I'll install it onto the server by compiling a Linux binary and copying it onto the remote server, or by including it directly in the project's repository.

Ink doesn't have a native package manager, so all dependencies are vendored into project repositories. This makes deployment simple, however -- just run the main Ink program file with the `ink` binary in the systemd service file definition, and the service is up and running.

<a href="https://github.com/thesephist/dotink" class="button">Example: dotink.co &rarr;</a>

## Nginx and TLS

I use Nginx as the static file server and reverse proxy behind all of my self-hosted projects. Nginx is available from the default repositories of most Linux distributions. If I'm using Nginx, I'm also probably using [Let's Encrypt](https://letsencrypt.org) to obtain and auto-renew TLS certificates. Let's Encrypt's CLI tool, `certbot`, also comes with a plugin to work with Nginx configuration files. To install these tools in one go, you can run

```
sudo apt install nginx certbot python3-certbot-nginx
```

Then running `sudo certbot` or `sudo certbot --nginx` will scan through the available domains in the Nginx configuration and run an interactive session to obtain a new TLS certificate.

### Server and proxy configuration

My typical Nginx server block looks like this.

```
server {
	# general configs
	server_name app.thesephist.com;
	root /var/www/html;
	index index.html index.htm;
	try_files $uri $uri/ =404;

	# if default server -- usually omitted
	listen 80 default_server;
	listen [::]:80 default_server;

	# if using HTTP auth headers
	auth_basic "[service] login";
	auth_basic_user_file /etc/nginx/conf.d/.htpasswd;

	# if HTTP proxy
	location / {
		proxy_pass http://localhost:7800;
	}

	# websockets path
	location /connect {
		proxy_pass http://localhost:7800;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "Upgrade";
	}
}
```

## Dotfiles

I also usually set up my VM user with my configuration files for Vim, Tmux, and a few other utilities, available in the [GitHub repository for it](https://github.com/thesephist/dotfiles).

## Nice-to-haves

Beyond these bare necessities to deploy and serve my applications, over time, I also end up installing a small collection of other tools that make working in a Linux server environment more efficient.

- `awk`, the venerable UNIX text-processing tool
- `curl` and `wget` for working with downloads / network requests
- [`ack`](https://beyondgrep.com) is a grep-like search tool that's simpler to use with source code. I've also heard many praises for `ag` (the "silver searcher"), but haven't had time to explore it, nor felt the need to switch.
- [`tree`](https://en.wikipedia.org/wiki/Tree_(command)), often nice for quickly getting an overview of a directory's file structure
- [`htop`](https://hisham.hm/htop/), a `top`-like tool with better visualizations
- [`make`](https://www.gnu.org/software/make/manual/make.html) for running various build and deployment scripts in a language-agnostic way
