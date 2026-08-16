#!/bin/bash

# Browser Engine & State Management

declare -a page_elements=()
declare -a page_links=()
current_title=""
browser_message=""

# Adapt parse_page tab-separated output to renderer page_elements (type|id|content|extra)
adapter_parse_to_elements() {
    local html="$1"
    page_elements=()
    page_links=()

    local parsed_output
    parsed_output=$(parse_page "$html")

    while IFS=$'\t' read -r type rest || [[ -n "$type" ]]; do
        [[ -z "$type" ]] && continue

        case "$type" in
            heading)
                # level=X text=Y
                local level="" text=""
                IFS=$'\t' read -r f1 f2 <<< "$rest"
                [[ "$f1" =~ ^level=(.*)$ ]] && level="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_elements+=("heading||${text}|${level}")
                ;;

            text)
                # text=Y
                local text=""
                [[ "$rest" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_elements+=("text||${text}|")
                ;;

            link)
                # href=X text=Y
                local href="" text=""
                IFS=$'\t' read -r f1 f2 <<< "$rest"
                [[ "$f1" =~ ^href=(.*)$ ]] && href="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_links+=("$href")
                page_elements+=("link||${text}|${href}")
                ;;

            button)
                # id=X type=Y text=Z
                local id="" btype="" text=""
                IFS=$'\t' read -r f1 f2 f3 <<< "$rest"
                [[ "$f1" =~ ^id=(.*)$ ]] && id="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^type=(.*)$ ]] && btype="${BASH_REMATCH[1]}"
                [[ "$f3" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_elements+=("button|${id}|${text}|${btype}")
                ;;

            input)
                # id=X name=Y type=Z value=W
                local id="" name="" itype="" value=""
                IFS=$'\t' read -r f1 f2 f3 f4 <<< "$rest"
                [[ "$f1" =~ ^id=(.*)$ ]] && id="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^name=(.*)$ ]] && name="${BASH_REMATCH[1]}"
                [[ "$f3" =~ ^type=(.*)$ ]] && itype="${BASH_REMATCH[1]}"
                [[ "$f4" =~ ^value=(.*)$ ]] && value="${BASH_REMATCH[1]}"
                # renderer uses: type | id | content (name) | extra (value)
                page_elements+=("input|${id}|${name}|${value}")
                ;;

            label)
                # for=X text=Y
                local for_id="" text=""
                IFS=$'\t' read -r f1 f2 <<< "$rest"
                [[ "$f1" =~ ^for=(.*)$ ]] && for_id="${BASH_REMATCH[1]}"
                [[ "$f2" =~ ^text=(.*)$ ]] && text="${BASH_REMATCH[1]}"
                page_elements+=("label|${for_id}|${text}|")
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

    # Prepend https:// if protocol is missing
    if [[ "$target_url" != http://* && "$target_url" != https://* ]]; then
        target_url="https://${target_url}"
    fi

    browser_message="Loading ${target_url}..."
    local html
    html=$(fetch_page "$target_url")
    local fetch_status=$?

    if [[ $fetch_status -ne 0 || -z "$html" ]]; then
        browser_message="Failed to load page: ${target_url}"
        return 1
    fi

    if [[ "$push_to_history" == "true" ]]; then
        history_push "$target_url"
    fi

    current_url="$target_url"
    current_title=$(get_title "$html")
    [[ -z "$current_title" ]] && current_title="[No Title]"

    adapter_parse_to_elements "$html"
    browser_message="Page loaded successfully (${#page_elements[@]} elements)."
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
            load_page "https://html.duckduckgo.com/html/?q=${encoded}" "true"
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
            local back_count=${#history_back[@]}
            if (( back_count == 0 )); then
                browser_message="No history to go back to."
                return 1
            fi

            local prev_url="${history_back[$((back_count - 1))]}"
            unset 'history_back[back_count - 1]'
            history_forward+=("$current_url")
            load_page "$prev_url" "false"
            ;;

        forward)
            local fwd_count=${#history_forward[@]}
            if (( fwd_count == 0 )); then
                browser_message="No forward history."
                return 1
            fi

            local next_url="${history_forward[$((fwd_count - 1))]}"
            unset 'history_forward[fwd_count - 1]'
            history_back+=("$current_url")
            load_page "$next_url" "false"
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
            browser_message="Pressed button: $arg"
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
            browser_message="Commands: open <url> | <n> (click link) | fill <id> <val> | press <btn> | reload | search <q> | back | forward | quit"
            ;;

        noop)
            # User simply pressed enter without input; do nothing and keep state
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
