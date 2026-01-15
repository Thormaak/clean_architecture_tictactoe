# Flutter Core Performance Patterns

Ce document détaille les patterns d'optimisation Flutter core (sans state management).

---

## 1. Const Widgets

### Pattern : Const Constructor

```dart
// Widget avec const constructor
class MyCard extends StatelessWidget {
  const MyCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16), // const literal
        child: Text(title),
      ),
    );
  }
}

// Usage avec const
const MyCard(title: 'Static Title')
```

### Pattern : Extraction de widgets statiques

```dart
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _Header(), // Extrait en classe const
        _Divider(), // Extrait en classe const
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Welcome',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 32, thickness: 1);
  }
}
```

---

## 2. Lists Patterns

### Pattern : ListView.builder avec Key

```dart
ListView.builder(
  itemCount: items.length,
  // itemExtent pour performance si hauteur fixe
  itemExtent: 72.0,
  itemBuilder: (context, index) {
    final item = items[index];
    return ItemTile(
      key: ValueKey(item.id), // Key basée sur l'ID unique
      item: item,
    );
  },
)
```

### Pattern : SliverList avec findChildIndexCallback

```dart
CustomScrollView(
  slivers: [
    SliverList.builder(
      itemCount: items.length,
      // Optimise le réordonnancement
      findChildIndexCallback: (Key key) {
        final id = (key as ValueKey<String>).value;
        final index = items.indexWhere((item) => item.id == id);
        return index != -1 ? index : null;
      },
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemTile(
          key: ValueKey(item.id),
          item: item,
        );
      },
    ),
  ],
)
```

---

## 3. Animation Patterns

### Pattern : AnimatedBuilder avec child

```dart
class RotatingLogo extends StatefulWidget {
  const RotatingLogo({super.key});

  @override
  State<RotatingLogo> createState() => _RotatingLogoState();
}

class _RotatingLogoState extends State<RotatingLogo>
    with SingleTickerProviderStateMixin { // vsync obligatoire
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // Toujours fournir vsync
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // child passé au builder = pas reconstruit
      child: const FlutterLogo(size: 100),
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: child, // Réutilise le child const
        );
      },
    );
  }
}
```

### Pattern : TweenAnimationBuilder

```dart
class FadeInWidget extends StatelessWidget {
  const FadeInWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      // child passé séparément = optimisé
      child: child,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
    );
  }
}
```

### Pattern : AnimatedSwitcher

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    return FadeTransition(opacity: animation, child: child);
  },
  // Key différente = animation de transition
  child: Text(
    '$counter',
    key: ValueKey(counter),
  ),
)
```

---

## 4. Image Patterns

### Pattern : Precache images critiques

```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Précache les images importantes
    precacheImage(const AssetImage('assets/logo.png'), context);
    precacheImage(const AssetImage('assets/background.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/logo.png');
  }
}
```

### Pattern : Image avec taille de cache

```dart
Image.asset(
  'assets/profile.png',
  width: 64,
  height: 64,
  // Cache à 2x pour écrans haute densité
  cacheWidth: 128,
  cacheHeight: 128,
  fit: BoxFit.cover,
)
```

### Pattern : FadeInImage pour images réseau

```dart
FadeInImage(
  placeholder: const AssetImage('assets/placeholder.png'),
  image: NetworkImage(user.avatarUrl),
  fadeInDuration: const Duration(milliseconds: 300),
  fit: BoxFit.cover,
  width: 100,
  height: 100,
  imageErrorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.error);
  },
)
```

### Pattern : CachedNetworkImage (package)

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: 200,
  memCacheHeight: 200,
)
```

---

## 5. Scrolling Patterns

### Pattern : CustomScrollView avec cacheExtent

```dart
CustomScrollView(
  // Pré-render 500px au-delà du viewport visible
  cacheExtent: 500,
  slivers: [
    SliverAppBar(
      floating: true,
      title: const Text('My App'),
    ),
    SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ItemCard(item: items[index]),
      ),
    ),
  ],
)
```

### Pattern : Lazy loading / Pagination

```dart
class PaginatedList extends StatefulWidget {
  const PaginatedList({super.key});

  @override
  State<PaginatedList> createState() => _PaginatedListState();
}

class _PaginatedListState extends State<PaginatedList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Charger plus de données
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return ItemTile(item: items[index]);
      },
    );
  }
}
```

### Pattern : SliverGrid pour grilles

```dart
CustomScrollView(
  slivers: [
    SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => GridItem(
          key: ValueKey(items[index].id),
          item: items[index],
        ),
        childCount: items.length,
      ),
    ),
  ],
)
```

---

## 6. RepaintBoundary Pattern

```dart
class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header statique - pas besoin de RepaintBoundary
        const GameHeader(),

        // Zone de jeu avec animations fréquentes
        RepaintBoundary(
          child: AnimatedGameGrid(),
        ),

        // Score qui update souvent
        RepaintBoundary(
          child: ScoreDisplay(),
        ),

        // Contrôles statiques
        const GameControls(),
      ],
    );
  }
}
```

---

## 7. Build Method Patterns

### Pattern : Objets constants

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  // Déclarations statiques en dehors de build
  static const _decoration = BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const _padding = EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration,
      padding: _padding,
      child: const Text('Content'),
    );
  }
}
```

### Pattern : Callbacks mémorisés

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // Callback défini une seule fois
  void _handleTap() {
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap, // Réutilisé, pas recréé
      child: const MyChild(),
    );
  }
}
```

---

## Résumé des patterns clés

| Catégorie | Pattern | Bénéfice |
|-----------|---------|----------|
| Const | `const` constructors | Évite rebuilds |
| Const | Extraction widgets | Réutilisation |
| Lists | `ListView.builder` | Lazy loading |
| Lists | `ValueKey(id)` | Réordonnancement efficace |
| Lists | `itemExtent` | Calcul scroll optimisé |
| Animation | `AnimatedBuilder` + child | Child non reconstruit |
| Animation | vsync | Synchronisation écran |
| Animation | `TweenAnimationBuilder` | Animation déclarative |
| Images | `cacheWidth/Height` | Mémoire optimisée |
| Images | `precacheImage` | Pas de délai affichage |
| Images | `FadeInImage` | UX fluide |
| Scroll | `cacheExtent` | Pre-rendering |
| Scroll | Slivers | Composition efficace |
| Isolation | `RepaintBoundary` | Repaint localisé |
| Build | Objets statiques | Pas de recréation |
| Build | Callbacks mémorisés | Références stables |
