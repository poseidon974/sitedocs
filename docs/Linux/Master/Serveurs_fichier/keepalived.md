# Keepalived

## Installation 

Installation de keepalived :

```bash
dnf -y install keepalived
```

!!!info "locatlisation des fichiers de configurations"
        /etc/keealived/

## Les virtuals serveurs dans keepalived

Sauvegarde du fichier par défaut de keepalived :

```bash
mv keepalived.conf keepalived.conf.sauv
```

Création du fichier de configuration :

```bash
virtual_server 10.56.126.223 80 {
  delay_loop 6
  lb_algo lc
  lb_kind NAT
#persistence_timeout 50
  protocol TCP

  real_server 10.0.0.1 80 {
    weight 1
  }
  real_server 10.0.0.2 80 {
  weight 1
  }
}
```
