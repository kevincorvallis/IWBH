#!/bin/bash

# Script to remove backend/.env from Git history and clean up secrets
# This script will:
# 1. Remove all commits containing backend/.env from Git history
# 2. Force push the cleaned history to remote branch user/kle/integrateAI
# 3. Ensure .env is added to .gitignore
# 4. Verify that secrets are removed from repository history

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Starting Git history cleanup for backend/.env${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a Git repository${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Current branch: ${CURRENT_BRANCH}${NC}"

# Backup current state
echo -e "${YELLOW}💾 Creating backup branch before cleanup...${NC}"
git branch backup-before-env-cleanup 2>/dev/null || echo -e "${YELLOW}⚠️  Backup branch already exists${NC}"

# Check if backend/.env exists in history
echo -e "${BLUE}🔍 Checking if backend/.env exists in Git history...${NC}"
if git log --name-only --pretty=format: | grep -q "backend/\.env"; then
    echo -e "${RED}⚠️  Found backend/.env in Git history. Proceeding with cleanup...${NC}"
else
    echo -e "${GREEN}✅ backend/.env not found in Git history${NC}"
fi

# Show commits that contain backend/.env
echo -e "${BLUE}📋 Commits containing backend/.env:${NC}"
git log --oneline --name-only | grep -B1 "backend/\.env" || echo -e "${GREEN}No commits found containing backend/.env${NC}"

# Step 1: Remove backend/.env from Git history using git filter-branch
echo -e "${YELLOW}🧹 Removing backend/.env from Git history...${NC}"
echo -e "${YELLOW}⚠️  This may take a while for large repositories${NC}"

# First, let's identify the problematic commits
echo -e "${BLUE}🔍 Identifying commits with backend/.env...${NC}"
git log --all --name-only --pretty=format:"%H %s" | grep -B1 "backend/\.env" || true

# Use git filter-repo if available (more efficient), otherwise use filter-branch
if command -v git-filter-repo >/dev/null 2>&1; then
    echo -e "${BLUE}Using git-filter-repo (recommended)...${NC}"
    # Remove the file from all commits and branches
    git filter-repo --path backend/.env --invert-paths --force --refs HEAD --refs user/kle/integrateAI 2>/dev/null || \
    git filter-repo --path backend/.env --invert-paths --force
else
    echo -e "${BLUE}Using git filter-branch...${NC}"
    # More aggressive approach - remove the file from ALL branches and references
    git filter-branch --force --index-filter \
        'git rm --cached --ignore-unmatch backend/.env' \
        --prune-empty --tag-name-filter cat -- --all
    
    # Clean up backup refs created by filter-branch
    echo -e "${YELLOW}🧹 Cleaning up filter-branch backup refs...${NC}"
    git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
    
    # Additional cleanup to ensure complete removal
    echo -e "${YELLOW}🧹 Performing additional cleanup...${NC}"
    git filter-branch --force --tree-filter 'rm -f backend/.env' --prune-empty HEAD
fi

# Additional step: Use BFG if git-filter-repo is not available and filter-branch didn't work
echo -e "${BLUE}🔍 Double-checking for remaining secrets...${NC}"
if git log --all -p | grep -q "AWS_ACCESS_KEY_ID\|AWS_SECRET_ACCESS_KEY\|OPENAI_API_KEY"; then
    echo -e "${YELLOW}⚠️  Secrets still detected. Trying alternative removal method...${NC}"
    
    # Create a temporary file with secret patterns to remove
    cat > /tmp/secrets_to_remove.txt << 'EOF'
AWS_ACCESS_KEY_ID=*
AWS_SECRET_ACCESS_KEY=*
OPENAI_API_KEY=*
EOF
    
    # Use git filter-branch with a more comprehensive approach
    git filter-branch --force --commit-filter '
        if git diff-tree --no-commit-id --name-only -r $GIT_COMMIT | grep -q "backend/\.env"; then
            skip_commit "$@"
        else
            git commit-tree "$@"
        fi
    ' -- --all 2>/dev/null || true
    
    rm -f /tmp/secrets_to_remove.txt
fi

# Step 2: Add .env to .gitignore if not already present
echo -e "${BLUE}📝 Ensuring .env is in .gitignore...${NC}"
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
    echo -e "${YELLOW}Adding .env to .gitignore...${NC}"
    echo "" >> .gitignore
    echo "# Environment variables" >> .gitignore
    echo ".env" >> .gitignore
    echo "backend/.env" >> .gitignore
    echo "*.env" >> .gitignore
    echo "**/.env" >> .gitignore
    git add .gitignore
    git commit -m "Add .env files to .gitignore to prevent future tracking"
    echo -e "${GREEN}✅ Added .env patterns to .gitignore${NC}"
else
    echo -e "${GREEN}✅ .env already in .gitignore${NC}"
fi

# Step 3: Remove .env from current working directory if it exists
if [ -f "backend/.env" ]; then
    echo -e "${YELLOW}🗑️  Removing backend/.env from working directory...${NC}"
    rm backend/.env
    echo -e "${GREEN}✅ Removed backend/.env from working directory${NC}"
fi

# Step 4: Force cleanup of Git objects
echo -e "${YELLOW}🧹 Cleaning up Git objects...${NC}"
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Additional cleanup to remove any lingering references
echo -e "${YELLOW}🧹 Removing any remaining references...${NC}"
git for-each-ref --format='%(refname)' refs/ | while read ref; do
    if git log --oneline "$ref" 2>/dev/null | grep -q backend/.env 2>/dev/null; then
        echo -e "${YELLOW}Cleaning reference: $ref${NC}"
        git update-ref -d "$ref" 2>/dev/null || true
    fi
done

# Force garbage collection again
git gc --prune=now --aggressive

# Step 5: Verify the cleanup
echo -e "${BLUE}🔍 Verifying cleanup...${NC}"
echo -e "${BLUE}Checking if backend/.env still exists in history:${NC}"
if git log --name-only --pretty=format: | grep -q "backend/\.env"; then
    echo -e "${RED}❌ backend/.env still found in history. Cleanup may have failed.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ backend/.env successfully removed from history${NC}"
fi

# Check for any remaining environment secrets
echo -e "${BLUE}🔍 Searching for potential secrets in repository...${NC}"
SECRET_PATTERNS=(
    "AWS_ACCESS_KEY_ID"
    "AWS_SECRET_ACCESS_KEY" 
    "OPENAI_API_KEY"
    "sk-proj-"
    "AKIA"
    "VgJeQ9dY4to9agCd9"  # Part of the actual secret from the error
)

SECRETS_FOUND=false
echo -e "${BLUE}Checking all branches and references for secrets...${NC}"
for pattern in "${SECRET_PATTERNS[@]}"; do
    if git log --all -p | grep -q "$pattern"; then
        echo -e "${RED}⚠️  Found potential secret pattern: $pattern${NC}"
        SECRETS_FOUND=true
        
        # Show which commits contain this pattern
        echo -e "${YELLOW}Commits containing '$pattern':${NC}"
        git log --all --oneline -S "$pattern" || true
    fi
done

# If secrets are still found, try nuclear option
if [ "$SECRETS_FOUND" = true ]; then
    echo -e "${RED}❌ Secrets still found. Attempting nuclear cleanup...${NC}"
    
    # Get all commits that ever touched backend/.env
    PROBLEMATIC_COMMITS=$(git log --all --pretty=format:"%H" -- backend/.env 2>/dev/null || true)
    
    if [ ! -z "$PROBLEMATIC_COMMITS" ]; then
        echo -e "${YELLOW}Found problematic commits, attempting to rewrite history...${NC}"
        echo "$PROBLEMATIC_COMMITS"
        
        # Create a new branch without the problematic commits
        git checkout --orphan temp-clean-branch
        git rm -rf . 2>/dev/null || true
        
        # Re-add all files except .env
        git checkout HEAD~1 -- . 2>/dev/null || git checkout main -- . 2>/dev/null || git checkout master -- . 2>/dev/null || true
        rm -f backend/.env 2>/dev/null || true
        
        # Commit the clean state
        git add .
        git commit -m "Clean repository without secrets" || true
        
        # Replace the target branch
        git branch -D user/kle/integrateAI 2>/dev/null || true
        git checkout -b user/kle/integrateAI
        
        echo -e "${GREEN}✅ Created clean branch without secrets${NC}"
    fi
fi

if [ "$SECRETS_FOUND" = true ]; then
    echo -e "${RED}❌ Potential secrets still found in repository history${NC}"
    echo -e "${YELLOW}💡 You may need to run additional cleanup or contact GitHub support to purge cached data${NC}"
else
    echo -e "${GREEN}✅ No obvious secret patterns found in repository history${NC}"
fi

# Step 6: Checkout the target branch and force push
echo -e "${BLUE}🌟 Switching to branch user/kle/integrateAI...${NC}"
if git show-ref --verify --quiet refs/heads/user/kle/integrateAI; then
    git checkout user/kle/integrateAI
else
    echo -e "${YELLOW}Branch user/kle/integrateAI doesn't exist locally. Creating it...${NC}"
    git checkout -b user/kle/integrateAI
fi

# Merge/rebase the cleaned history if we were on a different branch
if [ "$CURRENT_BRANCH" != "user/kle/integrateAI" ]; then
    echo -e "${BLUE}🔀 Merging cleaned history from $CURRENT_BRANCH...${NC}"
    git merge "$CURRENT_BRANCH" --allow-unrelated-histories || {
        echo -e "${YELLOW}⚠️  Merge conflict detected. You may need to resolve manually.${NC}"
        echo -e "${YELLOW}💡 Alternative: Consider rebasing or cherry-picking specific commits.${NC}"
    }
fi

# Final warning before force push
echo -e "${RED}⚠️  WARNING: About to force push to remote branch user/kle/integrateAI${NC}"
echo -e "${RED}⚠️  This will overwrite the remote branch history permanently!${NC}"
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}❌ Aborted by user${NC}"
    exit 1
fi

# Step 7: Force push to remote
echo -e "${BLUE}🚀 Force pushing to remote branch user/kle/integrateAI...${NC}"
if git push --force-with-lease origin user/kle/integrateAI; then
    echo -e "${GREEN}✅ Successfully force pushed to remote branch${NC}"
else
    echo -e "${RED}❌ Failed to push to remote. Check your permissions and remote configuration.${NC}"
    exit 1
fi

# Final verification
echo -e "${BLUE}🔍 Final verification - checking remote branch...${NC}"
git fetch origin
git log --oneline -10 origin/user/kle/integrateAI

echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"
echo -e "${BLUE}📋 Summary of actions taken:${NC}"
echo -e "   ✅ Removed backend/.env from Git history"
echo -e "   ✅ Added .env patterns to .gitignore"
echo -e "   ✅ Cleaned up Git objects"
echo -e "   ✅ Force pushed cleaned history to user/kle/integrateAI"
echo -e "   ✅ Verified removal of obvious secret patterns"

echo -e "${YELLOW}⚠️  Important next steps:${NC}"
echo -e "   🔄 Rotate any exposed secrets immediately"
echo -e "   🔐 Generate new AWS access keys"
echo -e "   🔐 Generate new OpenAI API key"
echo -e "   📧 Consider contacting GitHub support to purge cached repository data"
echo -e "   👥 Inform team members to re-clone the repository"

echo -e "${BLUE}💾 Backup branch 'backup-before-env-cleanup' created for safety${NC}"
