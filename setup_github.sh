#!/bin/bash

# GitHub Setup & Push Script for Fraud Detection App
# This script helps you push the code to GitHub

set -e  # Exit on error

echo "🚀 Fraud Detection App - GitHub Push Helper"
echo "=========================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first:"
    echo "   - Ubuntu/Debian: sudo apt-get install git"
    echo "   - Mac: brew install git"
    echo "   - Windows: Download from https://git-scm.com"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "fraud_detection_app/pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from /app directory"
    echo "   Current directory: $(pwd)"
    exit 1
fi

echo "✅ Git is installed"
echo ""

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already initialized"
fi
echo ""

# Create .gitignore if needed
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating main .gitignore..."
    cat > .gitignore << 'EOF'
# Node modules
node_modules/

# Python
__pycache__/
*.pyc
.venv/
venv/

# IDEs
.vscode/
.idea/
*.swp

# OS
.DS_Store

# Logs
*.log
logs/

# Environment files (IMPORTANT: Contains secrets)
.env
*.env
!.env.example

# Database
*.db
*.sqlite3
EOF
    echo "✅ Created .gitignore"
else
    echo "✅ .gitignore already exists"
fi
echo ""

# Configure git user if not configured
if [ -z "$(git config user.name)" ]; then
    echo "⚙️  Git user not configured. Let's set it up:"
    read -p "Enter your name: " git_name
    read -p "Enter your email: " git_email
    git config user.name "$git_name"
    git config user.email "$git_email"
    echo "✅ Git user configured"
else
    echo "✅ Git user already configured as: $(git config user.name)"
fi
echo ""

# Create .env.example (without secrets)
echo "📝 Creating .env.example (template without secrets)..."
cat > backend/.env.example << 'EOF'
# MongoDB Configuration
MONGO_URL="mongodb://localhost:27017"
DB_NAME="fraud_detection_db"

# CORS Configuration
CORS_ORIGINS="*"

# OpenAI API Key (Get from: https://platform.openai.com/api-keys)
# Or use Emergent LLM Key for testing
EMERGENT_LLM_KEY=your-key-here
EOF
echo "✅ Created backend/.env.example"
echo ""

# Add all files
echo "📦 Staging files for commit..."
git add .
echo "✅ Files staged"
echo ""

# Show what will be committed
echo "📋 Files to be committed:"
git status --short
echo ""

# Commit
echo "💾 Creating initial commit..."
if git diff-index --quiet HEAD --; then
    echo "ℹ️  No changes to commit"
else
    git commit -m "Initial commit: Fraud Detection System for Senior Citizens

- Flutter mobile app with senior-friendly UI
- Kotlin native layer for call detection
- FastAPI backend with AI fraud analysis
- OpenAI Whisper + GPT-4 integration
- Hindi language support
- Complete documentation"
    echo "✅ Committed successfully"
fi
echo ""

# Instructions for GitHub
echo "=========================================="
echo "📚 Next Steps - Push to GitHub:"
echo "=========================================="
echo ""
echo "1️⃣  Create a new repository on GitHub:"
echo "   - Go to: https://github.com/new"
echo "   - Repository name: fraud-detection-app"
echo "   - Description: AI-powered fraud detection for senior citizens"
echo "   - Make it Public or Private (your choice)"
echo "   - DO NOT initialize with README (we already have one)"
echo "   - Click 'Create repository'"
echo ""
echo "2️⃣  Copy your repository URL from GitHub"
echo "   It will look like: https://github.com/YOUR_USERNAME/fraud-detection-app.git"
echo ""
echo "3️⃣  Run these commands (replace YOUR_USERNAME):"
echo ""
echo "   git remote add origin https://github.com/YOUR_USERNAME/fraud-detection-app.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "Or if you want to use SSH:"
echo "   git remote add origin git@github.com:YOUR_USERNAME/fraud-detection-app.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "=========================================="
echo "✅ Your code is ready to push to GitHub!"
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT: Make sure .env files are NOT pushed (they contain secrets)"
echo "   Check .gitignore includes: *.env"
echo ""
