#!/bin/bash
# Creates a new writeup or experiment entry and adds it to index.md

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Gather inputs ---
echo "Type: (w)riteup or (e)xperiment?"
read -r type_input

case "$type_input" in
  w|writeup)  TYPE="writeup";    DIR="writeups";;
  e|experiment) TYPE="experiment"; DIR="experiments";;
  *) echo "Invalid type. Use 'w' or 'e'."; exit 1;;
esac

echo "Title:"
read -r TITLE

echo "Filename (no extension, e.g. 'my-topic'):"
read -r FILENAME

# --- Derive values ---
DATE_DISPLAY=$(date "+%B %-d, %Y")    # e.g. April 4, 2026
DATE_SHORT=$(date "+%B %-d %Y")       # e.g. April 4 2026
FILEPATH="$REPO_DIR/$DIR/$FILENAME.md"

if [ -f "$FILEPATH" ]; then
  echo "Error: $FILEPATH already exists."
  exit 1
fi

# --- Create the file ---
cat > "$FILEPATH" << EOF
[← back](../index.html){.back}

# $TITLE

::: {.date}
$DATE_DISPLAY
:::


EOF

echo "Created $DIR/$FILENAME.md"

# --- Add link to index.md ---
if [ "$TYPE" = "writeup" ]; then
  SECTION="## Writeups"
else
  SECTION="## Experiments"
fi

LINK="- [$TITLE]($DIR/$FILENAME.html) — *$DATE_SHORT*"

# Insert the link as the last entry in the relevant section
# (right before the next ## heading or end of file)
python3 -c "
import re, sys

with open('$REPO_DIR/index.md', 'r') as f:
    content = f.read()

section = '''$SECTION'''
link = '''$LINK'''

# Find the section, then find the last list item in it
lines = content.split('\n')
in_section = False
insert_idx = None
for i, line in enumerate(lines):
    if line.strip() == section:
        in_section = True
        continue
    if in_section:
        if line.startswith('## '):
            # hit next section, insert before blank lines preceding it
            insert_idx = i
            while insert_idx > 0 and lines[insert_idx - 1].strip() == '':
                insert_idx -= 1
            break
        if line.startswith('- '):
            insert_idx = i + 1  # after the last list item found so far

if insert_idx is None:
    print('Could not find section in index.md', file=sys.stderr)
    sys.exit(1)

lines.insert(insert_idx, link)

with open('$REPO_DIR/index.md', 'w') as f:
    f.write('\n'.join(lines))
"

echo "Added link to index.md under '$SECTION'"
echo "Done! Open $DIR/$FILENAME.md and start writing."
