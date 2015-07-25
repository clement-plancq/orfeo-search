# orfeo-search

This is a web search interface for annotated text corpora based on
Apache Solr and [Blacklight](http://projectblacklight.org).

See the [orfeo](https://github.com/orfeo-treebank/orfeo)
repository for more information about project Orfeo.


# Installation and Configuration

The best way to install for a production environment is to use the automated installation script in the [orfeo](https://github.com/orfeo-treebank/orfeo) repository. The steps below describe how to set up the app for development. In this simple scenario, the Solr server runs on localhost on port 8983, while Rails runs on localhost on port 3000 for debugging purposes.

The package orfeo-metadata must be installed before installing this
app. See the
[repository](https://github.com/orfeo-treebank/orfeo-metadata) for
installation instructions.

First, clone the git repository. The repository does not contain the
working file of the sqlite database, so database migrations must be
executed to create it:

```bash
git clone https://github.com/orfeo-treebank/orfeo-search.git
cd orfeo-search
rake db:migrate
```

The metadata model (defined by the orfeo-metadata gem) must be
incorporated into the Solr schema file. This is handled by a rake
task. The same task also sets a password for Solr, which must be
provided as a parameter:

```bash
rake orfeo:update password=PASSWORD
```

Note that the `orfeo:update` task creates some files required to start
Solr, which means that attempting to start the app before the above
task has been executed will result in failure.

It is strongly recommended that a secret key (used to verify the integrity of signed cookies) be defined in the environment variable `SECRET_KEY_BASE`. If it is undefined, the server will use insecure fallback keys. Note that contrary to conventional security protocol, even the production version can be run with a fallback key. The rationale for allowing this potential security risk is that since all of project Orfeo's data sets are accessible to the public, there is no confidential information at risk. Nevertheless, it is good practice to use an environment variable as stated above.

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
[importer module](https://github.com/orfeo-treebank/orfeo-importer).
