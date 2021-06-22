# Dockerized Taxa Tree Generators

Dockerized version of [Taxa Tree
Generators](https://github.com/specify/taxa_tree/)

## Installation

Clone the repositories:

```bash
git clone --single-branch --branch main https://github.com/specify/taxa_tree ./taxa_tree_gbif
git clone --single-branch --branch catalogue_of_life_2 https://github.com/specify/taxa_tree ./taxa_tree_col
git clone --single-branch --branch itis https://github.com/specify/taxa_tree ./taxa_tree_itis
git clone --single-branch --branch master https://github.com/specify/taxa_tree_stats ./taxa_tree_stats
```

## Config

Find the following line in the `./docker-compose.yml` file:

```yml
    args:
      LINK: "http://taxon.specifysoftware.org"
```

Change the `LINK` variable to an address where the server would be
publicly available.

## Usage

Start the containers:

```bash
docker-compose up
```

The first startup may take quite some time as the base container images
are downloaded, containers are built, taxa trees are downloaded and
cache is created.

The containers check for updates to the taxa files from the aggregators
every day (as specified in `./crontab`) and every time the containers
start.

