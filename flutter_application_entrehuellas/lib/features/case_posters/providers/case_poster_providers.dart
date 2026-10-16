import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../domain/repositories/case_poster_repository.dart';
import '../domain/use_cases/generate_case_poster.dart';
import '../domain/use_cases/export_case_poster.dart';

final casePosterRepositoryProvider = Provider<CasePosterRepository>(
  (_) => throw StateError('Inject CasePosterRepository'),
);
final posterSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
final generateCasePosterProvider = Provider(
  (ref) => GenerateCasePoster(ref.watch(casePosterRepositoryProvider)),
);
final exportCasePosterProvider = Provider(
  (ref) => ExportCasePoster(ref.watch(casePosterRepositoryProvider)),
);
