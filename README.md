# Hosts Updater

This script intends to help manage large collection of blacklisted domains. It's best to describe it as a replacement for adblock, but instead of slowing down your browser it blocks domains of ad and scam websites at DNS level.

## Quick start guide

```sh
$ gem install hosts_updater
$ sudo hosts-updater --help
```

It requires sudo in order to write to `/etc/hosts` file.

## What it does?

This script download lists of malicious domains from following websites:

- http://www.malwaredomainlist.com/hostslist/hosts.txt
- http://winhelp2002.mvps.org/hosts.txt
- http://someonewhocares.org/hosts/hosts
- http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&mimetype=plaintext

Unique entries from those lists are added together, and results are combined with your current `hosts` file (no data will be lost as original `hosts` file is copied and reused in the future).

## How is it better than AdBlock/Ghostery etc?

Each browser plugin that blocks ads is using [large amount of resources, hogs browser, and often causes strange errors](http://www.reddit.com/r/programming/comments/25j41u/adblock_pluss_effect_on_firefoxs_memory_usage/chhpomw). In constrast to this, blacklisting domains in `/etc/hosts` only takes couple seconds after file change, and besides that has nearly zero impact on performance. Additionally AdBlock is removing parts of websites very aggressively, often leaving broken layout - it should be less common problem with domain blacklisting.

On the other hand there is a small amount of ads that are unblockable by domain blacklisting - that are visible from time to time, but probably not often enough to complain ;)

## How to configure what domains I want whitelisted/blacklisted?

During first run `hosts-updater` will create folder in `/etc/hosts.d`, in which it will store all configuration files:

- `hosts.custom` - this will be copy of old `/etc/hosts` and it will be added to `/etc/hosts` at top upon each use of `hosts-updater`. You should store you developer domains and all similar stuff inside of this file, as it will never be modified by this script. If you need to blacklist additional domains you should put them here too.
- `hosts.auto` - this will be regenerated upon calling `hosts-updater` with `--update` flag. It stores downloaded blacklists and is used to regenerate `/etc/hosts`. It's good idea to refresh it from time to time.
- `hosts.whitelist` - in this file you can place domains that you want to access despite figuring in one of downloaded lists. In order to do so, simply paste full domain name inside there (one domain per line) and it will be picked up during next `hosts-updater` run.

## Any other configuration options?

See `hosts-updater --help` for more configuration options.

## Are you owner of those blacklists?

No - I'm just using them with proper attribution. All kudos and suggestions should be sent to maintainers of appropriate lists.

## License

MIT License

Copyright © 2014 Bernard Potocki
