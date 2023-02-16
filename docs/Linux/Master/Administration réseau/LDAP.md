---
hide:
  - footer
---

# LDAP

## Définition

LDAP est l'abréviation de Lightweight Directory Access Protocol (protocole léger d'accès à un annuaire). C'est un protocole de communication utilisé pour accéder à des annuaires en ligne, qui sont des bases de données contenant des informations sur des utilisateurs, des groupes, des ordinateurs et d'autres ressources réseau.

LDAP permet aux clients d'accéder à ces annuaires pour effectuer des opérations telles que la recherche, la lecture, la mise à jour et la suppression de données. Les annuaires LDAP sont utilisés dans de nombreuses applications, notamment pour la gestion des utilisateurs et des groupes, l'authentification et l'autorisation, la messagerie électronique, la voix sur IP, et bien d'autres.

LDAP utilise un modèle client-serveur et repose sur un ensemble de règles et de spécifications définies par l'Internet Engineering Task Force (IETF). Il est considéré comme un protocole efficace et sûr pour la gestion de données d'annuaire à grande échelle.

## Découverte et paramétrages

!!!success
        Changer toutes les commandes qui demande un editeur de texte comme ldapvi, on peut changer l'editeur avec :
        ```bash
        export EDITOR=nano
        ```

Recherche dans les schemas :

```bash
grep -rni --color PosixAccount /etc/openldap/schema/
```

Affichage des lignes de 161 à 180 du fichier `nis.schema` :

```bash
objectclass ( 1.3.6.1.1.1.2.0 NAME 'posixAccount'
        DESC 'Abstraction of an account with POSIX attributes'
        SUP top AUXILIARY
        MUST ( cn $ uid $ uidNumber $ gidNumber $ homeDirectory )
        MAY ( userPassword $ loginShell $ gecos $ description ) )

objectclass ( 1.3.6.1.1.1.2.1 NAME 'shadowAccount'
        DESC 'Additional attributes for shadow passwords'
        SUP top AUXILIARY
        MUST uid
        MAY ( userPassword $ shadowLastChange $ shadowMin $
              shadowMax $ shadowWarning $ shadowInactive $
              shadowExpire $ shadowFlag $ description ) )

objectclass ( 1.3.6.1.1.1.2.2 NAME 'posixGroup'
        DESC 'Abstraction of a group of accounts'
        SUP top STRUCTURAL
        MUST ( cn $ gidNumber )
        MAY ( userPassword $ memberUid $ description ) )
```

1 objet rentré dans l'annuaire doit obliatoirement avoir une classe structurale.

La classe Account se situe dans le fichier `cosine.schema` et cette classe est une classe Structurale :

```bash
objectclass ( 0.9.2342.19200300.100.4.5 NAME 'account'
        SUP top STRUCTURAL
        MUST userid
        MAY ( description $ seeAlso $ localityName $
                organizationName $ organizationalUnitName $ host )
        )
```

Démarrage de ldap :

```bash
systemctl start slapd
```

Plusieurs LDAP :

- Ldapi : Connexion avec le socket UNIX (locale)
- Ldaps : connexion avec des certficats (utlisé par des clients TLS)
- Ldap : connexion simple sans certificats (tuilisé par des clients non TLS)

Les commandes ***ldapwhoami*** permettent de tester l'accès à un annuaire.

Recherche et connexion dans l'annuaire avec connexion :

```bash
ldapsearch -Y EXTERNAL -H ldapi:/// -Q  -b CN=config
```

Options de filtres ( attention pas d'opérateur < ou > (opératuers strictes) ) :

- `= `(égal)
- `* `: joker
- `<=` (plus petit ou égal)
- `>=` (plus grand ou égal)
- `~= `(approximation)

Recherche portée avec scope `-s` et ses options :

- base (uniquement la base)
- sub (à partir de la base sur la totalité de la base)
- one (fils directs)

***ldapmodify*** utlise un schéma pour la modification :

- le DN,
    * **le type d'opération réalisée,**
    * changetype: add : pour ajouter une entrée
    * changetype: delete : pour supprimer une entrée
    * changetype: modify : pour modifier une entrée déjà présente
        - **La ligne du dessous mentionne alors le type de modification :**
        - add : attribut
        - delete : attribut
        - replace : attribut
            + **La ligne du dessous donne alors la nouvelle valeur de l'attribut**

Création d'un fichier pour modifier le mot de passe root :

```bash
dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: secret
```

Application de la modification : 

```bash
ldapmodify -Y EXTERNAL -H ldapi:/// -Q -f modif-rootpw.ldif
```
Observation de la modification avec la commande `ldapsearch -Y EXTERNAL -H ldapi:/// -Q -LLL -b 'olcDatabase={2}mdb,cn=config'` : 

```bash linenums="1" hl_lines="10"
dn: olcDatabase={2}mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {2}mdb
olcDbDirectory: /var/lib/ldap
olcSuffix: dc=my-domain,dc=com
olcRootDN: cn=Manager,dc=my-domain,dc=com
olcDbIndex: objectClass eq,pres
olcDbIndex: ou,cn,mail,surname,givenname eq,pres,sub
olcRootPW: secret
```

Pour obtenir un mot de passe chiffré, on utilise `slappasswd`.

!!!info "Saut de ligne"
        Dans les différents éditeurs, ceux-ci enregisre un saut de ligne qui est interprété par ldap (ex: mot de passe de 6 caractères comptera sur 7). Cela se suprrime avec la commande :
        ```bash
        echo -n secret > .ldappass
        ```
## Réalisation du travail

!!!abstract "Travail à réaliser"
        - [x] On cherche à créer une organisation "mon domaine domX.local" (entrée d'annuaire "organization")
              * [x] Création d'une OU "users" (entrée d'annuaire : organizationUnit")
                   + [x] Ajout d'une entrée basée sur posixAccount : "ldapuser1"
              * [x]  Création d'une OU "groups" (entrée d'annuaire : organizationUnit")
                   + [x] Ajout d'une entrée basée sur posixGroup : "ldapgroup1"

### Création d'une organisation avec la création d'un fichier `org.ldif`

```bash
dn: dc=dom3,dc=local
objectClass: organization
objectClass: dcObject
o: Mon domaine dom0.local
```

On ajout l'organistaion avec :

```bash
ldapadd -D cn=leo,dc=dom3,dc=local -y ~/.ldappass -f org.ldif -c
```

!!!info
        L'option `-c` permet de continuer si des lignes provoquent des erreurs


Dans la suite des travaux, nous continurons dans le fichier `org.ldif`.

### Création d'une OU "users"

```bash 
dn: ou=users,dc=dom3,dc=local
objectClass: organizationalUnit
```

### Ajout d'un utilisateur `ldapuser1` 

Ajout du schéma inetorgperson :

```bash
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
```

Ajout de l'utilisateur ici dans `groups`:

```bash linenums="1"
dn: cn=ldapuser1,ou=groups,dc=dom3,dc=local
objectClass: posixAccount
objectClass: inetOrgPerson
cn: Youzer Un
gn: Youzer
sn: Un
uid: ldpauser1
uidNumber: 10001
gidNumber: 10000
homeDirectory: /home/ldapuser1
```

Ajout d'utilisateur ici dans `users` :

```bash linenums="1"
dn: cn=ldapuser1,ou=users,dc=dom3,dc=local
objectClass: posixAccount
objectClass: inetOrgPerson
cn: Youzer Un
gn: Youzer
sn: Un
uid: ldapuser1
uidNumber: 10001
gidNumber: 10000
homeDirectory: /home/ldapuser1
```

### Création d'une OU "groups"

```bash
dn: ou=groups,dc=dom3,dc=local
objectClass: organizationalUnit
```

### Ajout d'un groupe `ldapgroup1` 

On cherche dans les schémas les références à posixGroup :

```bash
grep -rni --color PosixGroup /etc/openldap/schema/
```

On retrouve dans le fichier `nis.schema` que l'identifiant est *gidnumber*. 

On ajoute le schema nis.ldif :

```bash
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
```

On cherche l'erreur suivante sur les `manager` que l'on trouve dans cosine.schema. On ajoute ensuite le fichier ldif :

```bash
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
```

Si il y a des erreurs, il faut intégrer les fichier dans l'ordre `nis.ldif` puis `cosine.ldif`.

Code définitif pour la création :

```bash
dn: cn=ldapgroupe1,ou=groups,dc=dom3,dc=local
objectClass: posixGroup
gidNumber: 10000
```

## PAM

PAM permet d'authentifier des utilisateurs en utilisant LDAP.

On cherche les fichiers de PAM avec `/etc/pam.d/`.

Le fichier `other` est présent lorsque aucun fichier du nom du programme existe.

Pour voir si un programme dépend de pam ou tout autre programme, on utilise `ldd`. Par exemple pour ***passwd***, on obtient :

```bash linenums="1" hl_lines="6"
        linux-vdso.so.1 (0x00007ffcf63ec000)
        libuser.so.1 => /lib64/libuser.so.1 (0x00007ff80b72f000)
        libgobject-2.0.so.0 => /lib64/libgobject-2.0.so.0 (0x00007ff80b6d4000)
        libglib-2.0.so.0 => /lib64/libglib-2.0.so.0 (0x00007ff80b59a000)
        libpopt.so.0 => /lib64/libpopt.so.0 (0x00007ff80b58b000)
        libpam.so.0 => /lib64/libpam.so.0 (0x00007ff80b579000)
        libpam_misc.so.0 => /lib64/libpam_misc.so.0 (0x00007ff80b573000)
        libaudit.so.1 => /lib64/libaudit.so.1 (0x00007ff80b543000)
        libselinux.so.1 => /lib64/libselinux.so.1 (0x00007ff80b516000)
        libc.so.6 => /lib64/libc.so.6 (0x00007ff80b200000)
        libgmodule-2.0.so.0 => /lib64/libgmodule-2.0.so.0 (0x00007ff80b510000)
        libcrypt.so.2 => /lib64/libcrypt.so.2 (0x00007ff80b4d6000)
        libffi.so.8 => /lib64/libffi.so.8 (0x00007ff80b4ca000)
        libpcre.so.1 => /lib64/libpcre.so.1 (0x00007ff80b450000)
        libeconf.so.0 => /lib64/libeconf.so.0 (0x00007ff80b445000)
        libm.so.6 => /lib64/libm.so.6 (0x00007ff80b125000)
        libcap-ng.so.0 => /lib64/libcap-ng.so.0 (0x00007ff80b43c000)
        libpcre2-8.so.0 => /lib64/libpcre2-8.so.0 (0x00007ff80b089000)
        /lib64/ld-linux-x86-64.so.2 (0x00007ff80b762000)
```

On observe ligne 6, que le programme nécéssite PAM pour focntionner.

Pour l'authentification, le fichier de PAM `/etc/pam.d/system_auth` présente les règles d'authentifications.

```bash linenums="1"
auth        required      pam_env.so
auth        sufficient    pam_unix.so try_first_pass nullok
auth        required      pam_deny.so
```
!!!note
        PAM est appelé pour le login et ne donnera jamais l'élément qui à échoué. 

Chez PAM, plusieurs stratégies sont prédéfinies :

- Required : Réussir le module est nécessaire, on annoncera une erreur à la fin du traitement uniquement si 1 des
modules "required" échoue.
- Requisite : Réussir le module est nécessaire : la première erreur (on annoncera laquelle) est synonyme d'abandon
- Sufficient : La réussite du module est suffisante pour que l'on valide le contexte. On ne fait pas l'analyse des
modules qui suivent (même required ou requisite) dans le contexte
- Optional : La réussite d'un module optional est nécessaire si les autres sont ignorés. Le module n'est pas appelé si
un autre module réussit ou échoue
- Include : sert à brancher vers un sous-fichier de règles PAM

## SSSD

Pourquoi utiliser SSHD ? Car SSHD est plus récent que PAM pour LDAP.

Installation des packages SSHD :

```bash
dnf -y install sssd sssd-ldap sssd-tools oddjob oddjob-mkhomedir
```

Démarrage du service :

```bash
systemctl enable --now oddjobd.service
```

Authselect permet de configurer des profils d'authentifications.

Nous pouvons lister les profils avec `authselect list` :

```bash
- minimal        Local users only for minimal installations
- sssd           Enable SSSD for system authentication (also for local users only)
- winbind        Enable winbind for system authentication
```

Configuration de PAM avec SSHD :

```bash 
authselect select --force sssd with-mkhomedir
```

Si on regarde maintenant le fichier de pam `system_auth` :

```bash
auth        required                                     pam_env.so
auth        required                                     pam_faildelay.so delay=2000000
auth        [default=1 ignore=ignore success=ok]         pam_usertype.so isregular
auth        [default=1 ignore=ignore success=ok]         pam_localuser.so
auth        sufficient                                   pam_unix.so nullok
auth        [default=1 ignore=ignore success=ok]         pam_usertype.so isregular
auth        sufficient                                   pam_sss.so forward_pass
auth        required                                     pam_deny.so
```

On observe de nouvelles lignes qui se sont ajoutées dans le fichier avec des paramètres supplémentaires.

### Configuration de SSS

Ajout d'un fichier de configuration `/etc/sssd/sssd.conf` :

```bash
[sssd]
services = nss, pam
domains = dom3.local

[nss]
filter_users = root
filter_groups = root

[domain/dom3.local]
cache_credentials = true
id_provider = ldap
auth_provider = ldap
ldap_uri = ldap://10.56.126.220
#ldap_tls_reqcert = demand
ldap_search_base = dc=dom3,dc=local
ldap_user_search_base = ou=users,dc=dom3,dc=local
ldap_groups_search_base = ou=groups,dc=dom3,dc=local

[pam]
offline_credentials_expiration = 1
offline_failed_login_attempts = 3
offline_failed_login_delay = 5
```

Modification des droits en 600 :

```bash
chmod 600 /etc/sssd/sssd.conf
```

Démarrage du service SSSD qui nécéssitait un fichier de configuration :

```bash
systemctl restart sssd
```

On verifie la connexion avec `sssctl user-checks ldapuser1` (ici un extrait du message retour):

```bash linenums="1"
user: ldapuser1
action: acct
service: system-auth

SSSD nss user lookup result:
 - user name: ldapuser1
 - user id: 10001
 - group id: 10000
 - gecos: Youzer Un
 - home directory: /home/ldapuser1
 - shell:
```
Verficiation aussi avec `id ldapuser1` :

```bash
uid=10001(ldapuser1) gid=10000(ldapgroupe1) groupes=10000(ldapgroupe1)
```

### Certification avec TLS

#### Certificat auto-signé

Création d'un dossier avec des droits personnalisés sur le serveur :

```bash
install -d -m 2750 -o root -g ldap /etc/openldap/certs
```

Création des documents `ca.pem` et `ca-key.pem` :

```bash
openssl req \
-newkey rsa:4096 -nodes -keyout /etc/openldap/certs/ca-key.pem \
-subj '/countryName=FR/stateOrProvinceName=Bretagne/organizationName=Actilis/CN=CA-LDAP/' \
-x509 -sha256 -days 365 \
-extensions v3_ca \
-out /etc/openldap/certs/ca.pem
```

Ajout des droits sur le fichier `ca.pem` :

```bash
chmod 444 /etc/openldap/certs/ca.pem
```

#### Certificat serveur

Création des fichiers `server.csr` et `key.pem` :

```bash
openssl req \
-newkey rsa:4096 -nodes -keyout /etc/openldap/certs/key.pem \
-subj '/CN=dom3.local/' \
-out server.csr
```

Ajout des permissions :

```bash
chmod 440 /etc/openldap/certs/key.pem
```

#### Tamponnage du fichier 

```bash
openssl x509 -req -days 365 -sha256 -in server.csr -out /etc/openldap/certs/cert.pem \
-CA /etc/openldap/certs/ca.pem -CAkey /etc/openldap/certs/ca-key.pem -CAcreateserial \
-extfile <(printf "basicConstraints = CA:FALSE\n subjectAltName=IP:127.0.0.1,IP:10.56.126.220,DNS:ldap.dom3.local")
```

Verifications du certificat :

```bash
openssl x509 -noout -subject < /etc/openldap/certs/cert.pem
```

#### Intégration des configurations

Ajouter un fichier tls.ldif :

```bash linenums="1"
dn: cn=config
changetype: modify
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/openldap/certs/ca.pem
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/cert.pem
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/key.pem
```

Ajout de la configuration avec `ldapmodify` :

```bash
ldapmodify -Y EXTERNAL -H ldapi:/// < tls.ldif
```


Modification et ajout du fichier `/etc/openldap/ldap.conf` :

```bash
TLS_CACERT /etc/openldap/certs/ca.pem
TLS_REQCERT demand
``` 

Ajout pour sudo :

```bash
dn: cn=defaults,ou=SUDOers,dc=example,dc=com
objectClass: top
objectClass: sudoRole
cn: defaults
description: Default sudoOption's go here
sudoOption: env_keep+=SSH_AUTH_SOCK
```

Téléchargement de  schema2ldif :

- [Documentation](https://fusiondirectory-user-manual.readthedocs.io/en/1.3/index.html) de schema2ldif
- Ajout d'un repo avec la création d'un fichier `/etc/yum.repos.d/fusion.repo` :
```bash
[fusiondirectory-schema2ldif-release]
name=Fusiondirectory Packages for CentOS 7
baseurl=https://public.fusiondirectory.org/centos7-schema2ldif-release/RPMS
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-FUSIONDIRECTORY
```
- Télechargement via dnf de schema2ldif

Modification d'un fichier en ldif :

```bash
schema2ldif /usr/share/doc/sudo/schema.OpenLDAP > sudo-schema.ldif
```

On peut observer le début du fichier avec la commande `head sudo-schema.ldif` :

```bash
dn: cn=schema,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: schema
#
# OpenLDAP schema file for Sudo
# Save as /etc/openldap/schema/sudo.schema and restart slapd.
# For a version that uses online configuration, see schema.olcSudo.
#
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.1
  NAME 'sudoUser'
```