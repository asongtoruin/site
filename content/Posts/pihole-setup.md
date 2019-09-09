---
title: "An Initial Set-Up of PiHole"
date: "2019-09-09"
author: "Adam"
cover: "img/posts/pihole-setup/pihole-stats.png"
tags: ["raspberry-pi"]
description: "Ad blockers are great and all, but what if you could block the ads
from getting to your device entirely?"
showFullContent: false
---

# PiHole Set-Up

## Equipment
- Already had most of the things required, needed:
  - Micro-USB to Ethernet cable
  - microSD card
  - Short Ethernet cable

## Setting up the Raspberry Pi
- Download Raspbian Lite image (for the time being, we only want to use
  this for PiHole)
- Flash onto microSD with Etcher
- Plug everything in
- Cock-up 1: Raspbian now disables SSH by default. Need to plug in a screen
- Change the default password on activating SSH (we'll fix this later but
  it's still good to get this done early)
- Shutdown, unplug screen etc, set up cables as actually desired and re-plug in
- SSH in!
- Run updates (`sudo apt-get update`, `sudo apt-get upgrade`), reboot
- Set up SSH
```bash
$ cd ~
$ mkdir .ssh
$ cd .ssh
$ nano authorized_keys
```
- Use PuTTYgen to generate keys
- Cock-up 2: PuTTYgen's default public key is in an incompatible format.
  - Delete first two rows and last row
  - Add `ssh-rsa ` before the key
  - Delete all carriage returns
- Reboot to check it works
- Remove password authentication

## Installing PiHole
- `curl -sSL https://install.pi-hole.net | bash`
- Change from the default web admin password with `pihole -a -p`
