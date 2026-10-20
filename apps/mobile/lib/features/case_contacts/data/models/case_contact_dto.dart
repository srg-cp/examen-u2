class CaseContactDto {
  const CaseContactDto({
    required this.canEdit,
    required this.version,
    required this.suggestedName,
    this.name,
    this.phone,
    this.sharePhoto = false,
    this.avatarUri,
  });
  factory CaseContactDto.fromMap(Map<String, dynamic> row) {
    final c = row['contact'] as Map?;
    final name = c?['display_name'] as String?;
    final phone = c?['phone'] as String?;
    if (c != null &&
        (name == null ||
            name.trim().runes.length < 2 ||
            name.runes.length > 80 ||
            phone == null ||
            !RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(phone))) {
      throw const FormatException('Invalid contact projection');
    }
    final uri = c?['avatar_url'] is String
        ? Uri.tryParse(c!['avatar_url'] as String)
        : null;
    return CaseContactDto(
      canEdit: row['can_edit'] == true,
      version: (row['version'] as num?)?.toInt() ?? 0,
      suggestedName: row['suggested_name'] as String? ?? '',
      name: name,
      phone: phone,
      sharePhoto: c?['share_photo'] == true,
      avatarUri:
          uri != null &&
              uri.scheme == 'https' &&
              uri.host.isNotEmpty &&
              uri.userInfo.isEmpty
          ? uri
          : null,
    );
  }
  final bool canEdit, sharePhoto;
  final int version;
  final String suggestedName;
  final String? name, phone;
  final Uri? avatarUri;
}
