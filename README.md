# cook.sh – Gestionnaire de recettes de cuisine en Bash

Script Bash qui gère une collection de recettes écrites au format [Cooklang](https://cooklang.org/) : afficher la liste des recettes, chercher celles qui contiennent un ingrédient, lister les ingrédients et ustensiles d'une recette, et composer un **menu** à partir de plusieurs recettes.

> Projet universitaire (R1.04 – Introduction aux systèmes d'exploitation), BUT Informatique, IUT de Bordeaux, janvier 2025. Réalisé en binôme.

## Commandes

```
./cook.sh COMMAND [PARAMETER]...
```

| Commande | Rôle |
|---|---|
| `help` | Affiche l'aide |
| `list` | Liste toutes les recettes disponibles |
| `search INGREDIENT` | Liste les recettes qui contiennent l'ingrédient |
| `ingredients RECIPE` | Liste les ingrédients d'une recette, par ordre alphabétique, sans les quantités |
| `tools RECIPE` | Liste les ustensiles d'une recette, par ordre alphabétique |
| `menu RECIPE...` | Affiche un menu : ingrédients et ustensiles sur plusieurs colonnes, puis chaque recette |

Le nom de la commande est insensible à la casse (`list`, `LIST` et `lIsT` sont équivalents).

## Utilisation

Le dossier des recettes est défini par la variable d'environnement `BUT_RECIPES`. Les recettes sont des fichiers `.cook`, rangés dans l'arborescence de son choix.

```bash
# Récupérer des recettes d'exemple
git clone --depth 1 https://github.com/cooklang/recipes.git test_recipes
export BUT_RECIPES="test_recipes"

./cook.sh list
./cook.sh search egg
./cook.sh ingredients "Breakfast/Chicken roll"
./cook.sh tools "Soups/Chicken broth"
./cook.sh menu "Breakfast/Chicken roll" "Soups/Creamy mushroom soup" "Soups/Chicken broth"
```

Les noms de recettes s'écrivent sans le dossier racine ni l'extension `.cook` (exemple : `Soups/Chicken broth`). Les listes utilisent le `PAGER` de l'utilisateur lorsqu'il est défini.

## Gestion des erreurs

- Dossier `BUT_RECIPES` absent ou sans recette : message d'erreur et arrêt.
- Recette inexistante : message d'erreur et arrêt, avant tout traitement dans le cas de `menu`.
- Commande absente ou inconnue : message d'erreur suivi de l'aide.
- Les erreurs sont écrites sur la **sortie d'erreur** et le script retourne un **code de sortie non nul**.

## Aspects techniques

- Script découpé en **fonctions** à responsabilité unique, documentées et commentées (en anglais)
- Mode strict : `errexit`, `pipefail`, `nounset`, `IFS` restreint
- Analyse du format Cooklang par **expressions régulières** (`grep -P` avec lookahead / lookbehind, `sed`)
- Outils utilisés : `find`, `grep`, `sed`, `sort`, `column`
- Code vérifié avec **[ShellCheck](https://www.shellcheck.net/)**

## Structure du dépôt

```
RecetteCuiseBash/
├── cook.sh      Script principal
└── [rapport, scripts de test, etc.]
```

## Auteurs

- Elouan Rannou – [ta part : fonctions réalisées, commandes codées…]
- Maxime [Nom]

## Pistes d'amélioration

- Additionner les quantités identiques dans la liste d'ingrédients du menu
- Gérer une liste de courses selon les ingrédients déjà disponibles
- Édition des recettes depuis le script
