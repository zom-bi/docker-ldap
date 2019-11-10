FROM debian:buster
EXPOSE 389

ENV DEBIAN_FRONTEND noninteractive \
    CONFDIR /etc/ldap/slapd.d \
    DATADIR /var/lib/ldap

# add our users and groups first to ensure their IDs get assigned consitently
RUN groupadd -r -g 500 openldap && useradd -r -u 500 -g openldap openldap

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        slapd \
        ldap-utils \
        gnutls-bin \
        ssl-cert \
        ca-certificates && \
    # allow access to certificates
    usermod -a -G ssl-cert openldap && \
    # remove the default config, since the entrypoint
    # will populate it by hand.
    rm -rf /etc/ldap/slapd.d && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /entrypoint.sh
COPY scripts/ /
COPY fixtures/ /usr/share/slapd/fixtures/

ENTRYPOINT ["/entrypoint.sh"]
