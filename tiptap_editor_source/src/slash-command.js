import { Extension } from '@tiptap/core';
import Suggestion from '@tiptap/suggestion';
import tippy from 'tippy.js';
import { showSourceModal } from './source-modal.js';

export const slashCommandsList = [
  {
    title: 'Text',
    description: 'Just start writing with plain text.',
    icon: '¶',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setParagraph().run();
    },
  },
  {
    title: 'Heading 1',
    description: 'Large section heading.',
    icon: 'H1',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setNode('heading', { level: 1 }).run();
    },
  },
  {
    title: 'Heading 2',
    description: 'Medium section heading.',
    icon: 'H2',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setNode('heading', { level: 2 }).run();
    },
  },
  {
    title: 'Heading 3',
    description: 'Small section heading.',
    icon: 'H3',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setNode('heading', { level: 3 }).run();
    },
  },
  {
    title: 'To-do list',
    description: 'Track tasks with a to-do list.',
    icon: '☑',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).toggleTaskList().run();
    },
  },
  {
    title: 'Bulleted list',
    description: 'Create a simple bulleted list.',
    icon: '•',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).toggleBulletList().run();
    },
  },
  {
    title: 'Numbered list',
    description: 'Create a list with numbering.',
    icon: '1.',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).toggleOrderedList().run();
    },
  },
  {
    title: 'Quote',
    description: 'Capture a quote.',
    icon: '“',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).toggleBlockquote().run();
    },
  },
  {
    title: 'Code block',
    description: 'Code snippet with formatting.',
    icon: '</>',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).toggleCodeBlock().run();
    },
  },
  {
    title: 'Table',
    description: 'Insert a 3x3 table with headers.',
    icon: '▦',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run();
    },
  },
  {
    title: 'Source Pill',
    description: 'Google AI-mode source citation pill.',
    icon: '✨',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).run();
      showSourceModal(editor, (attrs) => {
        editor.chain().focus().insertSource(attrs).run();
      });
    },
  },
  {
    title: 'Math Formula',
    description: 'LaTeX math equation block.',
    icon: '∑',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).insertContent('\n$$\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}$$\n').run();
    },
  },
  {
    title: 'Divider',
    description: 'Visually divide blocks with a line.',
    icon: '―',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setHorizontalRule().run();
    },
  },
];

export const SlashCommands = Extension.create({
  name: 'slashCommands',

  addOptions() {
    return {
      suggestion: {
        char: '/',
        command: ({ editor, range, props }) => {
          props.command({ editor, range });
        },
      },
    };
  },

  addProseMirrorPlugins() {
    return [
      Suggestion({
        editor: this.editor,
        ...this.options.suggestion,
      }),
    ];
  },
});

export const renderSlashMenu = () => {
  let component;
  let popup;
  let selectedIndex = 0;
  let items = [];
  let currentCommand = null;

  function updateMenu() {
    if (!component) return;
    component.innerHTML = '';

    if (items.length === 0) {
      const empty = document.createElement('div');
      empty.className = 'slash-item-empty';
      empty.textContent = 'No matching commands';
      component.appendChild(empty);
      return;
    }

    items.forEach((item, index) => {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = `slash-item ${index === selectedIndex ? 'is-selected' : ''}`;
      
      const icon = document.createElement('div');
      icon.className = 'slash-item-icon';
      icon.textContent = item.icon;

      const info = document.createElement('div');
      info.className = 'slash-item-info';

      const title = document.createElement('div');
      title.className = 'slash-item-title';
      title.textContent = item.title;

      const desc = document.createElement('div');
      desc.className = 'slash-item-desc';
      desc.textContent = item.description;

      info.appendChild(title);
      info.appendChild(desc);

      btn.appendChild(icon);
      btn.appendChild(info);

      btn.addEventListener('click', () => {
        if (currentCommand) {
          currentCommand(item);
        }
      });

      component.appendChild(btn);
    });

    const selectedEl = component.children[selectedIndex];
    if (selectedEl) {
      selectedEl.scrollIntoView({ block: 'nearest' });
    }
  }

  return {
    onStart: (props) => {
      items = props.items;
      currentCommand = props.command;
      selectedIndex = 0;

      component = document.createElement('div');
      component.className = 'slash-menu';
      updateMenu();

      popup = tippy('body', {
        getReferenceClientRect: props.clientRect,
        appendTo: () => document.body,
        content: component,
        showOnCreate: true,
        interactive: true,
        trigger: 'manual',
        placement: 'bottom-start',
        theme: 'notion-slash',
        animation: false,
      });
    },

    onUpdate(props) {
      items = props.items;
      currentCommand = props.command;
      selectedIndex = Math.min(selectedIndex, Math.max(0, items.length - 1));
      updateMenu();

      if (popup && popup[0]) {
        popup[0].setProps({
          getReferenceClientRect: props.clientRect,
        });
      }
    },

    onKeyDown(props) {
      if (props.event.key === 'ArrowUp') {
        selectedIndex = (selectedIndex + items.length - 1) % (items.length || 1);
        updateMenu();
        return true;
      }

      if (props.event.key === 'ArrowDown') {
        selectedIndex = (selectedIndex + 1) % (items.length || 1);
        updateMenu();
        return true;
      }

      if (props.event.key === 'Enter') {
        if (items[selectedIndex] && currentCommand) {
          currentCommand(items[selectedIndex]);
          return true;
        }
      }

      if (props.event.key === 'Escape') {
        if (popup && popup[0]) {
          popup[0].hide();
        }
        return true;
      }

      return false;
    },

    onExit() {
      if (popup && popup[0]) {
        popup[0].destroy();
      }
      component = null;
      popup = null;
    },
  };
};
