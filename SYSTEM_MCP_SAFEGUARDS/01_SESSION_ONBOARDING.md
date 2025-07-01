# CLAUDE-SESSION-ONBOARDING: MCP-Safeguards

## 🔄 AUTOMATISCHES ONBOARDING-PROTOCOL

### **STEP 1: PROBLEM-AWARENESS**
```markdown
NEUE CLAUDE-SESSION MUSS BESTÄTIGEN:
"Ich bin mir des MCP-Multi-PDF-Crash-Bugs bewusst und werde sichere Workflows verwenden."
```

### **STEP 2: SAFEGUARD-ACTIVATION**
```yaml
Obligatorische Aktivierung:
  ✅ Single-PDF-Sequential-Mode: ON
  ✅ Multi-File-Restrictions: ACTIVE  
  ✅ User-Confirmation-Requirements: ENABLED
  ✅ Emergency-Recovery-Protocols: LOADED
```

### **STEP 3: WORKFLOW-CONFIGURATION**
```python
# Pseudocode für Claude-Session-Setup
def claude_session_init():
    confirm_problem_awareness()
    activate_pdf_safeguards()
    enable_sequential_file_mode()
    load_emergency_protocols()
    validate_safe_practices()
    return "MCP_SAFEGUARDS_ACTIVE"
```

## 📋 SCHNELL-REFERENZ FÜR CLAUDE

### **VERBOTENE AKTIONEN:**
```bash
❌ NIEMALS: read_multiple_files([pdf1, pdf2, pdf3])
❌ NIEMALS: Simultaner Multi-PDF-Access
❌ NIEMALS: >5MB Dateien gleichzeitig
```

### **ERLAUBTE AKTIONEN:**
```bash
✅ SICHER: read_file(single_pdf) → validate → continue
✅ SICHER: get_file_info(multiple_files) 
✅ SICHER: Einzelne PDFs mit User-Confirmation
```

### **EMERGENCY-PROTOCOL:**
```yaml
Bei Chat-Reset-Symptomen:
  1. Stop all file operations immediately
  2. Document last successful action
  3. Inform user about reset risk
  4. Restart with single-file-mode
```

## 🎯 SESSION-VALIDATION-CHECKLIST

### **Vor jeder PDF-Operation:**
- [ ] Dateigröße geprüft (<1MB = sicher, >1MB = Confirmation)
- [ ] Nur ein PDF pro Request geplant
- [ ] User über Vorgehen informiert
- [ ] Success-Validation bereit

### **Nach komplexen Tool-Operations:**
- [ ] Memory-State assessed  
- [ ] Pause vor nächster File-Operation
- [ ] Extra-vorsichtige Single-File-Approach
- [ ] User-Confirmation für kritische Ops

---

**DIESES SCRIPT MUSS VON JEDER NEUEN CLAUDE-SESSION DURCHLAUFEN WERDEN**
