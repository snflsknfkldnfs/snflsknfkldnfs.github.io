require('dotenv').config();
const axios = require('axios');
const fs = require('fs-extra');
const path = require('path');

class OpenRouterClient {
    constructor() {
        this.apiKey = process.env.OPENROUTER_API_KEY;
        this.baseUrl = 'https://openrouter.ai/api/v1';
        this.model = 'deepseek/deepseek-coder-33b-instruct';
        this.logDir = path.join('scripts', 'logs');
    }
    
    async initialize() {
        await fs.ensureDir(this.logDir);
    }
    
    async generateContent(prompt, systemPrompt = '', options = {}) {
        try {
            await this.initialize();
            
            const requestBody = {
                model: this.model,
                messages: [
                    { role: 'system', content: systemPrompt || 'You are a helpful assistant.' },
                    { role: 'user', content: prompt }
                ],
                max_tokens: options.maxTokens || 2000,
                temperature: options.temperature || 0.7,
            };
            
            const response = await axios.post(
                `${this.baseUrl}/chat/completions`,
                requestBody,
                {
                    headers: {
                        'Authorization': `Bearer ${this.apiKey}`,
                        'Content-Type': 'application/json'
                    }
                }
            );
            
            // Log the request and response
            await this.logInteraction({
                timestamp: new Date().toISOString(),
                request: requestBody,
                response: response.data
            });
            
            return response.data.choices[0].message.content;
        } catch (error) {
            console.error('Error generating content:', error.response ? error.response.data : error.message);
            throw error;
        }
    }
    
    async logInteraction(data) {
        const logFile = path.join(this.logDir, `interaction-${new Date().toISOString().split('T')[0]}.json`);
        
        let logs = [];
        if (await fs.pathExists(logFile)) {
            logs = await fs.readJson(logFile);
        }
        
        logs.push(data);
        await fs.writeJson(logFile, logs, { spaces: 2 });
    }
}

module.exports = new OpenRouterClient();
