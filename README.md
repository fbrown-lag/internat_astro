# Gestion Internat - Guide de Déploiement

Ce document explique en détail comment déployer l'application `gestion_internat` sur un réseau local depuis un serveur Linux, en utilisant **Docker**.

## Prérequis

- Un serveur Linux (ex: Ubuntu Server, Debian) connecté à votre réseau local.
- **Docker** et **Docker Compose** installés sur le serveur.
- L'accès SSH ou physique au serveur.

## 1. Récupération et Configuration

1. Connectez-vous à votre serveur Linux.
2. Clonez ce dépôt ou copiez les fichiers du projet dans un répertoire de votre choix (ex: `/var/www/internat_astro` ou `~/internat_astro`).
3. Placez-vous dans le répertoire du projet :
   ```bash
   cd /chemin/vers/internat_astro
   ```
4. Assurez-vous que les ports **4321** (application spatiale Astro) et **5433** (base de données exposée si nécessaire) sont libres ou ajustez-les dans le fichier `docker-compose.yml`.

> **Base de données : migration OVH**
>
> L'application reste actuellement construite sur PostgreSQL (`pg`, `psql`, `pg_dump`, scripts SQL PostgreSQL). La base OVH fournie est MySQL. Un branchement direct vers cette base n'est pas compatible sans migration SQL et de driver. Consultez le guide `OVH_MIGRATION.md` avant toute tentative de déploiement vers OVH.

## 2. Déploiement avec Docker (Lancement)

L'application est entièrement conteneurisée (Frontend NodeJS/Astro + Backend PostgreSQL).

Pour construire et lancer l'application en arrière-plan (mode détaché) :

```bash
docker compose up -d --build
```

### Que fait cette commande ?
- Elle lit le `docker-compose.yml` et le `Dockerfile`.
- Elle télécharge l'image PostgreSQL (`db`).
- Elle construit l'image de l'application (`app`), installe les dépendances et build le projet.
- Elle lance les deux conteneurs.
- Un script d'entrée (`entrypoint.sh`) vérifiera si la base de données est prête, proposera la restauration éventuelle d'une sauvegarde, ou initialisera la base si elle est vide.

> **Important** : cette version de l'application est encore dédiée à PostgreSQL. Une migration vers l'instance OVH MySQL nécessite la refonte des requêtes, des scripts de sauvegarde et du driver de base.

### Vérifier les logs :
Si vous devez vérifier que tout s'est bien lancé :
```bash
docker compose logs -f
```

## 3. Règles d'Accès et Sécurité (Serveur Linux)

Puisque cette application est destinée à être hébergée sur un réseau **local**, il est crucial de configurer les règles d'accès pour empêcher toute connexion depuis l'extérieur (Internet).

### Étape 3.1 : Identifier votre Réseau Local
Trouvez l'adresse IP de votre serveur sur le réseau local avec la commande :
```bash
ip addr
```
Exemple : Si l'IP est `192.168.1.50`, votre sous-réseau local est probablement `192.168.1.0/24`.

### Étape 3.2 : Configuration du Pare-feu (UFW sur Ubuntu/Debian)

UFW (Uncomplicated Firewall) permet de bloquer tous les accès sauf ceux explicitement autorisés.

1. **Bloquer tout par défaut** (sauf les requêtes sortantes) :
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   ```

2. **Autoriser SSH** obligatoirement pour ne pas perdre le contrôle du serveur distant :
   ```bash
   sudo ufw allow ssh
   ```

3. **Restreindre l'accès Web (Port 4321 ou 80) au réseau local uniquement** :
   Dans l'état actuel, Docker expose l'application sur le port `4321`.
   ```bash
   sudo ufw allow from 192.168.1.0/24 to any port 4321
   ```
   *(Remplacez `192.168.1.0/24` par le sous-réseau correspondant à votre établissement).*

4. **Activer le pare-feu** :
   ```bash
   sudo ufw enable
   ```
   Vérifiez l'état avec `sudo ufw status`.

### Étape 3.3 : Optionnel - Reverse Proxy (Nginx)

Si vous souhaitez accéder à l'application via le port classique `80` (HTTP) au lieu du `:4321`, vous pouvez installer Nginx et utiliser la configuration fournie.

1. Installez Nginx : `sudo apt install nginx`
2. Copiez la configuration :
   ```bash
   sudo cp nginx.conf /etc/nginx/sites-available/internat
   sudo ln -s /etc/nginx/sites-available/internat /etc/nginx/sites-enabled/
   ```
3. Sécurisez Nginx pour qu'il n'écoute que sur l'IP locale du serveur. Dans `/etc/nginx/sites-available/internat`, modifiez la ligne `listen` :
   ```nginx
   listen 192.168.1.50:80;
   ```
4. Autorisez le port 80 dans UFW pour le réseau local :
   ```bash
   sudo ufw allow from 192.168.1.0/24 to any port 80
   ```
5. Redémarrez Nginx : `sudo systemctl restart nginx`

Maintenant, tout ordinateur du réseau local peut y accéder via `http://192.168.1.50`.

## 4. Sauvegardes et Maintenance

Les sauvegardes de la base de données sont gérées via un volume Docker lié au dossier `./backups` sur la machine hôte.

### Restaurer une sauvegarde manuellement
Pour restaurer la toute dernière sauvegarde disponible dans le dossier `backups` (attention, cela écrase la base actuelle), exécutez la commande suivante depuis votre dossier projet :
```bash
docker compose exec app bash -c "export PGPASSWORD=password; psql -h db -U postgres -d gestion_internat -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;' && psql -h db -U postgres -d gestion_internat -f \$(ls -t /app/backups/*.sql | head -n1)"
```

### Réinitialiser la base de données (Danger)
Si vous avez besoin de remettre la base de données totalement à zéro (repartir des fichiers SQL d'initialisation) :
```bash
docker compose exec app node reset_db.js
```

### Commandes standard Docker
Pour arrêter l'application proprement :
```bash
docker compose down
```

Pour la déployer ou la mettre à jour après avoir récupéré la dernière version du code :
```bash
docker compose up -d --build
```
