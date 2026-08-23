import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/ui/features/home/cubits/home_cubit.dart';
import 'package:studyapp/ui/shared/utilities/dialog_helper.dart';

class NotebookGrid extends StatelessWidget {
  final HomeState homeState;
  const NotebookGrid({
    super.key,
    required GlobalKey<AnimatedGridState> gridKey,
    required this.homeState,
  }) : _gridKey = gridKey;

  final GlobalKey<AnimatedGridState> _gridKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedGrid(
      key: _gridKey,
      initialItemCount: homeState.notebooks.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
            final Notebook notebook = homeState.notebooks[index];
            return NotebookItem(
              index: index,
              notebook: notebook,
              animation: animation,
              gridKey: _gridKey,
            );
          },
    );
  }
}

class NotebookItem extends StatelessWidget {
  final Notebook notebook;
  final int index;
  final Animation<double> animation;
  final GlobalKey<AnimatedGridState> gridKey;

  const NotebookItem({
    super.key,
    required this.index,
    required this.notebook,
    required this.animation,
    required this.gridKey,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeInOutQuint),
      child: Stack(
        children: [
          Card(
            color: Theme.of(context).primaryColorLight,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              // highlightColor: const Color.fromARGB(20, 0, 0, 0),
              onTap: () => context.go('/notebook/${notebook.id}'),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(child: Text(notebook.name)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FPopoverMenu(
                menu: [
                  .group(
                    children: [
                      .item(
                        prefix: const Icon(FIcons.pencilLine),
                        title: const Text("Rename"),
                        onPress: () async {
                          String? result = await DialogHelper.getStringInput(
                            context,
                            "Rename",
                            notebook.name,
                            // 64,
                          );
                          if (result == null || result == "") {
                            return;
                          }
                          context.read<HomeCubit>().renameNotebook(
                            notebook.id,
                            result,
                          );
                        },
                      ),
                      .item(
                        prefix: const Icon(FIcons.trash),
                        title: const Text("Delete"),
                        onPress: () async {
                          bool confirmed = await DialogHelper.getConfirmation(
                            context,
                            true,
                            "Delete Notebook",
                            "Are you sure you want to delete the Notebook: ${notebook.name}",
                            "Delete",
                          );
                          if (!confirmed) return;

                          await context.read<HomeCubit>().deleteNotebook(
                            context,
                            notebook.id,
                          );
                          gridKey.currentState?.removeItem(index, (
                            context,
                            animation,
                          ) {
                            return ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInQuint,
                              ),
                              child: FCard(),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
                builder: (context, controller, child) {
                  return FButton.icon(
                    variant: .ghost,
                    onPress: controller.toggle,
                    child: const Icon(FIcons.ellipsisVertical),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
