#!/bin/bash

# Navigation & History Management

declare -a history_back=()
declare -a history_forward=()
current_url=""

url_encode() {
    local string="$1"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * )               printf -v o '%%%02x' "'$c"
        esac
        encoded+="${o}"
    done
    printf '%s\n' "$encoded"
}

resolve_url() {
    local base_url="$1"
    local link="$2"

    # If link is already absolute (http or https)
    if [[ "$link" == http://* || "$link" == https://* ]]; then
        printf '%s\n' "$link"
        return 0
    fi

    # Remove trailing hash/fragments for cleaner resolution if needed, or keep
    local scheme host base_path

    scheme=$(printf '%s\n' "$base_url" | grep -oP '^https?')
    host=$(printf '%s\n' "$base_url" | grep -oP '^https?://\K[^/?#]+')
    base_path=$(printf '%s\n' "$base_url" | grep -oP '^https?://[^/?#]+\K[^?#]*')

    if [[ -z "$scheme" || -z "$host" ]]; then
        printf '%s\n' "$link"
        return 0
    fi

    # Root-relative: /foo/bar
    if [[ "$link" == /* ]]; then
        printf '%s://%s%s\n' "$scheme" "$host" "$link"
        return 0
    fi

    # Relative path: foo/bar or ./foo
    if [[ -z "$base_path" || "$base_path" == "/" ]]; then
        base_path="/"
    else
        base_path="${base_path%/*}/"
    fi

    local combined="${base_path}${link}"
    # Clean up ./
    combined=$(printf '%s\n' "$combined" | sed -E 's|/\./|/|g; s|^\./||')

    printf '%s://%s/%s\n' "$scheme" "$host" "${combined#/}"
    return 0
}

history_push() {
    local new_url="$1"
    if [[ -n "$current_url" && "$current_url" != "$new_url" ]]; then
        history_back+=("$current_url")
        history_forward=()
    fi
}