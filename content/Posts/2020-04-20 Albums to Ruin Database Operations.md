---
title: "Albums to Ruin: database operations"
date: 2020-04-20T10:30:00+01:00
author: "Adam"
cover: ""
tags: ["Albums to Ruin", "Python"]
description: "Part 2 of the Albums to Ruin Twitter bot - tracking played albums with a database"
showFullContent: false
---

## Introduction
This post is a continuation of the development of my _Albums to Ruin_ Twitter 
bot. This is the first part of actual development of the bot - information 
on the concept and outline can be found in the
[Initial Concept post]({{<relref "2020-04-14 Albums to Ruin Initial Concept.md">}}).

In this post, I'm going to cover the database operations required to power the 
Twitter bot and keep track of what has already been posted and the queue of 
albums to post. This carries on from some of the work done in
[the previous post]({{<relref "2020-04-17 Albums to Ruin Working with the Spotify API.md">}}).

Also, a quick thanks to my eternal boy [@calrgn](<https://twitter.com/calrgn>) 
for help with some of the database stuff in this post.

## Getting Started
For simplicity's sake, I'm just going to use an SQLite database. It's included
with Python and is uncomplicated and lightweight.

My initial idea is that there will be two separate processes running - one to 
get the data from Spotify and another to process the artwork and post to 
Twitter. These will both need to interact with the same database, and the 
duration of the processes may overlap. As such, each album in the database will 
be either:

- In the queue of albums waiting to be processed;
- Currently being processed; or
- Already processed.

If each album is represented by a single record in our database, this 
information can be added by having an extra column that keeps track of this. 
This lets us keep our albums in a single table, which can be accessed by both 
processes, which in turn makes our database structure much simpler.

To make both of our processes fully functional, we'll need to consider the 
following actions:

- [Checking if an album already exists in the table]({{< relref "#check-exists">}});
- [Adding new album(s) to the table]({{< relref "#add-album" >}});
- [Getting album(s) from the table]({{< relref "#get-album" >}}); and
- [Updating the status of an album in the table]({{< relref "#update-album">}}).

I'd considered (and initially wrote some methods) using dictionaries to do some
of these operations, but ultimately this is intended to be a specialised 
database and as such it makes sense to just directly use our `SpotifyAlbum` 
class in our methods. This will make the code we use to actually run each 
process simpler, though could make updating the processing under the hood a 
little harder. 

## Creating the table
Before we can think about any of those actions, we need to start by setting up 
the table containing all of our albums. Again I'm going to use a class to 
represent our database, so in initialising our class we need to:

- Connect to the database;
- Do any associated set-up we need; and
- Check that our table exists, creating it if it doesn't.

Python's `sqlite3` module (from the standard library) helps to simplify this, as 
its standard method for connecting to a database will automatically create one 
if it doesn't already exist. SQLite also supports the `IF NOT EXISTS` option 
when creating a table within a database. This allows us to effectively use the 
same code whether the table (and database) already exists or not, making this
constructor fairly simple. Initialising our database object, then, looks like 
the following:

```python
import sqlite3

from .album import SpotifyAlbum


class AlbumDatabase:
    def __init__(self, db_path='spotify albums.sqlite'):
        self.conn = sqlite3.connect(db_path)
        # Get responses as dictionary
        self.conn.row_factory = sqlite3.Row

        self.cursor = self.conn.cursor()

        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS albums (
                name text NOT NULL,
                artists text NOT NULL,
                release_date text NOT NULL,
                link text,
                art_link text NOT NULL,
                status text DEFAULT "queued"
            )
            '''
        )

        self.conn.commit()
```

Here I've named each column directly in line with the attributes we gave to the 
`SpotifyAlbum` class in the previous post. This set-up will help us translate
between database records and object instances later on.

There's one additional part of this that I've not detailed yet - as noted in the
comment alongside it, setting `self.conn.row_factory = sqlite3.Row` allows us to 
get rows returned from the database as Python dictionaries. Again, this will 
make life easier later on.

Now we can start to write methods for this object corresponding to each of our
actions. Each of the following sections should be considered as adding onto the 
initial class outline above.

## Checking if an album already exists in the table {#check-exists}
We don't want to have duplicate albums in the table, so the first step before
adding any album in should be to check whether it's already present. This method
could look something like the following:

```python
class AlbumDatabase:
    def __init__(self, db_path='spotify albums.sqlite'):
        # ...

    def contains_album(self, album: SpotifyAlbum):
        self.cursor.execute('''
            SELECT * FROM albums 
            WHERE
                name = ?
                AND artists = ?
                AND release_date = ?
            LIMIT 1
            ''',
            (album.name, album.artists, album.release_date)
        )

        resp = self.cursor.fetchone()

        return resp and len(resp) > 0
```

You'll notice I haven't matched on all columns in the database when trying to 
find an album. I've excluded them for the following reasons:

- `link` _could_ change but as long as the existing link in the database is 
  valid, we don't mind it being different
- `art_link` is similar
- `status` we don't care about in this context - if it's in the database, then 
  it's either been, being or waiting to be processed. We don't need to add it 
  again

This leaves us with `name`, `artists` and `release_date` to identify a unique
album. In writing this down, I've realised there might actually be edge cases
where this isn't enough - for example, a single and an album with the same name
and the same release date. There's also a chance that these three columns may
be updated if the information was originally input incorrectly. Spotify does
provide a [unique(?) ID](<https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids>)
for different objects including albums which seems as though it would be less 
likely to change. We should be using this instead to identify our albums.

To use this, we will need to go back and update our `SpotifyAlbum` object from 
the previous post. Fortunately, `id` is a key available directly from each 
`album` object in the response. So we can simply make the change by adding a 
single extra line when we create our album object:

```python
class SpotifyAlbum:
    def __init__(self, resp_dict):
        self.name = resp_dict.get('name', None)
        self.release_date = resp_dict.get('release_date', 'Unknown')
        self.id = resp_dict.get('id', None)
```

This means we will also need to change the creation of the `albums` table above, 
but in turn this simplifies our `contains_album()` method:

```python
class AlbumDatabase:
    def __init__(self, db_path='spotify albums.sqlite'):
        # ...
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS albums (
                id text NOT NULL,
                name text NOT NULL,
                artists text NOT NULL,
                release_date text NOT NULL,
                link text,
                art_link text NOT NULL,
                status text DEFAULT "queued"
            )
            '''
        )
        #...

    def contains_album(self, album: SpotifyAlbum):
        self.cursor.execute('''
            SELECT * FROM albums 
            WHERE
                id = ?
            LIMIT 1
            ''',
            (album.id, )
        )

        resp = self.cursor.fetchone()

        return resp and len(resp) > 0
```

This should give us something that mitigates for our edge case! It will return 
`True` if the album is in our database, and `False` if it isn't.

## Adding new album(s) to the table {#add-album}
When we add to our database, there are going to be situations where we need to 
add multiple albums to the database at once. With up to 50 tracks returned by
the Spotify API this seems like it could be quite likely, particularly when the
bot first starts running and the database isn't highly populated. With that in
mind, it makes sense to use a set-up that allows us to batch-insert records into 
the database to keep processes running quickly and smoothly. Again, `sqlite3` 
allows us to do this simply with the `executemany()` method. 

We will also want to use the method defined in the previous section to check the
albums aren't already in the database before we add them in. This double-checks
we're not accidentally bringing in duplicates.

Combining these ideas gives us the following:

```python
class AlbumDatabase:
    def __init__(self, db_path='spotify albums.sqlite'):
        # ...

    def contains_album(self, album: SpotifyAlbum):
        # ...

    def add_albums(self, albums):
        filter_new = [
            album for album in albums if not self.contains_album(album)
        ]

        # Catch in case we have nothing new to add
        if filter_new:
            self.cursor.executemany('''
                INSERT INTO albums (
                    id, name, artists, release_date, link, art_link
                )
                VALUES (?, ?, ?, ?, ?, ?)
                ''',
                [
                    (
                        album.id, album.name, album.artists, album.release_date,
                        album.link, album.art_link
                    )
                    for album in filter_new
                ]
            )

            self.conn.commit()
```

We filter to only albums not already contained in the database, then add them in 
as one batch operation. If there are no new albums to add (i.e. 
`filter_new = []`) then the call is skipped. Nothing complicated, nice and easy.

## Getting album(s) from the table {#get-album}
The previous two sections address the process that checks and updates our 
database, so now we can move onto the process that gets data from it.

When we query the database, we want to pull out the next album that's queued up
to be posted. Now ideally, this will already be a `SpotifyAlbum` object that we 
can apply any operations to and pull attributes from. This is one of the reasons
to have our rows returned as dictionaries - our `SpotifyAlbum` constructor 
already takes a dictionary, the one returned by the Spotify API. Unfortunately,
that dictionary is nested for various attributes while the dictionary we return
from our database has all of the keys directly available. We could modify this
dictionary, but it's easy to instead add a flag to our constructor that lets us
use this kind of dictionary.

So, our `SpotifyAlbum` constructor changes again to be as follows:

```python
class SpotifyAlbum:
    def __init__(self, resp_dict, from_api=True):
        self.name = resp_dict.get('name', None)
        self.release_date = resp_dict.get('release_date', 'Unknown')
        self.id = resp_dict.get('id', None)

        if from_api:
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
        else:
            self.artists = resp_dict.get('artists', 'Unknown')
            self.link = resp_dict.get('link', None)
            self.art_link = resp_dict.get('art_link', None)
```

This flag lets us easily pull the values from our flat dictionary without 
altering any of the functionality for processing responses from the API.

Now we can get our next queued album from the database and return it as a 
`SpotifyAlbum` object ready for processing:

```python
class AlbumDatabase:
    def __init__(self, db_path='spotify albums.sqlite'):
        # ...

    def contains_album(self, album: SpotifyAlbum):
        # ...

    def add_albums(self, albums):
        # ...

    def get_from_queue(self):
        self.cursor.execute('''
            SELECT * FROM albums
            WHERE
                status="queued"
            LIMIT 1
            '''
        )

        resp = self.cursor.fetchone()
        if resp is not None:
            # convert from Row to dict
            resp_dict = dict(resp)

            # return Album object
            return SpotifyAlbum(resp_dict, from_api=False)
        else:
            return None
```

Note that we `LIMIT` our query to a single row to ensure we only get one album
back and use the `fetchone()` method anyway, just to be super-sure we're only
getting one album back. Combined these will hopefully keep our queries speedy!

## Updating the status of an album in the table {#update-album}
Lastly, we need a method to let us update an album's status. As mentioned 
earlier, we have three main states - queued, being processed or completed. To
mitigate for unforseen errors, we're going to allow a 4th status - one that 
simply lets us know that there has been some kind of error. Hopefully we won't 
get any, but if there is some issue with an album (e.g. the links changing) then
we don't want it to go back into the queue. This leaves us with the following:

```python
class AlbumDatabase:
    def __init__(self, db_path='spotify albums.sqlite'):
        # ...

    def contains_album(self, album: SpotifyAlbum):
        # ...

    def add_albums(self, albums):
        # ...

    def get_from_queue(self):
        # ...

    def update_album(self, album: SpotifyAlbum, status='processing'):
        if not status in ('queued', 'processing', 'completed', 'error'):
            raise ValueError(
                'status should be one of "queued", "processing", "completed" '
                f'or "error", received {status}'
            )
        
        self.cursor.execute('''
            UPDATE albums
            SET status=?
            WHERE
                id = ?
            ''',
            (status, album.id)
        )

        self.conn.commit()
```

## Final script
Combining all of this we get the following script:

```python
import sqlite3

from .album import SpotifyAlbum


class AlbumDatabase:
    def __init__(self, db_path='spotify albums.sqlite'):
        self.conn = sqlite3.connect(db_path)
        # Get responses as dictionary
        self.conn.row_factory = sqlite3.Row

        self.cursor = self.conn.cursor()

        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS albums (
                id text NOT NULL,
                name text NOT NULL,
                artists text NOT NULL,
                release_date text NOT NULL,
                link text,
                art_link text NOT NULL,
                status text DEFAULT "queued"
            )
            '''
        )

        self.conn.commit()

    def contains_album(self, album: SpotifyAlbum):
        self.cursor.execute('''
            SELECT * FROM albums 
            WHERE
                id = ?
            LIMIT 1
            ''',
            (album.id, )
        )

        resp = self.cursor.fetchone()

        return resp and len(resp) > 0

    def add_albums(self, albums):
        filter_new = [
            album for album in albums if not self.contains_album(album)
        ]

        # Catch in case we have nothing new to add
        if filter_new:
            self.cursor.executemany('''
                INSERT INTO albums (
                    id, name, artists, release_date, link, art_link
                )
                VALUES (?, ?, ?, ?, ?, ?)
                ''',
                [
                    (
                        album.id, album.name, album.artists, album.release_date,
                        album.link, album.art_link
                    )
                    for album in filter_new
                ]
            )

            self.conn.commit()

    def update_album(self, album: SpotifyAlbum, status='processing'):
        if not status in ('queued', 'processing', 'completed', 'error'):
            raise ValueError(
                'status should be one of "queued", "processing", "completed" '
                f'or "error", received {status}'
            )
        
        self.cursor.execute('''
            UPDATE albums
            SET status=?
            WHERE
                id = ?
            ''',
            (status, album.id)
        )

        self.conn.commit()
    
    def get_from_queue(self):
        self.cursor.execute('''
            SELECT * FROM albums
            WHERE
                status="queued"
            LIMIT 1
            '''
        )

        resp = self.cursor.fetchone()
        if resp is not None:
            # convert from Row to dict
            resp_dict = dict(resp)

            # return Album object
            return SpotifyAlbum(resp_dict, from_api=False)
        else:
            return None
```

## Putting it into use
Now that we're adding complexity into our processing, it makes sense to use 
Python's module structure to organise it. Seeing as the procvess is ultimately
to pull colours from album artwork, I've called the module `colour_puller`.
At present, it contains three files:

- An empty `__init__.py`;
- `album.py`, which contains our `SpotifyAlbum` class; and
- `database.py`, which contains our `AlbumDatabase` class.

With this structure in place, we can more-or-less finalise the process for 
adding new albums from the Spotify API:

```python
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

from colour_puller.album import SpotifyAlbum
from colour_puller.database import AlbumDatabase


auth = spotipy.SpotifyOAuth(
    redirect_uri='http://localhost:8888/callback', username='valeadam'
)

sp = spotipy.Spotify(auth_manager=auth)

recently_played = sp.current_user_recently_played()

recent_albums = []

for item in recently_played['items'][::-1]:
    album = SpotifyAlbum(item['track']['album'])
    if album.art_link and not any(prev == album for prev in recent_albums):
        recent_albums.append(album)

ad = AlbumDatabase()

ad.add_albums(recent_albums)
```

With this in place, we can move on to extracting the colour palette from the 
album artwork and posting it.