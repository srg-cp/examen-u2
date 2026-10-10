import '../../../pets/domain/entities/pet.dart';
import '../../../pets/domain/entities/pet_photo.dart';
import '../../domain/entities/lost_case.dart';

enum CaseEditorStage { form, preview, confirmed }

class CaseEditorState {
  CaseEditorState({
    required this.ownerId,
    required this.draftId,
    required List<Pet> pets,
    this.pet,
    List<PetPhoto> photos = const [],
    Set<String> selectedPhotos = const {},
    this.occurredAt,
    this.latitude,
    this.longitude,
    this.placeReference = '',
    this.issue,
    this.errorId = 0,
    Set<CaseField> invalidFields = const {},
    this.busy = false,
    this.loadingPhotos = false,
    this.dirty = false,
    this.lockedDraft,
    this.stage = CaseEditorStage.form,
    this.published,
  }) : pets = List.unmodifiable(pets),
       photos = List.unmodifiable(photos),
       selectedPhotos = Set.unmodifiable(selectedPhotos),
       invalidFields = Set.unmodifiable(invalidFields);
  final String ownerId, draftId, placeReference;
  final List<Pet> pets;
  final Pet? pet;
  final List<PetPhoto> photos;
  final Set<String> selectedPhotos;
  final DateTime? occurredAt;
  final double? latitude, longitude;
  final int errorId;
  final CaseFailureKind? issue;
  final Set<CaseField> invalidFields;
  final bool busy, loadingPhotos, dirty;
  final CaseEditorStage stage;
  final PublishedLostCase? published;
  // Ambiguous response: freeze the exact command until its retry is confirmed.
  final LostCaseDraft? lockedDraft;
  CaseEditorState copyWith({
    Pet? pet,
    List<PetPhoto>? photos,
    Set<String>? selectedPhotos,
    DateTime? occurredAt,
    double? latitude,
    double? longitude,
    String? placeReference,
    CaseFailureKind? issue,
    Set<CaseField>? invalidFields,
    bool clearIssue = false,
    bool? busy,
    bool? loadingPhotos,
    bool? dirty,
    CaseEditorStage? stage,
    PublishedLostCase? published,
    LostCaseDraft? lockedDraft,
    bool clearLockedDraft = false,
  }) => CaseEditorState(
    ownerId: ownerId,
    draftId: draftId,
    pets: pets,
    pet: pet ?? this.pet,
    photos: photos ?? this.photos,
    selectedPhotos: selectedPhotos ?? this.selectedPhotos,
    occurredAt: occurredAt ?? this.occurredAt,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    placeReference: placeReference ?? this.placeReference,
    issue: clearIssue ? null : issue ?? this.issue,
    errorId: issue != null ? errorId + 1 : errorId,
    invalidFields: clearIssue ? {} : invalidFields ?? this.invalidFields,
    busy: busy ?? this.busy,
    loadingPhotos: loadingPhotos ?? this.loadingPhotos,
    dirty: dirty ?? this.dirty,
    stage: stage ?? this.stage,
    published: published ?? this.published,
    lockedDraft: clearLockedDraft ? null : lockedDraft ?? this.lockedDraft,
  );
}
