---
hide:
  - footer
---

## Verification

Dans cette partie, on va vérifier si un dossier est crée àù non.

Pour test si un dossier existe, on va utiliser `Get-Item` :

```powershell
$retour = Get-Item -Path "c:/log" -ErrorAction SilentlyContinue
```

Ici, on stocke la valeur rendu par la commande dans `$retour`.

On va ensuite aller chercher le dossier `c:/log`.

On va s'assurer que la commande s'excute en silence même si il y a des erreurs avec `-ErrorAction SilentlyContinue`

!!! note
    Ici nous utilisons un dossier qui n'existe pas.
    
    Le but de cette activité est de créer un script qui quand il ne trouve pas le dossier `c:/log`, il crée un dossier. 
    
    Dans ce dossier, nous souhaitons qu'il y ai un fichier nommé 'ESPION.txt'.

On va donc créer un dossier à la racine si celui-ci n'existe pas :

```powershell
if (!(Get-Item -Path "c:\log" -ErrorAction SilentlyContinue)) {New-Item "c:\log" -ItemType Directory }
```

On vérifie ensuite si le fichier `espion.txt` existe dans le dossier `c:\log` :

```powershell
if (!(Get-Item -Path "c:\log\espion.txt" -ErrorAction SilentlyContinue)) {New-Item -Path "c:\log\espion.txt" -ItemType File}
```

On réalise ensuite le script complet avec l'implémentation du user et de la date/heure :

```powershell
if (!(Get-Item -Path "c:\log" -ErrorAction SilentlyContinue)) {New-Item "c:\log" -ItemType Directory }
if (!(Get-Item -Path "c:\log\espion.txt" -ErrorAction SilentlyContinue)) {New-Item -Path "c:\log\espion.txt" -ItemType File}

$export = "{0,-20}:{1:yyyy}:{2}:{3}:{4}:{5}:{6}" -f $env:USERNAME, (Get-Date),(Get-Date).Month,(Get-Date).Day,(Get-Date).Hour,(Get-Date).Minute, (Get-Date).DayOfWeek
Write-Output $export

ADD-content -path "c:\log\espion.txt" -value $export
```

!!! note
    Le `ADD-content -path "c:\log\espion.txt" -value $export` permet d'écrit dans le fichier espion.txt