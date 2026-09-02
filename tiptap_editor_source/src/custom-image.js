import Image from '@tiptap/extension-image';
import { mergeAttributes } from '@tiptap/core';

export const CustomImage = Image.extend({
  name: 'image',

  addAttributes() {
    return {
      ...this.parent?.(),
      src: {
        default: null,
      },
      alt: {
        default: null,
      },
      title: {
        default: null,
      },
      width: {
        default: null,
        renderHTML: attrs => (attrs.width ? { width: attrs.width, style: `width: ${attrs.width}px; max-width: 100%;` } : {}),
      },
      isNetwork: {
        default: true,
      },
      filename: {
        default: null,
      },
    };
  },

  renderHTML({ HTMLAttributes }) {
    return [
      'img',
      mergeAttributes(this.options.HTMLAttributes, HTMLAttributes, {
        class: 'notion-image',
      }),
    ];
  },

  addNodeView() {
    return ({ node }) => {
      const dom = document.createElement('div');
      dom.className = 'notion-image-wrapper';

      const img = document.createElement('img');
      let src = node.attrs.src || '';
      // If local path on Windows/mac without file://, ensure proper file URL format if needed
      if (src && !src.startsWith('http://') && !src.startsWith('https://') && !src.startsWith('data:') && !src.startsWith('file://') && !src.startsWith('blob:')) {
        src = 'file:///' + src.replace(/\\/g, '/');
      }
      img.src = src;
      img.alt = node.attrs.alt || node.attrs.filename || 'Image';
      img.className = 'notion-image';
      if (node.attrs.width) {
        img.style.width = `${node.attrs.width}px`;
      }
      img.style.maxWidth = '100%';
      img.style.borderRadius = '8px';
      img.style.display = 'block';
      img.style.cursor = 'pointer';

      img.addEventListener('click', (e) => {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('onImageClick', {
            url: node.attrs.src || '',
          });
        }
      });

      dom.appendChild(img);

      return {
        dom,
        selectNode: () => dom.classList.add('ProseMirror-selectednode'),
        deselectNode: () => dom.classList.remove('ProseMirror-selectednode'),
      };
    };
  },
});
