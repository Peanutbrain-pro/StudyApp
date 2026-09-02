export function showSourceModal(editor, onInsert) {
  const existing = document.getElementById('source-pill-modal');
  if (existing) existing.remove();

  const backdrop = document.createElement('div');
  backdrop.id = 'source-pill-modal';
  backdrop.className = 'source-modal-backdrop';

  const modal = document.createElement('div');
  modal.className = 'source-modal';

  modal.innerHTML = `
    <div class="source-modal-header">
      <div class="source-modal-title">Insert Source Pill</div>
      <button type="button" class="source-modal-close">&times;</button>
    </div>
    <div class="source-modal-body">
      <div class="source-form-group">
        <label>Source / Document Name *</label>
        <input type="text" id="sm-filename" placeholder="e.g. Physics_Mechanics.pdf" autofocus />
      </div>
      <div class="source-form-row">
        <div class="source-form-group" style="flex: 1.5;">
          <label>File Type</label>
          <select id="sm-filetype">
            <option value="pdf">PDF Document</option>
            <option value="docx">Word (DOCX)</option>
            <option value="pptx">PowerPoint (PPTX)</option>
            <option value="xlsx">Excel (XLSX)</option>
            <option value="txt">Text / Notes</option>
            <option value="image">Image</option>
            <option value="web">Web Link</option>
          </select>
        </div>
        <div class="source-form-group" style="flex: 1;">
          <label>Page # (Optional)</label>
          <input type="number" id="sm-page" placeholder="e.g. 14" min="1" />
        </div>
      </div>
      <div class="source-form-group">
        <label>Location / Section / Chapter (Optional)</label>
        <input type="text" id="sm-location" placeholder="e.g. Chapter 3 > Section 2" />
      </div>
      <div class="source-form-group">
        <label>File Path or URL (Optional)</label>
        <input type="text" id="sm-url" placeholder="e.g. C:/documents/physics.pdf or https://..." />
      </div>
    </div>
    <div class="source-modal-footer">
      <button type="button" class="source-btn source-btn-cancel">Cancel</button>
      <button type="button" class="source-btn source-btn-primary">Insert Source</button>
    </div>
  `;

  backdrop.appendChild(modal);
  document.body.appendChild(backdrop);

  const filenameInput = modal.querySelector('#sm-filename');
  const filetypeSelect = modal.querySelector('#sm-filetype');
  const pageInput = modal.querySelector('#sm-page');
  const locationInput = modal.querySelector('#sm-location');
  const urlInput = modal.querySelector('#sm-url');

  setTimeout(() => filenameInput?.focus(), 50);

  function close() {
    backdrop.remove();
    editor?.commands.focus();
  }

  modal.querySelector('.source-modal-close').addEventListener('click', close);
  modal.querySelector('.source-btn-cancel').addEventListener('click', close);
  backdrop.addEventListener('click', (e) => {
    if (e.target === backdrop) close();
  });

  modal.querySelector('.source-btn-primary').addEventListener('click', () => {
    const filename = filenameInput.value.trim();
    const filetype = filetypeSelect.value;
    const page = pageInput.value.trim() ? parseInt(pageInput.value.trim(), 10) : null;
    const location = locationInput.value.trim() || null;
    const url = urlInput.value.trim() || filename;

    if (!filename) {
      filenameInput.focus();
      return;
    }

    if (onInsert) {
      onInsert({ filename, filetype, url, page, location });
    } else {
      editor?.chain().focus().insertSource({
        filename,
        filetype,
        url,
        page,
        location,
      }).run();
    }
    close();
  });

  modal.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      close();
    } else if (e.key === 'Enter' && e.target.tagName === 'INPUT') {
      modal.querySelector('.source-btn-primary').click();
    }
  });
}
