# Migration vers la base OVH

## État actuel de l'application

L'application est actuellement construite autour d'un backend PostgreSQL :
- driver utilisé côté Node : `pg`
- scripts de reset et de sauvegarde : `psql`, `pg_dump`, `DROP SCHEMA public CASCADE`
- fichiers SQL de la base : vues, fonctions et types PostgreSQL (`public.*`, `CREATE FUNCTION`, `CREATE VIEW`, `nextval(...)`)

Le service OVH fourni est une base MySQL. Un raccordement direct vers cette base ne fonctionne donc pas sans migration de schéma et de code.

## Informations de connexion à conserver en variables d'environnement

Les paramètres de connexion OVH à utiliser après migration doivent rester hors du dépôt et dans l'environnement d'exécution (Vercel, serveur, CI/CD) :
- hôte : `bp78703-001.eu.clouddb.ovh.net`
- port : `35727`
- base : `vsi2026_tlpu065_grenoble`
- utilisateur applicatif : `medium`

Les mots de passe doivent rester secrets et ne jamais être ajoutés au dépôt.

## Ce qu'il faut migrer

1. Remplacer le driver PostgreSQL par un driver MySQL (`mysql2` ou équivalent).
2. Migrer les requêtes SQL vers la syntaxe MySQL.
3. Reconvertir les vues et fonctions (MySQL n'accepte pas les objets PostgreSQL de type `public.*`, `CREATE FUNCTION ... RETURNS void`, etc.).
4. Remplacer les sauvegardes automatiques (`pg_dump`) par un mécanisme MySQL (`mysqldump` ou export SQL).
5. Adapter le script de reset de base (`reset_db.js`) aux commandes MySQL.

## Recommandation

Pour conserver un déploiement fiable, il est préférable de :
- soit garder la base PostgreSQL existante,
- soit effectuer une migration complète vers MySQL, avec refonte des scripts SQL et des accès base.

Ce guide ne doit pas être utilisé comme configuration de production tant que cette migration n'a pas été réalisée.
