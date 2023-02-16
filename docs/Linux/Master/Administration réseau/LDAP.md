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

Ajout de l'utilisateur :

```bash
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
