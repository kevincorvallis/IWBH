#!/bin/bash

# Nuclear option script to completely remove secrets from Git history
# This script will create a completely clean branch without any trace of the secrets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}🔥 NUCLEAR OPTION: Complete secret removal${NC}"
echo -e "${RED}⚠️  This will create a completely new history without the problematic commits${NC}"

# Confirm the nuclear option
read -p "Are you absolutely sure you want to proceed with the nuclear option? This will rewrite ALL history (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}❌ Aborted by user${NC}"
    exit 1
fi

# Get current branch for reference
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Current branch: ${CURRENT_BRANCH}${NC}"

# Create backup
echo -e "${YELLOW}💾 Creating nuclear-backup branch...${NC}"
git branch nuclear-backup-$(date +%Y%m%d-%H%M%S) 2>/dev/null || true

# Get the latest commit that doesn't contain secrets
echo -e "${BLUE}🔍 Finding clean commits...${NC}"

# Method 1: Create orphan branch and rebuild history
echo -e "${YELLOW}🔥 Creating orphan branch without history...${NC}"
git checkout --orphan clean-temp-branch

# Remove all files
git rm -rf . 2>/dev/null || true

# Get all files from the latest state, excluding .env files
echo -e "${BLUE}📁 Restoring files without secrets...${NC}"
git checkout HEAD -- . 2>/dev/null || git checkout $CURRENT_BRANCH -- . 2>/dev/null || true

# Remove any .env files
find . -name "*.env" -type f -delete 2>/dev/null || true
find . -name ".env" -type f -delete 2>/dev/null || true
rm -f backend/.env 2>/dev/null || true

# Ensure .gitignore includes .env patterns
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
    echo -e "${YELLOW}Adding .env to .gitignore...${NC}"
    echo "" >> .gitignore
    echo "# Environment variables" >> .gitignore
    echo ".env" >> .gitignore
    echo "backend/.env" >> .gitignore
    echo "*.env" >> .gitignore
    echo "**/.env" >> .gitignore
fi

# Stage all clean files
git add .

# Commit the clean state
git commit -m "Clean repository without secrets

This commit removes all previous history containing environment secrets.
All .env files have been removed and added to .gitignore.

Previous history backed up to nuclear-backup branch."

# Replace the target branch
echo -e "${YELLOW}🔄 Replacing user/kle/integrateAI branch...${NC}"
git branch -D user/kle/integrateAI 2>/dev/null || true
git checkout -b user/kle/integrateAI

# Clean up temporary branch
git branch -D clean-temp-branch 2>/dev/null || true

# Force cleanup
echo -e "${YELLOW}🧹 Final cleanup...${NC}"
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Verify no secrets remain
echo -e "${BLUE}🔍 Final verification...${NC}"
SECRET_PATTERNS=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "OPENAI_API_KEY" "sk-proj-" "AKIA" "VgJeQ9dY4to9agCd9")

SECRETS_FOUND=false
for pattern in "${SECRET_PATTERNS[@]}"; do
    if git log --all -p | grep -q "$pattern"; then
        echo -e "${RED}❌ Still found secret pattern: $pattern${NC}"
        SECRETS_FOUND=true
    fi
done

if [ "$SECRETS_FOUND" = false ]; then
    echo -e "${GREEN}✅ No secrets found in new history${NC}"
else
    echo -e "${RED}❌ Nuclear option failed - secrets still present${NC}"
    exit 1
fi

# Final warning before force push
echo -e "${RED}⚠️  WARNING: About to force push completely new history to user/kle/integrateAI${NC}"
echo -e "${RED}⚠️  This will PERMANENTLY overwrite all remote history!${NC}"
read -p "Final confirmation - proceed with force push? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}❌ Aborted by user${NC}"
    exit 1
fi

# Force push the clean branch
echo -e "${BLUE}🚀 Force pushing clean history...${NC}"
git push --force origin user/kle/integrateAI

echo -e "${GREEN}🎉 Nuclear cleanup completed!${NC}"
echo -e "${BLUE}📋 What was done:${NC}"
echo -e "   🔥 Created completely new Git history"
echo -e "   🗑️  Removed all traces of secrets"
echo -e "   📁 Restored all files except .env"
echo -e "   🚫 Added comprehensive .env patterns to .gitignore"
echo -e "   🚀 Force pushed clean history to remote"

echo -e "${YELLOW}⚠️  CRITICAL: You MUST now:${NC}"
echo -e "   🔄 Rotate ALL exposed secrets immediately"
echo -e "   🔐 Generate new AWS access keys"
echo -e "   🔐 Generate new OpenAI API key"
echo -e "   👥 Tell all team members to delete and re-clone the repository"
echo -e "   📧 Consider contacting GitHub support about cached data"
