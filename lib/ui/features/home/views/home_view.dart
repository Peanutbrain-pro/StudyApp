import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/shared/widgets/appbar.dart';
import 'package:forui/forui.dart';

import '../../../../data/database/app_database.dart';
import '../cubits/home_cubit.dart';
import '../../../shared/utilities/dialog_helper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(notebookRepository: context.read<NotebookRepository>()),
      child: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<AnimatedGridState> _gridKey = GlobalKey<AnimatedGridState>();

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: MainAppBar(
        title: "Notebooks",
        actions: [
          FTooltip(
            tipAnchor: .topRight,
            childAnchor: .topLeft,
            tipBuilder: (context, _) => Text("Add a new Notebook"),
            child: FButton.icon(
              variant: .ghost,
              onPress: () async {
                final notebooks = await context.read<HomeCubit>().getNotebooks();
                int i = 1;
                while (true) {
                  bool nochange = true;
                  for (Notebook notebook in notebooks) {
                    if (notebook.name == "New Notebook $i") {
                      i++;
                      nochange = false;
                    }
                  }
                  if (nochange) break;
                }
            
                // String result = "New Notebook $i";
                String? result = await DialogHelper.getStringInput(context, "Notebook Name", "New Notebook $i");
                if (result == null || result == "") {
                  return;
                }
                context.read<HomeCubit>().addNotebook(result);
              },
              child: Icon(FIcons.plus),
              size: .md,
            ),
          ),
        ],
      ),
      child: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (previous, current) {
          print("prvious: ${previous.notebooks.toString()}");
          print("current: ${current.notebooks.toString()}");
          if (previous is HomeReady && current is HomeReady) {
            return current.notebooks.length == previous.notebooks.length + 1;
          }
          return false;
        },
        listener: (BuildContext context, HomeState state) {
          final newIndex = state.notebooks.length - 1;
          print("state: ${state.notebooks.toString()}");
          print(newIndex);
          _gridKey.currentState?.insertItem(newIndex);
        },
        builder: (BuildContext context, state) {
          if (state is HomeLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is HomeReady) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: AnimatedGrid(
                      key: _gridKey,
                      initialItemCount: state.notebooks.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                        final Notebook notebook = state.notebooks[index];
                        return NotebookItem(
                          index: index,
                          notebook: notebook,
                          animation: animation,
                          gridKey: _gridKey,
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(child: Text("The state is neither loading nor ready. What did you do?"));
        },
      ),
    );
  }
}

class NotebookItem extends StatelessWidget {
  final Notebook notebook;
  final int index;
  final Animation<double> animation;
  final GlobalKey<AnimatedGridState> gridKey;
  // final TextEditingController _textEditingController = TextEditingController();

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
      child: Card(
        color: Theme.of(context).primaryColorLight,
        child: Stack(
          // fit: .expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text(notebook.name)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FPopoverMenu(
                  menu: [
                    .group(
                      children: [
                        .item(
                          prefix: Icon(FIcons.trash),
                          title: Text("Delete"),
                          onPress: () async {
                            bool confirmed = await DialogHelper.getConfirmation(
                              context,
                              true,
                              "Delete Notebook",
                              "Are you sure you want to delete the Notebook: ${notebook.name}",
                              "Delete",
                            );
                            if (!confirmed) return;
                            
                            await context.read<HomeCubit>().deleteNotebook(context, notebook.id);
                            gridKey.currentState?.removeItem(index, (context, animation) {
                              return ScaleTransition(
                                scale: CurvedAnimation(parent: animation, curve: Curves.easeInQuint),
                                child: FCard(),
                              );
                            });
                          },
                        ),
                        .item(
                          prefix: Icon(FIcons.pencilLine),
                          title: Text("Rename"),
                          onPress: () async {
                            String? result = await DialogHelper.getStringInput(
                              context,
                              "Rename",
                              "${notebook.name}",
                            );
                            if (result == null || result == "") {
                              return;
                            }
                            context.read<HomeCubit>().renameNotebook(notebook.id, result);
                          },
                        ),
                      ],
                    ),
                  ],
                  builder: (context, controller, child) {
                    return FButton.icon(variant: .ghost, onPress: controller.toggle, child: Icon(FIcons.ellipsisVertical));
                  },
                ),
              ),
              // child: PopupMenuButton(itemBuilder: (BuildContext context) {
              //   return <PopupMenuItem>[
              //     PopupMenuItem(
              //       child: Text(
              //         "Delete",
              //         style: TextStyle(color: Colors.red),
              //       ),
              //       onTap: () async {
              //         bool confirmed = await DialogHelper.getConfirmation(context, "Delete Notebook",
              //             "Are you sure you want to delete the Notebook: ${notebook.name}", "Delete");
              //         if (!confirmed) return;
            
              //         await context.read<HomeCubit>().deleteNotebook(context, notebook.id);
              //         gridKey.currentState?.removeItem(
              //           index,
              //           (context, animation) {
              //             return ScaleTransition(
              //               scale: CurvedAnimation(parent: animation, curve: Curves.easeInQuint),
              //               child: Card(
              //                 color: Colors.amber,
              //               ),
              //             );
              //           },
              //         );
              //       },
              //     ),
              //     PopupMenuItem(
              //       child: Text("Rename"),
              //       onTap: () async {
              //         String result =
              //             await DialogHelper.getStringInput(context, "Rename", "${notebook.name}");
              //         if (result == "") {
              //           return;
              //         }
              //         context.read<HomeCubit>().renameNotebook(notebook.id, result);
              //       },
              //     )
              //   ];
              // }),
            ),
          ],
        ),
      ),
    );
  }
}
