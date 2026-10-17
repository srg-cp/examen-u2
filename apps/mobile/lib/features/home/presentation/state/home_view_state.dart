enum HomeSection { home, explore, pets }

class HomeViewState {
  const HomeViewState({this.section = HomeSection.home});
  final HomeSection section;
}
