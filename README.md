# Description

🚀 Projet : GitStats Viewer

 Un mini-projet projet de création d'un dashboard de profil GitHub qui sera une application Flutter Multi-platform (Desktop + Mobile).

📅 *Début :* 2 septembre 2026
🏁 *Fin prévue :* 16 septembre 2026

👥 Membres de l'équipe :
-David BONGOUADE
-RAJAONARISON Notahinjanahary Marcelo Giovanni
-Davy Moïse ISHIMWE 
-Mujibu Akandji
-DJOBO Olassan Donatien
-ZOTOGLO Noé 
-Justin Bashige

👨‍💼 Chef d'équipe : RAJAONARISON Notahinjanahary Marcelo Giovanni
🎓 Mentor : David BONGOUADE

## Fonctionnalités clés

- **Authentification GitHub via Device Flow OAuth** : pas de mot de passe stocké dans l'app, connexion sécurisée par code à valider dans le navigateur, avec gestion du `slow_down` (backoff progressif imposé par GitHub) et persistance du token via `flutter_secure_storage`.
- **Dashboard** : vue d'ensemble avec nombre de dépôts, total de commits, collaborateurs uniques, répartition des langages (diagramme circulaire), liste des dépôts filtrable, et flux d'activité récente (derniers commits, tous dépôts confondus).
- **Statistiques de commits par dépôt** : recherche d'un dépôt précis (owner/repo), historique des commits, top contributeurs, graphique d'activité quotidienne.
- **Profil utilisateur** : informations du compte GitHub connecté (avatar, bio, followers/following), accès direct aux paramètres du compte GitHub, déconnexion.
- **Responsive multi-plateforme** : mise en page adaptative mobile (colonne unique) / desktop-web (multi-colonnes), navigation par onglets, raccourcis clavier natifs sur le web (`/` pour focus la recherche, navigation `Tab`).

## Architecture

Le projet suit les principes de la **Clean Architecture**, avec une séparation stricte en trois couches par feature :
lib/
core/ # Code partagé entre toutes les features
network/ # Clients Dio (OAuth GitHub + API REST GitHub)
storage/ # Stockage sécurisé du token d'accès
widgets/ # Widgets réutilisables (StatCard, GhSearchField, SectionHeader, State Views...)
utils/ # Fonctions utilitaires (couleurs de langages, temps relatif...)
providers/ # Providers Riverpod transverses (navigation...)
features/
auth/
data/ # Modèles JSON + accès réseau (Device Flow)
domain/ # États d'authentification
presentation/ # AuthNotifier (StateNotifier), AuthScreen
dashboard/
data/ # Modèles + datasource + implémentation du repository
domain/ # Entités (GithubUser, Repo, LanguageStat, DashboardStats, DashboardCommit) + contrat du repository
presentation/ # Providers Riverpod, écrans (Dashboard, Profil), widgets dédiés
commit_stats/
data/ # Accès aux commits d'un dépôt donné
domain/
presentation/ # Écran de statistiques par dépôt, widgets dédiés


**Règle de dépendance** : `presentation` dépend de `domain`, `data` implémente `domain` — jamais l'inverse. Les entités du `domain` ne connaissent rien de Dio, JSON ou Flutter.

## Workflow d'équipe

Le projet a été découpé en trois lots de travail confiés à 3 membres distincts, développés en parallèle puis intégrés :

| Binôme | Feature | Responsabilité |
|---|---|---|
| Binôme 1 | `features/auth` | Écran d'authentification, consommation du Device Flow OAuth, redirection post-connexion |
| Binôme 2 | `feature/dashboard` (fusionné dans `profile`) | Récupération et modélisation des données `/user` et `/user/repos` |
| Binôme 3 | `feature/commit-stats` | Statistiques d'activité de commits, gestion des états loading/erreur |

**Points d'intégration critiques identifiés et corrigés pendant le développement :**
- Un client Dio unique par hôte : `github.com` (OAuth) et `api.github.com` (API REST) exigent des configurations distinctes — un même client mal partagé casse silencieusement les appels API.
- Un `ref.listen` sur `authProvider` doit vivre au niveau de la coquille de navigation (`HomeScreen`), pas seulement sur `AuthScreen`, pour que la déconnexion (logout) redirige effectivement l'utilisateur.
- Les composants UI partagés (`StatCard`, champs de recherche, en-têtes de section, vues de chargement/erreur/vide) ont été extraits dans `core/widgets/` dès qu'un second binôme en a eu besoin, pour éviter la duplication de code entre features.

**Cycle de développement suivi pour chaque fonctionnalité :**
1. Modélisation du `domain` (entités + contrat de repository), indépendante de toute source de données.
2. Implémentation `data` (modèles JSON + datasource réseau + implémentation du repository).
3. Exposition via des providers Riverpod (`Provider`, `FutureProvider`, `StateNotifier` selon le besoin).
4. Construction de l'UI en `presentation`, avec gestion explicite des états chargement / erreur / vide / données.
5. Tests unitaires sur la logique métier (repository) et tests de widgets sur les composants réutilisables.

## Prérequis
- Flutter SDK (Version 3.47.2 recommandée)
- VS Code avec l'extension Flutter & Dart
- Un compte GitHub avec accès à la création de Personal Access Token

## Installation
1. Cloner le dépôt :
```bash
   git clone <https://github.com/Giovanni2907/gitstat_viewer>
   cd gitstat_viewer
```

### Installer les dépendances :
```bash
   flutter pub get
```

### Configurer l'environnement :

1 - Dupliquer .env.example, renommer le copie en .env tout court

2 - Générer un Personal Access Token (PAT) sur GitHub (Settings > Developer Settings > Personal Access Tokens)

3 - Renseigner le token dans le fichier .env an changeant 'votre_token_github_personnel_ici' par le PAT

**Scopes GitHub requis pour le PAT / l'application OAuth :** `read:user` et `repo` (nécessaires pour lire le profil, les dépôts privés, les commits et les collaborateurs).

⚠️ Le fichier `.env` contient un secret : il est ignoré par Git (`.gitignore`) et ne doit **jamais** être commité.

### Pour lancer l'application
```bash
   flutter run
```

## Exécuter les tests

```bash
flutter test
```

Les tests sont organisés ainsi :
- `test/features/<feature>/` : tests unitaires de la logique métier (repositories, notifiers), avec les dépendances réseau simulées via `mocktail` — aucun appel réseau réel n'est effectué.
- `test/widget/` : tests de widgets isolés (rendu, interactions, callbacks), indépendants de toute donnée réelle.

## Dépannage (problèmes rencontrés pendant le développement)

- **`compileSdk` insuffisant pour `flutter_secure_storage`** : si Gradle signale qu'une dépendance exige une version d'Android SDK supérieure à celle configurée, mettre à jour `compileSdk` dans `android/app/build.gradle.kts` en conséquence.
- **Échec de compilation Kotlin incrémentale sur Windows** (`this and base files have different roots`) : survient quand le projet et le cache Pub (`Pub Cache`) sont sur des lettres de lecteur différentes (ex. projet sur `D:\`, cache sur `C:\`). Solutions : désactiver `kotlin.incremental` dans `android/gradle.properties`, exécuter `flutter clean` puis `gradlew --stop`, ou aligner projet et cache sur le même disque.
- **Le Device Flow reste bloqué sur "en attente"** : vérifier que le client respecte l'intervalle de polling demandé par GitHub (réponse `slow_down` avec un champ `interval` croissant) — un polling trop rapide entretient indéfiniment l'erreur `slow_down` sans jamais laisser passer la vraie réponse.
- **Rate limit GitHub** : les statistiques du Dashboard (commits, collaborateurs, activité récente) effectuent plusieurs appels par dépôt possédé. Sur un compte avec un grand nombre de dépôts, le quota horaire de l'API REST (5000 requêtes/heure pour un utilisateur authentifié) peut être approché plus vite que prévu.