---
title: "Astronauts"
date: 2019-09-16T23:13:29+01:00
author: "Adam"
image: "img/graphs/astro.png"
code: ""
type: "Graphs"
---

# What?
A waffle chart showing the number of astronauts to have achieved distance
milestones in space.

Space is cool, humans travelling in space is extra cool and this gives an
interesting way to see that a perhaps surprisingly large number of humans have
travelled to space, though very few have actually set foot on the moon.

It was somewhat difficult to find precise details about this - hence the
slightly old date associated with the values. This is my best interpretation of
what's on Wikipedia.

# How?
Nothing fancy here - a manually written dictionary and a short bit of `pywaffle`
code.

# Libraries / Resources
- [`matplotlib`](<https://matplotlib.org/>)
- [`pywaffle`](<https://github.com/gyli/PyWaffle>)

# Data Sources
As noted earlier and on the graph itself, the data here comes from
[Wikipedia](<https://en.wikipedia.org/wiki/List_of_space_travelers_by_name>).

# Code
```python
import matplotlib.pyplot as plt
from pywaffle import Waffle


plt.rcParams['savefig.facecolor'] = '#001021'
plt.rcParams['text.color'] = 'w'

data = {
    'Sub-Orbital Flight': 3, 'Earth Orbit': 533,
    'Beyond Low Earth Orbit': 12, 'Walked On The Moon': 12
}

fig = plt.figure(
    FigureClass=Waffle,
    rows=20,
    values=data,
    colors=('#028090', '#C6D8D3', '#145C9E', '#D81E5B'),
    labels=["{0} ({1})".format(k, v) for k, v in data.items()],
    legend={
        'loc': 'upper center',
        'bbox_to_anchor': (0.5, 0),
        'ncol': len(data) // 2,
        'framealpha': 0
    },
    icons='user-astronaut',
    icon_legend=True,
    icon_size=17,
    plot_direction='NW',
    figsize=(8, 8),
    facecolor='#001021'
)

plt.suptitle(
    'Furthest Distance Travelled by Astronaut',
    y=0.90, size='x-large', weight='bold'
)

fig.gca().set_title(
    'Correct as of 2013-11-06'
    '\nSource: en.wikipedia.org/wiki/List_of_space_travelers_by_name',
    fontsize='small'
)

plt.savefig('Astro.png', bbox_inches='tight')
```
