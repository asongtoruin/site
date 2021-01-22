---
title: "GitHub Actions on a Schedule"
date: 2021-01-21T22:06:55Z
author: "Adam"
cover: ""
tags: ["GitHub"]
description: "Using GitHub Actions on a schedule to automate tasks"
showFullContent: false
---

Over the past year or so I've been using GitHub Actions on a few different 
projects for building documentation and executables. The direct integration into
GitHub makes it a bit more convenient than Travis, and being able to use 
predefined Actions makes simple processes way easier to set up.

However, one thing I hadn't noticed until recently was that you can trigger
workflows to run [on a schedule](<https://docs.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events>).
This is an extremely powerful feature that, to me, seems under-publicised. My 
first idea was that gives us the option of setting up auto-updating graphs - so
I decided to try that out with UK Covid-19 vaccination data. You can see the 
results of this [here]({{<relref "Graphs/2021-01-21 Covid-19 Vaccinations.md">}}),
but in this post I'm going to run through the (fairly straightforward) set-up I 
used.

#### The config file
As with all(?) uses of GitHub Actions, the workflow is a YAML file stored in 
`.github/workflows` in the 
[project](<https://github.com/asongtoruin/covid-graphs>). 
It's relatively short, so here's the whole thing:

```yaml
name: Redraw graph

on:
  schedule:
    - cron:  '0 2 * * *'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v2

      - name: Get date
        run: |
          echo "CURR_DATE=$(date +%Y-%m-%d)" >> $GITHUB_ENV
        
      - name: Set up Python 3.7
        uses: actions/setup-python@v2
        with:
          python-version: 3.7

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip setuptools wheel
          pip install -r requirements.txt
      - name: Draw graph
        run: python draw.py

      - name: Commit updated graph back to the repo
        uses: EndBug/add-and-commit@v7
        with:
          message: '${{ env.CURR_DATE }}: Automated graph update'
          add: 'Graphs/*.png'
```

### The process
From the above, you can see there are several different steps in the process.
This is running on Ubuntu just to make sure the module installs are nice and 
smooth (as opposed to Windows potentially needing a bit of faff).

1. We checkout the repo. A fairly standard first step.
2. We get the current date and store it in a way that we can access in other 
   parts of the process. In this instance, we're just using it to keep our 
   commit messages informative
3. We set up Python. Again, GitHub Actions coming into its own by making this a 
   single line command
4. We update `pip`, just in case, and then install our dependencies.
5. We actually draw the graph!
6. We use the [add-and-commit](<https://github.com/marketplace/actions/add-commit>)
   Action to stage and commit our updated graph. The beauty of this Action is
   that it doesn't create a commit if the files are unchanged - so if the data 
   we're using hasn't been updated between our scheduled runs of the process, 
   our graph doesn't change and we don't get an empty commit. This helps to keep
   the commit logs nice and clean.

#### The scheduling
Setting it up to run on a schedule is super-simple and is shown right near the 
top of the file. Simply:

```yaml
on:
  schedule:
    - cron:  '0 2 * * *'
```

The syntax is as standard for cron jobs (I always use the 
[crontab guru](<https://crontab.guru/>) to check before I run) and... that's 
it??? You don't need to do anything else with your repo, simply having the 
schedule defined in your workflow ensures it is automatically called. As you can
see here, I have my process run at 2am each day, in the hope that this will 
ensure the open data has been updated.