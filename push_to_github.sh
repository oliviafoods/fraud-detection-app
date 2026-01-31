#!/bin/bash

# Push to GitHub Script for Fraud Detection App
# Run this on your local machine after extracting the project

set -e

echo "🚀 Pushing Fraud Detection App to GitHub"
echo "Repository: https://github.com/oliviafoods/fraud-detection-app"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    git config user.name "oliviafoods"
    git config user.email "oliviafoods@users.noreply.github.com"
fi

# Create .gitignore
echo "📝 Creating .gitignore..."
cat > .gitignore << 'EOF'
# Environment files (Contains API keys - NEVER COMMIT)
.env
backend/.env
*.env
!.env.example

# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
**/android/.gradle
**/android/captures/
**/android/local.properties

# Python
__pycache__/
*.pyc
.venv/
venv/

# IDEs
.vscode/
.idea/
*.swp
*.iml

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Archives
*.tar.gz
*.zip

# Test directories
tests/
scripts/
memory/
frontend/
EOF

# Stage files
echo "📦 Staging files..."
git add -A

# Commit
echo "💾 Creating commit..."
git commit -m "Initial commit: AI-powered Fraud Detection System for Senior Citizens

Features:
- Flutter mobile app with senior-friendly UI
- Kotlin native layer for call detection
- FastAPI backend with AI fraud analysis (Whisper + GPT-4)
- Hindi, English, and Hinglish support
- Privacy-first with local storage
- Color-coded fraud alerts
- Complete documentation

Tech Stack:
- Mobile: Flutter, Kotlin, Android SDK
- Backend: FastAPI, Python, OpenAI APIs
- Database: MongoDB
- AI: Whisper (speech-to-text), GPT-4 (fraud detection)

Documentation:
- QUICK_START_GUIDE.md - Flutter setup from scratch
- BUILD_INSTRUCTIONS.md - Build and troubleshooting
- TECHNICAL_DOCS.md - Architecture and API docs
- HINDI_LANGUAGE_SUPPORT.md - Hindi optimization details"

# Add remote
echo "🔗 Adding GitHub remote..."
git remote add origin https://github.com/oliviafoods/fraud-detection-app.git 2>/dev/null || \
git remote set-url origin https://github.com/oliviafoods/fraud-detection-app.git

# Set branch
git branch -M main

# Push
echo "🚀 Pushing to GitHub..."
echo ""
echo "⚠️  You will be prompted for your GitHub credentials:"
echo "   Username: oliviafoods"
echo "   Password: Use a Personal Access Token (not your GitHub password)"
echo ""
echo "To create a token: https://github.com/settings/tokens"
echo "Required scope: 'repo'"
echo ""

git push -u origin main

echo ""
echo "=========================================="
echo "✅ Successfully pushed to GitHub!"
echo "=========================================="
echo ""
echo "View your repository at:"
echo "https://github.com/oliviafoods/fraud-detection-app"
echo ""
echo "Next steps:"
echo "1. Visit the repository URL above"
echo "2. Add topics: flutter, android, fraud-detection, ai, openai, hindi"
echo "3. Add description: AI-powered fraud detection for senior citizens"
echo "4. Review README.md on GitHub"
echo ""
