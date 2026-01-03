#!/bin/bash

# IMPORTANT: This script removes sensitive Firebase files from Git history
# Run this to clean up the repository history

echo "⚠️  WARNING: This will rewrite Git history!"
echo "This removes Firebase config files from all previous commits."
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo "Removing sensitive files from Git history..."

# Remove google-services.json
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch android/app/google-services.json" \
  --prune-empty --tag-name-filter cat -- --all

# Remove firebase_options.dart
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch lib/firebase_options.dart" \
  --prune-empty --tag-name-filter cat -- --all

# Remove firebase.json
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch firebase.json" \
  --prune-empty --tag-name-filter cat -- --all

echo "✅ Files removed from history!"
echo "Now run: git push --force --all"
echo "⚠️  Warning: Force push will rewrite remote history!"
