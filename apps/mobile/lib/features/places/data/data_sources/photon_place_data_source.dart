import 'dart:convert';
import 'package:http/http.dart' as http;
import 'place_search_data_source.dart';
import '../models/search_place_dto.dart';

class PhotonPlaceDataSource implements PlaceSearchDataSource {
  const PhotonPlaceDataSource(
    this._client, {
    this.endpoint = 'https://photon.komoot.io/api/',
  });
  final http.Client _client;
  final String endpoint;
  @override
  Future<List<SearchPlaceDto>> search(
    String query, {
    bool citiesOnly = false,
  }) async {
    final base = Uri.parse(endpoint);
    if (base.scheme != 'https' ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty) {
      throw const FormatException('Invalid place service');
    }
    final response = await _client
        .get(
          base.replace(
            queryParameters: {
              'q': query,
              'limit': '5',
              if (citiesOnly) 'layer': 'city',
            },
          ),
          headers: {
            'Accept': 'application/json',
            'User-Agent':
                'EntreHuellas/0.1 (+https://github.com/srg-cp/entrehuellas)',
          },
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200 || response.bodyBytes.length > 262144) {
      throw const FormatException('Place service unavailable');
    }
    final result = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    final features = result['features'] as List;
    final rows = <SearchPlaceDto>[];
    for (final feature in features.take(5)) {
      try {
        rows.add(
          SearchPlaceDto.fromJson(
            Map<String, dynamic>.from(feature as Map),
            citiesOnly: citiesOnly,
          ),
        );
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      } on RangeError {
        continue;
      }
    }
    if (!citiesOnly && features.isNotEmpty && rows.isEmpty) {
      throw const FormatException('No valid places');
    }
    return rows;
  }
}
