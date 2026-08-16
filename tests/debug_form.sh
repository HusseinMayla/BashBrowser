#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/network.sh"
source "$BASE_DIR/src/parser.sh"
source "$BASE_DIR/src/renderer.sh"
source "$BASE_DIR/src/navigation.sh"
source "$BASE_DIR/src/browser_engine.sh"

load_page "https://ums.usal.edu.lb/" false
handle_action "fill" "userId|1124171"

echo "=== Form Action: $form_action ==="
echo "=== Form Method: $form_method ==="
echo "=== Hidden Inputs (${#form_hidden_inputs[@]}): ==="
for k in "${!form_hidden_inputs[@]}"; do
    echo "  $k = ${form_hidden_inputs[$k]}"
done

echo "=== Page Elements (${#page_elements[@]}): ==="
for elem in "${page_elements[@]}"; do
    echo "  $elem"
done
