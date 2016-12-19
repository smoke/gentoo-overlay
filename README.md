Welcome to the smoke-gentoo overlay!
=====================================

This is where ebuilds for [Gentoo](https://www.gentoo.org/) are maintained
for my own personal usage

Get Started
-----------

### Get the overlay

#### Option 1 - using portage repos.conf

Add the following settings in your /etc/portage/repos.conf or as a file /etc/portage/repos.conf/smoke-gentoo.conf
```ini
[smoke-gentoo]
location = /usr/local/smoke-gentoo-overlay
sync-type = git
sync-uri = https://github.com/smoke/gentoo-overlay.git
auto-sync = yes
```

Sync the overlay
```bash
emaint sync -r smoke-gentoo # or emerge --sync to sync all
```

#### Option 2 - using layman

Note this overlay is not yet available as layman overlay!
TODO - write instructions
