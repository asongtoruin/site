---
title: "Albums to Ruin: working with the Spotify API"
date: 2020-04-17T11:30:00+01:00
author: "Adam"
cover: ""
tags: ["Albums to Ruin", "Python"]
description: "Part 1 of the Albums to Ruin Twitter bot - working with the Spotify API"
showFullContent: false
---

## Introduction
This post is a continuation of the development of my _Albums to Ruin_ Twitter 
bot. This is the first part of actual development of the bot - information 
on the concept and outline can be found in the
[Initial Concept post]({{<ref "Posts\2020-04-14 Albums to Ruin Initial Concept.md">}}).

In this post, I'm going to cover the process required for getting the recently 
played tracks from Spotify and the URL for the album art.

## Getting Started
First of all, we need to register an application with Spotify. This is done via 
the [Developer Dashboard](<https://developer.spotify.com/dashboard/applications>)
and is relatively straightforward. This provides us with the `Client ID` and 
`Client Secret` keys that let us access the APIs. 

While we're here, we also need to set up a Redirect URI. For other Spotify apps, 
this will be the address the user is redirected to once they log in. For the 
time being, we'll only be using the account we're logged into the developer 
console with, so this is not critical, but we need _something_ here to ensure 
we can connect properly later on. 

Clicking on the application and then clicking on _Edit Settings_ should allow 
you to add in a Redirect URI. Setting this to `http://localhost:8888/callback` 
gives us something we can work with later on. The settings page will look 
something like this:

{{< image src="/img/posts/albums-to-ruin/redirect_uri.png" >}}

Next, we need to set up our Python environment. For the purposes of this project,
I'm going to be using the `spotipy` [library](<https://github.com/plamere/spotipy>)
(latest version at time of writing is 2.1.1) as it's lightweight and has 
[good documentation](<https://spotipy.readthedocs.io/>). Spotipy lets you pass 
your `Client ID` and `Client Secret` keys either through parameters or through 
environment variables - for ease of sharing the code, I'm going to use 
environment variables. The Spotipy documentation has good advice for setting 
this up, particularly for Windows. In Linux (e.g. on a Raspberry Pi), it's a 
little more fiddly than I'm used to as you need to make sure it's set 
permanently. I did this through `~/etc/profile`. Now we should be ready to go.

## Authenticating
The first step in connecting to the API is authenticating. First, we'll request 
a token allowing access to the endpoint we require. Spotipy should be able to 
cache this token and refresh it when needed, so you should only need to call 
this section of the code once ever. This is the first time we need our Redirect 
URI, and if you want to run this code yourself you'll need to replace my 
username with your own.

```python
import spotipy.util as util

token = util.prompt_for_user_token(
    'valeadam', scope='user-read-recently-played', 
    redirect_uri='http://localhost:8888/callback'
)
```

If you run this, your web browser should load asking for permission to connect
your application to your Spotify account. Once this is approved, we should be 
clear to start accessing our information.

Now we need to set up an authenticated connection. Spotipy makes this fairly 
easy via its `Spotify` and `SpotifyOAuth` classes. Again, if you wanted to run 
this you'd need to replace my username with your own.

```python
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials


auth = spotipy.SpotifyOAuth(
    redirect_uri='http://localhost:8888/callback', username='valeadam'
)

sp = spotipy.Spotify(auth_manager=auth)
print(sp.me())
```

This prints out some information about the connected user:

```python
{
    'display_name': 'valeadam',
    'external_urls': {'spotify': 'https://open.spotify.com/user/valeadam'},
    'followers': {'href': None, 'total': 39},
    'href': 'https://api.spotify.com/v1/users/valeadam',
    'id': 'valeadam',
    'images': [],
    'type': 'user',
    'uri': 'spotify:user:valeadam'
}
```

If it doesn't, there may be some error in your process. Double-check your 
username is correct, and that the `SPOTIPY_CLIENT_ID` and 
`SPOTIPY_CLIENT_SECRET` environment variables are set up correctly.

## Getting recently played tracks
Now we have our authenticated connection, we can use this to access our recently
played tracks. This can be done through the `current_user_recently_played()` 
method of our `Spotify` object. This provides (a lot of) information on the 50 
most recently played tracks as a Python dictionary. The method returns 
track-level information, but for the purposes of this bot we actually only want 
the album-level data. I've cleared out information irrelevant to the task at 
hand with ellipses, for a more complete example consult the 
[Spotify web api reference](<https://developer.spotify.com/documentation/web-api/reference/player/get-recently-played/>)
for this method.The information I'll want to access for the Twitter bot is 
structured as follows:

```python
{
    'items':
        [
            {'track': {'album': {'album_type': 'album',
                                 'artists': [
                                     {'external_urls': {'spotify': '...'},
                                      'href': '...',
                                      'id': '4xYk2flbrS0hDzDLyDimbO',
                                      'name': 'Tubelord',
                                      'type': 'artist',
                                      'uri': 'spotify:artist:4xYk2flbrS0hDzDLyDimbO'
                                      }],
                                 # ...
                                 'external_urls': {'spotify': '...'},
                                 # ...
                                 'images': [{'height': 640,
                                             'url': '...',
                                             'width': 640
                                             },
                                            {'height': 300,
                                             'url': '...',
                                             'width': 300
                                             },
                                            {'height': 64,
                                             'url': '...',
                                             'width': 64
                                             }],
                                 'name': 'Our First American Friends',
                                 'release_date': '2009',
                                 'release_date_precision': 'year',
                                 'total_tracks': 10,
                                 'type': 'album',
                                 'uri': 'spotify:album:4nXbDzk9hxR8aUMkBvpV6u'
                                 },
                       # ...
                       },
             # ...
             },
             # ...
        ]
}
```

There's a few things we can note from this. Firstly, there's the possibility of 
multiple artists showing up on one album. It would be nice to be able simply 
combine them all into a comma-separated list, as this is likely how I'd want to
include this information in the corresponding tweet. The only issue here is it's 
unclear how compilations are dealt with - would 20 artists on a compilation each 
appear individually? If so, we might risk going past the tweet length limit. A
simple way of avoiding this issue is to replace the returned set of artists if
they exceed a certain length. We'll arbitrarily set this to 5.

Secondly, multiple sizes of artwork are returned. For the best result, we want
the largest image provided. It looks as though the images are ordered by size
from largest to smallest, but it's not too complicated to add an extra bit of
processing to ensure we do indeed get the largest.

Now we can begin to construct our class for the album object. There are a few 
other things we might want to think about:

- If multiple tracks are played from the same album, the album will appear in 
  the response multiple times. As such, we some way to check if two of our
  objects correspond to the same album so we can remove duplicates. Doing this
  through the `__eq__` magic method makes sense here, and allows us to directly
  use `==`. 

- Thinking ahead for the tweets, we might also want a nice string version of the
  album information to include with the image. We can use another magic method 
  for this - `__str__` - so we'll add this too.

- If we're going to be adding the data to a database, it'll help to have a quick
  way to access all of the attributes of each album object. The `__dict__` 
  magic method does this, but isn't a particularly nice method of access. 
  Additionally, we may end up wanting to exclude certain attributes from the 
  returned dictionary. Adding another method gives us this flexibilty.

Putting these things together gets us the following class:


```python
class SpotifyAlbum:
    def __init__(self, resp_dict):
        self.name = resp_dict.get('name', None)
        self.release_date = resp_dict.get('release_date', 'Unknown')

        # Handle possibility of many artists
        artists = resp_dict['artists']
        if len(artists) > 5:
            self.artists = 'Various'
        else:
            self.artists = ', '.join(
                art.get('name', 'Unknown') for art in artists
            )
        
        urls = resp_dict.get('external_urls', {'spotify': None})
        self.link = urls['spotify']
        
        # Get the largest version of the album artwork
        images = resp_dict.get('images', [{'url': None, 'height': 0}])
        images.sort(key=lambda x: x['height'], reverse=True)
        self.art_link = images[0]['url']
    
    def __str__(self):
        return (
            f'Album Name: {self.name}\n'
            f'Artist(s): {self.artists}\n'
            f'Released: {self.release_date}\n'
            f'Link: {self.link}'
        )
    
    def __eq__(self, other):
        if type(other) is type(self):
            return self.__dict__ == other.__dict__
        return NotImplemented
    
    def to_dict(self):
        return self.__dict__
```

This should give us the basic amount of information we need. As a last step for 
this section, we might want to consider how we can get the unique albums from
the most recent 50 played tracks. This API returns the most recently played 
track first in the list, whereas for my Twitter bot I want to have the albums 
posted in the order they've been encountered. This means reversing the items
passed by the API. It also means we can't just use `set`, as it ignores order.
It's not a huge issue, as we need just a few lines of code:

```python
recently_played = sp.current_user_recently_played()

recent_albums = []

for item in recently_played['items'][::-1]:
    album = SpotifyAlbum(item['track']['album'])
    if album.art_link and not any(prev == album for prev in recent_albums):
        recent_albums.append(album)
```

Now, via `recent_albums`, we have a list of unique recently played albums in the 
order in which they've been played. This gives us the starting point for the 
rest of the project. Putting all the code together, we get the following:

```python
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials


class SpotifyAlbum:
    def __init__(self, resp_dict):
        self.name = resp_dict.get('name', None)
        self.release_date = resp_dict.get('release_date', 'Unknown')
        self.artists = ', '.join(
            a.get('name', 'Unknown') for a in resp_dict['artists']
        )
        
        urls = resp_dict.get('external_urls', {'spotify': None})
        self.link = urls['spotify']
        
        images = resp_dict.get('images', [{'url': None, 'height': 0}])
        images.sort(key=lambda x: x['height'], reverse=True)
        self.art_link = images[0]['url']
    
    def __str__(self):
        return (
            f'Album: {self.name}\n'
            f'Artist(s): {self.artists}\n'
            f'Released: {self.release_date}\n'
            f'Link: {self.link}'
        )
    
    def __eq__(self, other):
        if type(other) is type(self):
            return self.__dict__ == other.__dict__
        return NotImplemented
    
    def to_dict(self):
        return self.__dict__

if __name__ == '__main__':
    auth = spotipy.SpotifyOAuth(
        redirect_uri='http://localhost:8888', username='valeadam'
    )

    sp = spotipy.Spotify(auth_manager=auth)

    recently_played = sp.current_user_recently_played()

    recent_albums = []

    for item in recently_played['items'][::-1]:
        album = SpotifyAlbum(item['track']['album'])
        if album.art_link and not any(prev == album for prev in recent_albums):
            recent_albums.append(album)
```