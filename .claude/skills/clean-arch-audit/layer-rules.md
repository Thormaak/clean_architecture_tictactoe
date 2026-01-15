# Clean Architecture Layer Rules

Ce document détaille les règles strictes pour chaque couche.

---

## 1. Domain Layer (Cœur métier)

### Responsabilités
- Définir les **Entities** (objets métier)
- Définir les **Repository Interfaces** (contrats)
- Contenir la **logique métier pure**
- Définir les **Value Objects** si nécessaire
- Définir les **Failures/Exceptions** métier

### Structure

```
domain/
├── entities/
│   ├── user.dart
│   └── order.dart
├── repositories/
│   ├── user_repository.dart      # Interface UNIQUEMENT
│   └── order_repository.dart
├── value_objects/                 # Optionnel
│   └── email.dart
└── failures/                      # Optionnel
    └── domain_failure.dart
```

### Règles STRICTES

| Règle | Description |
|-------|-------------|
| **Pas de Flutter** | Aucun `import 'package:flutter/...'` |
| **Freezed autorisé** | `@freezed` OK avec `part 'xxx.freezed.dart'` uniquement |
| **Pas de JSON** | Pas de `part 'xxx.g.dart'` ni `fromJson/toJson` |
| **Pas d'implémentations** | Que des interfaces pour les repositories |
| **Immutabilité** | Utiliser Freezed pour garantir l'immutabilité |

### Entity correcte

```dart
// ✅ CORRECT : Entity avec Freezed SANS JSON
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
// ❌ PAS de part 'user.g.dart' !

@freezed
class User with _$User {
  const User._(); // Nécessaire pour les getters/méthodes custom

  const factory User({
    required String id,
    required String name,
    required Email email,
    required DateTime createdAt,
  }) = _User;

  // ✅ Logique métier
  bool get isNewUser => DateTime.now().difference(createdAt).inDays < 7;

  // ❌ PAS de factory fromJson !
}
```

### Repository Interface correcte

```dart
// ✅ CORRECT : Interface abstraite
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<List<User>> getUsers();
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
  Stream<List<User>> watchUsers();
}
```

---

## 2. Application Layer (Use Cases)

### Responsabilités
- Orchestrer la **logique applicative**
- Coordonner les appels aux **repositories**
- Implémenter les **Use Cases** (cas d'utilisation)
- Gérer les **transactions** multi-repository

### Structure

```
application/
└── use_cases/
    ├── get_user_use_case.dart
    ├── create_user_use_case.dart
    ├── update_user_use_case.dart
    └── delete_user_use_case.dart
```

### Règles STRICTES

| Règle | Description |
|-------|-------------|
| **Import Domain uniquement** | Peut importer entities, repositories interfaces |
| **Pas d'Infrastructure** | Ne connaît pas les implémentations |
| **Pas de Flutter UI** | Pas de widgets, pas de BuildContext |
| **Un Use Case = Une action** | Single Responsibility Principle |

### Use Case correct

```dart
// ✅ CORRECT : Use Case avec orchestration
import '../../domain/entities/user.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/failures/domain_failure.dart';

class CreateOrderUseCase {
  final OrderRepository _orderRepository;
  final UserRepository _userRepository;
  final PaymentService _paymentService;

  CreateOrderUseCase(
    this._orderRepository,
    this._userRepository,
    this._paymentService,
  );

  Future<Either<DomainFailure, Order>> call(CreateOrderParams params) async {
    // 1. Vérifier l'utilisateur
    final user = await _userRepository.getUser(params.userId);
    if (!user.canPlaceOrder) {
      return Left(DomainFailure.userCannotOrder());
    }

    // 2. Valider le paiement
    final paymentResult = await _paymentService.process(params.payment);
    if (paymentResult.isLeft()) {
      return Left(DomainFailure.paymentFailed());
    }

    // 3. Créer la commande
    final order = Order(
      id: generateId(),
      userId: params.userId,
      items: params.items,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now(),
    );

    await _orderRepository.createOrder(order);

    return Right(order);
  }
}

// Params encapsulés
class CreateOrderParams {
  final String userId;
  final List<OrderItem> items;
  final PaymentInfo payment;

  const CreateOrderParams({
    required this.userId,
    required this.items,
    required this.payment,
  });
}
```

---

## 3. Infrastructure Layer (Implémentations)

### Responsabilités
- **Implémenter** les repository interfaces
- Définir les **Models/DTOs** avec sérialisation
- Gérer les **Data Sources** (API, DB, Cache)
- Convertir Models ↔ Entities

### Structure

```
infrastructure/
├── repositories/
│   └── user_repository_impl.dart
├── models/
│   └── user_model.dart
├── data_sources/
│   ├── user_remote_data_source.dart
│   └── user_local_data_source.dart
└── mappers/                        # Optionnel
    └── user_mapper.dart
```

### Règles STRICTES

| Règle | Description |
|-------|-------------|
| **Import Domain uniquement** | Pour les interfaces et entities |
| **Pas d'Application** | Ne connaît pas les use cases |
| **Pas de Presentation** | Ne connaît pas les widgets |
| **Conversion obligatoire** | Model.toEntity() et Model.fromEntity() |

### Model correct

```dart
// ✅ CORRECT : Model avec sérialisation
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String name,
    required String email,
    @TimestampConverter() required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // ✅ Conversion vers Entity (Domain)
  User toEntity() => User(
    id: id,
    name: name,
    email: Email(email),
    createdAt: createdAt,
  );

  // ✅ Conversion depuis Entity
  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    name: user.name,
    email: user.email.value,
    createdAt: user.createdAt,
  );
}
```

### Repository Implementation correcte

```dart
// ✅ CORRECT : Implémentation avec conversion
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  CollectionReference<UserModel> get _collection =>
      _firestore.collection('users').withConverter(
        fromFirestore: (doc, _) => UserModel.fromJson(doc.data()!),
        toFirestore: (model, _) => model.toJson(),
      );

  @override
  Future<User> getUser(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) throw UserNotFoundException(id);
    return doc.data()!.toEntity(); // ✅ Conversion vers Entity
  }

  @override
  Future<void> createUser(User user) async {
    final model = UserModel.fromEntity(user); // ✅ Conversion depuis Entity
    await _collection.doc(user.id).set(model);
  }

  @override
  Stream<List<User>> watchUsers() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => doc.data().toEntity()) // ✅ Conversion
          .toList(),
    );
  }
}
```

---

## 4. Presentation Layer (UI)

### Responsabilités
- Afficher l'**interface utilisateur**
- Gérer le **state management**
- Connecter les **Use Cases** à l'UI via DI
- Gérer la **navigation**

### Structure

```
presentation/
├── pages/                  # Containers avec state management
│   └── user_page.dart
├── views/                  # Widgets purs (stateless)
│   └── user_view.dart
├── widgets/                # Composants réutilisables
│   └── user_card.dart
└── providers/              # State management
    └── user_provider.dart
```

### Règles STRICTES

| Règle | Description |
|-------|-------------|
| **Pas d'Infrastructure directe** | Utiliser DI pour les repositories |
| **View = Pure Widget** | Reçoit données via props, pas de state management |
| **Page = Container** | Connecte View au state management |
| **Use Cases via DI** | Jamais d'instanciation directe |

### View correcte (widget pur)

```dart
// ✅ CORRECT : View stateless pure
class UserView extends StatelessWidget {
  final String name;
  final String email;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;

  const UserView({
    super.key,
    required this.name,
    required this.email,
    required this.isLoading,
    this.error,
    required this.onRefresh,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          children: [
            Text(error!),
            ElevatedButton(onPressed: onRefresh, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(name, style: Theme.of(context).textTheme.headlineMedium),
        Text(email),
        ElevatedButton(onPressed: onEdit, child: const Text('Edit')),
      ],
    );
  }
}
```

### Page correcte (container)

```dart
// ✅ CORRECT : Page connecte View au state management
class UserPage extends ConsumerWidget {
  final String userId;

  const UserPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: UserView(
        name: state.user?.name ?? '',
        email: state.user?.email ?? '',
        isLoading: state.isLoading,
        error: state.error,
        onRefresh: () => ref.invalidate(userProvider(userId)),
        onEdit: () => context.push('/user/$userId/edit'),
      ),
    );
  }
}
```

---

## Résumé des imports autorisés

| Couche | Peut importer |
|--------|--------------|
| **Domain** | `freezed_annotation` (sans JSON uniquement) |
| **Application** | Domain |
| **Infrastructure** | Domain, Packages externes (Freezed + JSON OK) |
| **Presentation** | Domain, Application, Flutter, Packages UI |
