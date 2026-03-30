import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/shared/widgets/appbar.dart';

import '../../../../data/database/app_database.dart';
import '../../../app/cubits/app_cubit.dart';
import '../cubits/home_cubit.dart';

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
                context.read<HomeCubit>().addNotebook("New Notebook $i");
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
                            maxCrossAxisExtent: 150,
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
      child: TextButton(
        onPressed: () async {
          await context.read<HomeCubit>().deleteNotebook(notebook.id);
          gridKey.currentState?.removeItem(
            index,
            (context, animation) {
              return ScaleTransition(
                scale: CurvedAnimation(parent: animation, curve: Curves.easeInQuint),
                child: TextButton(
                  onPressed: null,
                  child: Text(notebook.name),
                  style: TextButton.styleFrom(backgroundColor: Colors.amber),
                ),
              );
            },
          );
          
        },
        style: TextButton.styleFrom(backgroundColor: Colors.amber),
        child: Text(notebook.name),
      ),
    );
  }
}
