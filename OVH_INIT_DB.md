# Comment installer le projet de zéro sur Vercel et OVH

## Sur la console de management OVH

- Achetez une BDD PostgresSQL sur le site OVH (datacloud)
- Autorisez la plage d'adresse IP 0.0.0.0/0
- Créez une nouvelle base de données
- Ajoutez un utilisateur Administrateur de la base de données

## Sur le site Vercel

- Créez un compte GitHub et authentifiez-vous à Vercel depuis celui-ci
- Importez le projet source depuis l'URL du dépôt sur votre GitHub
- Importez le projet de votre GitHub sur Vercel pour le déploiement

**Variables d'environnement secrètes :**

```text
POSTGRES_USER : N.C.
POSTGRES_PASSWORD : N.C.
POSTGRES_DB : N.C.
DATABASE_URL : Chaîne de connexion de la forme postgresql://user:password@hote:port/db
ADMIN_PASSWORD : Mot de passe de connexion au site web après déploiement
```

## Premier déploiement

Le fichier `package_init_new_db.json` est utilisé uniquement pour **initialiser une nouvelle base de données**.

Lors du build, ce fichier lance automatiquement le script `reset_db.js`, qui permet de créer et remplir la base de données pour la première fois.

### Procédure pour le premier déploiement

1. **Renommer** `package_init_new_db.json` en `package.json`
2. Lancer le déploiement afin que `reset_db.js` soit exécuté pendant le build
3. Vérifier que la base de données a bien été créée et remplie

### Attention

Avant de faire cette modification, il faut **sauvegarder le fichier `package.json` original**, car il ne doit pas contenir l’initialisation de la base de données.

### Une fois la base créée

Après le premier déploiement réussi :

1. **Remettre le fichier `package.json` d’origine**
2. Conserver `package_init_new_db.json` à part, sans l’utiliser pour les déploiements normaux
3. Ne plus exécuter `reset_db.js` au build, afin d’éviter de réinitialiser la base à chaque déploiement
