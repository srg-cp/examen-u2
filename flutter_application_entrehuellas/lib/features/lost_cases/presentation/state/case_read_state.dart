import '../../domain/entities/lost_case.dart';

class CaseListState {
  CaseListState({
    required this.ownerId,
    required List<PublishedLostCase> cases,
    this.refreshing = false,
    this.refreshFailed = false,
  }) : cases = List.unmodifiable(cases);
  final String ownerId;
  final List<PublishedLostCase> cases;
  final bool refreshing, refreshFailed;
}

class PublicCaseState {
  const PublicCaseState({
    required this.ownerId,
    required this.value,
    this.refreshing = false,
    this.refreshFailed = false,
  });
  final String? ownerId;
  final PublicLostCase? value;
  final bool refreshing, refreshFailed;
}
