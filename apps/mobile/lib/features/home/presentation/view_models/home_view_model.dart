import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/home_view_state.dart';

final homeViewModelProvider =
    NotifierProvider.autoDispose<HomeViewModel, HomeViewState>(
      HomeViewModel.new,
    );

class HomeViewModel extends Notifier<HomeViewState> {
  @override
  HomeViewState build() => const HomeViewState();
  void select(HomeSection section) {
    if (state.section != section) state = HomeViewState(section: section);
  }
}
