import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/app/app_theme.dart';
import 'package:rick_and_morty/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty/features/characters/domain/entities/characters_page.dart';
import 'package:rick_and_morty/features/characters/domain/repositories/characters_repository.dart';
import 'package:rick_and_morty/features/characters/presentation/cubit/characters_cubit.dart';
import 'package:rick_and_morty/features/characters/presentation/pages/catalog_page.dart';
import 'package:rick_and_morty/features/characters/presentation/pages/character_details_page.dart';

const _character = Character(
  id: 1,
  name: 'Rick Sanchez',
  image: 'https://example.com/1.png',
  status: 'Alive',
  species: 'Human',
  origin: 'Earth (Replacement Dimension)',
  location: 'A very long last known location somewhere in another dimension',
);

class _Repository implements CharactersRepository {
  bool fail = false;
  final queries = <String>[];
  List<Character> characters = [_character];

  @override
  Future<CharactersPage> getCharacters({
    required int page,
    required String name,
  }) async {
    queries.add(name);
    if (fail) throw Exception('offline');
    return CharactersPage(
      characters: name.isEmpty || name == 'Rick' ? characters : [],
      hasMore: false,
    );
  }
}

Future<void> _mount(WidgetTester tester, _Repository repository) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: BlocProvider(
        create: (_) => CharactersCubit(repository)..loadCharacters(),
        child: const CatalogPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('details and back preserve catalog and search controller', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      final repository = _Repository();
      repository.characters = List.generate(
        30,
        (index) => Character(
          id: index + 1,
          name: _character.name,
          image: _character.image,
          status: _character.status,
          species: _character.species,
          origin: _character.origin,
          location: _character.location,
        ),
      );
      await _mount(tester, repository);
      await tester.enterText(find.byType(TextField), 'Rick');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      final catalogContext = tester.element(find.byType(CatalogPage));
      final cubit = catalogContext.read<CharactersCubit>();
      final stateBeforeDetails = cubit.state;
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
      await tester.pumpAndSettle();
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      final offsetBeforeDetails = position.pixels;
      expect(offsetBeforeDetails, greaterThan(0));
      expect(
        tester
            .getSemantics(
              find.bySemanticsLabel('Rick Sanchez, Alive. Open details').first,
            )
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      await tester.tap(find.text('Rick Sanchez').hitTestable().first);
      await tester.pumpAndSettle();
      expect(find.byType(CharacterDetailsPage), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Species'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(CatalogPage), findsOneWidget);
      expect(repository.queries, ['', 'Rick']);
      expect(
        tester.element(find.byType(CatalogPage)).read<CharactersCubit>(),
        same(cubit),
      );
      expect(cubit.state, stateBeforeDetails);
      expect(position.pixels, offsetBeforeDetails);
      position.jumpTo(0);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Rick',
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('empty server search can be cleared', (tester) async {
    final repository = _Repository();
    await _mount(tester, repository);
    await tester.enterText(find.byType(TextField), 'Nobody');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('An unexplored dimension'), findsOneWidget);
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Clear search'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear search'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(repository.queries, ['', 'Nobody', '']);
    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('initial error retries without technical error text', (
    tester,
  ) async {
    final repository = _Repository()..fail = true;
    await _mount(tester, repository);
    expect(find.text('Signal lost'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
    repository.fail = false;
    await tester.ensureVisible(find.text('Retry'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Rick Sanchez'), findsOneWidget);
  });

  testWidgets('keyboard leaves narrow catalog scrollable', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await _mount(tester, _Repository());
    await tester.tap(find.byType(TextField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nobody');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Clear search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear search'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long details wrap with large text on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final character = Character(
      id: 9,
      name: 'An extraordinarily long character name from a distant dimension',
      image: _character.image,
      status: 'unknown',
      species: _character.species,
      origin: _character.origin,
      location: _character.location,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: CharacterDetailsPage(character: character),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(character.location), 300);
    await tester.pumpAndSettle();
    expect(find.text(character.location), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop details use two columns and scroll only when needed', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final height in [800.0, 480.0]) {
      tester.view.physicalSize = Size(1280, height);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const CharacterDetailsPage(character: _character),
        ),
      );
      await tester.pumpAndSettle();
      final portrait = tester.getRect(find.byType(Hero));
      final name = tester.getRect(find.text(_character.name));
      expect(portrait.right, lessThan(name.left));
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      expect(position.maxScrollExtent, height == 800 ? 0 : greaterThan(0));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('narrow, wide and large text layouts avoid overflow', (
    tester,
  ) async {
    for (final size in [
      const Size(320, 640),
      const Size(360, 800),
      const Size(390, 844),
      const Size(430, 932),
      const Size(768, 1024),
      const Size(1100, 600),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      for (final scale in [1.0, 2.0]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: BlocProvider(
              create: (_) => CharactersCubit(_Repository())..loadCharacters(),
              child: const CatalogPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$size, text scale $scale',
        );
        await tester.pumpWidget(const SizedBox());
      }
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
