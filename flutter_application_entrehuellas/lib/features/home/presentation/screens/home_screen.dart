import '../../../../core/presentation/widgets/scroll_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/brand_wordmark.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../view_models/home_view_model.dart';
import '../state/home_view_state.dart';
import '../widgets/liquid_navigation.dart';
import '../widgets/home_content.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({required this.profileAvatar, this.petsContent, super.key});
  final Widget profileAvatar;
  final Widget? petsContent;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final model = ref.read(homeViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      body: ScrollSafeArea(
        top: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: BrandWordmark(
                                    iconSize: 46,
                                    textSize: 22,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Alertas',
                                onPressed: () => showHomeInfo(
                                  context,
                                  title: 'Alertas',
                                  description:
                                      'Las novedades de tus casos y zonas estarán aquí. Las alertas aún no están disponibles.',
                                ),
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF6E6E73),
                                ),
                              ),
                              const SizedBox(width: 4),
                              profileAvatar,
                            ],
                          ),
                        ),
                        AuthStageTransition(
                          enabled: state.section != HomeSection.pets,
                          stage: state.section,
                          startCovered: true,
                          builder: (play) => StaggerReveal(
                            enabled: state.section != HomeSection.pets,
                            key: ValueKey(state.section),
                            count: state.section == HomeSection.home ? 3 : 2,
                            play: play,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                24,
                                6,
                                24,
                                ScrollSafeArea.bottomPadding(context, 130),
                              ),
                              child: state.section == HomeSection.home
                                  ? HomeContent(
                                      onSelect: model.select,
                                      onReport: (source) => openLostReport(
                                        source,
                                        color: const Color(0xFFF5F5F7),
                                        radius: 22,
                                      ),
                                    )
                                  : state.section == HomeSection.pets &&
                                        petsContent != null
                                  ? petsContent!
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        StaggerRevealItem(
                                          order: 0,
                                          child: Text(
                                            state.section == HomeSection.explore
                                                ? 'Explorar'
                                                : 'Mis mascotas',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF111111),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        StaggerRevealItem(
                                          order: 1,
                                          child: HomeNotice(
                                            icon:
                                                state.section ==
                                                    HomeSection.explore
                                                ? Icons.travel_explore
                                                : Icons.pets_outlined,
                                            title:
                                                state.section ==
                                                    HomeSection.explore
                                                ? 'Ayuda a encontrar su hogar'
                                                : 'Su información, en un solo lugar',
                                            description:
                                                state.section ==
                                                    HomeSection.explore
                                                ? 'Aquí podrás consultar casos en lista o mapa y filtrar por zona. La búsqueda de casos aún no está disponible.'
                                                : 'Aquí podrás registrar tus mascotas, sus fotos y consultar sus casos. El registro de mascotas aún no está disponible.',
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: ScrollSafeArea.bottomPadding(context, 16),
                  child: LiquidNavigation(
                    selected: state.section,
                    onSelect: model.select,
                    onReport: (source) => openLostReport(source),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
