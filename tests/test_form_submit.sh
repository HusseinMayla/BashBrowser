#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/network.sh"
source "$BASE_DIR/src/parser.sh"
source "$BASE_DIR/src/renderer.sh"
source "$BASE_DIR/src/navigation.sh"
source "$BASE_DIR/src/browser_engine.sh"

echo "=== 1. Load UMS Login Page ==="
load_page "https://ums.usal.edu.lb/" false

echo "=== 2. Fill UserID ==="
handle_action "fill" "userId|1124171"

echo "=== 3. Press Submit Button ==="
handle_action "press" "Submit"

echo "=== 4. Post Submission State ==="
echo "Current URL: $current_url"
echo "Current Title: $current_title"
echo "Status Message: $browser_message"
echo "Render Output:"
render_page
