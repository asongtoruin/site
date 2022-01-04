---
title: "Sunshine on Leith"
date: 2022-01-04T21:44:40Z
author: "Adam"
image: "img/graphs/sunshine-on-leith.png"
code: ""
type: "graphs"
---

# What?
I recently saw a [very nice tweet](<https://twitter.com/setalyas/status/1476864080371720197>) about sunrise and sunset times in London. It looked a lot like a `matplotlib` graph, so I decided to look into how it could have been made. A bit of googling took me to an [excellent blog post](<https://chrisramsay.co.uk/posts/2017/03/fun-with-the-sun-and-pyephem/>) about undertaking very similar tasks, from which I learned about _different kinds of twilight_. I then realised switching the focus to Edinburgh gave an opportunity for a terrible pun and decided to make my own, so here we are.

# How?
Though the above blog post references `PyEphem`, [`skyfield`](<https://rhodesmill.org/skyfield/>) seems to be a more modern approach to the same kinds of calculations, so I worked with it instead. Its documentation gives perfect examples on [finding the various twilight times](<https://rhodesmill.org/skyfield/examples.html#when-will-it-get-dark-tonight>), alongside [identifying equinoxies and solstices](<https://rhodesmill.org/skyfield/almanac.html#the-seasons>). Coupling these with a bit of `pandas` gave me something I could pass to `axpcolormesh`, from which point it was just a case of playing about with `matplotlib` until I thought it looked nice.

As this is an area of study I am completely and utterly unfamiliar with it's entirely possible that there are some errors here, but the profile looked similar enough to those given [by other sources](<https://www.timeanddate.com/sun/uk/edinburgh>) that I don't think it's too far off.

# Libraries / Resources
- `skyfield` for the calculations
- `pandas` / `numpy` for data wrangling
- `matplotlib` for plotting
- [Noway](<https://www.atipofoundry.com/fonts/noway>) for the font

# Data Sources
No external sources - the calculations are all done within `skyfield` itself.

# Code
Find it on [Github](<https://github.com/asongtoruin/sun-plots>)