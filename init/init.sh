#!/bin/bash

# Source all components
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export BASE_DIR

source "$BASE_DIR/src/network.sh"
source "$BASE_DIR/src/navigation.sh"
source "$BASE_DIR/src/history.sh"
source "$BASE_DIR/src/bookmarks.sh"
source "$BASE_DIR/src/parser.sh"
source "$BASE_DIR/src/renderer.sh"
source "$BASE_DIR/src/input.sh"
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
│ Commands: open <url> | <n> | fill <id> <val> | press | search <q> | reload  │
│ Bookmarks: bm add | bm (list) | bm <n> (open) | bm del <n>                  │
│ History:   h (list) | h <n> (jump) | back (b) | forward (f)                 │
│ Other:     help (?) | quit (q)                                              │
└─────────────────────────────────────────────────────────────────────────────┘
EOF
}

main() {
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
