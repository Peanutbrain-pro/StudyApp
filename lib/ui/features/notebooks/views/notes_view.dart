import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:studyapp/data/repositories/note_repository.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';
import 'package:studyapp/ui/features/notebooks/cubits/note_cubit.dart';
import 'package:studyapp/ui/shared/widgets/super_editor/super_editor_screen.dart';

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
    final noteCubit = context.read<NoteCubit>();
    final appState = context.watch<AppCubit>().state;
    final editorFont = appState is AppReady ? appState.editorFont : null;

    return BlocBuilder<NoteCubit, NoteState>(
      buildWhen: (previous, current) => previous.isLoading != current.isLoading,
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: FCard(
                  clipBehavior: Clip.antiAlias,
                  child: SuperEditorNoteScreen(
                    key: ValueKey('super_editor_${noteCubit.notebookId}'),
                    notebookId: noteCubit.notebookId,
                    noteFilePath: noteCubit.notePath(),
                    sourcesDirectoryPath: noteCubit.sourcesDirectory(),
                    fontFamily: editorFont,
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
