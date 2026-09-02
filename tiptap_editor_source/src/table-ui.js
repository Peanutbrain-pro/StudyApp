export function initTableUI(editor) {
  let contextMenu = null;

  function removeContextMenu() {
    if (contextMenu) {
      contextMenu.remove();
      contextMenu = null;
    }
  }

  document.addEventListener('click', (e) => {
    if (contextMenu && !contextMenu.contains(e.target)) {
      removeContextMenu();
    }
  });

  document.addEventListener('contextmenu', (e) => {
    const tableCell = e.target.closest('td, th');
    if (!tableCell || !editor) {
      removeContextMenu();
      return;
    }

    e.preventDefault();
    removeContextMenu();

    contextMenu = document.createElement('div');
    contextMenu.className = 'table-context-menu';
    contextMenu.style.left = `${e.clientX}px`;
    contextMenu.style.top = `${e.clientY}px`;

    const items = [
      {
        label: 'Add Row Above',
        icon: '⬆️',
        action: () => editor.chain().focus().addRowBefore().run(),
      },
      {
        label: 'Add Row Below',
        icon: '⬇️',
        action: () => editor.chain().focus().addRowAfter().run(),
      },
      {
        label: 'Delete Row',
        icon: '❌',
        action: () => editor.chain().focus().deleteRow().run(),
      },
      { divider: true },
      {
        label: 'Add Column Left',
        icon: '⬅️',
        action: () => editor.chain().focus().addColumnBefore().run(),
      },
      {
        label: 'Add Column Right',
        icon: '➡️',
        action: () => editor.chain().focus().addColumnAfter().run(),
      },
      {
        label: 'Delete Column',
        icon: '❌',
        action: () => editor.chain().focus().deleteColumn().run(),
      },
      { divider: true },
      {
        label: 'Toggle Header Row',
        icon: '🔲',
        action: () => editor.chain().focus().toggleHeaderRow().run(),
      },
      {
        label: 'Delete Table',
        icon: '🗑️',
        danger: true,
        action: () => editor.chain().focus().deleteTable().run(),
      },
    ];

    items.forEach(item => {
      if (item.divider) {
        const hr = document.createElement('div');
        hr.className = 'table-menu-divider';
        contextMenu.appendChild(hr);
        return;
      }

      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = `table-menu-item ${item.danger ? 'is-danger' : ''}`;
      btn.innerHTML = `<span class="table-menu-icon">${item.icon}</span><span>${item.label}</span>`;
      btn.addEventListener('click', (ev) => {
        ev.stopPropagation();
        item.action();
        removeContextMenu();
      });
      contextMenu.appendChild(btn);
    });

    document.body.appendChild(contextMenu);

    // Adjust position if overflowing viewport
    const rect = contextMenu.getBoundingClientRect();
    if (rect.right > window.innerWidth) {
      contextMenu.style.left = `${window.innerWidth - rect.width - 10}px`;
    }
    if (rect.bottom > window.innerHeight) {
      contextMenu.style.top = `${window.innerHeight - rect.height - 10}px`;
    }
  });
}
