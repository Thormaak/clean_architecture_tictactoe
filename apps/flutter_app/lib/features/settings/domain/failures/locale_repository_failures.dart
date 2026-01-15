import 'package:freezed_annotation/freezed_annotation.dart';

part 'locale_repository_failures.freezed.dart';

/// Union de types représentant les différentes erreurs possibles pour GetLocale
@freezed
sealed class GetLocaleFailure with _$GetLocaleFailure implements Exception {
  /// Erreur lorsqu'aucune locale n'est trouvée
  const factory GetLocaleFailure.notFound() = GetLocaleNotFound;

  /// Erreur liée au repository
  const factory GetLocaleFailure.repositoryError() = GetLocaleRepositoryError;

  /// Erreur inattendue
  const factory GetLocaleFailure.unexpected() = GetLocaleUnexpected;
}

/// Union de types représentant les différentes erreurs possibles pour SetLocale
@freezed
sealed class SetLocaleFailure with _$SetLocaleFailure implements Exception {
  /// Erreur lors de la sauvegarde
  const factory SetLocaleFailure.saveFailed() = SetLocaleSaveFailed;

  /// Erreur inattendue
  const factory SetLocaleFailure.unexpected() = SetLocaleUnexpected;
}
