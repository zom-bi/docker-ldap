## slapd
Slapd offers a LDAP server, which we mostly use for authentication of various
services.
Therefore, a lot of services have a direct (or indirect) dependency on this
image.

### Building slapd

```
docker build -t zombi/slapd .
```

### Running slapd

```
docker run -d --name ldap -v /data/ldap:/data -p 389:389 zombi/slapd
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

