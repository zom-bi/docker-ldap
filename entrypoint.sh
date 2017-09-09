#!/bin/bash -e
set -eo pipefail

# set default values for undefined vars
CONFDIR=${CONFDIR:-'/etc/ldap/slapd.d'}
DATADIR=${DATADIR:-'/var/lib/ldap'}

if [[ -z "$ORGANIZATION" && -z "$SUFFIX" ]] ; then
  fail 'neither ORGANIZATION nor SUFFIX supplied as environment var'
fi

if [[ -n "$ORGANIZATION" ]] ; then
  # if an organization was set, we can generate the RootDN from that
  SUFFIX=${SUFFIX:-"o=${ORGANIZATION}"}
fi

function fail {
	# write to stderr
	echo "ERROR: $@" >&2
	exit 1
}

function configure {
	sed \
		-e "s|@SUFFIX@|${SUFFIX}|g" \
		-e "s|@PASSWORD@|${ROOTPW}|g" \
		-e "s|@DATADIR@|${DATADIR}|g" \
		/usr/share/slapd/fixtures/config.ldif \
		| slapadd -F "$CONFDIR" -b "cn=config"

	return $?
}

function init_fixtures {
  mkdir -p /docker-entrypoint-initdb.d
  # if no files exist in this directory then copy example structure
  if ! ls /docker-entrypoint-initdb.d/* 1> /dev/null 2>&1 ; then
    cp /usr/share/slapd/fixtures/example_structure.ldif /docker-entrypoint-initdb.d/structure.ldif
  fi

	for f in /docker-entrypoint-initdb.d/*; do

		case "$f" in
			*.sh)
				echo "$0: running $f"; . "$f"
				;;
			*.ldif)
				sed \
					-e "s|@SUFFIX@|${SUFFIX}|g" \
					-e "s|@PASSWORD@|${ROOTPW}|g" \
					-e "s|@DATADIR@|${DATADIR}|g" \
					-e "s|@ORGANIZATION@|${ORGANIZATION}|g" \
					"$f" \
					| slapadd -F "$CONFDIR" -b "$SUFFIX"
				;;
			*) echo "$0: ignoring $f" ;;
		esac
		echo
	done

}

# Reduce maximum number of open file descriptors to 1024
# otherwise slapd consumes two orders of magnitude more of RAM
# see https://github.com/docker/docker/issues/8231
ulimit -n 1024 || fail "could not set ulimits"

# create dirs if they not already exists
[ -d $CONFDIR ] || mkdir -p $CONFDIR
[ -d $DATADIR ] || mkdir -p $DATADIR

if [[ ! -d "$CONFDIR/cn=config" ]] ; then
	echo "configuration not found, creating one for $SUFFIX .."
	[[ -z "$ROOTPW" ]] && fail "ROOTPW not set."
	[[ -z "$SUFFIX" ]] && fail "SUFFIX not set."

	# if rootpw is not already in hashed format, hash it first
	[[ "${ROOTPW:0:1}" == '{' ]] \
		||ROOTPW=`slappasswd -s "$ROOTPW"`

	configure || fail "could not create slapd config"
fi

if [[ ! -f "$DATADIR/data.mdb" ]] ; then
	init_fixtures
fi

# fix file permissions
chown -R openldap:openldap $CONFDIR $DATADIR \
	|| fail "could not change permissions"

echo "Starting slapd."
exec /usr/sbin/slapd -F $CONFDIR -u openldap -g openldap -h 'ldapi:// ldap://' -d stats
