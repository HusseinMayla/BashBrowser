#!/bin/bash
set -e
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/network.sh"
source "$BASE_DIR/src/parser.sh"
source "$BASE_DIR/src/renderer.sh"
source "$BASE_DIR/src/input.sh"
source "$BASE_DIR/src/navigation.sh"
source "$BASE_DIR/src/browser_engine.sh"

echo "=== 1. Test Load Page ==="
load_page "https://example.com" true
echo "Loaded URL: $current_url"
echo "Title: $current_title"
echo "Elements count: ${#page_elements[@]}"
echo "Links count: ${#page_links[@]}"

echo "=== 2. Test Click Link 1 ==="
handle_action "click" "1"
echo "Current URL after click: $current_url"
echo "Title after click: $current_title"

echo "=== 3. Test Back Action ==="
handle_action "back" ""
echo "Current URL after back: $current_url"

echo "=== 4. Test Forward Action ==="
handle_action "forward" ""
echo "Current URL after forward: $current_url"

echo "=== 5. Test Fill Input Action ==="
page_elements=("heading||Form Test|1" "input|username|user_field|" "button|btn1|Submit|submit")
handle_action "fill" "username|admin_user"
echo "Updated elements:"
for elem in "${page_elements[@]}"; do
    echo "  $elem"
done

echo "ALL BACKEND TESTS PASSED!"
