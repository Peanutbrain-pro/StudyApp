import { Editor } from '@tiptap/core';
import StarterKit from '@tiptap/starter-kit';
import Placeholder from '@tiptap/extension-placeholder';
import TaskList from '@tiptap/extension-task-list';
import TaskItem from '@tiptap/extension-task-item';
import { Table, TableRow, TableHeader, TableCell } from '@tiptap/extension-table';
import Highlight from '@tiptap/extension-highlight';
import { Markdown } from 'tiptap-markdown';
import { SourceEmbed } from './source-pill.js';
import { CustomImage } from './custom-image.js';
import { SlashCommands, slashCommandsList, renderSlashMenu } from './slash-command.js';
import { initTableUI } from './table-ui.js';
import { showSourceModal } from './source-modal.js';

let editor = null;
let changeDebounceTimer = null;
let isSettingContentInternally = false;

function notifyContentChange(markdown) {
  if (isSettingContentInternally) return;
  if (changeDebounceTimer) {
    clearTimeout(changeDebounceTimer);
  }
  changeDebounceTimer = setTimeout(() => {
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler('onContentChange', markdown);
    }
  }, 150);
}

function notifySelectionChange() {
  if (!editor || !window.flutter_inappwebview) return;
  const state = {
    isBold: editor.isActive('bold'),
    isItalic: editor.isActive('italic'),
    isStrike: editor.isActive('strike'),
    isUnderline: editor.isActive('underline'),
    isCode: editor.isActive('code'),
    isHighlight: editor.isActive('highlight'),
    isHeading1: editor.isActive('heading', { level: 1 }),
    isHeading2: editor.isActive('heading', { level: 2 }),
    isHeading3: editor.isActive('heading', { level: 3 }),
    isBulletList: editor.isActive('bulletList'),
    isOrderedList: editor.isActive('orderedList'),
    isTaskList: editor.isActive('taskList'),
    isBlockquote: editor.isActive('blockquote'),
    isCodeBlock: editor.isActive('codeBlock'),
    isTable: editor.isActive('table'),
    canUndo: editor.can().undo(),
    canRedo: editor.can().redo(),
  };
  window.flutter_inappwebview.callHandler('onSelectionChange', state);
}

function initEditor() {
  const container = document.getElementById('editor-container');
  if (!container) return;

  editor = new Editor({
    element: container,
    extensions: [
      StarterKit.configure({
        heading: {
          levels: [1, 2, 3],
        },
      }),
      Placeholder.configure({
        placeholder: "Write your notes here, or type '/' for commands...",
        emptyEditorClass: 'is-editor-empty',
      }),
      TaskList.configure({
        HTMLAttributes: {
          class: 'task-list',
        },
      }),
      TaskItem.configure({
        nested: true,
        HTMLAttributes: {
          class: 'task-item',
        },
      }),
      Table.configure({
        resizable: true,
      }),
      TableRow,
      TableHeader,
      TableCell,
      Highlight.configure({
        multicolor: true,
      }),
      CustomImage,
      SourceEmbed,
      SlashCommands.configure({
        suggestion: {
          items: ({ query }) => {
            return slashCommandsList.filter(item =>
              item.title.toLowerCase().includes(query.toLowerCase()) ||
              item.description.toLowerCase().includes(query.toLowerCase())
            );
          },
          render: renderSlashMenu,
        },
      }),
      Markdown.configure({
        html: true,
        tightLists: true,
        bulletListMarker: '-',
        linkify: true,
        breaks: false,
        transformPastedText: true,
        transformCopiedText: true,
      }),
    ],
    content: '',
    autofocus: false,
    editable: true,
    onUpdate({ editor }) {
      const markdown = editor.storage.markdown?.getMarkdown?.() || editor.getHTML();
      notifyContentChange(markdown);
    },
    onSelectionUpdate() {
      notifySelectionChange();
    },
    onCreate() {
      initTableUI(editor);
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onEditorReady');
      }
    },
  });

  // Global window functions for Flutter JS evaluation
  window.setMarkdown = function (markdown) {
    if (!editor) return;
    try {
      isSettingContentInternally = true;
      editor.commands.setContent(markdown || '', false, { preserveWhitespace: 'full' });
    } catch (e) {
      console.error('Error setting markdown:', e);
    } finally {
      isSettingContentInternally = false;
    }
  };

  window.getMarkdown = function () {
    if (!editor) return '';
    return editor.storage.markdown?.getMarkdown?.() || editor.getHTML();
  };

  window.getHTML = function () {
    if (!editor) return '';
    return editor.getHTML();
  };

  window.setHTML = function (html) {
    if (!editor) return;
    isSettingContentInternally = true;
    editor.commands.setContent(html || '', false);
    isSettingContentInternally = false;
  };

  window.focusEditor = function () {
    if (editor) {
      editor.commands.focus();
      if (editor.view && editor.view.dom) {
        editor.view.dom.focus();
      }
    }
  };

  window.openSourceModal = function () {
    if (editor) {
      showSourceModal(editor);
    }
  };

  window.insertImage = function (data) {
    if (!editor) return;
    const options = typeof data === 'string' ? JSON.parse(data) : data;
    editor.chain().focus().setImage({
      src: options.url,
      alt: options.filename || 'Image',
      title: options.filename || 'Image',
      width: options.width || null,
      isNetwork: options.isNetwork !== false,
      filename: options.filename || null,
    }).run();
  };

  window.insertSource = function (data) {
    if (!editor) return;
    const options = typeof data === 'string' ? JSON.parse(data) : data;
    editor.chain().focus().insertSource({
      filename: options.filename || 'Document',
      filetype: options.filetype || 'file',
      url: options.url || '',
      page: options.page || null,
      location: options.location || null,
    }).run();
  };

  window.insertMath = function (latex) {
    if (!editor) return;
    const text = typeof latex === 'string' ? latex : (latex?.latex || '');
    editor.chain().focus().insertContent(`\n$$\n${text}\n$$\n`).run();
  };

  window.setTheme = function (theme) {
    const isDark = theme === 'dark' || (theme === 'auto' && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
    if (isDark) {
      document.body.classList.add('dark-theme');
      document.body.classList.remove('light-theme');
      document.documentElement.setAttribute('data-theme', 'dark');
    } else {
      document.body.classList.add('light-theme');
      document.body.classList.remove('dark-theme');
      document.documentElement.setAttribute('data-theme', 'light');
    }
  };

  // Formatting commands
  window.toggleBold = () => editor?.chain().focus().toggleBold().run();
  window.toggleItalic = () => editor?.chain().focus().toggleItalic().run();
  window.toggleStrike = () => editor?.chain().focus().toggleStrike().run();
  window.toggleUnderline = () => editor?.chain().focus().toggleUnderline().run();
  window.toggleCode = () => editor?.chain().focus().toggleCode().run();
  window.toggleHighlight = () => editor?.chain().focus().toggleHighlight().run();
  window.toggleHeading = (opts) => {
    const level = typeof opts === 'number' ? opts : (opts?.level || 1);
    editor?.chain().focus().toggleHeading({ level }).run();
  };
  window.toggleBulletList = () => editor?.chain().focus().toggleBulletList().run();
  window.toggleOrderedList = () => editor?.chain().focus().toggleOrderedList().run();
  window.toggleTaskList = () => editor?.chain().focus().toggleTaskList().run();
  window.toggleBlockquote = () => editor?.chain().focus().toggleBlockquote().run();
  window.toggleCodeBlock = () => editor?.chain().focus().toggleCodeBlock().run();
  window.insertHorizontalRule = () => editor?.chain().focus().setHorizontalRule().run();
  
  // Table commands
  window.insertTable = (opts) => {
    const rows = opts?.rows || 3;
    const cols = opts?.cols || 3;
    editor?.chain().focus().insertTable({ rows, cols, withHeaderRow: true }).run();
  };
  window.addColumnBefore = () => editor?.chain().focus().addColumnBefore().run();
  window.addColumnAfter = () => editor?.chain().focus().addColumnAfter().run();
  window.deleteColumn = () => editor?.chain().focus().deleteColumn().run();
  window.addRowBefore = () => editor?.chain().focus().addRowBefore().run();
  window.addRowAfter = () => editor?.chain().focus().addRowAfter().run();
  window.deleteRow = () => editor?.chain().focus().deleteRow().run();
  window.deleteTable = () => editor?.chain().focus().deleteTable().run();
  window.mergeCells = () => editor?.chain().focus().mergeCells().run();
  window.splitCell = () => editor?.chain().focus().splitCell().run();
  window.toggleHeaderRow = () => editor?.chain().focus().toggleHeaderRow().run();
  window.toggleHeaderColumn = () => editor?.chain().focus().toggleHeaderColumn().run();

  window.undo = () => editor?.chain().focus().undo().run();
  window.redo = () => editor?.chain().focus().redo().run();
  window.focus = () => {
    if (editor) {
      editor.commands.focus();
      if (editor.view && editor.view.dom) {
        editor.view.dom.focus();
      }
    }
  };
  window.clear = () => editor?.chain().focus().clearContent().run();
}

if (typeof document !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initEditor);
  } else {
    initEditor();
  }
}
