---
title: "NFL Injury Data"
date: 2019-10-07T21:47:04+01:00
author: "Adam"
image: "img/graphs/nfl-injuries/concussions.png"
code: ""
type: "Graphs"
---

*Update 2020-02-16: Graphs updated with 2019 data*

# What?
The NFL puts out injury data each year, covering three areas. The cover image
for this post provides the headline stat of concussions, but information is also
provided for ACL Tears:
{{< image src="/img/graphs/nfl-injuries/acl-tears.png" >}}

and MCL Tears:
{{< image src="/img/graphs/nfl-injuries/mcl-tears.png" >}}

# How?
A stacked bar chart in `matplotlib`, with a bit of post-processing to make the
graphs look nice. Honestly, the biggest hassle involved in making these graphs
was getting the data itself, as the NFL inexplicably only seems to embed the
values as images.

# Libraries / Resources
- `pandas`
- `matplotlib`
- `seaborn` (only for figure aesthetics)
- NFL logo colours as detailed on a site called [SchemeColor](https://www.schemecolor.com/national-football-league-nfl-logo-colors.php)

# Data Sources
As noted in each image, the injury data comes directly from
["Play Smart Play Safe"](https://www.playsmartplaysafe.com/newsroom/reports/injury-data/),
the NFL's own website for player health data. Seems a slightly inappropriate
name considering they're seeing over 200 reported concussions each year.

# Code
Find it on [Github](https://github.com/asongtoruin/data_analysis/tree/master/nfl/injury%20data)
