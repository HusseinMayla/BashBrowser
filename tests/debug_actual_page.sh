#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/parser.sh"

if [ -f /tmp/bashbrowser_page ]; then
    echo "File size: $(wc -c < /tmp/bashbrowser_page) bytes"
    echo "=== Running Parser on /tmp/bashbrowser_page ==="
    parse_page "$(cat /tmp/bashbrowser_page)" | head -n 40
    echo "..."
    echo "=== Total lines parsed ==="
    parse_page "$(cat /tmp/bashbrowser_page)" | wc -l
else
    echo "/tmp/bashbrowser_page does not exist"
fi
