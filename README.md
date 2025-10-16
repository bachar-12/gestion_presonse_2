# Gestion Présence — Skeleton

Squelette Flutter minimal pour une app de gestion de présence (enseignant/étudiant) avec Firebase.

## Structure

```
lib/
 ├─ app/ (router, theme)
 ├─ core/ (constants, widgets communs)
 ├─ data/ (Model): modèles + repositories + services Firebase
 ├─ mvc/
 │   ├─ controllers/ (Controller): logique d’orchestration (Auth/Users/Classes)
 │   └─ providers.dart (injection Riverpod des controllers)
 ├─ features/ (View): écrans/widgets qui consomment les controllers
 │   ├─ auth/
 │   ├─ classes/
 │   ├─ sessions/
 │   ├─ attendance/
 │   └─ stats/
 └─ main.dart
```

## Démarrage rapide

1) Configurer Firebase (Android/iOS/Web) dans le projet.
   - Ajouter les fichiers de config (`google-services.json`, `GoogleService-Info.plist`) ou `firebase_options.dart` (FlutterFire CLI)
2) Lancer `flutter pub get` pour installer les dépendances.
3) `flutter run`

Note: `FirebaseService.ensureInitialized()` capture les erreurs d'init pour permettre l'exécution même sans configuration complète. Les écrans (View) s’appuient désormais sur des Controllers (MVC) exposés via Riverpod.

### MVC dans ce projet
- Model: `lib/data/models/*` (+ repositories comme source de données)
- View: `lib/features/**` (UI)
- Controller: `lib/mvc/controllers/*` (orchestration et API pour la View)

Exemples:
- Auth: `AuthController` (inscription/connexion/déconnexion) consommé par `LoginScreen`/`SignupScreen`.
- Classes: `ClassesController` (watch/create/update/delete) consommé par `ClassesScreen` et `ClassEditorDialog`.
- Users: `UsersController` (compteurs par rôle, flux d’utilisateurs) consommé par `UsersCounters` et `StatsScreen`.

## Règles Firestore/Storage

Voir `firebase/firestore.rules` et `firebase/storage.rules` (extrait minimal à adapter).

Astuce: si vous n'utilisez pas de Custom Claims pour le rôle, vous pouvez baser les règles sur le document utilisateur:

```
function userRole() {
  return get(/databases/$(db)/documents/users/$(request.auth.uid)).data.role;
}
function isTeacher() { return userRole() == 'teacher'; }
function isStudent() { return userRole() == 'student'; }
```

## Board de tâches

Un CSV importable (Trello/Notion) est fourni: `project_board.csv`.

## Prochaines étapes suggérées

- Brancher l'authentification (email/mot de passe) et la redirection par rôle.
- Implémenter CRUD classes + affectation étudiants.
- Générer et scanner des QR pour marquer la présence.
- Ajouter l'historique et les statistiques (fl_chart).
- Mettre en place FCM + notifications.

## Cloud Functions (squelette)

Un dossier `functions/` (TypeScript) fournit:
- `verifySessionCode` (callable): vérifie `sessionId|code` côté serveur.
- `onAttendanceCreate` (trigger): notifie l'étudiant si `status=='absent'` (token attendu dans `users/{uid}.fcmToken`).
- `checkRepeatedAbsences` (squelette, commenté): job planifié pour notifications enseignants.

Commande type:
- `cd functions && npm install`
- `npm run build && firebase deploy --only functions`
