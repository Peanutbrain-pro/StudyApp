import 'package:flutter/material.dart';
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

        return FScaffold(
          header: MainAppBar(
            title: Row(
              children: [
                TabHeader(tabController: _tabController),
                const SizedBox(width: 40),
                Expanded(
                  // Make the gradient disappear when near the end of the text
                  child: Text(state.notebookName, overflow: .ellipsis),
                ),
                // const SizedBox(width: 40),
              ],
            ),
            prefixes: [
              FButton.icon(
                size: .lg,
                variant: .ghost,
                onPress: () => context.pop(),
                child: const Icon(FIcons.chevronLeft),
              ),
            ],
            actions: [],
          ),
          child: Column(
            spacing: 10,
            children: [
              // if (nameTooLong)
              //   Align(
              //     alignment: .centerLeft,
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
                    const NotesPage(),
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
    return Container(
      height: 40,
      width: 300,
      decoration: BoxDecoration(color: colors.secondary, borderRadius: .circular(15)),
      child: TabBar(
        labelColor: colors.primaryForeground,
        splashBorderRadius: .circular(15),
        tabAlignment: .start,
        isScrollable: true,
        controller: _tabController,
        dividerColor: Colors.transparent,
        // indicatorPadding: .all(3),
        // indicatorPadding: .only(left: 4, right: 4),
        indicatorSize: .tab,
        labelPadding: .zero,
        indicator: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(15)),
        tabs: [
          const SizedBox(width: 100, child: Tab(text: "Index")),
          const SizedBox(width: 100, child: Tab(text: 'Notes')),
          const SizedBox(width: 100, child: Tab(text: 'PYQs')),
        ],
      ),
    );
  }
}
