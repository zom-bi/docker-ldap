## slapd
Slapd offers a LDAP server, which we mostly use for authentication of various
services.
Therefore, a lot of services have a direct (or indirect) dependency on this
image.

### Getting the image
This image is automatically build and pushed to the docker hub. Therefore
getting the image should be as easy as running

```
docker pull zombi/ldap
```

### Building slapd
It is also possible to manually build this image from this repository.

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
State stored in this container is essential to many other services, that
use authentication and authorization. Therefore you should think about
backing up the LDAP database in regular intervals.

**simply copying all the data from `data` MAY NOT WORK**, as there could
be race conditions leading to database corruption during the backup.
The recommended way is to use the included script for backing up the database
into a compact .ldif plain text file.

running `contrib/create-ldap-backup.sh` will create two files:
* `conf.ldif` is a backup of the configuration.
* `data.ldif` contains all the saved datasets.
