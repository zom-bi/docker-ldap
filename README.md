## slapd
Slapd offers a LDAP server, which we mostly use for authentication of various
services.
Therefore, a lot of services have a direct (or indirect) dependency on this
image.

### Building slapd

```
docker build -t zombi/ldap .
```

### Running slapd

Copy over example configuration

```bash
cp docker-compose.yml{.example,}
```

run the service

```
docker-compose up -d
```

### Backing up data
Data in this container is considered essential, since it influences almost
all other services we run.

We recently discovered that **simply copying all the data from `data` DOES
NOT WORK**, therefore we included scripts for backing up the slapd database
into a compact .ldif format.

running `tools/create-ldap-backup.sh` will create two files:
* `conf.ldif` is a backup of the configuration.
* `data.ldif` contains all the saved datasets.

