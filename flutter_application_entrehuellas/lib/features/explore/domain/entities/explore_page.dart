import 'explore_query.dart';

class ExploreCase {
  const ExploreCase({
    required this.id,
    this.reportKind = 'own_loss',
    required this.fromPet,
    required this.kind,
    required this.status,
    required this.species,
    required this.name,
    required this.traits,
    required this.occurredAt,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    this.coverUri,
  });
  final String id, species, name, traits, reportKind;
  final bool fromPet;
  final ExploreKind kind;
  final ExploreStatus status;
  final DateTime occurredAt;
  final double latitude, longitude;
  final int? distanceMeters;
  final Uri? coverUri;
  String get key => '${fromPet ? 'lost' : 'found'}:$id';
}

class ExplorePage {
  ExplorePage({required List<ExploreCase> items, this.nextCursor})
    : items = List.unmodifiable(items);
  final List<ExploreCase> items;
  final String? nextCursor;
}
