#!/bin/bash

# Browser Engine & State Management

declare -a page_elements=()
declare -a page_links=()
current_url=""
current_title=""
browser_message=""

declare -A form_hidden_inputs=()
form_action=""
form_method="post"

# Adapt parse_page tab-separated output to renderer page_elements (type|id|content|extra)
adapter_parse_to_elements() {
    local html="$1"
    page_elements=()
    page_links=()
    declare -gA form_hidden_inputs=()

    # Extract form action and method if present
    form_action=$(printf '%s\n' "$html" | grep -oiP '<form[^>]*action="?\K[^" >]+' | head -n 1)
    form_method=$(printf '%s\n' "$html" | grep -oiP '<form[^>]*method="?\K[^" >]+' | head -n 1)
    [[ -z "$form_method" ]] && form_method="post"
    [[ -z "$form_action" ]] && form_action="$current_url"

    local parsed_output
    parsed_output=$(parse_page "$html")

    while IFS=$'\t' read -r type rest || [[ -n "$type" ]]; do
        [[ -z "$type" ]] && continue

        case "$type" in
            heading)
                local level="" text=""
                local f1 f2
                IFS=$'\t' read -r f1 f2 <<< "$rest"
                [[ "$f1" =~ ^level=(.*)$ ]] && level="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_elements+=("heading||${text}|${level}")
                ;;

            text)
                local text=""
                [[ "$rest" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_elements+=("text||${text}|")
                ;;

            link)
                local href="" text=""
                local f1 f2
                IFS=$'\t' read -r f1 f2 <<< "$rest"
                [[ "$f1" =~ ^href=(.*)$ ]] && href="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_links+=("$href")
                page_elements+=("link||${text}|${href}")
                ;;

            button)
                local bid="" btype="" text=""
                local f1 f2 f3
                IFS=$'\t' read -r f1 f2 f3 <<< "$rest"
                [[ "$f1" =~ ^id=(.*)$ ]] && bid="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^type=(.*)$ ]] && btype="${BASH_REMATCH[1]}"
                [[ "$f3" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_elements+=("button|${bid}|${text}|${btype}")
                ;;

            input)
                local iid="" iname="" itype="" ival=""
                local f1 f2 f3 f4
                IFS=$'\t' read -r f1 f2 f3 f4 <<< "$rest"
                [[ "$f1" =~ ^id=(.*)$ ]] && iid="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^name=(.*)$ ]] && iname="${BASH_REMATCH[1]}"
                [[ "$f3" =~ ^type=(.*)$ ]] && itype="${BASH_REMATCH[1]}"
                [[ "$f4" =~ ^value=(.*)$ ]] && ival="${BASH_REMATCH[1]}"

                local field_id="${iid:-$iname}"
                if [[ "$itype" == "hidden" ]]; then
                    [[ -n "$field_id" ]] && form_hidden_inputs["$field_id"]="$ival"
                else
                    page_elements+=("input|${field_id}|${iname}|${ival}")
                fi
                ;;

            label)
                local lfor="" text=""
                local f1 f2
                IFS=$'\t' read -r f1 f2 <<< "$rest"
                [[ "$f1" =~ ^for=(.*)$ ]] && lfor="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_elements+=("label|${lfor}|${text}|")
                ;;

            br)
                page_elements+=("br|||")
                ;;
        esac
    done <<< "$parsed_output"
}

# Fetch, parse, and populate page state
load_page() {
    local target_url="$1"
    local push_to_history="${2:-true}"

    if [[ -z "$target_url" ]]; then
        browser_message="No URL specified."
        return 1
    fi

    # Prepend https:// if protocol is missing
    if [[ "$target_url" != http://* && "$target_url" != https://* ]]; then
        target_url="https://${target_url}"
    fi

    browser_message="Loading ${target_url}..."
    local html
    html=$(fetch_page "$target_url")
    local fetch_status=$?

    if [[ $fetch_status -ne 0 || -z "$html" ]]; then
        local err_reason="Network error or empty response"
        [[ -f /tmp/bashbrowser_error ]] && err_reason=$(cat /tmp/bashbrowser_error)
        browser_message="Failed to load page: ${err_reason}"
        return 1
    fi

    if [[ -f /tmp/bashbrowser_effective_url ]]; then
        local eff_url
        eff_url=$(cat /tmp/bashbrowser_effective_url)
        [[ -n "$eff_url" ]] && target_url="$eff_url"
    fi

    current_url="$target_url"

    if [[ "$push_to_history" == "true" ]]; then
        history_add "$current_url"
    fi

    current_title=$(get_title "$html")
    [[ -z "$current_title" ]] && current_title="[No Title]"

    adapter_parse_to_elements "$html"
    browser_message="Page loaded successfully (${#page_elements[@]} elements)."
    return 0
}

submit_form() {
    local target_url="$current_url"
    if [[ -n "$form_action" ]]; then
        target_url=$(resolve_url "$current_url" "$form_action")
    fi

    # Build URL-encoded post parameters from visible + hidden inputs
    local post_data=""

    # 1. Hidden inputs (CSRF tokens, etc.)
    for key in "${!form_hidden_inputs[@]}"; do
        local val="${form_hidden_inputs[$key]}"
        local enc_key enc_val
        enc_key=$(url_encode "$key")
        enc_val=$(url_encode "$val")
        [[ -n "$post_data" ]] && post_data="${post_data}&"
        post_data="${post_data}${enc_key}=${enc_val}"
    done

    # 2. Visible input fields
    for element in "${page_elements[@]}"; do
        IFS='|' read -r etype eid econtent eextra <<< "$element"
        if [[ "$etype" == "input" ]]; then
            local field_name="${econtent:-$eid}"
            local field_val="$eextra"
            if [[ -n "$field_name" ]]; then
                local enc_key enc_val
                enc_key=$(url_encode "$field_name")
                enc_val=$(url_encode "$field_val")
                [[ -n "$post_data" ]] && post_data="${post_data}&"
                post_data="${post_data}${enc_key}=${enc_val}"
            fi
        fi
    done

    browser_message="Submitting form to ${target_url}..."
    local html
    if [[ "${form_method,,}" == "get" ]]; then
        html=$(fetch_page "${target_url}?${post_data}")
    else
        html=$(post_page "$target_url" "$post_data" "$current_url")
    fi
    local fetch_status=$?

    if [[ $fetch_status -ne 0 || -z "$html" ]]; then
        local err_reason="Submission rejected or timeout"
        [[ -f /tmp/bashbrowser_error ]] && err_reason=$(cat /tmp/bashbrowser_error)
        browser_message="Form submission failed: ${err_reason}"
        return 1
    fi

    if [[ -f /tmp/bashbrowser_effective_url ]]; then
        local eff_url
        eff_url=$(cat /tmp/bashbrowser_effective_url)
        [[ -n "$eff_url" ]] && current_url="$eff_url"
    else
        current_url="$target_url"
    fi

    history_add "$current_url"

    current_title=$(get_title "$html")
    [[ -z "$current_title" ]] && current_title="[No Title]"

    adapter_parse_to_elements "$html"
    browser_message="Form submitted successfully (${#page_elements[@]} elements)."
    return 0
}

# Dispatch user actions
handle_action() {
    local act="$1"
    local arg="$2"

    browser_message=""

    case "$act" in
        open)
            if [[ -z "$arg" ]]; then
                browser_message="Usage: open <url>"
                return 1
            fi
            load_page "$arg" "true"
            ;;

        search)
            if [[ -z "$arg" ]]; then
                browser_message="Usage: search <keyword>"
                return 1
            fi
            local encoded
            encoded=$(url_encode "$arg")
            browser_message="Searching for '$arg'..."
            local html
            html=$(post_page "https://lite.duckduckgo.com/lite/" "q=${encoded}")
            local fetch_status=$?

            if [[ $fetch_status -ne 0 || -z "$html" ]]; then
                local err_reason="Search request failed"
                [[ -f /tmp/bashbrowser_error ]] && err_reason=$(cat /tmp/bashbrowser_error)
                browser_message="Search failed: ${err_reason}"
                return 1
            fi

            current_url="https://lite.duckduckgo.com/lite/?q=${encoded}"
            history_add "$current_url"
            current_title=$(get_title "$html")
            [[ -z "$current_title" || "$current_title" == "[No Title]" ]] && current_title="Search: $arg"

            adapter_parse_to_elements "$html"
            browser_message="Search results for '${arg}' (${#page_elements[@]} elements)."
            ;;

        click)
            if [[ -z "$arg" ]]; then
                browser_message="Usage: click <link_number>"
                return 1
            fi

            if ! [[ "$arg" =~ ^[0-9]+$ ]]; then
                browser_message="Invalid link number: $arg"
                return 1
            fi

            local idx=$((arg - 1))
            if (( idx < 0 || idx >= ${#page_links[@]} )); then
                browser_message="Link index [$arg] out of range (1-${#page_links[@]})."
                return 1
            fi

            local raw_href="${page_links[$idx]}"
            local resolved
            resolved=$(resolve_url "$current_url" "$raw_href")
            load_page "$resolved" "true"
            ;;

        back)
            if history_back; then
                load_page "$history_result" "false"
            else
                browser_message="No previous page in history."
            fi
            ;;

        forward)
            if history_forward; then
                load_page "$history_result" "false"
            else
                browser_message="No forward page in history."
            fi
            ;;

        history)
            echo ""
            echo "── Visited History ──"
            history_list
            echo "─────────────────────"
            read -r -p "Press Enter to return to browser..." _
            ;;

        history_jump)
            if history_get "$arg"; then
                load_page "$history_result" "false"
            else
                browser_message="Invalid history index: $arg"
            fi
            ;;

        bookmark_add)
            if [[ -z "$current_url" ]]; then
                browser_message="No active page to bookmark."
            else
                local msg
                msg=$(bookmark_add "$current_url")
                browser_message="${msg:-Bookmark added: $current_url}"
            fi
            ;;

        bookmark_list)
            echo ""
            echo "── Saved Bookmarks ──"
            bookmark_list
            echo "─────────────────────"
            read -r -p "Press Enter to return to browser..." _
            ;;

        bookmark_open)
            local bm_url
            if bm_url=$(bookmark_get "$arg"); then
                load_page "$bm_url" "true"
            else
                browser_message="Bookmark #$arg not found."
            fi
            ;;

        bookmark_del)
            local del_msg
            if del_msg=$(bookmark_delete "$arg"); then
                browser_message="$del_msg"
            else
                browser_message="Failed to delete bookmark #$arg"
            fi
            ;;

        fill)
            # arg format: field_identifier|value
            IFS='|' read -r field_id val <<< "$arg"
            local matched=0
            local new_elements=()

            for element in "${page_elements[@]}"; do
                IFS='|' read -r etype eid econtent eextra <<< "$element"
                if [[ "$etype" == "input" ]] && [[ "$eid" == "$field_id" || "$econtent" == "$field_id" ]]; then
                    new_elements+=("input|${eid}|${econtent}|${val}")
                    matched=1
                else
                    new_elements+=("$element")
                fi
            done

            if (( matched == 1 )); then
                page_elements=("${new_elements[@]}")
                browser_message="Updated input [$field_id] to: $val"
            else
                browser_message="Input field not found: $field_id"
            fi
            ;;

        press)
            submit_form
            ;;

        reload)
            if [[ -n "$current_url" ]]; then
                load_page "$current_url" "false"
                browser_message="Page reloaded."
            else
                browser_message="No page currently loaded to reload."
            fi
            ;;

        help)
            echo ""
            echo "── BashBrowser Help ──"
            echo "  open <url>           : Navigate to URL"
            echo "  <n>                  : Click link number <n>"
            echo "  fill <id> <val>      : Fill an input field"
            echo "  press                : Submit active form"
            echo "  search <query>       : Search DuckDuckGo"
            echo "  bm add               : Bookmark current page"
            echo "  bm / bookmarks       : List bookmarks"
            echo "  bm <n>               : Open bookmark number <n>"
            echo "  bm del <n>           : Delete bookmark number <n>"
            echo "  h / history          : View navigation history"
            echo "  h <n>                : Jump to history entry <n>"
            echo "  b / back             : Go back"
            echo "  f / forward          : Go forward"
            echo "  r / reload           : Reload page"
            echo "  q / quit             : Exit browser"
            echo "──────────────────────"
            read -r -p "Press Enter to return to browser..." _
            ;;

        noop)
            ;;

        quit)
            clear
            echo "Exiting BashBrowser. Goodbye!"
            exit 0
            ;;

        *)
            browser_message="Unknown command: '$arg'. Type 'help' to see all commands."
            ;;
    esac
}
