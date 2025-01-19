#!/bin/bash

# Define the base directory
BASE_DIR="$HOME"

# Ensure a directory name is provided
if [ -z "$1" ]; then
    echo "Error: No directory name provided."
    echo "Usage: $0 directory-name"
    exit 1
fi

# Construct the full directory path by prepending BASE_DIR
TARGET_DIR="${BASE_DIR}/$1"

# Check if the directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Navigate to the target directory
cd "$TARGET_DIR" || exit

# Check if the directory is a Git repository
if [ ! -d ".git" ]; then
    echo "Error: '$TARGET_DIR' is not a Git repository."
    exit 1
fi

# Detect the default branch (master or main)
DEFAULT_BRANCH=$(git remote show origin | awk '/HEAD branch/ {print $NF}')

if [ -z "$DEFAULT_BRANCH" ]; then
    echo "Error: Unable to detect the default branch for the repository."
    exit 1
fi

# Pull the latest changes from the detected default branch
echo "Pulling the latest changes for '$DEFAULT_BRANCH' branch in '$TARGET_DIR'..."
git checkout "$DEFAULT_BRANCH"
PULL_OUTPUT=$(git pull origin "$DEFAULT_BRANCH" 2>&1)
PULL_EXIT_CODE=$?

# Handle git pull result
if [ $PULL_EXIT_CODE -eq 0 ]; then
    if [[ "$PULL_OUTPUT" == *"Already up to date."* ]]; then
        echo "The repository is already up to date."
    else
        echo "Successfully pulled the latest changes."
    fi
else
    echo "Failed to pull the latest changes."
    echo "Error: $PULL_OUTPUT"
    exit 1
fi
