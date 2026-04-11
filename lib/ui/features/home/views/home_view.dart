import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/shared/widgets/appbar.dart';

import '../../../../data/database/app_database.dart';
import '../../../app/cubits/app_cubit.dart';
import '../cubits/home_cubit.dart';
import '../../../shared/utilities/dialog_helper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        notebookRepository: context.read<NotebookRepository>(),
      ),
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
    return Scaffold(
        appBar: MainAppBar(
          title: "Notebooks (This is the main page)",
          actions: [
            IconButton(
              onPressed: () async {
                final notebooks =
                    await context.read<HomeCubit>().getNotebooks();
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
                String result = await DialogHelper.getStringInput(context, "Notebook Name", "New Notebook $i");
                context.read<HomeCubit>().addNotebook(result);
              },
              icon: Icon(Icons.add),
              iconSize: 25,
            ),
            TextButton(
              onPressed: () {
                context.read<AppCubit>().clearSettings();
              },
              child: Text("Reset Shared Preferences"),
            ),
          ],
        ),
        body: BlocConsumer<HomeCubit, HomeState>(
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
                          // physics: const NeverScrollableScrollPhysics(),
                          // itemCount: state.notebooks.length,
                          key: _gridKey,
                          initialItemCount: state.notebooks.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                          itemBuilder: (BuildContext context, int index,
                              Animation<double> animation) {
                            final Notebook notebook = state.notebooks[index];
                            return NotebookItem(
                                index: index,
                                notebook: notebook,
                                animation: animation,
                                gridKey: _gridKey);
                          },
                        )),
                  ),
                ],
              );
            }

            return Center(
                child: Text(
                    "The state is neither loading nor ready. What did you do?"));
          },
        ));
  }
}

class NotebookItem extends StatelessWidget {
  final Notebook notebook;
  final int index;
  final Animation<double> animation;
  final GlobalKey<AnimatedGridState> gridKey;
  // final TextEditingController _textEditingController = TextEditingController();

  const NotebookItem(
      {super.key,
      required this.index,
      required this.notebook,
      required this.animation,
      required this.gridKey});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeInOutQuint),
      child: Card(
        color: Colors.amber,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text(notebook.name)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: PopupMenuButton(itemBuilder: (BuildContext context) {
                  return <PopupMenuItem>[
                    PopupMenuItem(
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () async {
                        await context
                            .read<HomeCubit>()
                            .deleteNotebook(notebook.id);
                        gridKey.currentState?.removeItem(
                          index,
                          (context, animation) {
                            return ScaleTransition(
                              scale: CurvedAnimation(
                                  parent: animation, curve: Curves.easeInQuint),
                              child: Card(
                                color: Colors.amber,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: Text("Rename"),
                      onTap: () async {
                        String result = await DialogHelper.getStringInput(context, "Rename", "${notebook.name}");
                        if (result == "") {
                          return;
                        }
                        context
                            .read<HomeCubit>()
                            .renameNotebook(notebook.id, result);
                      },
                    )
                  ];
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
