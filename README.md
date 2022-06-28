# README

# Exemple d'application du didacticiel Ruby on Rails

Ceci est l'exemple d'application pour le
[*Tutoriel Ruby on Rails :
Apprendre le développement Web avec Rails*](https://www.railstutorial.org/)
par [Michael Hartl](https:// www.michaelhartl.com/).

## Licence

Tout le code source du [tutoriel Ruby on Rails](https://www.railstutorial.org/)
est disponible conjointement sous la licence MIT et la licence Beerware. Voir
[LICENSE.md](LICENSE.md) pour plus de détails.

## Premiers pas

Pour démarrer avec l'application, clonez le référentiel, puis installez les gems nécessaires :

```
$ gem install bundler -v 2.3.14
$ bundle _2.3.14_ config set --local without 'production'
$ bundle _2.3.14_ installer
```

Ensuite, migrez la base de données :

```
$ rails db:migrate
```

Enfin, exécutez la suite de tests pour vérifier que tout fonctionne correctement :

```
$ rails test
```

Si la suite de tests réussit, vous serez prêt à exécuter l'application sur un serveur local :

```
$ rails server
```

Pour plus d'informations, consultez le
[*livre Ruby on Rails Tutorial*](https://www.railstutorial.org/book).
