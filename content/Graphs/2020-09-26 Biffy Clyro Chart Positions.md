---
title: "Biffy Clyro Chart Positions"
date: 2020-09-26T16:43:18+01:00
author: "Adam"
image: "img/graphs/biffy-chart-positions.png"
code: ""
type: "Graphs"
---

# What?
This graph shows the peak UK chart position reached by each release from
Scotland's greatest band, Biffy Clyro, to have cracked the top 100. Each point
is scaled in line with the number of weeks the release has spent in the top 100.

I first came across the idea of a "lollipop" charts through Spotify's
[`chartify`](<https://github.com/spotify/chartify>) library a while ago, and 
have been trying to think of something that would look good as one. Biffy's 
latest album, _A Celebration of Endings_, managed to reach number one in the
album charts, and that got me thinking about how their previous releases had
performed in the charts.

# How?
Using `axvlines` and `scatter` in `matplotlib` makes drawing the lollipops easy,
and obtaining the data was incredibly simple with `pandas.read_html`.

# Libraries / Resources
- `matplotlib`
- `pandas`, with the additional dependency of `lxml` in order to use `read_html`
- [Geomanist](<https://www.atipofoundry.com/fonts/geomanist>) for the font again
- The colour palette I've used here is actually one extracted by my album art
  bot from their best album, Infinity Land
<blockquote class="twitter-tweet" data-theme="dark" data-align="center"><p lang="fr" dir="ltr">Colour hex codes: <a href="https://twitter.com/hashtag/a3a137?src=hash&amp;ref_src=twsrc%5Etfw">#a3a137</a>, <a href="https://twitter.com/hashtag/d9e5c4?src=hash&amp;ref_src=twsrc%5Etfw">#d9e5c4</a>, <a href="https://twitter.com/hashtag/6c8a88?src=hash&amp;ref_src=twsrc%5Etfw">#6c8a88</a>, <a href="https://twitter.com/hashtag/262e2f?src=hash&amp;ref_src=twsrc%5Etfw">#262e2f</a> <a href="https://t.co/PFnx1EsB5i">pic.twitter.com/PFnx1EsB5i</a></p>&mdash; Albums to Ruin (@albumstoruin) <a href="https://twitter.com/albumstoruin/status/1272440577842388992?ref_src=twsrc%5Etfw">June 15, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

# Data Sources
- Chart stats were sourced from the [Official Charts](<https://www.officialcharts.com/>)
  site's [Biffy Clyro page](<https://www.officialcharts.com/artist/10292/biffy-clyro/>)

# Code
Find it on [Github](<https://github.com/asongtoruin/data_analysis/blob/master/music/charts/biffy_charts.py>)
