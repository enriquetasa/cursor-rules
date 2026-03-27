#!/bin/bash

# Define paths
SOURCE_REPO="$HOME/Code/cursor-rules"
TARGET_DIR="$HOME/.cursor"
FOLDERS=("rules" "agents" "commands" "skills")

echo "🚀 Starting Cursor Global Rules setup..."

# 1. Check if source repository exists
if [ ! -d "$SOURCE_REPO" ]; then
  echo "❌ Error: Source directory $SOURCE_REPO not found."
  exit 1
fi

# 2. Ensure target directories exist
echo "📂 Creating ~/.cursor structure..."
for folder in "${FOLDERS[@]}"; do
  mkdir -p "$TARGET_DIR/$folder"
done

# 3. Create Symlinks
echo "🔗 Symlinking files..."
for folder in "${FOLDERS[@]}"; do
  SRC_PATH="$SOURCE_REPO/$folder"

  # Check if the folder exists in your repo
  if [ -d "$SRC_PATH" ]; then
    # Loop through files in the source folder
    for file in "$SRC_PATH"/*; do
      # Skip if folder is empty (shell glob star stays as '*')
      [ -e "$file" ] || continue

      FILENAME=$(basename "$file")
      DEST_FILE="$TARGET_DIR/$folder/$FILENAME"

      # Create symbolic link (-s), overwrite if exists (-f)
      ln -sf "$file" "$DEST_FILE"
      echo "   ✅ Linked: $folder/$FILENAME"
    done
  else
    echo "   ⚠️  Skipping: Folder '$folder' not found in your repository."
  fi
done

echo "🎉 Setup complete! Restart Cursor to ensure all rules are indexed."
