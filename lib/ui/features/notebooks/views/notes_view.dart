import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:studyapp/data/repositories/note_repository.dart';
import 'package:studyapp/ui/features/notebooks/cubits/note_cubit.dart';
import 'package:studyapp/ui/shared/widgets/MilkdownEditor.dart';

class NotesPage extends StatelessWidget {
  final int notebookId;

  const NotesPage({super.key, required this.notebookId});

  @override
  Widget build(BuildContext context) {
    final saveLocation = context.read<AppRepository>().getSaveLocation();
    return BlocProvider(
      create: (context) => NoteCubit(
        noteRepository: context.read<NoteRepository>(),
        notebookId: notebookId,
        saveLocation: saveLocation,
      ),
      child: const NotesView(),
    );
  }
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> with AutomaticKeepAliveClientMixin {
  // ignore: unused_field
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.theme.colors;
    final noteCubit = context.read<NoteCubit>();

    return BlocBuilder<NoteCubit, NoteState>(
      buildWhen: (previous, current) => previous.isLoading != current.isLoading,
      // listenWhen: (previous, current) => previous.markdown != current.markdown && !_tiptapController.isReady,
      // listener: (context, state) {
      //   if (state.markdown.isNotEmpty) {
      //     // _tiptapController.setMarkdown(state.markdown);
      //   }
      // },
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    border: Border.all(width: 1.5, color: colors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MilkdownFileEditorScreen(
                    key: ValueKey('milkdown_${noteCubit.notebookId}'),
                    notebookId: noteCubit.notebookId,
                    noteFilePath: noteCubit.notePath(),
                    sourcesDirectoryPath: noteCubit.sourcesDirectory(),
                    onContentChanged: (markdown) {
                      noteCubit.saveMarkdown(markdown);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
