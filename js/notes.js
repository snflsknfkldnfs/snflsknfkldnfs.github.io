function renderNotesList(notes) {
  const container = document.getElementById('notes-list');
  container.innerHTML = '';

  notes.forEach(note => {
    const noteElement = document.createElement('div');
    noteElement.className = 'note-item';
    noteElement.dataset.category = note.category;
    noteElement.innerHTML = `
      <h3>${note.title}</h3>
      <span class="note-category">${note.category}</span>
      <button onclick="useNoteInPrompt('${note.id}')">Verwenden</button>
    `;
    container.appendChild(noteElement);
  });
}

function filterNotes(notes, searchTerm) {
  const filteredNotes = notes.filter(note =>
    note.title.toLowerCase().includes(searchTerm) ||
    note.category.toLowerCase().includes(searchTerm)
  );
  renderNotesList(filteredNotes);
}
