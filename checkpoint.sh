#!/bin/bash
# Manual Checkpoint Creator for Entire
# Use this when not running in Claude Code

cd ~/.openfang

# Get checkpoint description
if [ -z "$1" ]; then
    echo "Usage: bash checkpoint.sh 'description of changes'"
    echo "Example: bash checkpoint.sh 'Added Telegram bot v2.0'"
    exit 1
fi

DESCRIPTION="$1"
CHECKPOINT_NAME="checkpoint-$(date +%Y%m%d-%H%M%S)"

echo "🎯 Creating checkpoint: $CHECKPOINT_NAME"
echo "   Description: $DESCRIPTION"
echo ""

# Stage all changes
git add -A

# Create commit with checkpoint marker
git commit -m "[$CHECKPOINT_NAME] $DESCRIPTION"

# Create tag for easy reference
git tag "$CHECKPOINT_NAME"

echo ""
echo "✅ Checkpoint created!"
echo ""
echo "📊 Current status:"
entire status
echo ""
echo "🏷️  Available checkpoints:"
git tag -l "checkpoint-*" | tail -5
echo ""
echo "🔄 To rewind to this checkpoint:"
echo "   git checkout $CHECKPOINT_NAME"
