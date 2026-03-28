import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/shared/widgets/appbar.dart';

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
              onPressed: () {
                final newid =
                    context.read<HomeCubit>().state.notebooks.length + 1;
                context
                    .read<HomeCubit>()
                    .addNotebook("New Subject $newid");
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
            return previous.notebooks.length < current.notebooks.length;
          },
          listener: (BuildContext context, HomeState state) {
            final newIndex = state.notebooks.length - 1;
            _gridKey.currentState?.insertItem(newIndex);
          },
          builder: (BuildContext context, state) {
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
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemBuilder: (BuildContext context, int index,
                            Animation<double> animation) {
                          return NotebookItem(
                              index: index, animation: animation);
                        },
                      )),
                ),
              ],
            );
          },
        ));
  }
}

class NotebookItem extends StatelessWidget {
  final int index;
  final Animation<double> animation;

  const NotebookItem({super.key, required this.index, required this.animation});

  @override
  Widget build(BuildContext context) {
    final String text = context.read<HomeCubit>().state.notebooks[index].name;
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeInOutQuint),
      child: TextButton(
          onPressed: () {},
          child: Text(text),
          style: TextButton.styleFrom(backgroundColor: Colors.amber)),
    );
  }
}
