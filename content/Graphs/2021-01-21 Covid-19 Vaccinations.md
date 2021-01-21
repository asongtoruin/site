---
title: "Covid-19 Vaccinations"
date: 2021-01-21T21:47:25Z
author: "Adam"
image: "https://raw.githubusercontent.com/asongtoruin/covid-graphs/main/Graphs/Vaccine%20count.png"
code: ""
type: "Graphs"
---

# What?
The UK government has been offering up a lot of open data through its 
[Coronavirus data portal](<https://coronavirus.data.gov.uk/>), but much of it is
intense and slightly stressful. One perhaps more positive piece of information
it offers is the number of vaccinations that have been provided, for both the
first and second stage. I decided that might be something a bit nicer to plot.

# How?
So not only is the government offering up a lot of open data, they've also 
provided a 
[Python module](<https://github.com/publichealthengland/coronavirus-dashboard-api-python-sdk>)
for easy access to the data, including directly to `pandas` dataframes. From 
there it was extremely easy to pull together the data, and there's nothing 
particularly fancy about the graph itself.

What _is_ fancy about this however is that the graph should automatically be 
updated every day through Github Actions. I've gone into detail about this in
[its own post]({{<relref "Posts/2021-01-21 GitHub Actions on a Schedule.md">}}).

# Libraries / Resources
- The usual `pandas` / `matplotlib` / `seaborn` triplet
- My own [`plot_styles`](<https://github.com/asongtoruin/plot_styles>) repo for 
  getting `matplotlib`'s colours to match up with this blog
- [`uk_covid19`](<https://github.com/publichealthengland/coronavirus-dashboard-api-python-sdk>)
  to get the data
- The font used is [Lato](<https://fonts.google.com/specimen/Lato>), as this is
  one of the default fonts in GitHub's Ubuntu environments

# Data Sources
- The [Coronavirus data portal](<https://coronavirus.data.gov.uk/>) via its 
  Python module

# Code
Find it on [Github](<https://github.com/asongtoruin/covid-graphs/blob/main/draw.py>)