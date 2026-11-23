import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';
import 'package:studyapp/ui/features/settings/cubits/settings_cubit.dart';

import '../../../../data/repositories/app_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(
        appRepository: context.read<AppRepository>(),
        notebookRepository: context.read<NotebookRepository>(),
      ),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _openFontPicker({
    required BuildContext context,
    required String title,
    required String currentFont,
    required List<String> availableFonts,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => _FontPickerDialog(
        title: title,
        currentFont: currentFont,
        fonts: availableFonts,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final appState = context.watch<AppCubit>().state;
    final showTitleBar = appState is AppReady ? appState.showTitleBar : true;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, SettingsState state) => Dialog(
        backgroundColor: colors.card,
        insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 680),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pinned Header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Settings",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.foreground),
                      ),
                      IconButton(
                        icon: Icon(FLucideIcons.x, size: 20, color: colors.mutedForeground),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Typography & Appearance
                  FTileGroup(
                    label: const Text("Typography & Appearance"),
                    children: [
                      FTile(
                        title: const Text("App UI Font"),
                        details: Text(
                          state.appFont.isEmpty ? "System Default" : state.appFont,
                          style: TextStyle(
                            fontFamily: state.appFont != "System Default" ? state.appFont : null,
                            color: colors.mutedForeground,
                          ),
                        ),
                        suffix: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: FButton(
                            variant: .outline,
                            mainAxisSize: .min,
                            child: const Text("Select Font"),
                            onPress: () {
                              _openFontPicker(
                                context: context,
                                title: "Select App UI Font",
                                currentFont: state.appFont,
                                availableFonts: state.availableFonts,
                                onSelected: (font) {
                                  context.read<SettingsCubit>().setAppFont(context, font);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      FTile(
                        title: const Text("Editor Font"),
                        details: Text(
                          state.editorFont.isEmpty ? "System Default" : state.editorFont,
                          style: TextStyle(
                            fontFamily: state.editorFont != "System Default" ? state.editorFont : null,
                            color: colors.mutedForeground,
                          ),
                        ),
                        suffix: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: FButton(
                            variant: .outline,
                            mainAxisSize: .min,
                            child: const Text("Select Font"),
                            onPress: () {
                              _openFontPicker(
                                context: context,
                                title: "Select Editor Font",
                                currentFont: state.editorFont,
                                availableFonts: state.availableFonts,
                                onSelected: (font) {
                                  context.read<SettingsCubit>().setEditorFont(context, font);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Storage & Data
                  FTileGroup(
                    label: const Text("Storage & Data"),
                    children: [
                      FTile(
                        title: const Text("Notebooks Save Location"),
                        details: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: SelectableText(state.saveLocation),
                        ),
                        suffix: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: FButton.icon(
                            variant: .outline,
                            child: const Icon(FLucideIcons.folder),
                            onPress: () => context.read<SettingsCubit>().changeSaveLocation(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // UI options
                  FTileGroup(
                    label: const Text("UI options"),
                    children: [
                      FTile(
                        title: const Text("Show title bar?"),
                        suffix: FCheckbox(
                          value: showTitleBar,
                          onChange: (value) => context.read<SettingsCubit>().toggleTitleBar(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Danger Zone
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      "Danger Zone",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.destructive,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FButton(
                        variant: .destructive,
                        mainAxisSize: .min,
                        child: const Text("Reset Settings"),
                        onPress: () => context.read<SettingsCubit>().resetSettings(context),
                      ),
                      const SizedBox(height: 10),
                      FButton(
                        variant: .destructive,
                        mainAxisSize: .min,
                        child: const Text("Delete All Data"),
                        onPress: () => context.read<SettingsCubit>().deleteAppData(context),
                      ),
                      const SizedBox(height: 10),
                      FButton(
                        variant: .destructive,
                        mainAxisSize: .min,
                        child: const Text("Reset and Delete Everything"),
                        onPress: () => context.read<SettingsCubit>().completeReset(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
    );
  }
}

class _FontPickerDialog extends StatefulWidget {
  final String title;
  final String currentFont;
  final List<String> fonts;
  final ValueChanged<String> onSelected;

  const _FontPickerDialog({
    required this.title,
    required this.currentFont,
    required this.fonts,
    required this.onSelected,
  });

  @override
  State<_FontPickerDialog> createState() => _FontPickerDialogState();
}

class _FontPickerDialogState extends State<_FontPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredFonts = [];
  bool _isScrolling = false;
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _filteredFonts = widget.fonts;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFonts = widget.fonts;
      } else {
        _filteredFonts = widget.fonts.where((font) => font.toLowerCase().contains(query)).toList();
      }
    });
  }

  void _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification || notification is ScrollUpdateNotification) {
      if (!_isScrolling) {
        setState(() {
          _isScrolling = true;
        });
      }
      _scrollDebounce?.cancel();
      _scrollDebounce = Timer(const Duration(milliseconds: 100), () {
        if (mounted && _isScrolling) {
          setState(() {
            _isScrolling = false;
          });
        }
      });
    } else if (notification is ScrollEndNotification) {
      _scrollDebounce?.cancel();
      _scrollDebounce = Timer(const Duration(milliseconds: 60), () {
        if (mounted && _isScrolling) {
          setState(() {
            _isScrolling = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Dialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.foreground),
                        ),
                        IconButton(
                          icon: Icon(FLucideIcons.x, size: 16, color: colors.mutedForeground),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Search fonts...',
                        prefixIcon: Icon(FLucideIcons.search, size: 16, color: colors.mutedForeground),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(FLucideIcons.circleX, size: 14, color: colors.mutedForeground),
                                onPressed: () => _searchController.clear(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true,
                        filled: true,
                        fillColor: colors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: colors.primary, width: 1.5),
                        ),
                      ),
                      style: TextStyle(color: colors.foreground, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredFonts.isEmpty
                    ? Center(
                        child: Text(
                          'No matching fonts found',
                          style: TextStyle(color: colors.mutedForeground, fontSize: 13),
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          _onScrollNotification(notification);
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                          itemExtent: 36.0,
                          itemCount: _filteredFonts.length,
                          itemBuilder: (context, index) {
                            final font = _filteredFonts[index];
                            final isSelected = font == widget.currentFont;

                            return _FontItemTile(
                              key: ValueKey(font),
                              font: font,
                              isSelected: isSelected,
                              isScrolling: _isScrolling,
                              colors: colors,
                              onTap: () {
                                widget.onSelected(font);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontItemTile extends StatefulWidget {
  final String font;
  final bool isSelected;
  final bool isScrolling;
  final FColors colors;
  final VoidCallback onTap;

  const _FontItemTile({
    super.key,
    required this.font,
    required this.isSelected,
    required this.isScrolling,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_FontItemTile> createState() => _FontItemTileState();
}

class _FontItemTileState extends State<_FontItemTile> with AutomaticKeepAliveClientMixin {
  static final Set<String> _resolvedFonts = {'System Default', 'Inter', 'JetBrains Mono'};
  bool _isResolved = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (_resolvedFonts.contains(widget.font)) {
      _isResolved = true;
    } else if (!widget.isScrolling) {
      _resolveFont();
    }
  }

  @override
  void didUpdateWidget(covariant _FontItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isResolved && !widget.isScrolling) {
      _resolveFont();
    }
  }

  void _resolveFont() {
    if (_isResolved) return;
    _resolvedFonts.add(widget.font);
    setState(() {
      _isResolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final effectiveFontFamily = (_isResolved && widget.font != 'System Default') ? widget.font : null;

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: widget.onTap,
      child: Container(
        height: 36.0,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: widget.isSelected ? widget.colors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.font,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: effectiveFontFamily,
                  fontFamilyFallback: const ['sans-serif'],
                  fontSize: 14,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  color: widget.isSelected ? widget.colors.primary : widget.colors.foreground,
                ),
              ),
            ),
            if (widget.isSelected) Icon(FLucideIcons.check, size: 16, color: widget.colors.primary),
          ],
        ),
      ),
    );
  }
}
