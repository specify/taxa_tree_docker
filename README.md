# Dockerized Taxa Tree Generators

Dockerized version of
[Taxa Tree Generators](https://github.com/specify/taxa_tree/)

Live version available at
[https://taxon.specifysoftware.org](https://taxon.specifysoftware.org)

## Installation

Clone the repositories:

```bash
git clone https://github.com/specify/taxa_tree_docker
cd taxa_tree_docker
git clone --single-branch --branch gbif https://github.com/specify/taxa_tree ./taxa_tree_gbif
git clone --single-branch --branch itis https://github.com/specify/taxa_tree ./taxa_tree_itis
git clone --single-branch --branch catalogue_of_life_3 https://github.com/specify/taxa_tree ./taxa_tree_col 
git clone --single-branch --branch master https://github.com/specify/taxa_tree_stats ./taxa_tree_stats
git clone --single-branch --branch worms https://github.com/specify/taxa_tree ./taxa_tree_worms
git clone https://github.com/specify/taxa_tree_stats
```

Install certbot and generate the certificates

```bash
sudo certbot certonly -d taxon.specifysoftware.org
```

---
In development, you can generate some test certificates by running these commands inside the `taxa_tree_docker` dir:

```bash
openssl genrsa -out privkey.pem 2048
openssl req -new -key privkey.pem -out localhost.csr
openssl x509 -req -days 365 -in localhost.csr -signkey privkey.pem -out fullchain.pem
```

---

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
docker cp /full/path/on/your/system/to/archive.zip taxa_tree_docker-back_end-1:/home/specify/taxa_tree_worms_working_dir/archive.zip
```

## Update data

To begin, you'll need to call the `update-taxa` shell script file in the back-end container.

**Catalogue of Life:**
```bash
docker exec taxa_tree_docker-back_end-1 sh -c "cd /home/specify/taxa_tree_col/back_end/ && /home/specify/venv/bin/python3 refresh_data.py"
```

**GBIF:**
```bash
docker exec taxa_tree_docker-back_end-1 sh -c "cd /home/specify/taxa_tree_gbif/back_end/ && /home/specify/venv/bin/python3 refresh_data.py"
```

**ITIS:**
```bash
docker exec taxa_tree_docker-back_end-1 sh -c "cd /home/specify/taxa_tree_itis/back_end/ && /home/specify/venv/bin/python3 refresh_data.py"
```


**WoRMS:** (Requires the WoRMS archive in the previous step)
```bash
docker exec taxa_tree_docker-back_end-1 sh -c "cd /home/specify/taxa_tree_worms/back_end/ && /home/specify/venv/bin/python3 refresh_data.py"
```

****

## Regular updates

It is recommended to also configure a CRON job to check for taxa updates from
each provider.

Example crontab:

```
0 4 * * * docker exec taxa_tree_docker-back_end-1 ./update-taxa.sh >> /home/specify/update-taxa.log 2>&1
```
