#!/bin/bash

# Comprehensive Integration & Regression Test Suite

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export BASE_DIR

echo "=== 1. Sourcing all modules ==="
source "$BASE_DIR/src/network.sh" || { echo "Failed to source network.sh"; exit 1; }
source "$BASE_DIR/src/navigation.sh" || { echo "Failed to source navigation.sh"; exit 1; }
source "$BASE_DIR/src/history.sh" || { echo "Failed to source history.sh"; exit 1; }
source "$BASE_DIR/src/bookmarks.sh" || { echo "Failed to source bookmarks.sh"; exit 1; }
source "$BASE_DIR/src/parser.sh" || { echo "Failed to source parser.sh"; exit 1; }
source "$BASE_DIR/src/renderer.sh" || { echo "Failed to source renderer.sh"; exit 1; }
source "$BASE_DIR/src/input.sh" || { echo "Failed to source input.sh"; exit 1; }
source "$BASE_DIR/src/browser_engine.sh" || { echo "Failed to source browser_engine.sh"; exit 1; }
echo "[PASS] All modules sourced successfully."

echo "=== 2. Testing History System ==="
history_add "https://example.com"
history_add "https://example.com/page1"
history_add "https://example.com/page2"

if [[ $(history_current) != "https://example.com/page2" ]]; then
    echo "[FAIL] history_current should be page2, got: $(history_current)"
    exit 1
fi

history_back
if [[ "$history_result" != "https://example.com/page1" ]]; then
    echo "[FAIL] history_back should be page1, got: $history_result"
    exit 1
fi

history_forward
if [[ "$history_result" != "https://example.com/page2" ]]; then
    echo "[FAIL] history_forward should be page2, got: $history_result"
    exit 1
fi

history_get 1
if [[ "$history_result" != "https://example.com" ]]; then
    echo "[FAIL] history_get 1 should be example.com, got: $history_result"
    exit 1
fi
echo "[PASS] History system working as expected."

echo "=== 3. Testing Bookmarks System ==="
rm -rf "$BASE_DIR/data/bookmarks"
bookmark_add "https://example.com" >/dev/null
bookmark_add "https://github.com" >/dev/null
bookmark_add "https://example.com" >/dev/null # duplicate test

bm1=$(bookmark_get 1)
bm2=$(bookmark_get 2)

if [[ "$bm1" != "https://example.com" || "$bm2" != "https://github.com" ]]; then
    echo "[FAIL] Bookmark get failed. bm1=$bm1, bm2=$bm2"
    exit 1
fi

bookmark_delete 1 >/dev/null
bm1_after=$(bookmark_get 1)
if [[ "$bm1_after" != "https://github.com" ]]; then
    echo "[FAIL] Bookmark delete failed. Remaining first item should be github, got: $bm1_after"
    exit 1
fi
echo "[PASS] Bookmarks system working as expected."

echo "=== 4. Testing URL Encoding & Resolution ==="
encoded=$(url_encode "hello world & foo=bar")
if [[ "$encoded" != *"hello%20world"* && "$encoded" != *"hello+world"* ]]; then
    echo "[FAIL] URL encode failed: $encoded"
    exit 1
fi

res1=$(resolve_url "https://example.com/dir/page.html" "/root.html")
res2=$(resolve_url "https://example.com/dir/page.html" "sub.html")
res3=$(resolve_url "https://example.com/dir/page.html" "../parent.html")

if [[ "$res1" != "https://example.com/root.html" ]]; then
    echo "[FAIL] resolve_url root-relative failed: $res1"
    exit 1
fi
if [[ "$res2" != "https://example.com/dir/sub.html" ]]; then
    echo "[FAIL] resolve_url relative failed: $res2"
    exit 1
fi
if [[ "$res3" != "https://example.com/parent.html" ]]; then
    echo "[FAIL] resolve_url parent failed: $res3"
    exit 1
fi
echo "[PASS] Navigation resolution working as expected."

echo "=== 5. Testing Parser on Sample HTML with Form ==="
sample_html='<!DOCTYPE html>
<html>
<head><title>Test Form Page</title></head>
<body>
    <h1>Welcome to Testing</h1>
    <p>This is a paragraph with <a href="/inline-link">an inline link</a>.</p>
    <form action="/login" method="post">
        <input type="hidden" name="csrf_token" value="secret123">
        <label for="username">Username:</label>
        <input type="text" id="username" name="user" value="admin">
        <button type="submit" id="btn_submit">Sign In</button>
    </form>
</body>
</html>'

adapter_parse_to_elements "$sample_html"

if [[ "$form_action" != "/login" || "$form_method" != "post" ]]; then
    echo "[FAIL] Form action/method detection failed: action=$form_action, method=$form_method"
    exit 1
fi

if [[ "${form_hidden_inputs[csrf_token]}" != "secret123" ]]; then
    echo "[FAIL] Hidden CSRF token not captured: ${form_hidden_inputs[csrf_token]}"
    exit 1
fi

if [[ "${#page_elements[@]}" -lt 4 ]]; then
    echo "[FAIL] Expected at least 4 page elements, found: ${#page_elements[@]}"
    exit 1
fi
echo "[PASS] Parser & Form state extraction working as expected."

echo "=== 6. Testing Input Parser ==="
test_input() {
    local cmd="$1"
    read_browser_input <<< "$cmd"
}

test_input "open https://example.com"
[[ "$action" == "open" && "$argument" == "https://example.com" ]] || { echo "[FAIL] input 'open' failed"; exit 1; }

test_input "42"
[[ "$action" == "click" && "$argument" == "42" ]] || { echo "[FAIL] input numeric link click failed"; exit 1; }

test_input "bm add"
[[ "$action" == "bookmark_add" ]] || { echo "[FAIL] input 'bm add' failed"; exit 1; }

test_input "bm 2"
[[ "$action" == "bookmark_open" && "$argument" == "2" ]] || { echo "[FAIL] input 'bm 2' failed"; exit 1; }

test_input "h"
[[ "$action" == "history" ]] || { echo "[FAIL] input 'h' failed"; exit 1; }

test_input "h 3"
[[ "$action" == "history_jump" && "$argument" == "3" ]] || { echo "[FAIL] input 'h 3' failed"; exit 1; }

test_input "fill username myuser"
[[ "$action" == "fill" && "$argument" == "username|myuser" ]] || { echo "[FAIL] input 'fill' failed"; exit 1; }

test_input "press"
[[ "$action" == "press" ]] || { echo "[FAIL] input 'press' failed"; exit 1; }

echo "[PASS] Input command parser working as expected."

echo ""
echo "=========================================="
echo ">>> ALL INTEGRATION TESTS PASSED (100%) <<<"
echo "=========================================="
