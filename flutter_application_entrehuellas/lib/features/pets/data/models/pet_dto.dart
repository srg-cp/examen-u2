import '../../domain/entities/pet.dart';

class PetDto {
  const PetDto({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.version,
    this.sex,
    this.ageMonths,
    this.traits,
    this.speciesDetail,
    this.size,
    this.coverUri,
  });
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String? sex;
  final int? ageMonths;
  final String? traits;
  final String? speciesDetail;
  final String? size;
  final Uri? coverUri;
  final int version;
  factory PetDto.fromMap(Map<String, dynamic> row, {Uri? coverUri}) => PetDto(
    coverUri: coverUri,
    id: row['id'] as String,
    ownerId: row['owner_id'] as String,
    version: row['version'] as int,
    name: row['name'] as String,
    species: row['species'] as String,
    sex: row['sex'] as String?,
    ageMonths: row['age_months'] as int?,
    traits: row['traits'] as String?,
    speciesDetail: row['species_detail'] as String?,
    size: row['size'] as String?,
  );
  Pet toEntity() => Pet(
    coverUri: coverUri,
    id: id,
    ownerId: ownerId,
    version: version,
    fields: PetFields(
      speciesDetail: speciesDetail,
      size: size == null ? null : PetSize.values.byName(size!),
      name: name,
      species: PetSpecies.values.byName(species),
      sex: sex == null ? null : PetSex.values.byName(sex!),
      ageMonths: ageMonths,
      traits: traits,
    ),
  );
}
