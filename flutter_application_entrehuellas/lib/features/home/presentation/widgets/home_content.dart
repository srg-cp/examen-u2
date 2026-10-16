import '../../../../core/presentation/widgets/origin_page_transition.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../state/home_view_state.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({
    required this.onSelect,
    required this.onReport,
    super.key,
  });
  final ValueChanged<HomeSection> onSelect;
  final ValueChanged<BuildContext> onReport;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StaggerRevealItem(
        order: 0,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.pets_outlined,
                size: 32,
                color: Color(0xFF111111),
              ),
              const SizedBox(height: 16),
              const Text(
                'Su regreso empieza contigo',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Una comunidad para conectar mascotas perdidas con quienes pueden ayudar.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF6E6E73),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => onSelect(HomeSection.pets),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Conoce Mis mascotas'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
      StaggerRevealItem(
        order: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final vertical =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            final cards = [
              HomeQuickAction(
                icon: Icons.search_rounded,
                label: 'Reportar',
                onTap: onReport,
              ),
              HomeQuickAction(
                icon: Icons.assignment_outlined,
                label: 'Mis reportes',
                onTap: (source) => source.push('/home/my-reports'),
              ),
              HomeQuickAction(
                icon: Icons.pets_outlined,
                label: 'Mis mascotas',
                onTap: (_) => onSelect(HomeSection.pets),
              ),
            ];
            return vertical
                ? Column(
                    children: [
                      for (final card in cards)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: card,
                        ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: cards[i]),
                      ],
                    ],
                  );
          },
        ),
      ),
      const SizedBox(height: 28),
      StaggerRevealItem(
        order: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cerca de ti',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 14),
            const HomeNotice(
              icon: Icons.location_on_outlined,
              title: 'Explora cerca de ti',
              description:
                  'Consulta casos cercanos con tu ubicación actual y un radio inicial de 15 km, o elige otra ubicación manualmente.',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => onSelect(HomeSection.explore),
                child: const Text('Conoce Explorar'),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class HomeQuickAction extends StatelessWidget {
  const HomeQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String label;
  final ValueChanged<BuildContext> onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFF5F5F7),
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => onTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Icon(icon, size: 28, color: const Color(0xFF111111)),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class HomeNotice extends StatelessWidget {
  const HomeNotice({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE5E5EA)),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6E6E73), size: 28),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Color(0xFF6E6E73),
          ),
        ),
      ],
    ),
  );
}

void showHomeInfo(
  BuildContext context, {
  required String title,
  required String description,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : null,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: Colors.white,
  builder: (context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Color(0xFF6E6E73),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  ),
);

void openLostReport(
  BuildContext context, {
  VoidCallback? onReturn,
  Color color = const Color(0xFF111111),
  double radius = 32,
}) {
  final box = context.findRenderObject();
  final navigator = Navigator.of(context).context.findRenderObject();
  final origin = box is RenderBox && box.hasSize
      ? box.localToGlobal(Offset.zero, ancestor: navigator) & box.size
      : null;
  context
      .push(
        '/home/lost-cases/new',
        extra: origin == null
            ? null
            : OriginPageSource(
                bounds: origin,
                color: color,
                radius: radius,
                child: Icon(
                  Icons.search_rounded,
                  color: color == const Color(0xFF111111)
                      ? Colors.white
                      : const Color(0xFF111111),
                ),
              ),
      )
      .then((_) => onReturn?.call());
}
