import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/entity_screen_shell.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../view_models/saved_case_list_view_model.dart';
import '../widgets/saved_cases_section.dart';

class SavedCasesScreen extends ConsumerWidget {
  const SavedCasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedCaseListViewModelProvider);
    return PullToRefresh(
      indicatorTop: MediaQuery.paddingOf(context).top + 8,
      child: EntityScreenShell(
        title: 'Guardados',
        loading: state.isLoading,
        count: 1,
        scrollPhysics: const AlwaysScrollableScrollPhysics(),
        child: const StaggerRevealItem(order: 0, child: SavedCasesSection()),
      ),
    );
  }
}
