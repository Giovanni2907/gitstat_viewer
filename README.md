# GitStat Viewer

Dashboard de statistiques GitHub développé en Flutter (Clean Architecture + Riverpod).

## Prérequis
- Flutter SDK (Version 3.47.2 recommandée)
- VS Code avec l'extension Flutter & Dart

## Installation
1. Cloner le dépôt :
   ```bash
   git clone <URL_DU_DEPOT>
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

### Pour lancer l'application
```bash
   flutter run
   ```
