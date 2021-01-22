---
title: "Edinburgh 2017 Temperatures"
date: 2019-10-10T23:15:26+01:00
author: "Adam"
image: "img/graphs/edinburgh-temperatures/edinburgh-2017-temperatures.png"
code: ""
type: "graphs"
---

# What?
A ridge plot (i.e. overlapping distributions) showing the average hourly
temperatures at a particular location in Edinburgh in 2017, for the roughly
daytime hours of 7am-7pm.

# How?
This is based quite heavily on
[an example](https://seaborn.pydata.org/examples/kde_ridgeplot.html)
given as part of the `seaborn` documentation. The only real tweaks made to This
are to use the average temperature to determine the hue rather than just the row
and some neat labelling.

This site has long-term data available so ideally I'd like to create an
animation showing the changes in temperature over time, though that seems like
an optimistic goal at the moment!

# Libraries / Resources
- `pandas`
- `matplotlib`
- `seaborn`

# Data Sources
- [MIDAS Open: UK daily weather observation data](https://catalogue.ceda.ac.uk/uuid/0049795739e44310a4982e26d8e26748)
  (registration is required to access the data, but it's very straightforward)

# Code
Find it on [Github](https://github.com/asongtoruin/data_analysis/blob/master/weather/edinburgh_2017.py)
