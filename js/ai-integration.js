const API_KEY = '';

// Check if we should use the local OpenRouter service
const useOpenRouter = true;

async function generateContent(prompt, template) {
    if (useOpenRouter) {
        try {
            const response = await fetch('/api/generate-content', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    prompt,
                    template
                })
            });
            
            if (!response.ok) {
                throw new Error(`HTTP error ${response.status}`);
            }
            
            const data = await response.json();
            document.getElementById('generated-content').value = data.content;
            
            if (template === 'tabelle') {
                insertTableContent(data.content);
            } else if (template === 'bildkarten') {
                insertImageCardContent(data.content);
            } else if (template === 'arbeitsblatt') {
                insertWorksheetContent(data.content);
            }
            
        } catch (error) {
            console.error('Fehler bei der API-Anfrage:', error);
            // Fall back to the copy-paste interface
            showPromptCopyField(prompt, template);
        }
    } else if (!API_KEY) {
        showPromptCopyField(prompt, template);
        return;
    } else {
        try {
            const response = await fetch('https://api.openai.com/v1/completions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${API_KEY}`
                },
                body: JSON.stringify({
                    model: "text-davinci-003",
                    prompt: prompt,
                    max_tokens: 2000,
                    temperature: 0.7
                })
            });
            
            const data = await response.json();
            if (data.choices && data.choices.length > 0) {
                const generatedText = data.choices[0].text;
                document.getElementById('generated-content').value = generatedText;
                
                if (template === 'tabelle') {
                    insertTableContent(generatedText);
                } else if (template === 'bildkarten') {
                    insertImageCardContent(generatedText);
                } else if (template === 'arbeitsblatt') {
                    insertWorksheetContent(generatedText);
                }
            }
        } catch (error) {
            console.error('Fehler bei der API-Anfrage:', error);
            alert('Fehler bei der API-Anfrage. Bitte versuche es später noch einmal.');
        }
    }
}

function showPromptCopyField(prompt, template) {
    const promptContainer = document.getElementById('prompt-container');
    promptContainer.innerHTML = `
        <div class="instructions">
            <h3>Prompt für externe KI kopieren</h3>
            <p>Kopiere diesen Prompt und füge ihn bei deinem KI-Tool ein:</p>
            <textarea id="prompt-text" rows="10" style="width: 100%; padding: 10px;">${prompt}</textarea>
            <button onclick="copyPrompt()" class="button">Prompt kopieren</button>
            <p>Füge dann das Ergebnis hier ein:</p>
            <textarea id="generated-content" rows="15" style="width: 100%; padding: 10px;"></textarea>
            <button onclick="insertContent('${template}')" class="button">Inhalt einfügen</button>
        </div>
    `;
    promptContainer.style.display = 'block';
}

function copyPrompt() {
    const promptText = document.getElementById('prompt-text');
    promptText.select();
    document.execCommand('copy');
    alert('Prompt wurde in die Zwischenablage kopiert!');
}

function insertContent(template) {
    const generatedText = document.getElementById('generated-content').value;
    if (!generatedText) {
        alert('Bitte füge zuerst den generierten Inhalt ein!');
        return;
    }
    
    if (template === 'tabelle') {
        insertTableContent(generatedText);
    } else if (template === 'bildkarten') {
        insertImageCardContent(generatedText);
    } else if (template === 'arbeitsblatt') {
        insertWorksheetContent(generatedText);
    }
}

function insertTableContent(content) {
    document.getElementById('tabelleninhalt').innerHTML = content;
    document.getElementById('content-preview').style.display = 'block';
    document.getElementById('prompt-container').style.display = 'none';
    document.getElementById('export-buttons').style.display = 'block';
}

function insertImageCardContent(content) {
    document.getElementById('bildkarten').innerHTML = content;
    document.getElementById('content-preview').style.display = 'block';
    document.getElementById('prompt-container').style.display = 'none';
    document.getElementById('export-buttons').style.display = 'block';
}

function insertWorksheetContent(content) {
    document.getElementById('aufgabeninhalt').innerHTML = content;
    document.getElementById('content-preview').style.display = 'block';
    document.getElementById('prompt-container').style.display = 'none';
    document.getElementById('export-buttons').style.display = 'block';
}

function exportHTML() {
    const previewContainer = document.getElementById('content-preview');
    const htmlContent = previewContainer.innerHTML;
    
    const blob = new Blob([htmlContent], { type: 'text/html' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = 'export.html';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function copyHTML() {
    const previewContainer = document.getElementById('content-preview');
    const htmlContent = previewContainer.innerHTML;
    
    const textarea = document.createElement('textarea');
    textarea.value = htmlContent;
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
    
    alert('HTML-Code wurde in die Zwischenablage kopiert!');
}
