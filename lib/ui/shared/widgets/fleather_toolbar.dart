import 'package:file_picker/file_picker.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';

class CustomFleatherToolbar extends StatelessWidget {
  final FleatherController _controller;

  const CustomFleatherToolbar({super.key, required FleatherController controller}) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      height: 50,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FleatherToolbar(
        children: [
          SelectHeadingButton(controller: _controller),
          const VerticalDivider(),

          ToggleStyleButton(
            attribute: ParchmentAttribute.bold,
            icon: Icons.format_bold,
            controller: _controller,
          ),
          ToggleStyleButton(
            attribute: ParchmentAttribute.italic,
            icon: Icons.format_italic,
            controller: _controller,
          ),
          ToggleStyleButton(
            attribute: ParchmentAttribute.underline,
            icon: Icons.format_underline,
            controller: _controller,
          ),
          const VerticalDivider(),

          // Alignment
          AlignmentButton(
            attribute: ParchmentAttribute.alignment.unset,
            icon: Icons.format_align_left,
            controller: _controller,
          ),
          AlignmentButton(
            attribute: ParchmentAttribute.alignment.center,
            icon: Icons.format_align_center,
            controller: _controller,
          ),
          AlignmentButton(
            attribute: ParchmentAttribute.alignment.right,
            icon: Icons.format_align_right,
            controller: _controller,
          ),
          AlignmentButton(
            attribute: ParchmentAttribute.alignment.justify,
            icon: Icons.format_align_justify,
            controller: _controller,
          ),

          ToggleStyleButton(
            attribute: ParchmentAttribute.block.bulletList,
            icon: Icons.format_list_bulleted,
            controller: _controller,
          ),

          ToggleStyleButton(
            attribute: ParchmentAttribute.block.numberList,
            icon: Icons.format_list_numbered,
            controller: _controller,
          ),
          const VerticalDivider(),

          // Insert Image at the cursor position
          ImageButton(controller: _controller),
          SourceButton(controller: _controller),
        ],
      ),
    );
  }
}

class AlignmentButton extends StatelessWidget {
  final ParchmentAttribute attribute;
  final IconData icon;
  final FleatherController controller;

  const AlignmentButton({super.key, required this.attribute, required this.icon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final style = controller.getSelectionStyle();
        final currentAlignment = style.get(ParchmentAttribute.alignment);
        final isToggled =
            currentAlignment?.value == attribute.value ||
            (currentAlignment == null && attribute == ParchmentAttribute.alignment.unset);

        return FButton.icon(
          variant: isToggled ? .primary : .ghost,
          onPress: () {
            final selection = controller.selection;

            if (selection.isCollapsed) {
              final lookup = controller.document.lookupLine(selection.baseOffset);

              if (lookup.node != null && lookup.node!.length == 1) {
                controller.replaceText(
                  selection.baseOffset,
                  0,
                  '\n\u200B',
                  selection: TextSelection.collapsed(
                    offset: selection.baseOffset,
                  ),
                );
              }
            }

            controller.formatSelection(attribute);
          },
          child: Icon(icon),
        );
      },
    );
  }
}

class ImageButton extends StatelessWidget {
  final FleatherController _controller;

  const ImageButton({super.key, required FleatherController controller}) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FPopover(
      offset: const Offset(0, 7),
      style: .delta(
        decoration: .boxDelta(
          border: DashedBorder.all(dashLength: 9, color: colors.foreground.withValues(alpha: 0.3)),
          color: colors.secondary,
        ),
      ),
      popoverBuilder: (BuildContext context, FPopoverController _) {
        return Column(
          children: [
            SizedBox(
              width: 300,
              height: 250,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 280,
                    height: 150,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                    ),
                    child: FButton(
                      size: .lg,
                      variant: .ghost,
                      onPress: () async {
                        final result = await FilePicker.pickFile();
                        if (result == null) {
                          return;
                        }
                        int index = _controller.selection.baseOffset;
                        int length = _controller.selection.extentOffset - index;
                        if (index < 0) {
                          index = _controller.document.length - 1;
                          length = 0;
                        }
                        _controller.replaceText(
                          index,
                          length,
                          EmbeddableObject(
                            'image',
                            inline: false,
                            data: {'source': result.path, 'isNetwork': false},
                          ),
                        );
                      },
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [Icon(FLucideIcons.imagePlus, size: 24), Text("Pick a file from your computer")],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'URL : e.g. https://unsplash.com/xxxx'),
                      onSubmitted: (text) {
                        int index = _controller.selection.baseOffset;
                        int length = _controller.selection.extentOffset - index;
                        if (index < 0) {
                          index = _controller.document.length - 1;
                          length = 0;
                        }
                        _controller.replaceText(
                          index,
                          length,
                          EmbeddableObject(
                            'image',
                            inline: false,
                            data: {'source': text, 'isNetwork': true},
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      builder: (_, controller, _) {
        return FButton(variant: .ghost, onPress: controller.toggle, child: const Icon(FLucideIcons.image));
      },
    );
  }
}

class SourceButton extends StatelessWidget {
  final FleatherController _controller;

  const SourceButton({super.key, required FleatherController controller}) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: .ghost,
      onPress: () {
        final selection = _controller.selection;
        int index = selection.isCollapsed ? selection.baseOffset : selection.start;
        int length = selection.isCollapsed ? 0 : (selection.end - selection.start);

        if (index < 0) {
          index = _controller.document.length - 1;
          length = 0;
        }
        _controller.replaceText(
          index,
          length,
          EmbeddableObject(
            'source',
            inline: true,
            data: {
              'filename': 'filename very very long.pdf',
              'filetype': 'pdf',
              'url': r'C:\Users\KIIT0001\Downloads\Resume_Julaiba_Academic-20250415113753.docx',
            },
          ),
        );
      },
      child: const Icon(FLucideIcons.squareArrowOutUpRight),
    );
  }
}
