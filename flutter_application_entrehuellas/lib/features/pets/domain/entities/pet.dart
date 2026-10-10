import 'dart:math';

enum PetSpecies { dog, cat, other }

enum PetSex { male, female }

enum PetSize { small, medium, large }

class PetFields {
  const PetFields({
    required this.name,
    required this.species,
    this.sex,
    this.ageMonths,
    this.traits,
    this.speciesDetail,
    this.size,
  });
  final String name;
  final PetSpecies? species;
  final PetSex? sex;
  final int? ageMonths;
  final String? traits;
  final String? speciesDetail;
  final PetSize? size;
}

class Pet {
  const Pet({
    required this.id,
    required this.ownerId,
    required this.fields,
    required this.version,
    this.coverUri,
  });
  final String id;
  final String ownerId;
  final PetFields fields;
  final int version;
  final Uri? coverUri;
}

/// One UUID per draft, reused after an ambiguous network response.
String newPetId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
