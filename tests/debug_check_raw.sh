#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/parser.sh"

echo "=== Searching course/view.php in raw /tmp/bashbrowser_page ==="
grep -o 'course/view.php[^"'\'' ]*' /tmp/bashbrowser_page | head -n 10

echo "=== Checking block_myoverview in raw page ==="
grep -n 'block_myoverview' /tmp/bashbrowser_page || echo "NOT FOUND"

echo "=== Checking Recently accessed courses in raw page ==="
grep -n 'Recently accessed' /tmp/bashbrowser_page || echo "NOT FOUND"
