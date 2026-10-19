import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/dio_client.dart';
import '../features/characters/data/repositories/characters_repository_impl.dart';
import '../features/characters/presentation/cubit/characters_cubit.dart';
import '../features/characters/presentation/pages/catalog_page.dart';
import 'app_theme.dart';

class CatalogApp extends StatefulWidget {
  const CatalogApp({super.key});

  @override
  State<CatalogApp> createState() => _CatalogAppState();
}

class _CatalogAppState extends State<CatalogApp> {
  late final Dio _dio = createDio();
  late final _repository = CharactersRepositoryImpl(_dio);

  @override
  void dispose() {
    _dio.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'The Multiverse • Character Catalog',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: BlocProvider(
      create: (_) => CharactersCubit(_repository)..loadCharacters(),
      child: const CatalogPage(),
    ),
  );
}
