# Flutter Core Performance Rules

Ces règles s'appliquent à tout code Flutter, quel que soit le state manager utilisé.

## 1. Const Constructors

- Utiliser `const` partout où c'est possible
- Extraire les widgets statiques en classes `const` séparées
- Préférer les literals const : `const EdgeInsets.all(8)`, `const SizedBox(height: 16)`

```dart
// Bon
const SizedBox(height: 16)
const Icon(Icons.check)
const Text('Static text')

// Mauvais
SizedBox(height: 16)
Icon(Icons.check)
```

## 2. Listes et Collections

```dart
// Bon : ListView.builder (lazy loading)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(key: ValueKey(items[index].id), item: items[index]),
)

// Bon : itemExtent si hauteur fixe
ListView.builder(
  itemExtent: 72.0, // Performance++
  itemBuilder: ...
)

// Mauvais : ListView avec children directs
ListView(children: items.map((i) => ItemWidget(item: i)).toList()) // Charge tout en mémoire
```

### Keys obligatoires

- Toujours fournir une `Key` pour les items de liste dynamique
- Utiliser `ValueKey(item.id)` plutôt que `Key(index.toString())`

## 3. RepaintBoundary

Isoler les widgets qui se repeignent fréquemment :

```dart
RepaintBoundary(
  child: AnimatedWidget(...), // Widget avec animation
)

RepaintBoundary(
  child: VideoPlayer(...), // Widget coûteux
)
```

## 4. Animations

```dart
// Bon : AnimatedBuilder (ne rebuild que le child)
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) => Transform.rotate(
    angle: _controller.value,
    child: child, // Réutilisé, pas reconstruit
  ),
  child: const ExpensiveWidget(),
)

// Bon : TweenAnimationBuilder pour animations simples
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: 1),
  duration: Duration(milliseconds: 300),
  builder: (context, value, child) => Opacity(opacity: value, child: child),
  child: const MyWidget(),
)

// Mauvais : rebuild de tout le widget pendant l'animation
```

### TickerProviderStateMixin

- Toujours utiliser `SingleTickerProviderStateMixin` ou `TickerProviderStateMixin`
- Ne jamais créer d'AnimationController sans vsync

## 5. Images

```dart
// Bon : Précacher les images critiques
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(AssetImage('assets/hero.png'), context);
}

// Bon : Taille adaptée
Image.asset(
  'assets/image.png',
  width: 100,
  height: 100,
  cacheWidth: 200, // 2x pour écrans haute densité
  cacheHeight: 200,
)

// Bon : Placeholder pendant chargement
FadeInImage.assetNetwork(
  placeholder: 'assets/placeholder.png',
  image: networkUrl,
)
```

## 6. Scrolling

```dart
// Bon : CustomScrollView avec Slivers
CustomScrollView(
  cacheExtent: 500, // Pré-render 500px au-delà du viewport
  slivers: [
    SliverAppBar(...),
    SliverList.builder(...),
  ],
)

// Bon : findChildIndexCallback pour listes avec réordonnancement
SliverList.builder(
  findChildIndexCallback: (Key key) {
    final id = (key as ValueKey<String>).value;
    return items.indexWhere((item) => item.id == id);
  },
  ...
)
```

## 7. Build Method

```dart
// Mauvais : Calculs dans build
Widget build(BuildContext context) {
  final sorted = items..sort(); // Recalculé à chaque rebuild
  return ListView(...);
}

// Mauvais : Nouveaux objets dans build
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(...), // Nouveau à chaque rebuild
  );
}

// Bon : Objets constants
static const _decoration = BoxDecoration(...);

Widget build(BuildContext context) {
  return Container(decoration: _decoration);
}
```

## Checklist rapide

- [ ] `const` sur tous les widgets statiques
- [ ] `ListView.builder` pour les listes
- [ ] `Key` sur les items de liste dynamique
- [ ] `RepaintBoundary` sur les widgets animés/coûteux
- [ ] `child` parameter dans les AnimatedBuilder
- [ ] `vsync` sur tous les AnimationController
- [ ] `cacheWidth/cacheHeight` sur les images
- [ ] `cacheExtent` sur les scrollables
- [ ] Pas de calculs lourds dans build()
