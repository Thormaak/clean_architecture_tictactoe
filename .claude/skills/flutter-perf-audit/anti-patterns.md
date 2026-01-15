# Flutter Core Performance Anti-Patterns

Ce document liste les anti-patterns Flutter core à éviter (sans state management).

---

## 1. Const Manquants

### Anti-pattern : Widget sans const

```dart
// MAUVAIS : Reconstruit à chaque build du parent
Widget build(BuildContext context) {
  return Column(
    children: [
      SizedBox(height: 16),        // Devrait être const
      Icon(Icons.check),           // Devrait être const
      Padding(                     // Devrait être const
        padding: EdgeInsets.all(8),
        child: Text('Hello'),
      ),
    ],
  );
}
```

```dart
// BON : Avec const
Widget build(BuildContext context) {
  return const Column(
    children: [
      SizedBox(height: 16),
      Icon(Icons.check),
      Padding(
        padding: EdgeInsets.all(8),
        child: Text('Hello'),
      ),
    ],
  );
}
```

### Anti-pattern : Widget inline complexe

```dart
// MAUVAIS : Widget complexe inline, reconstruit à chaque fois
Widget build(BuildContext context) {
  return ListView.builder(
    itemBuilder: (context, index) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(items[index].name),
                  Text(items[index].email),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
```

```dart
// BON : Extrait en widget séparé
Widget build(BuildContext context) {
  return ListView.builder(
    itemBuilder: (context, index) => UserCard(
      key: ValueKey(items[index].id),
      user: items[index],
    ),
  );
}

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name),
                Text(user.email),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 2. List Anti-Patterns

### Anti-pattern : ListView avec children

```dart
// MAUVAIS : Tous les widgets construits immédiatement
Widget build(BuildContext context) {
  return ListView(
    children: items.map((item) => ItemTile(item: item)).toList(),
    // Même avec 1000 items, tous sont créés en mémoire
  );
}
```

```dart
// BON : ListView.builder pour lazy loading
Widget build(BuildContext context) {
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ItemTile(
      key: ValueKey(items[index].id),
      item: items[index],
    ),
  );
}
```

### Anti-pattern : Absence de Key

```dart
// MAUVAIS : Pas de Key = Flutter ne peut pas optimiser le réordonnancement
ListView.builder(
  itemBuilder: (context, index) => ItemTile(item: items[index]),
)
```

```dart
// BON : Key basée sur l'ID unique
ListView.builder(
  itemBuilder: (context, index) => ItemTile(
    key: ValueKey(items[index].id), // Pas Key('$index')
    item: items[index],
  ),
)
```

### Anti-pattern : Key basée sur l'index

```dart
// MAUVAIS : L'index change lors du réordonnancement
ItemTile(
  key: Key('$index'), // Index = mauvaise key
  item: items[index],
)
```

```dart
// BON : ID stable et unique
ItemTile(
  key: ValueKey(items[index].id),
  item: items[index],
)
```

---

## 3. Animation Anti-Patterns

### Anti-pattern : AnimationController sans vsync

```dart
// MAUVAIS : Pas de vsync = consommation CPU inutile
class _MyWidgetState extends State<MyWidget> {
  late final _controller = AnimationController(
    duration: Duration(seconds: 1),
    // vsync manquant !
  );
}
```

```dart
// BON : Avec SingleTickerProviderStateMixin
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
}
```

### Anti-pattern : Rebuild complet pendant animation

```dart
// MAUVAIS : Tout le widget rebuild 60 fois/seconde
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            ExpensiveHeader(),    // Reconstruit inutilement
            Transform.rotate(
              angle: _controller.value,
              child: Logo(),       // Reconstruit inutilement
            ),
            ExpensiveFooter(),    // Reconstruit inutilement
          ],
        );
      },
    );
  }
}
```

```dart
// BON : Seule la rotation change
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      const ExpensiveHeader(),
      AnimatedBuilder(
        animation: _controller,
        child: const Logo(), // Passé via child = pas reconstruit
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value,
            child: child,
          );
        },
      ),
      const ExpensiveFooter(),
    ],
  );
}
```

### Anti-pattern : setState dans AnimationListener

```dart
// MAUVAIS : setState 60 fois/seconde pour mettre à jour la valeur
_controller.addListener(() {
  setState(() {
    _currentValue = _controller.value;
  });
});
```

```dart
// BON : AnimatedBuilder gère automatiquement les updates
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Text('${(_controller.value * 100).toInt()}%');
  },
)
```

### Anti-pattern : AnimationController non disposé

```dart
// MAUVAIS : Fuite mémoire
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  // dispose() manquant ou incomplet !
}
```

```dart
// BON : Toujours disposer le controller
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

## 4. Image Anti-Patterns

### Anti-pattern : Image sans contrainte de taille

```dart
// MAUVAIS : Image en pleine résolution en mémoire
Image.asset('assets/large_image.png')

// Si l'image fait 4000x4000 mais affichée en 100x100,
// Flutter garde 4000x4000 en mémoire
```

```dart
// BON : Contraindre le cache
Image.asset(
  'assets/large_image.png',
  width: 100,
  height: 100,
  cacheWidth: 200,  // 2x pour haute densité
  cacheHeight: 200,
)
```

### Anti-pattern : Image réseau sans placeholder

```dart
// MAUVAIS : Espace vide puis image qui "pop"
Image.network(imageUrl)
```

```dart
// BON : Transition fluide avec placeholder
FadeInImage.assetNetwork(
  placeholder: 'assets/placeholder.png',
  image: imageUrl,
  fadeInDuration: const Duration(milliseconds: 300),
)
```

### Anti-pattern : Chargement synchrone au build

```dart
// MAUVAIS : Bloque le build
Widget build(BuildContext context) {
  final bytes = File('path/to/image').readAsBytesSync(); // Synchrone !
  return Image.memory(bytes);
}
```

```dart
// BON : Asynchrone avec FutureBuilder ou precache
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(AssetImage('assets/image.png'), context);
}
```

---

## 5. Scrolling Anti-Patterns

### Anti-pattern : Scroll sans cacheExtent

```dart
// MAUVAIS : Pas de pre-rendering, saccades lors du scroll rapide
ListView.builder(
  itemBuilder: (context, index) => HeavyWidget(item: items[index]),
)
```

```dart
// BON : Pre-render au-delà du viewport
ListView.builder(
  cacheExtent: 500, // Pre-render 500px de plus
  itemBuilder: (context, index) => HeavyWidget(item: items[index]),
)
```

### Anti-pattern : Nested ScrollViews sans shrinkWrap

```dart
// MAUVAIS : Nested scrollables sans contrainte
ListView(
  children: [
    ListView( // Nested ListView
      children: [...], // Essaie de prendre une hauteur infinie
    ),
  ],
)
```

```dart
// BON : CustomScrollView avec Slivers
CustomScrollView(
  slivers: [
    SliverList(...),
    SliverList(...), // Plusieurs slivers dans un seul scrollable
  ],
)

// Ou si vraiment nécessaire
ListView(
  children: [
    ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [...],
    ),
  ],
)
```

### Anti-pattern : ScrollController créé dans build

```dart
// MAUVAIS : Nouveau controller à chaque rebuild
Widget build(BuildContext context) {
  final controller = ScrollController(); // Fuite mémoire !
  return ListView(controller: controller, ...);
}
```

```dart
// BON : Controller dans State, disposé proprement
class _MyWidgetState extends State<MyWidget> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(controller: _scrollController, ...);
  }
}
```

---

## 6. Build Method Anti-Patterns

### Anti-pattern : Calculs lourds dans build

```dart
// MAUVAIS : Recalculé à chaque rebuild
Widget build(BuildContext context) {
  final sortedItems = items..sort((a, b) => a.name.compareTo(b.name));
  final filteredItems = sortedItems.where((i) => i.isActive).toList();
  final groupedItems = groupBy(filteredItems, (i) => i.category);

  return ListView(...);
}
```

```dart
// BON : Calculs dans initState ou via state management
class _MyWidgetState extends State<MyWidget> {
  late List<Item> _processedItems;

  @override
  void initState() {
    super.initState();
    _processedItems = _processItems(widget.items);
  }

  List<Item> _processItems(List<Item> items) {
    return items
        .where((i) => i.isActive)
        .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _processedItems.length,
      itemBuilder: (context, index) => ItemTile(item: _processedItems[index]),
    );
  }
}
```

### Anti-pattern : Création d'objets dans build

```dart
// MAUVAIS : Nouveaux objets créés à chaque rebuild
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration( // Nouveau BoxDecoration
      borderRadius: BorderRadius.circular(8), // Nouveau BorderRadius
      color: Colors.blue,
    ),
  );
}
```

```dart
// BON : Objets constants ou en dehors du build
static const _decoration = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  color: Colors.blue,
);

Widget build(BuildContext context) {
  return Container(decoration: _decoration);
}
```

### Anti-pattern : Callbacks inline

```dart
// MAUVAIS : Nouvelle fonction créée à chaque rebuild
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      doSomething();
    },
    child: const Text('Click'),
  );
}
```

```dart
// BON : Callback mémorisé
class _MyWidgetState extends State<MyWidget> {
  void _handlePress() {
    doSomething();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handlePress,
      child: const Text('Click'),
    );
  }
}
```

---

## Checklist de détection

| Anti-pattern | Comment détecter | Impact |
|--------------|------------------|--------|
| Const manquant | Rechercher `SizedBox(`, `Icon(` sans const | Moyen |
| ListView children | `ListView(children:` | Majeur |
| Key manquante | itemBuilder sans `key:` | Majeur |
| Key sur index | `Key('$index')` ou `Key(index.toString())` | Majeur |
| vsync manquant | `AnimationController(` sans `vsync:` | Critique |
| AnimatedBuilder sans child | `AnimatedBuilder` sans paramètre `child:` | Majeur |
| Controller non disposé | AnimationController/ScrollController sans dispose | Critique |
| Image sans cache | `Image.asset/network(` sans cacheWidth | Moyen |
| Scroll sans cache | ListView/GridView sans cacheExtent | Mineur |
| Build lourd | Boucles/sort/filter dans build() | Majeur |
| Objets inline | `BoxDecoration(`, `EdgeInsets(` dans build | Mineur |
| Callback inline | `() {` ou `() =>` dans onPressed/onTap | Mineur |
