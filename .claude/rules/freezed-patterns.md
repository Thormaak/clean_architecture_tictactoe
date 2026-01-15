# Freezed Patterns Rules

Ces regles s'appliquent a l'utilisation de Freezed dans le projet.

## 1. Distinction Entity vs Model

### Entity (Domain Layer) - SANS JSON

```dart
// domain/entities/user.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
// PAS de part 'user.g.dart' !

@freezed
class User with _$User {
  const User._(); // Necessaire pour getters/methodes custom

  const factory User({
    required String id,
    required String name,
    required String email,
    @Default(false) bool isVerified,
  }) = _User;

  // Logique metier dans l'entity
  bool get canPost => isVerified;
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  // PAS de factory fromJson !
}
```

### Model (Infrastructure Layer) - AVEC JSON

```dart
// infrastructure/models/user_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart'; // Pour JSON

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
  }) = _UserModel;

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Conversion vers Entity
  User toEntity() => User(
    id: id,
    name: name,
    email: email,
    isVerified: isVerified,
  );

  // Conversion depuis Entity
  factory UserModel.fromEntity(User entity) => UserModel(
    id: entity.id,
    name: entity.name,
    email: entity.email,
    isVerified: entity.isVerified,
  );
}
```

## 2. Unions (Sealed Classes)

### Pattern pour etats

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error(String message) = AuthError;
}

// Utilisation avec when (exhaustif)
state.when(
  initial: () => const SplashScreen(),
  loading: () => const LoadingScreen(),
  authenticated: (user) => HomePage(user: user),
  unauthenticated: () => const LoginPage(),
  error: (message) => ErrorPage(message: message),
);

// Utilisation avec maybeWhen (partiel)
state.maybeWhen(
  authenticated: (user) => Text('Hello ${user.name}'),
  orElse: () => const LoginButton(),
);

// Utilisation avec map (acces au type)
state.map(
  initial: (_) => Colors.grey,
  loading: (_) => Colors.blue,
  authenticated: (s) => Colors.green,
  unauthenticated: (_) => Colors.orange,
  error: (_) => Colors.red,
);
```

### Pattern pour resultats

```dart
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(String message, [StackTrace? stackTrace]) = Failure<T>;
}

// Utilisation
Future<Result<User>> getUser(String id) async {
  try {
    final user = await repository.getUser(id);
    return Result.success(user);
  } catch (e, s) {
    return Result.failure(e.toString(), s);
  }
}

// Consommation
final result = await getUser('123');
result.when(
  success: (user) => showUser(user),
  failure: (message, _) => showError(message),
);
```

## 3. Default values et assertions

### @Default

```dart
@freezed
class Settings with _$Settings {
  const factory Settings({
    @Default('en') String locale,
    @Default(false) bool darkMode,
    @Default(1.0) double textScale,
    @Default([]) List<String> favorites,
    @Default({}) Map<String, dynamic> preferences,
  }) = _Settings;
}
```

### @Assert

```dart
@freezed
class Product with _$Product {
  @Assert('price >= 0', 'Price must be non-negative')
  @Assert('quantity >= 0', 'Quantity must be non-negative')
  const factory Product({
    required String id,
    required String name,
    required double price,
    @Default(0) int quantity,
  }) = _Product;
}
```

## 4. JSON Customization (Models only)

### @JsonKey

```dart
@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(includeIfNull: false) String? notes,
    @JsonKey(defaultValue: 0) int quantity,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    required OrderStatus status,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}

OrderStatus _statusFromJson(String value) => OrderStatus.values.byName(value);
String _statusToJson(OrderStatus status) => status.name;
```

### @JsonSerializable options

```dart
@Freezed(toJson: true, fromJson: true)
class ConfigModel with _$ConfigModel {
  @JsonSerializable(explicitToJson: true) // Pour nested objects
  const factory ConfigModel({
    required String version,
    required NestedModel nested,
  }) = _ConfigModel;

  factory ConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ConfigModelFromJson(json);
}
```

## 5. Private constructors et getters

```dart
@freezed
class Order with _$Order {
  const Order._(); // OBLIGATOIRE pour ajouter des methodes

  const factory Order({
    required String id,
    required List<OrderItem> items,
    required OrderStatus status,
    DateTime? completedAt,
  }) = _Order;

  // Getters calcules
  double get totalPrice => items.fold(0, (sum, item) => sum + item.total);
  int get itemCount => items.length;
  bool get isEmpty => items.isEmpty;
  bool get isCompleted => status == OrderStatus.completed;

  // Methodes metier
  bool canBeCancelled() => status == OrderStatus.pending;

  Order addItem(OrderItem item) => copyWith(
    items: [...items, item],
  );

  Order removeItem(String itemId) => copyWith(
    items: items.where((i) => i.id != itemId).toList(),
  );
}
```

## 6. copyWith patterns

### Basic copyWith

```dart
final updatedUser = user.copyWith(name: 'New Name');
```

### Nested copyWith

```dart
@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required Address address,
  }) = _Order;
}

@freezed
class Address with _$Address {
  const factory Address({
    required String street,
    required String city,
  }) = _Address;
}

// Deep copy
final updatedOrder = order.copyWith(
  address: order.address.copyWith(city: 'New City'),
);
```

### Nullable copyWith

```dart
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String name,
    String? bio, // Nullable
  }) = _Profile;
}

// Mettre a null explicitement
final cleared = profile.copyWith(bio: null);
```

## 7. Generic Freezed classes

```dart
@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required T data,
    required int statusCode,
    String? message,
  }) = _ApiResponse<T>;
}

// Utilisation
ApiResponse<User> userResponse = ApiResponse(data: user, statusCode: 200);
ApiResponse<List<Product>> productsResponse = ApiResponse(
  data: products,
  statusCode: 200,
);
```

## 8. Erreurs courantes a eviter

### Mauvais : fromJson dans Entity

```dart
// INTERDIT dans domain/entities/
@freezed
class User with _$User {
  const factory User({...}) = _User;

  factory User.fromJson(Map<String, dynamic> json) => // NON!
      _$UserFromJson(json);
}
```

### Mauvais : Oublier const User._()

```dart
// Sans le constructeur prive, impossible d'ajouter des methodes
@freezed
class User with _$User {
  const factory User({...}) = _User;

  // ERREUR: This won't work without const User._()
  String get fullName => '$firstName $lastName';
}
```

### Mauvais : Modifier l'etat mutable

```dart
// INTERDIT - Freezed est immutable
user.name = 'New Name'; // Compile error

// CORRECT
final newUser = user.copyWith(name: 'New Name');
```

## Checklist

- [ ] Entities (Domain) : `part 'xxx.freezed.dart'` uniquement
- [ ] Models (Infrastructure) : `part 'xxx.freezed.dart'` + `part 'xxx.g.dart'`
- [ ] `const ClassName._()` present si getters/methodes custom
- [ ] `@Default` pour valeurs par defaut
- [ ] `@JsonKey` pour mapping JSON custom (Models seulement)
- [ ] `when`/`maybeWhen` pour unions exhaustives
- [ ] Pas de mutation directe, toujours `copyWith`
- [ ] Conversion Entity <-> Model via `toEntity()` et `fromEntity()`
