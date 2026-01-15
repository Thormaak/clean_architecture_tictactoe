# Clean Architecture Rules

Ces règles STRICTES s'appliquent à toute feature Flutter suivant la Clean Architecture.

## 1. Structure obligatoire par Feature

```
lib/features/{feature_name}/
├── domain/
│   ├── entities/           # Objets métier purs
│   │   └── {name}.dart
│   └── repositories/       # Interfaces UNIQUEMENT
│       └── {name}_repository.dart
│
├── application/
│   └── use_cases/          # Un fichier = une action
│       ├── get_{name}_use_case.dart
│       ├── create_{name}_use_case.dart
│       └── ...
│
├── infrastructure/
│   ├── repositories/       # Implémentations
│   │   └── {name}_repository_impl.dart
│   ├── data_sources/       # Sources de données
│   │   ├── {name}_remote_data_source.dart
│   │   └── {name}_local_data_source.dart
│   └── models/             # DTOs / Models avec fromJson/toJson
│       └── {name}_model.dart
│
└── presentation/
    ├── pages/              # Containers avec state management
    │   └── {name}_page.dart
    ├── views/              # Widgets purs (stateless)
    │   └── {name}_view.dart
    ├── widgets/            # Composants réutilisables
    │   └── {name}_widget.dart
    └── providers/          # State management (Riverpod/Bloc)
        └── {name}_provider.dart
```

## 2. Règles de dépendances (STRICTES)

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                         │
│  (peut importer: Application, Domain)                   │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    APPLICATION                          │
│  (peut importer: Domain UNIQUEMENT)                     │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                      DOMAIN                             │
│  (NE PEUT RIEN IMPORTER - couche pure)                  │
└─────────────────────────────────────────────────────────┘
                          ▲
                          │
┌─────────────────────────────────────────────────────────┐
│                   INFRASTRUCTURE                        │
│  (peut importer: Domain UNIQUEMENT)                     │
└─────────────────────────────────────────────────────────┘
```

### Imports autorisés et INTERDITS

| Couche | ✅ Autorisé | ❌ INTERDIT |
|--------|-------------|-------------|
| **Domain** | `freezed_annotation` (sans JSON) | Flutter, Infrastructure, Application, fromJson/toJson |
| **Application** | Domain | Infrastructure, Presentation, Flutter UI |
| **Infrastructure** | Domain, packages externes | Application, Presentation |
| **Presentation** | Domain, Application, Flutter | Infrastructure directement (passer par DI) |

### Exemple d'imports corrects

```dart
// domain/entities/user.dart
// ✅ Freezed autorisé SANS JSON
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
// ❌ PAS de part 'user.g.dart' !

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
  }) = _User;

  // ❌ PAS de factory fromJson !
}

// domain/repositories/user_repository.dart
// ✅ Import uniquement depuis domain
import '../entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(String id);
}

// application/use_cases/get_user_use_case.dart
// ✅ Import uniquement depuis domain
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository _repository;
  GetUserUseCase(this._repository);

  Future<User> call(String id) => _repository.getUser(id);
}

// infrastructure/repositories/user_repository_impl.dart
// ✅ Import depuis domain (interface) + packages externes OK
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<User> getUser(String id) async { ... }
}
```

## 3. Naming Conventions

### Fichiers

| Type | Pattern | Exemple |
|------|---------|---------|
| Entity | `{name}.dart` | `user.dart`, `product.dart` |
| Repository Interface | `{name}_repository.dart` | `user_repository.dart` |
| Repository Impl | `{name}_repository_impl.dart` | `user_repository_impl.dart` |
| Use Case | `{action}_{name}_use_case.dart` | `get_user_use_case.dart` |
| Model/DTO | `{name}_model.dart` | `user_model.dart` |
| Data Source | `{name}_{type}_data_source.dart` | `user_remote_data_source.dart` |
| Page | `{name}_page.dart` | `user_page.dart` |
| View | `{name}_view.dart` | `user_view.dart` |
| Provider | `{name}_provider.dart` | `user_provider.dart` |

### Classes

| Type | Pattern | Exemple |
|------|---------|---------|
| Entity | `PascalCase` | `User`, `Product` |
| Repository Interface | `{Name}Repository` | `UserRepository` |
| Repository Impl | `{Name}RepositoryImpl` | `UserRepositoryImpl` |
| Use Case | `{Action}{Name}UseCase` | `GetUserUseCase` |
| Model | `{Name}Model` | `UserModel` |
| Page | `{Name}Page` | `UserPage` |
| View | `{Name}View` | `UserView` |

## 4. Règles par couche

### Domain (Cœur métier)

```dart
// ✅ Entity avec Freezed SANS JSON
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
// ❌ PAS de part 'order.g.dart' !

@freezed
class Order with _$Order {
  const Order._(); // Nécessaire pour les getters custom

  const factory Order({
    required String id,
    required List<OrderItem> items,
    required OrderStatus status,
  }) = _Order;

  // ✅ Logique métier dans l'entity
  double get totalPrice => items.fold(0, (sum, item) => sum + item.price);
  bool get canBeCancelled => status == OrderStatus.pending;

  // ❌ PAS de factory fromJson !
}

// ✅ Repository = interface abstraite
abstract class OrderRepository {
  Future<Order> getOrder(String id);
  Future<List<Order>> getOrders();
  Future<void> createOrder(Order order);
}

// ❌ INTERDIT dans Domain
// - import 'package:flutter/...';
// - import 'package:cloud_firestore/...';
// - part 'xxx.g.dart' (génération JSON)
// - factory fromJson / méthode toJson
```

### Application (Use Cases)

```dart
// ✅ Un Use Case = une action métier
class CreateOrderUseCase {
  final OrderRepository _orderRepository;
  final PaymentRepository _paymentRepository;

  CreateOrderUseCase(this._orderRepository, this._paymentRepository);

  Future<Either<Failure, Order>> call(CreateOrderParams params) async {
    // Orchestration de la logique métier
    final payment = await _paymentRepository.process(params.paymentMethod);
    if (payment.isLeft()) return payment.map((_) => throw Error());

    final order = Order(
      id: generateId(),
      items: params.items,
      status: OrderStatus.pending,
    );

    await _orderRepository.createOrder(order);
    return Right(order);
  }
}

// ❌ INTERDIT dans Application
// - import 'package:flutter/...';
// - Accès direct à Firebase/API
// - Logique UI
```

### Infrastructure (Implémentations)

```dart
// ✅ Model = DTO avec sérialisation
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // ✅ Conversion vers Entity
  User toEntity() => User(id: id, name: name, email: email);

  // ✅ Conversion depuis Entity
  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    name: user.name,
    email: user.email,
  );
}

// ✅ Repository Implementation
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  @override
  Future<User> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    final model = UserModel.fromJson(doc.data()!);
    return model.toEntity(); // Convertir en Entity
  }
}
```

### Presentation (UI)

> **Voir [page-view-pattern.md](page-view-pattern.md)** pour les regles detaillees du pattern Page/View et la gestion de la localisation (l10n).

#### Resume

| Composant | Responsabilite | Type |
|-----------|----------------|------|
| **Page** | Container avec state management, routing, providers | `ConsumerWidget` / `ConsumerStatefulWidget` |
| **View** | Widget pur, UI uniquement, pas de state management | `StatelessWidget` |

```dart
// Page = Container
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    return userState.when(
      data: (user) => UserView(
        name: user.name,  // Donnees dynamiques en props
        onEdit: () => ref.read(userProvider.notifier).edit(),
      ),
      loading: () => const LoadingView(),
      error: (e, s) => ErrorView(error: e),
    );
  }
}

// View = Widget pur avec l10n directement
class UserView extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;  // l10n dans View
    return Column(
      children: [
        Text(l10n.userName),  // Labels statiques
        Text(name),           // Donnees dynamiques
        ElevatedButton(onPressed: onEdit, child: Text(l10n.edit)),
      ],
    );
  }
}
```

## 5. Dependency Injection

```dart
// ✅ Toutes les dépendances injectées via DI (GetIt, Riverpod, etc.)

// Avec Riverpod
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(firestoreProvider));
});

final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  return GetUserUseCase(ref.read(userRepositoryProvider));
});

// ❌ INTERDIT : Instanciation directe dans Presentation
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ JAMAIS ça
    final useCase = GetUserUseCase(UserRepositoryImpl(FirebaseFirestore.instance));

    // ✅ Toujours via DI
    final useCase = ref.read(getUserUseCaseProvider);
  }
}
```

## Checklist

- [ ] Chaque feature a les 4 dossiers (domain, application, infrastructure, presentation)
- [ ] Domain : Freezed autorisé, mais SANS `part 'xxx.g.dart'` ni `fromJson`
- [ ] Entities utilisent `@freezed` avec uniquement `part 'xxx.freezed.dart'`
- [ ] Repository interfaces sont dans Domain (abstraites uniquement)
- [ ] Repository implementations sont dans Infrastructure
- [ ] Models (DTOs) sont dans Infrastructure avec Freezed + `fromJson/toJson`
- [ ] Models ont `toEntity()` et `fromEntity()` pour conversion
- [ ] Use Cases orchestrent la logique sans accès direct aux sources de données
- [ ] Views sont des widgets purs sans state management
- [ ] Pages connectent Views au state management
- [ ] Toutes les dépendances sont injectées via DI
