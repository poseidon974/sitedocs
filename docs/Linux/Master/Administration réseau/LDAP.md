---
hide:
  - footer
---

# LDAP

LDAP est l'abréviation de Lightweight Directory Access Protocol (protocole léger d'accès à un annuaire). C'est un protocole de communication utilisé pour accéder à des annuaires en ligne, qui sont des bases de données contenant des informations sur des utilisateurs, des groupes, des ordinateurs et d'autres ressources réseau.

LDAP permet aux clients d'accéder à ces annuaires pour effectuer des opérations telles que la recherche, la lecture, la mise à jour et la suppression de données. Les annuaires LDAP sont utilisés dans de nombreuses applications, notamment pour la gestion des utilisateurs et des groupes, l'authentification et l'autorisation, la messagerie électronique, la voix sur IP, et bien d'autres.

LDAP utilise un modèle client-serveur et repose sur un ensemble de règles et de spécifications définies par l'Internet Engineering Task Force (IETF). Il est considéré comme un protocole efficace et sûr pour la gestion de données d'annuaire à grande échelle.

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

Les commandes `ldapwhoami` permettent de tester l'accès à un annuaire.

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

ldapmodifiy utlise un schéma pour la modification :

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
