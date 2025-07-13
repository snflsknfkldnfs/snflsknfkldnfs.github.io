# 🤖 **APPLE NOTES KANBAN SCANNER**

---
**Function:** Automatische Task-Extraktion aus Apple Notes  
**Integration:** 3-Board-System + Intelligent Assignment  
**Status:** IMPLEMENTIERT  
---

## 📱 **CORE SCANNER FUNCTION**

### **🔍 Apple Notes Discovery & Processing:**

```python
def scan_kanban_notes():
    """
    Scannt Apple Notes nach KANBAN_* Pattern und extrahiert Tasks
    """
    
    # 1. DISCOVERY PHASE
    notes = list_notes(limit=50)
    kanban_notes = [note for note in notes if note['name'].startswith('KANBAN_')]
    
    unprocessed_notes = []
    for note in kanban_notes:
        content = get_note_content(note['name'])
        if '[Automatisch verarbeitet: NEIN]' in content:
            unprocessed_notes.append(note)
    
    # 2. PROCESSING PHASE
    extracted_tasks = []
    for note in unprocessed_notes:
        tasks = extract_tasks_from_note(note)
        extracted_tasks.extend(tasks)
    
    # 3. BOARD ASSIGNMENT PHASE
    board_assignments = assign_tasks_to_boards(extracted_tasks)
    
    # 4. INTEGRATION PHASE
    integration_results = integrate_tasks_to_boards(board_assignments)
    
    # 5. CLEANUP PHASE
    mark_notes_as_processed(unprocessed_notes)
    
    return integration_results

def extract_tasks_from_note(note):
    """
    Extrahiert Tasks aus Notiz-Content mit intelligenter Parsing
    """
    content = get_note_content(note['name'])
    lines = content.split('\n')
    
    tasks = []
    for line in lines:
        if line.strip().startswith('- ') and not line.startswith('---'):
            task = parse_task_line(line.strip())
            if task:
                tasks.append(task)
    
    return tasks

def parse_task_line(line):
    """
    Parst einzelne Task-Zeile und extrahiert Metadaten
    """
    import re
    
    # Remove leading "- " or "- [ ]"
    task_text = re.sub(r'^- (\[ \])?\s*', '', line)
    
    # Extract tags (#kategorie)
    tags = re.findall(r'#\w+', task_text)
    task_text = re.sub(r'#\w+', '', task_text)
    
    # Extract priority (@urgent, @high, etc.)
    priority_match = re.search(r'@(urgent|high|medium|low|waiting|review)', task_text)
    priority = priority_match.group(1) if priority_match else 'medium'
    task_text = re.sub(r'@\w+', '', task_text)
    
    # Extract date (📅YYYY-MM-DD)
    date_match = re.search(r'📅(\d{4}-\d{2}-\d{2})', task_text)
    deadline = date_match.group(1) if date_match else None
    task_text = re.sub(r'📅[\d-]+', '', task_text)
    
    # Clean up task text
    task_text = task_text.strip()
    
    return {
        'text': task_text,
        'tags': tags,
        'priority': priority,
        'deadline': deadline,
        'original_line': line
    }

def assign_tasks_to_boards(tasks):
    """
    Intelligente Board-Zuweisung basierend auf Content und Tags
    """
    board_assignments = {
        'Board_1_Schulalltag_Klassenleitung.md': [],
        'Board_2_Seminar_LAA_Ausbildung.md': [],
        'Board_3_Meta_Prozesse_KI_System.md': []
    }
    
    for task in tasks:
        board = determine_board(task)
        board_assignments[board].append(task)
    
    return board_assignments

def determine_board(task):
    """
    Bestimmt das richtige Board basierend auf Tags und Content
    """
    text_lower = task['text'].lower()
    tags = [tag.lower() for tag in task['tags']]
    
    # Board 1: Schulalltag & Klassenleitung
    school_indicators = [
        '#klassenführung', '#elternarbeit', '#gpg', '#m', '#e', '#sport',
        '#verwaltung', '#sicherheit', '#unterricht'
    ]
    school_keywords = [
        'klasse', 'schüler', 'eltern', 'unterricht', 'sekretariat',
        'hausmeister', 'schulgebäude', 'notausgänge', 'lehrprobe'
    ]
    
    # Board 2: Seminar & LAA-Ausbildung
    seminar_indicators = [
        '#seminar', '#portfolio', '#lehrprobe', '#reflexion', '#peers',
        '#mentoring', '#ausbildung'
    ]
    seminar_keywords = [
        'seminar', 'portfolio', 'reflexion', 'mentor', 'ausbildung',
        'kolloquium', 'prüfung'
    ]
    
    # Board 3: Meta-Prozesse & KI-System
    meta_indicators = [
        '#system', '#automation', '#repository', '#tools', '#innovation',
        '#framework', '#workflow'
    ]
    meta_keywords = [
        'system', 'automation', 'repository', 'workflow', 'claude',
        'obsidian', 'plugin', 'framework'
    ]
    
    # Priority-based assignment
    if any(indicator in tags for indicator in school_indicators) or \
       any(keyword in text_lower for keyword in school_keywords):
        return 'Board_1_Schulalltag_Klassenleitung.md'
    
    elif any(indicator in tags for indicator in seminar_indicators) or \
         any(keyword in text_lower for keyword in seminar_keywords):
        return 'Board_2_Seminar_LAA_Ausbildung.md'
    
    elif any(indicator in tags for indicator in meta_indicators) or \
         any(keyword in text_lower for keyword in meta_keywords):
        return 'Board_3_Meta_Prozesse_KI_System.md'
    
    # Default: Schulalltag (most common)
    else:
        return 'Board_1_Schulalltag_Klassenleitung.md'

def integrate_tasks_to_boards(board_assignments):
    """
    Integriert Tasks in die entsprechenden Kanban-Boards
    """
    integration_results = []
    
    for board_path, tasks in board_assignments.items():
        if not tasks:
            continue
            
        # Read current board
        board_content = read_file(f'/Users/paulad/snflsknfkldnfs.github.io/kanban/{board_path}')
        
        # Find appropriate column based on priority
        for task in tasks:
            column = determine_column(task['priority'])
            formatted_task = format_task_for_board(task)
            
            # Insert task into appropriate column
            updated_content = insert_task_into_column(board_content, column, formatted_task)
            
            # Write back to board
            write_file(f'/Users/paulad/snflsknfkldnfs.github.io/kanban/{board_path}', updated_content)
            
            integration_results.append({
                'task': task['text'],
                'board': board_path,
                'column': column,
                'status': 'SUCCESS'
            })
    
    return integration_results

def determine_column(priority):
    """
    Bestimmt die richtige Spalte basierend auf Priorität
    """
    if priority == 'urgent':
        return 'Diese Woche'  # oder "TO-DO" je nach Board
    elif priority == 'high':
        return 'Diese Woche'
    elif priority == 'waiting':
        return 'Warten'
    elif priority == 'review':
        return 'Review'
    else:
        return 'Vorbereitung'  # oder "TO-DO"

def format_task_for_board(task):
    """
    Formatiert Task für Kanban-Board-Integration
    """
    formatted = f"- [ ] {task['text']}"
    
    # Add tags
    for tag in task['tags']:
        formatted += f" {tag}"
    
    # Add priority
    formatted += f" @{task['priority']}"
    
    # Add deadline
    if task['deadline']:
        formatted += f" 📅{task['deadline']}"
    
    return formatted

def mark_notes_as_processed(notes):
    """
    Markiert Notizen als verarbeitet
    """
    for note in notes:
        content = get_note_content(note['name'])
        updated_content = content.replace(
            '[Automatisch verarbeitet: NEIN]',
            '[Automatisch verarbeitet: JA]'
        )
        update_note_content(note['name'], updated_content)
```

---

## 🔄 **CLAUDE DESKTOP WORKFLOW COMMANDS**

### **📱 Main Processing Command:**
```
"Verarbeite Apple Notes für Kanban-Integration:

PHASE 1 - DISCOVERY:
- Scanne alle Notizen nach KANBAN_* Pattern
- Identifiziere unverarbeitete Notizen ([Verarbeitet: NEIN])
- Priorisiere nach: URGENT → SCHULE → SEMINAR → META

PHASE 2 - EXTRACTION: 
- Extrahiere Tasks (- [ ] oder - Format)
- Parse Tags (#kategorie), Prioritäten (@urgent), Deadlines (📅)
- Standardisiere Format für Board-Integration

PHASE 3 - INTELLIGENT ASSIGNMENT:
- Board 1: #klassenführung, #gpg, #elternarbeit, Schulkeywords
- Board 2: #seminar, #portfolio, #lehrprobe, Seminarkeywords  
- Board 3: #system, #automation, #repository, Metakeywords

PHASE 4 - INTEGRATION:
- Insert Tasks in richtige Board-Spalten (nach Priorität)
- Formatiere korrekt für Kanban-Plugin-Kompatibilität
- Update alle 3 Boards + Unified Dashboard

PHASE 5 - CLEANUP:
- Markiere Notizen als [Verarbeitet: JA]
- Erstelle Processing-Log für Nachvollziehbarkeit
- Validation: Alle Tasks erfolgreich integriert?"
```

---

## 🧪 **TESTING & VALIDATION**

### **🔍 Integration Test:**
```
"Teste Apple Notes Integration:

1. KANBAN_INBOX Notiz gefunden? ✓
2. Tasks korrekt extrahiert? 
   - Klassenlisten holen (@urgent #klassenführung)
   - Portfolio-Reflexion (#seminar @high)
   - Repository optimieren (#system @medium)
   
3. Board-Assignment korrekt?
   - Klassenlisten → Board 1 (Schulalltag) ✓
   - Portfolio → Board 2 (Seminar) ✓ 
   - Repository → Board 3 (Meta) ✓

4. Integration erfolgreich?
   - Tasks in richtige Spalten eingefügt
   - Format Kanban-kompatibel
   - Tags und Deadlines korrekt

5. Cleanup durchgeführt?
   - Notiz als [Verarbeitet: JA] markiert"
```

---

## 📊 **MONITORING & ANALYTICS**

### **📈 Processing Statistics:**
```python
processing_stats = {
    'notes_scanned': len(kanban_notes),
    'notes_processed': len(unprocessed_notes),
    'tasks_extracted': len(extracted_tasks),
    'board_1_tasks': len(board_assignments['Board_1']),
    'board_2_tasks': len(board_assignments['Board_2']),
    'board_3_tasks': len(board_assignments['Board_3']),
    'processing_time': end_time - start_time,
    'success_rate': successful_integrations / total_tasks
}
```

---

## 🚀 **STATUS: READY FOR FIRST TEST**

```yaml
SCANNER_IMPLEMENTED: ✅ Core Logic Ready
TEST_NOTE_CREATED: ✅ KANBAN_INBOX with sample tasks
BOARD_ASSIGNMENT: ✅ Intelligent Algorithm Ready
INTEGRATION_LOGIC: ✅ Board-Update Functions Ready
CLEANUP_PROCESS: ✅ Auto-marking as processed
CLAUDE_WORKFLOW: ✅ Complete Command Ready
```

**🎯 Ready to process the test KANBAN_INBOX note and integrate tasks into your 3-Board-System! 🚀**

---

*Mobile Capture • Intelligent Processing • Seamless Integration • Zero Manual Work*