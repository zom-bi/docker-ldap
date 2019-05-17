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

#### Custom schema
every .ldif or .sh file will be evaluated on server startup, if it's placed
inside the '/docker-entrypoint-initdb.d/' directory. This allows you to
Specify custom behaviour of the LDAP Server.

By default the server will load the schema from the 'fixtures/' directory,
which will provide this features:

 * MDB backend for better performance
 * Indexing of most referenced attributes by default
 * Base structure with People, Groups, Sevices, Domains and Policies.
 * Simple but useful ACL rules, allowing users to change their own passwords.
 * Password policy for strong cryptographic hashing of user passwords and password rotation.
 * Referential integrity for e.g. group memberships.
 * Support for core, cosine, nis, inetorgperson, ppolicy and misc schemas.
 * Support for user-definable SSH public keys as attributes.
 * enforcing of username and user ID uniqueness.

### Configuration
The LDAP server can be configured for your organization using the environment variables:
 * `ROOTPW` password for the administration user that is created by default. Make this hard to guess!
 * `ORGANIZATION` Name of the organization running this LDAP server.
 * `SUFFIX` overwrites the root node for all entries. By default this will be 'o=organizationname', but for compatibility you might want to set this to 'dc=domain,dc=tld'.
 * `DATADIR` is the path to the directory containing the LDAP DATA; by default this is '/var/lib/ldap/'.
 * `CONFDIR` points to the path containing the server configuration, by default this is '/etc/ldap/slapd.d'.

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
