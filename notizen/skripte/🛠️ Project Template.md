---
tags:
  - projects
scheduled: 
due: 
status: 
priority: 
project_type: 
Cover: "{image-url}"
---
```meta-bind-button
label: add cover
icon: ""
hidden: false
class: ""
tooltip: ""
id: ""
style: destructive
actions:
  - type: command
    command: insert-unsplash-image:insert-in-frontmatter

```

```dataviewjs
function renderProgressBar() {
    const container = dv.el("div", "", { attr: { style: `
            width: 100%;
            margin: 0 auto;
            padding: 1rem;
            display: flex;
            flex-direction: column;
            gap: 16px;
            align-items: center;
            justify-content: center;
            align: center; 
            background: rgba(255, 255, 255, 0.25);
            border-radius: 4px;
        ` 
    }});

	const progressText = dv.el("text")
	
    const progressBar = dv.el("progress", "", { attr : { max: "100", value: "0",
        style: `
            width: 95%;
        `
    }});

    container.appendChild(progressText);
    container.appendChild(progressBar);
    
    return { container, progressText, progressBar };
}


function calculateProgress() {
	const tasks = (dv.current()?.file?.lists || []).filter(({task}) => task);
    return Math.round([...tasks].reduce((acc, { checked }) => acc + 
	    Number(checked), 0) / tasks.length * 100 || 0);
}

function updateProgressBar({ container, progressText, progressBar }) {
		const progress = calculateProgress();
		if(typeof progress === 'number') {
		    progressBar.value = progress;
		    progressText.innerHTML = `${progress}%`;
		}
}
	
const progressBar = renderProgressBar();
updateProgressBar(progressBar);

setInterval(updateProgressBar, 500, progressBar);
```

```meta-bind-button
label: add task
icon: plus
hidden: false
class: ""
tooltip: ""
id: ""
style: default
actions:
  - type: command
    command: obsidian-tasks-plugin:edit-task

```

