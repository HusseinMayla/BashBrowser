#!/bin/bash

# Source all components
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/network.sh"
source "$BASE_DIR/src/parser.sh"
source "$BASE_DIR/src/renderer.sh"
source "$BASE_DIR/src/input.sh"
source "$BASE_DIR/src/navigation.sh"
source "$BASE_DIR/src/browser_engine.sh"

render_ui_chrome() {
    local url_display="${current_url:-about:blank}"
    local title_display="${current_title:-[No Page Loaded]}"

    cat <<EOF
┌─────────────────────────────────────────────────────────────────────────────┐
│ Bash Browser                                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ URL:    $url_display
│ Title:  $title_display
│ Status: ${browser_message:-Ready}
├─────────────────────────────────────────────────────────────────────────────┤
│ Commands: open <url> | <n> | fill <id> <val> | press <btn> | reload | search│
│ Nav:      back (b) | forward (f) | reload (r) | help (?) | quit (q)          │
└─────────────────────────────────────────────────────────────────────────────┘
EOF
}

main() {
    # Default start page if desired
    local initial_url="${1:-https://example.com}"
    load_page "$initial_url" "true"

    while true; do
        # 1. Render web page content using renderer.sh
        render_page

        # 2. Render UI chrome / status bar
        echo ""
        render_ui_chrome
        echo ""

        # 3. Read user command using input.sh
        read_browser_input

        # 4. Process command in the backend engine
        handle_action "$action" "$argument"
    done
}

main "$@"
