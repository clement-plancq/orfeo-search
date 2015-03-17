# orfeo-search

Web search interface for linguistic annotations


# Installation and Configuration

These are the steps from zero to running the Solr index server and the
search application. In this simple scenario, the Solr server runs on
localhost on port 8983, while Rails runs on localhost on port 3000 for
debugging purposes. Many other configurations are possible (e.g. Solr
could run on a different server altogether) but detailed setup of
those is beyond the scope of this readme.

The package orfeo-metadata must be installed before installing this
app. See the
[repository](https://github.com/larilampen/orfeo-metadata) for
installation instructions.

First, clone the git repository. The repository does not contain the
working file of the sqlite database, so database migrations must be
executed to create it:

```bash
git clone https://github.com/larilampen/orfeo-search.git
cd orfeo-search
rake db:migrate
```

A secret key (used to verify the integrity of signed cookies) should
be defined in the environment variable `SECRET_KEY_BASE`. If it is
undefined, the server will use insecure fallback keys for development
and test configurations. For production, a missing secret key prevents
starting up the server.

The secret key should be an unpredictable string of at least 30
characters. Note that changing the key invalidates all open sessions,
so it is advisable to store the key value in some (secure) way. To use
a new random secure secret key:

```bash
export SECRET_KEY_BASE=`rake secret`
```

Start the Solr index server, then start the search app itself:

```bash
rake jetty:start
rails server
```

Point your browser to http://localhost:3000/ to see the front page of
the search interface. To fill the index, refer to the documentation of
the associated
[importer module](https://github.com/larilampen/orfeo-importer).
