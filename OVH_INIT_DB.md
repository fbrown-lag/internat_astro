# Comment installer le projet de zéro sur Vercel et OVH

## Sur la console de management OVH

- Acheter une BDD PostgresSQL sur le site OVH (datacloud)
- Autoriser la plage d'adresse IP 0.0.0.0/0
- Créez une nouvelle base de données
- Ajouter un utilisateur Administrateur de la base de données

## Sur le site Vercel

- Créez un compte GitHub et authentifiez-vous à Vercel depuis celui-ci
- Importez le projet source depuis l'URL du dépôt sur votre GitHub
- Importer le projet de votre GitHub sur Vercel pour le déploiement

- Variables d'environnement secrètes :
  `POSTGRES_USER` : N.C.
  `POSTGRES_PASSWORD` : N.C.
  `POSTGRES_DB` : N.C.
  `DATABASE_URL` : Chaîne de connexion de la forme postgresql://user:password@hote:port/db
  `ADMIN_PASSWORD` : Mot de passe de connexion au site web après déploiement
