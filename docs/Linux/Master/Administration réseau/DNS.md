---
hide:
  - footer
---

# Les DNS

!!!info "Objectifs"
    - Déclarer le serveur DNS

    - Etre un salve d'un autre serveur

## Bind

Installation de bind :

```bash
dnf install -y bind
```

Observation des nouvelles installations :

```bash
rpm -ql bind | grep /etc/
```

Mise en place de l'ecoute sur l'ip "publique" dans `/etc/named.conf` :

```bash linenums="1" hl_lines="2"
options {
        listen-on port 53 { 127.0.0.1; 10.56.126.223};
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        allow-query     { localhost; };

        /*
         - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
         - If you are building a RECURSIVE (caching) DNS server, you need to enable
           recursion.
         - If your recursive DNS server has a public IP address, you MUST enable access
           control to limit queries to your legitimate users. Failing to do so will
           cause your server to become part of large scale DNS amplification
           attacks. Implementing BCP38 within your network would greatly
           reduce such attack surface
        */
        recursion yes;

        dnssec-validation yes;

        managed-keys-directory "/var/named/dynamic";
        geoip-directory "/usr/share/GeoIP";

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";

        /* https://fedoraproject.org/wiki/Changes/CryptoPolicy */
        include "/etc/crypto-policies/back-ends/bind.config";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "." IN {
        type hint;
        file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

Ajout d'une ACL que l'on pourra réutiliser : 

```bash linenums="1"
acl mes-clients {
    10.56.126.0/24;
};
```

Ajout de *mes-clients* sur la ligne suivante: 

```bash
allow-query     { localhost; mes-clients; };
```