import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/places/data/data_sources/photon_place_data_source.dart';
import 'package:flutter_application_entrehuellas/features/places/data/repositories/place_search_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/cancellation/place_search_cancellation.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/failures/place_search_failure.dart';
import 'package:flutter_application_entrehuellas/features/places/presentation/view_models/place_search_view_model.dart';
import 'package:flutter_application_entrehuellas/features/places/providers/places_providers.dart';
import 'support/fake_place_search.dart';

void main() {
  for (final citiesOnly in [false, true]) {
    testWidgets(
      'Latest lookup starts at 300ms without waiting for obsolete response: cities=$citiesOnly',
      (tester) async {
        final repo = FakePlaceSearch()..pending = Completer();
        final oldResponse = repo.pending!;
        final container = ProviderContainer(
          overrides: [
            placeSearchRepositoryProvider.overrideWithValue(repo),
            placesSessionProvider.overrideWith(
              (_) => Stream.value(const AuthSession(userId: 'one')),
            ),
          ],
        );
        addTearDown(container.dispose);
        final provider = placeSearchByModeViewModelProvider(citiesOnly);
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);
        await tester.pump();
        final model = container.read(provider.notifier);
        final oldWork = model.search('Chic');
        await tester.pump();
        final oldCancellation = repo.cancellations.single!;
        // A new response can complete while the old transport is still unwinding.
        repo.pending = Completer();
        final latest = repo.pending!;
        model.queryChanged('Chiclayo');
        expect(oldCancellation.isCancelled, isTrue);
        await tester.pump(const Duration(milliseconds: 299));
        expect(repo.queries, ['Chic']);
        await tester.pump(const Duration(milliseconds: 1));
        expect(repo.queries, ['Chic', 'Chiclayo']);
        latest.complete(const [FakePlaceSearch.place]);
        await tester.pump();
        expect(
          container.read(provider).places.single.label,
          FakePlaceSearch.place.label,
        );
        oldResponse.completeError(
          StateError('Old network request completed late'),
        );
        await oldWork;
        await tester.pump();
        expect(
          container.read(provider).places.single.label,
          FakePlaceSearch.place.label,
        );
        expect(container.read(provider).notice, isNull);
        expect(container.read(provider).busy, isFalse);
      },
    );
  }

  test(
    'Cancellation reaches HTTP abort trigger; aborted results never enter cache',
    () async {
      final started = Completer<void>();
      var calls = 0;
      var aborted = false;
      final client = MockClient.streaming((request, _) async {
        calls++;
        expect(request.url.queryParameters['countrycode'], 'PE');
        expect(request, isA<http.AbortableRequest>());
        if (calls == 1) {
          started.complete();
          await (request as http.AbortableRequest).abortTrigger;
          aborted = true;
          throw http.RequestAbortedException(request.url);
        }
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'features': [
                  {
                    'geometry': {
                      'coordinates': [-79.84, -6.77],
                    },
                    'properties': {'name': 'Chiclayo', 'countrycode': 'PE'},
                  },
                ],
              }),
            ),
          ),
          200,
        );
      });
      addTearDown(client.close);
      final repo = PlaceSearchRepositoryImpl(PhotonPlaceDataSource(client));
      final cancellation = PlaceSearchCancellation();
      final old = expectLater(
        repo.search('Chiclayo', cancellation: cancellation),
        throwsA(
          isA<PlaceSearchFailure>().having(
            (failure) => failure.kind,
            'kind',
            PlaceSearchFailureKind.cancelled,
          ),
        ),
      );
      await started.future;
      cancellation.cancel();
      await old;
      expect(aborted, isTrue);
      final result = await repo.search('Chiclayo');
      expect(result.single.label, 'Chiclayo');
      await repo.search('chiclayo');
      expect(calls, 2);
    },
  );

  testWidgets(
    'Clearing and disposal abort active lookup and prevent delayed requests',
    (tester) async {
      final repo = FakePlaceSearch()..pending = Completer();
      final pending = repo.pending!;
      final container = ProviderContainer(
        overrides: [
          placeSearchRepositoryProvider.overrideWithValue(repo),
          placesSessionProvider.overrideWith(
            (_) => Stream.value(const AuthSession(userId: 'one')),
          ),
        ],
      );
      final sub = container.listen(placeSearchViewModelProvider, (_, _) {});
      await tester.pump();
      final model = container.read(placeSearchViewModelProvider.notifier);
      final old = model.search('Chiclayo');
      await tester.pump();
      model.clear();
      expect(repo.cancellations.single!.isCancelled, isTrue);
      model.queryChanged('Tacna');
      sub.close();
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
      pending.complete(const []);
      await old;
      expect(repo.queries, ['Chiclayo']);
    },
  );
}
