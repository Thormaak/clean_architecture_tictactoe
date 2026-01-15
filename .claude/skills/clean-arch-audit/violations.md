# Clean Architecture Violations

Ce document liste les violations courantes et comment les corriger.

---

## 1. Violations CRITIQUES

### 1.1 Domain importe Flutter

```dart
// ❌ CRITIQUE : Flutter dans Domain
// domain/entities/user.dart
import 'package:flutter/foundation.dart'; // INTERDIT

@immutable
class User {
  final String id;
  final String name;
}
```

```dart
// ✅ CORRECTION : Pure Dart
// domain/entities/user.dart
class User {
  final String id;
  final String name;

  const User({required this.id, required this.name});
}
```

---

### 1.2 Domain importe Infrastructure

```dart
// ❌ CRITIQUE : Import Infrastructure dans Domain
// domain/repositories/user_repository.dart
import '../../../infrastructure/models/user_model.dart'; // INTERDIT

abstract class UserRepository {
  Future<UserModel> getUser(String id); // Retourne un Model, pas une Entity
}
```

```dart
// ✅ CORRECTION : Retourner des Entities
// domain/repositories/user_repository.dart
import '../entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(String id); // Retourne une Entity
}
```

---

### 1.3 Domain avec sérialisation JSON

```dart
// ❌ CRITIQUE : JSON dans Domain (part 'xxx.g.dart' + fromJson)
// domain/entities/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';  // ❌ INTERDIT !

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);  // ❌ INTERDIT !
}
```

```dart
// ✅ CORRECTION : Freezed SANS JSON dans Domain
// domain/entities/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
// ✅ PAS de part 'user.g.dart' !

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
  }) = _User;

  // ✅ PAS de fromJson !
}

// infrastructure/models/user_model.dart
// ✅ Freezed AVEC JSON dans Infrastructure
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String name,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() => User(id: id, name: name);

  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    name: user.name,
  );
}
```

---

### 1.4 Implémentation Repository dans Domain

```dart
// ❌ CRITIQUE : Implémentation dans Domain
// domain/repositories/user_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  // ... implémentation
}
```

```dart
// ✅ CORRECTION : Implémentation dans Infrastructure
// domain/repositories/user_repository.dart (interface uniquement)
abstract class UserRepository {
  Future<User> getUser(String id);
}

// infrastructure/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  // ... implémentation
}
```

---

## 2. Violations MAJEURES

### 2.1 Presentation importe Infrastructure

```dart
// ❌ MAJEUR : Import direct d'Infrastructure
// presentation/pages/user_page.dart
import '../../infrastructure/repositories/user_repository_impl.dart';

class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = UserRepositoryImpl(FirebaseFirestore.instance);
    // ...
  }
}
```

```dart
// ✅ CORRECTION : Passer par DI
// presentation/pages/user_page.dart
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider); // Via DI
    // ...
  }
}

// providers/user_provider.dart
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(firestoreProvider));
});
```

---

### 2.2 Application importe Infrastructure

```dart
// ❌ MAJEUR : Use Case avec implémentation concrète
// application/use_cases/get_user_use_case.dart
import '../../infrastructure/repositories/user_repository_impl.dart';

class GetUserUseCase {
  final UserRepositoryImpl _repository; // Type concret !

  GetUserUseCase(this._repository);
}
```

```dart
// ✅ CORRECTION : Dépendre de l'interface
// application/use_cases/get_user_use_case.dart
import '../../domain/repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository _repository; // Interface

  GetUserUseCase(this._repository);
}
```

---

### 2.3 Logique métier dans Presentation

```dart
// ❌ MAJEUR : Calcul métier dans un widget
// presentation/pages/cart_page.dart
class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);

    // ❌ Logique métier dans presentation
    final subtotal = items.fold(0.0, (sum, item) => sum + item.price * item.qty);
    final tax = subtotal * 0.2;
    final discount = subtotal > 100 ? subtotal * 0.1 : 0;
    final total = subtotal + tax - discount;

    return Text('Total: $total');
  }
}
```

```dart
// ✅ CORRECTION : Logique dans Domain ou Application
// domain/entities/cart.dart
class Cart {
  final List<CartItem> items;

  const Cart({required this.items});

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get tax => subtotal * 0.2;
  double get discount => subtotal > 100 ? subtotal * 0.1 : 0;
  double get total => subtotal + tax - discount;
}

// presentation/pages/cart_page.dart
class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return Text('Total: ${cart.total}'); // Logique dans Entity
  }
}
```

---

### 2.4 Use Case trop couplé à l'UI

```dart
// ❌ MAJEUR : Use Case retourne des types UI
// application/use_cases/get_users_use_case.dart
import 'package:flutter/material.dart';

class GetUsersUseCase {
  Future<List<Widget>> call() async {
    final users = await _repository.getUsers();
    return users.map((u) => ListTile(title: Text(u.name))).toList();
  }
}
```

```dart
// ✅ CORRECTION : Use Case retourne des données
// application/use_cases/get_users_use_case.dart
class GetUsersUseCase {
  Future<List<User>> call() async {
    return _repository.getUsers();
  }
}

// presentation/... - UI crée les widgets à partir des données
```

---

## 3. Violations MINEURES

### 3.1 Convention de nommage Use Case

```dart
// ❌ MINEUR : Nom non standard
// application/use_cases/user_getter.dart
class UserGetter { ... }

// application/use_cases/fetch_user.dart
class FetchUser { ... }
```

```dart
// ✅ CORRECTION : Standard {Action}{Name}UseCase
// application/use_cases/get_user_use_case.dart
class GetUserUseCase { ... }
```

---

### 3.2 Structure de dossiers incomplète

```dart
// ❌ MINEUR : Structure manquante
lib/features/user/
├── user_page.dart        // Tout mélangé
├── user_repository.dart
└── user.dart
```

```dart
// ✅ CORRECTION : Structure complète
lib/features/user/
├── domain/
│   ├── entities/user.dart
│   └── repositories/user_repository.dart
├── application/
│   └── use_cases/get_user_use_case.dart
├── infrastructure/
│   ├── repositories/user_repository_impl.dart
│   └── models/user_model.dart
└── presentation/
    ├── pages/user_page.dart
    └── views/user_view.dart
```

---

### 3.3 Model sans conversion

```dart
// ❌ MINEUR : Model sans toEntity()
// infrastructure/models/user_model.dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Pas de toEntity() !
}
```

```dart
// ✅ CORRECTION : Ajouter les conversions
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String name,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() => User(id: id, name: name);

  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    name: user.name,
  );
}
```

---

### 3.4 Repository retourne Model au lieu d'Entity

```dart
// ❌ MINEUR : Retourne Model
class UserRepositoryImpl implements UserRepository {
  @override
  Future<UserModel> getUser(String id) async { // Retourne Model
    final doc = await _collection.doc(id).get();
    return UserModel.fromJson(doc.data()!);
  }
}
```

```dart
// ✅ CORRECTION : Retourner Entity
class UserRepositoryImpl implements UserRepository {
  @override
  Future<User> getUser(String id) async { // Retourne Entity
    final doc = await _collection.doc(id).get();
    final model = UserModel.fromJson(doc.data()!);
    return model.toEntity(); // Conversion
  }
}
```

---

## Checklist de détection

| Violation | Grep pattern | Sévérité |
|-----------|--------------|----------|
| Flutter dans Domain | `import 'package:flutter` dans domain/ | Critique |
| Packages interdits dans Domain | `import 'package:` (sauf `freezed_annotation`) dans domain/ | Critique |
| Infrastructure dans Domain | `import '.*infrastructure` dans domain/ | Critique |
| JSON dans Domain | `part '.*\.g\.dart'` ou `fromJson` dans domain/ | Critique |
| Impl dans Domain | `implements.*Repository` dans domain/ | Critique |
| Infrastructure dans Presentation | `import '.*infrastructure` dans presentation/ | Majeur |
| Infrastructure dans Application | `import '.*infrastructure` dans application/ | Majeur |
| Nom Use Case incorrect | Fichiers sans `_use_case.dart` dans use_cases/ | Mineur |
| Model sans toEntity | `class.*Model` sans `toEntity()` | Mineur |

**Note** : `@freezed` avec `part 'xxx.freezed.dart'` est autorisé dans Domain. Seul `part 'xxx.g.dart'` et `fromJson/toJson` sont interdits.
