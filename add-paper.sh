#!/bin/bash
# Non-interactive paper entry creation.
# Usage: bash add-paper.sh <filename> <title>
# Example: bash add-paper.sh grpo "DeepSeekMath: Pushing the Limits of Mathematical Reasoning"

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

FILENAME="$1"
TITLE="$2"

if [ -z "$FILENAME" ] || [ -z "$TITLE" ]; then
  echo "Usage: bash add-paper.sh <filename> <title>"
  echo "Example: bash add-paper.sh grpo \"DeepSeekMath: Pushing the Limits\""
  exit 1
fi

DATE_DISPLAY=$(date "+%B %-d, %Y")
DATE_SHORT=$(date "+%B %-d %Y")
FILEPATH="$REPO_DIR/papers/$FILENAME.md"

if [ -f "$FILEPATH" ]; then
  echo "Error: $FILEPATH already exists."
  exit 1
fi

cat > "$FILEPATH" << EOF
[← back](../index.html){.back}

# $TITLE

::: {.date}
$DATE_DISPLAY
:::

**Authors:**

**Link:**

## Summary


## Key Ideas


## Strengths


## Weaknesses


## Relevance to Our Work


EOF

echo "Created papers/$FILENAME.md"

# Add link to index.md under ## Papers
LINK="- [$TITLE](papers/$FILENAME.html) — *$DATE_SHORT*"

python3 -c "
import sys

with open('$REPO_DIR/index.md', 'r') as f:
    content = f.read()

section = '## Papers'
link = '''$LINK'''

lines = content.split('\n')
in_section = False
insert_idx = None
for i, line in enumerate(lines):
    if line.strip() == section:
        in_section = True
        continue
    if in_section:
        if line.startswith('## '):
            insert_idx = i
            while insert_idx > 0 and lines[insert_idx - 1].strip() == '':
                insert_idx -= 1
            break
        if line.startswith('- '):
            insert_idx = i + 1

if insert_idx is None:
    print('Could not find ## Papers section in index.md', file=sys.stderr)
    sys.exit(1)

lines.insert(insert_idx, link)

with open('$REPO_DIR/index.md', 'w') as f:
    f.write('\n'.join(lines))
"

echo "Added link to index.md under '## Papers'"
echo "Done! papers/$FILENAME.md is ready."
