---
title: "Albums to Ruin: Initial Concept"
date: "2020-04-14"
author: "Adam"
cover: ""
tags: ["python", "albums to ruin"]
description: "An initial concept for approximately my millionth twitter bot."
showFullContent: false
---

## Inspiration
Recently, I've seen a few posts shared around from the Instagram account 
[colorpalette.cinema](<https://www.instagram.com/colorpalette.cinema/>). 
I'm a big fan of a nice colour palette (indeed, a few years ago I had a 
Twitter bot running that did something similar with 
[Marvel comics covers](<https://www.twitter.com/marvelcovers>)) and it got me
thinking about whether I could do something similar of my own.

## The idea, and an initial outline
As you might have guessed from the post title, my plan is to make something 
similar for album covers. I'm a big music dork and pleasing covers are part of 
the reason why I still buy records, so this is a natural fit for me. 

I'm far too lazy to actually manually produce posts, so it's going to be a bot.
It'd be great to run this as an Instagram account, seeing as we'll just be
posting photos, but automating posts on there seems to be surprisingly difficult 
so I guess I'll stick with what I know and do a Twitter bot.

One major part of the equation is keeping it active, so for that my plan is to 
connect it up to my Spotify account via the Spotify APIs. The 
[Recently Played endpoint](https://developer.spotify.com/documentation/web-api/reference-beta/#endpoint-get-recently-played)
(at time of writing) gives access to up to 50 of the authenticated user's most 
recently played tracks. As the track object includes album art, that makes life 
much easier for me, as it's only one endpoint to access rather than needing one
to get the songs and another to get their art. Thanks, Spotify!

There's also the question of tracking what's already been posted to make sure 
it's not just posting every _Joyce Manor_ album cover a hundred times, and 
actually having somewhere to run the bot itself. For that I'm planning on using
one of the numerous Raspberry Pi I have lying about the flat, with a simple
SQLite database to log albums that have already been posted.

Ultimately, this leaves us with four broad sections:

1. Getting the recently played tracks from Spotify and link to the album art;
2. Checking against our database to see if we've already enountered this album,
   discarding if we have or adding it in if we have not;
3. Downloading the image, getting its dominant colours and combining these in a
   visually appealing way; and
4. Posting to twitter.

My plan is to dedicate a post to each of these sections and ultimately end up
with a functional Twitter bot. How long will that take me? Only time will tell.