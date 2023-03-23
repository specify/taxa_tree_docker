# Dockerized Taxa Tree Generators

Dockerized version of
[Taxa Tree Generators](https://github.com/specify/taxa_tree/)

Live version available at
[https://taxon.specifysoftware.org](https://taxon.specifysoftware.org)

## Installation

Clone the repositories:

```bash
git clone https://github.com/specify/taxa_tree
cd taxa_tree
git clone --single-branch --branch gbif https://github.com/specify/taxa_tree ./taxa_tree_gbif
git clone --single-branch --branch itis https://github.com/specify/taxa_tree ./taxa_tree_itis
git clone --single-branch --branch catalogue_of_life_3 https://github.com/specify/taxa_tree ./taxa_tree_col 
git clone --single-branch --branch master https://github.com/specify/taxa_tree_stats ./taxa_tree_stats
git clone --single-branch --branch worms https://github.com/specify/taxa_tree ./taxa_tree_worms
```

Install certbot and generate the certificates

```
sudo certbot certonly -d taxon.specifysoftware.org
```

Modify the nginx's volumes section of `docker-compose.yml` to point to
the location of `fullchain.pem` and `privkey.pem`

```yaml
      - './fullchain.pem:/etc/letsencrypt/live/taxon.specifysoftware.org/fullchain.pem:ro'
      - './privkey.pem:/etc/letsencrypt/live/taxon.specifysoftware.org/privkey.pem:ro'
```

You can configure regular certificate renewal, but that is beyound
the scope of this documentation

## Config

Find the following line in the `./docker-compose.yml` file:

```yml
args:
  LINK: 'https://taxon.specifysoftware.org'
```

Change the `LINK` variable to an address where the server would be publicly
available.

To disable a certain provider, remove it from `update-taxa.sh` and
`index.html`.

## Usage

Start the containers:

```bash
docker-compose up
```

The first startup may take quite some time as the base container images are
downloaded, containers are built, taxa trees are downloaded and cache is
created.

### Copying WoRMS archive

Once you have obtained an archive of WoRMS data, you need to copy it to the correct directory in the back end container to generate the tree.

```bash
docker cp /full/path/on/your/system/to/archive.zip <backEndContainerName>:/home/specify/taxa_tree_worms_working_dir/archive.zip
```

### Refresh data

Once you enter the back-end container, navigate to `taxa_tree_worms/back_end/` and run `refresh_data.py`

```
~/taxa_tree_worms/back_end $ python3 refresh_data.py
```

## Regular updates

It is recommended to also configure a CRON job to check for taxa updates from
each provider.

Example crontab:

```
0 4 * * * docker exec taxa_tree_docker_back_end_1 ./update-taxa.sh >> /home/specify/update-taxa.log 2>&1
```
