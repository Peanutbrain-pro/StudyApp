import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class CustomFleatherToolbar extends StatelessWidget {
  final FleatherController _controller;

  const CustomFleatherToolbar({super.key, required FleatherController controller}) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      height: 50,
      // width: 400,
      margin: const .all(5),
      // padding: .zero,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: .circular(10),
        // border: .all(color: colors.primary.withAlpha(170), width: 2),
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

            // Only run the empty-line hack if the user hasn't highlighted text
            if (selection.isCollapsed) {
              final lookup = controller.document.lookupLine(selection.baseOffset);

              // length == 1 means the line is completely empty (only contains '\n')
              if (lookup.node != null && lookup.node!.length == 1) {
                controller.replaceText(
                  selection.baseOffset,
                  0,
                  // '\u200B',
                  '\n\u200B',
                  // Fix: Highlight the invisible character instead of collapsing past it!
                  selection: TextSelection.collapsed(
                    offset: selection.baseOffset,
                    // extentOffset: selection.baseOffset + 1,
                  ),
                );
              }
            }

            controller.formatSelection(attribute);
          }, // icon: Icon(icon),
          child: Icon(icon),
        );
      },
    );
  }
}

class ImageButton extends StatelessWidget {
  final FleatherController controller;

  const ImageButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: .ghost,
      onPress: () {
        int index = controller.selection.baseOffset;
        int length = controller.selection.extentOffset - index;
        if (index < 0) {
          index = controller.document.length - 1;
          length = 0;
        }
        controller.replaceText(
          index,
          length,
          EmbeddableObject('image', inline: false, data:{'source': 'https://cdn.pixabay.com/photo/2024/09/21/10/53/anime-9063542_1280.png'}),
        );
      },
      child: const Icon(FIcons.image),
    );
  }
}
