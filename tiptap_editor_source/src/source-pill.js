import { Node, mergeAttributes } from '@tiptap/core';

function escapeAttr(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

function getFiletypeInfo(filetype) {
  const ft = (filetype || 'file').toLowerCase();
  if (ft === 'pdf') {
    return {
      bg: '#fce8e6',
      color: '#d93025',
      icon: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>`,
      label: 'PDF'
    };
  } else if (['doc', 'docx'].includes(ft)) {
    return {
      bg: '#e8f0fe',
      color: '#1a73e8',
      icon: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>`,
      label: 'DOC'
    };
  } else if (['ppt', 'pptx'].includes(ft)) {
    return {
      bg: '#fef7e0',
      color: '#e37400',
      icon: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>`,
      label: 'PPT'
    };
  } else if (['xls', 'xlsx', 'csv'].includes(ft)) {
    return {
      bg: '#e6f4ea',
      color: '#188038',
      icon: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="3" y1="15" x2="21" y2="15"></line><line x1="9" y1="3" x2="9" y2="21"></line><line x1="15" y1="3" x2="15" y2="21"></line></svg>`,
      label: 'XLS'
    };
  } else if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'image'].includes(ft)) {
    return {
      bg: '#f3e8fd',
      color: '#9334e6',
      icon: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>`,
      label: 'IMG'
    };
  } else if (['http', 'https', 'url', 'web'].includes(ft)) {
    return {
      bg: '#e8f0fe',
      color: '#1a73e8',
      icon: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>`,
      label: 'WEB'
    };
  }

  return {
    bg: '#f1f3f4',
    color: '#5f6368',
    icon: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>`,
    label: ft.toUpperCase()
  };
}

export const SourceEmbed = Node.create({
  name: 'sourceEmbed',
  group: 'inline',
  inline: true,
  selectable: true,
  draggable: true,
  atom: true,

  addAttributes() {
    return {
      filename: {
        default: 'Document',
        parseHTML: el => el.getAttribute('data-filename') || el.getAttribute('filename') || 'Document',
        renderHTML: attrs => ({ 'data-filename': attrs.filename }),
      },
      filetype: {
        default: 'file',
        parseHTML: el => el.getAttribute('data-filetype') || el.getAttribute('filetype') || 'file',
        renderHTML: attrs => ({ 'data-filetype': attrs.filetype }),
      },
      url: {
        default: '',
        parseHTML: el => el.getAttribute('data-url') || el.getAttribute('url') || '',
        renderHTML: attrs => ({ 'data-url': attrs.url }),
      },
      page: {
        default: null,
        parseHTML: el => el.getAttribute('data-page') || el.getAttribute('page') || null,
        renderHTML: attrs => (attrs.page ? { 'data-page': attrs.page } : {}),
      },
      location: {
        default: null,
        parseHTML: el => el.getAttribute('data-location') || el.getAttribute('location') || null,
        renderHTML: attrs => (attrs.location ? { 'data-location': attrs.location } : {}),
      },
    };
  },

  parseHTML() {
    return [
      {
        tag: 'source-embed',
      },
      {
        tag: 'span[data-type="source-embed"]',
      },
      {
        tag: 'div[data-type="source-embed"]',
      },
    ];
  },

  renderHTML({ node, HTMLAttributes }) {
    const { filename, filetype, url, page, location } = node.attrs;
    const info = getFiletypeInfo(filetype);

    return [
      'span',
      mergeAttributes(
        {
          'class': 'g-source-pill',
          'data-type': 'source-embed',
          'data-filename': filename,
          'data-filetype': filetype,
          'data-url': url,
          ...(page ? { 'data-page': String(page) } : {}),
          ...(location ? { 'data-location': location } : {}),
          'title': `${filename}${page ? ` (Page ${page})` : ''}${location ? ` - ${location}` : ''}`,
        },
        HTMLAttributes
      ),
      [
        'span',
        {
          'class': 'g-source-icon-wrap',
          'style': `background-color: ${info.bg}; color: ${info.color};`,
        },
        // We will render icon in DOM NodeView
      ],
      ['span', { 'class': 'g-source-filename' }, filename || 'Source'],
      ...(page ? [['span', { 'class': 'g-source-page' }, `p. ${page}`]] : []),
      ...(location ? [['span', { 'class': 'g-source-loc' }, location]] : []),
    ];
  },

  addNodeView() {
    return ({ node }) => {
      const { filename, filetype, url, page, location } = node.attrs;
      const info = getFiletypeInfo(filetype);

      const dom = document.createElement('span');
      dom.className = 'g-source-pill';
      dom.setAttribute('data-type', 'source-embed');
      dom.setAttribute('data-filename', filename || '');
      dom.setAttribute('data-filetype', filetype || '');
      dom.setAttribute('data-url', url || '');
      if (page) dom.setAttribute('data-page', String(page));
      if (location) dom.setAttribute('data-location', location);
      dom.title = `${filename || 'Document'}${page ? ` (Page ${page})` : ''}${location ? ` • ${location}` : ''} [Click to open]`;

      // Icon wrap
      const iconWrap = document.createElement('span');
      iconWrap.className = 'g-source-icon-wrap';
      iconWrap.style.backgroundColor = info.bg;
      iconWrap.style.color = info.color;
      iconWrap.innerHTML = info.icon;
      dom.appendChild(iconWrap);

      // Filename text
      const nameSpan = document.createElement('span');
      nameSpan.className = 'g-source-filename';
      nameSpan.textContent = filename || 'Source';
      dom.appendChild(nameSpan);

      // Page badge
      if (page) {
        const pageSpan = document.createElement('span');
        pageSpan.className = 'g-source-page';
        pageSpan.textContent = `p. ${page}`;
        dom.appendChild(pageSpan);
      }

      // Location badge
      if (location) {
        const locSpan = document.createElement('span');
        locSpan.className = 'g-source-loc';
        locSpan.textContent = location;
        dom.appendChild(locSpan);
      }

      // Click event
      dom.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('onSourceClick', {
            filename: filename || '',
            filetype: filetype || '',
            url: url || '',
            page: page || null,
            location: location || null,
          });
        }
      });

      return {
        dom,
        selectNode: () => dom.classList.add('ProseMirror-selectednode'),
        deselectNode: () => dom.classList.remove('ProseMirror-selectednode'),
      };
    };
  },

  addStorage() {
    return {
      markdown: {
        serialize(state, node) {
          const fn = escapeAttr(node.attrs.filename || '');
          const ft = escapeAttr(node.attrs.filetype || '');
          const u = escapeAttr(node.attrs.url || '');
          const p = node.attrs.page ? ` data-page="${escapeAttr(String(node.attrs.page))}"` : '';
          const loc = node.attrs.location ? ` data-location="${escapeAttr(node.attrs.location)}"` : '';
          state.write(`<source-embed data-filename="${fn}" data-filetype="${ft}" data-url="${u}"${p}${loc}></source-embed>`);
        },
        parse: {
          setup(markdownit) {
            // Markdown-it allows HTML inline tags by default
          },
        },
      },
    };
  },

  addCommands() {
    return {
      insertSource: options => ({ commands }) => {
        return commands.insertContent({
          type: this.name,
          attrs: options,
        });
      },
    };
  },
});
