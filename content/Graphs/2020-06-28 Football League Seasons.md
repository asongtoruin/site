---
title: "Football League Seasons"
date: 2020-06-28T18:35:59+01:00
author: "Adam"
image: "img/graphs/football-league-seasons/outsiders.png"
code: ""
type: "graphs"
---

# What?
Generally, I like to complain about my football club. Being a Port Vale fan is 
exhilirating at the best of times but heartbreaking at the worst. There is, at 
time of writing, a slightly hidden presentation on this very site that talks a
bit about that. See if you can find it (or, ask me and I'll probably just send
you the link).

A good while ago, I heard the stat that Vale were the team who had spent the 
most seasons in the Football League (as in, the top four tiers of professional 
football in England) without ever playing in the top flight. This was believable 
enough that I've quoted it a fair few times, but never actually bothered 
checking the data. I realised I should probably actually confirm this, and it 
turns out it was accurate - though it is a title we share with Lincoln City.

While I was at it, I decided to see who had spent the most seasons in the second
tier of English football without ever playing in the top flight. Guess who came
out top...

{{< image src="img/graphs/football-league-seasons/nearly.png" >}}

# How?
A straightforward horizontal bar chart, so nothing complicated here. Labelling
both the teams and season counts was slightly fiddly, but just required keeping
track of what needed to be aligned in what way. The description at the top is 
also fairly manual - it took trial and error to work out where to place the line 
break so that it filled the width without adding extra whitespace after the 
chart.

# Libraries / Resources
- `matplotlib`
- The font here is the beautiful [Noway Round](<https://www.atipofoundry.com/fonts/noway-round>) from Atipo

# Data Sources
- As always, [RSSSF](<http://www.rsssf.com/tablese/engall.html>) provided an 
  outstanding starting point through its [divisional movements](<http://www.rsssf.com/tablese/engall.html>) 
  records. This page at present only details divisional movements up to the 
  2015-2016 season, so I manually generated the subsequent seasons using...
  [more data from RSSSF](<http://www.rsssf.com/tablese/eng2017.html>).

# Code
Find it on [Github](<https://github.com/asongtoruin/data_analysis/tree/master/football/league_standings>)
