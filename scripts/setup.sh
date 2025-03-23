#!/bin/bash

echo "Installing necessary dependencies..."
npm init -y
npm install dotenv axios fs-extra chokidar nomic @dqbd/tiktoken express cors body-parser

echo "Creating project structure..."
mkdir -p scripts/embeddings
mkdir -p scripts/logs
mkdir -p api

echo "Setup completed successfully!"
