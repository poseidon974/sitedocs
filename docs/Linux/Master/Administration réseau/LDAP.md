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

