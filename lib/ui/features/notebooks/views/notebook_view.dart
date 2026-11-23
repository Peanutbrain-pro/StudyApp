import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/features/notebooks/cubits/notebook_cubit.dart';
import 'package:studyapp/ui/features/notebooks/views/index_view.dart';
import 'package:studyapp/ui/features/notebooks/views/notes_view.dart';
import 'package:studyapp/ui/features/notebooks/views/pyqs_view.dart';
import 'package:studyapp/ui/shared/widgets/appbar.dart';

class NotebookPage extends StatelessWidget {
  final int notebookId;
  const NotebookPage({super.key, required this.notebookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotebookCubit(notebookId: notebookId, notebookRepository: context.read<NotebookRepository>())
            ..initialize(),
      child: NotebookView(notebookId: notebookId),
    );
  }
}

class NotebookView extends StatefulWidget {
  final int notebookId;
  const NotebookView({super.key, required this.notebookId});

  @override
  State<NotebookView> createState() => _NotebookViewState();
}

class _NotebookViewState extends State<NotebookView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotebookCubit, NotebookState>(
      builder: (context, state) {
        // final bool nameTooLong = state.notebookName.length > 35;

        final typography = context.theme.typography;
        final colors = context.theme.colors;

        return FScaffold(
          header: MainAppBar(
            title: Row(
              children: [
                TabHeader(tabController: _tabController),
                const SizedBox(width: 28),
                Expanded(
                  child: Text(
                    state.notebookName,
                    overflow: TextOverflow.ellipsis,
                    style: typography.display.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                ),
              ],
            ),
            prefixes: [
              FButton.icon(
                size: .md,
                variant: .ghost,
                onPress: () => context.pop(),
                child: const Icon(FLucideIcons.chevronLeft),
              ),
            ],
            actions: [],
          ),
          child: Column(
            spacing: 10,
            children: [
              // if (nameTooLong)
              //   Align(\n              //     alignment: .centerLeft,
              //     child: Padding(
              //       padding: const .only(left: 48),
              //       child: TabHeader(tabController: _tabController),
              //     ),
              //   ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    IndexPage(notebookId: widget.notebookId),
                    NotesPage(notebookId: widget.notebookId),
                    const PyqsView(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required TabController tabController}) : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Container(
      height: 36,
      width: 270,
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        labelColor: colors.primaryForeground,
        unselectedLabelColor: colors.mutedForeground,
        labelStyle: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: typography.body.sm,
        splashBorderRadius: BorderRadius.circular(10),
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        tabs: const [
          SizedBox(width: 90, child: Tab(text: "Index")),
          SizedBox(width: 90, child: Tab(text: 'Notes')),
          SizedBox(width: 90, child: Tab(text: 'PYQs')),
        ],
      ),
    );
  }
}
