import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';
import 'package:studyapp/ui/app/views/first_launch_view.dart';
import 'package:studyapp/ui/features/home/views/home_view.dart';
import 'package:studyapp/ui/features/notebooks/views/notebook_view.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          switch (state) {
            case AppFirstLaunch():
              return const FirstLaunchView();
            case AppReady():
              return const HomePage();
            case AppLoading():
              return const FCircularProgress.loader();
          }
        },
      ),
      routes: [
        GoRoute(
          path: 'notebook/:id',
          pageBuilder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return CustomTransitionPage(
              child: NotebookPage(notebookId: id),
              transitionsBuilder:
                  (
                    BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child,
                  ) {
                    return SlideTransition(
                      position: Tween(
                        begin: const Offset(1, 0),
                        end: const Offset(0, 0),
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
                      child: child,
                    );
                  },
            );
          },
        ),
      ],
    ),
  ],
);
