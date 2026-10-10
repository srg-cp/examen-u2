import '../../../pets/domain/entities/pet.dart';
import '../../domain/entities/lost_case.dart';

class LostCaseDto {
  const LostCaseDto(this.row);
  final Map<String, dynamic> row;
  PublishedLostCase toPublished() => PublishedLostCase(
    id: row['id'] as String,
    ownerId: row['owner_id'] as String,
    petId: row['pet_id'] as String,
    status: row['status'] as String,
    petName: row['pet_name'] as String? ?? '',
  );
  PublicLostCase toPublic(List<CasePhoto> photos) => PublicLostCase(
    id: row['id'] as String,
    status: row['status'] as String,
    occurredAt: DateTime.parse(row['occurred_at'] as String),
    latitude: (row['latitude'] as num).toDouble(),
    longitude: (row['longitude'] as num).toDouble(),
    fields: PetFields(
      name: row['pet_name'] as String,
      species: PetSpecies.values.byName(row['species'] as String),
      speciesDetail: row['species_detail'] as String?,
      size: PetSize.values.byName(row['size'] as String),
      sex: row['sex'] == null
          ? null
          : PetSex.values.byName(row['sex'] as String),
      ageMonths: row['age_months'] as int,
      traits: row['traits'] as String,
    ),
    photos: photos,
  );
}
