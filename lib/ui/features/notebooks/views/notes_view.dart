import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/data/repositories/note_repository.dart';
import 'package:studyapp/ui/features/notebooks/cubits/note_cubit.dart';
import 'package:studyapp/ui/shared/widgets/markdown_toolbar.dart';
import 'package:studyapp/ui/shared/widgets/markdown_webview_editor.dart';

class NotesPage extends StatelessWidget {
  final int notebookId;

  const NotesPage({super.key, required this.notebookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoteCubit(
        noteRepository: context.read<NoteRepository>(),
        notebookId: notebookId,
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
  late final MarkdownEditorController _markdownController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _markdownController = MarkdownEditorController();
  }

  @override
  void dispose() {
    _markdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.theme.colors;

    return BlocConsumer<NoteCubit, NoteState>(
      listenWhen: (previous, current) => previous.markdown != current.markdown && !_markdownController.isReady,
      listener: (context, state) {
        if (state.markdown.isNotEmpty) {
          _markdownController.setMarkdown(state.markdown);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            MarkdownToolbar(controller: _markdownController),
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
                  child: MarkdownWebviewEditor(
                    controller: _markdownController,
                    initialMarkdown: state.markdown,
                    onContentChanged: (markdown) {
                      context.read<NoteCubit>().saveMarkdown(markdown);
                    },
                    onSourceClicked: (filename, filetype, url) {
                      debugPrint('Source clicked: $filename ($filetype) at $url');
                    },
                    onImageClicked: (url) {
                      debugPrint('Image clicked: $url');
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
