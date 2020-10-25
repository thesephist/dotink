---
title: "Histools: visualizing my browser history over time with Ink and Torus"
date: 2020-10-24T22:53:37-04:00
---

Today I made [**Histools**](https://github.com/thesephist/histools), a small set of tools for visualizing browser history data from Apple's Safari browser. It renders a heatmap of pages visited on Safari over time, alongside a searchable, sorted list of pages I've visited most often with mini-heatmaps for each URL.

![Histools screenshot](/img/histools.png)

Histools is built on my homebrew tech stack: Ink for the analysis script and server and the Torus UI library for the interactive visualizations. If you want to run Histools over your own Safari history file, you can find the how-to's in the GitHub readme linked here. In the rest of this post, I want to explore how Safari stores its history entries on disk.

<a href="https://github.com/thesephist/histools" class="button">See Histools on GitHub &rarr;</a>

## Inspecting Safari's history database

Histools works by transforming history data from the database into a format that can be usefully visualized on a heatmap. In macOS Catalina, Safari keeps history in a simple SQLite3 database, at `~/Library/Safari/History.db`. So the first step for me was to copy this database file out to a safe location, and open the sqlite shell to look at the database schema.

```
sqlite History.db ".schema"
```

This returns us all of the table definitions, which you can also check out [here](https://github.com/thesephist/histools/blob/main/meta/History.schema.sql). For the sake of looking at history, we're only really concerned with two tables: `history_items` and `history_visits`. Here's what those tables looks like.

```
CREATE TABLE history_items
(
    id INTEGER PRIMARY KEY autoincrement,
    url text NOT NULL UNIQUE,
    domain_expansion text NULL,
    visit_count INTEGER NOT NULL,
    daily_visit_counts BLOB NOT NULL,
    weekly_visit_counts BLOB NULL,
    autocomplete_triggers BLOB NULL,
    should_recompute_derived_visit_counts INTEGER NOT NULL,
    visit_count_score                     INTEGER NOT NULL
);

CREATE TABLE history_visits
(
    id           INTEGER PRIMARY KEY autoincrement,
    history_item INTEGER NOT NULL REFERENCES history_items(id) ON DELETE CASCADE,
    visit_time REAL NOT NULL,
    title text NULL,
    load_successful boolean NOT NULL DEFAULT 1,
    http_non_get    boolean NOT NULL DEFAULT 0,
    synthesized     boolean NOT NULL DEFAULT 0,
    redirect_source INTEGER NULL UNIQUE REFERENCES history_visits(id) ON DELETE CASCADE,
    redirect_destination INTEGER NULL UNIQUE REFERENCES history_visits(id) ON DELETE CASCADE,
    origin     INTEGER NOT NULL DEFAULT 0,
    generation INTEGER NOT NULL DEFAULT 0,
    attributes INTEGER NOT NULL DEFAULT 0,
    score      INTEGER NOT NULL DEFAULT 0
);
```

Safari stores new history entries in two different formats, one for efficiently looking through _distinct_ history entries, and one for recording visits, with timestamp information. Namely, `history_items` stores distinct history entries by their URL, and `history_visits` stores information Safari expects to change with every visit, like the timestamp, load success state, and (curiously) the page title.

From this schema, we can also see that each history visit points to exactly one history item -- there can be one or more visits to the same URL. On each visit, Safari will add a new history visit entry and increment some aggregate information for the corresponding history item, like the total `visit_count`.

Like any good exploration, the answer to one question also opens up many others. What are the `score`s next to each page? What's a `synthesized` visit? What are `autocomplete_triggers` used for? I haven't had a chance to dive into those yet, because there's also plenty of fun to be had playing around with the Histools visualization itself. From the heatmap, I can see when I go to sleep each day and when I wake up in the morning (or the few times I was woken up overnight). I can see when my homework was due, when I was researching certain topics, and so on and on and on.

I'm looking forward to spinning up Histools from time to time to get another perspective on how I've been using the Web in my life.

