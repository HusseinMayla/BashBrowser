#!/bin/bash

# Navigation & URL Helpers

# URL encode a string using python3 or perl
url_encode() {
    local string="$1"
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import urllib.parse, sys; sys.stdout.write(urllib.parse.quote(sys.argv[1]))" "$string"
    elif command -v perl >/dev/null 2>&1; then
        printf '%s' "$string" | perl -MURI::Escape -ne 'print uri_escape($_)'
    else
        # Pure bash fallback for alphanumeric and standard URL chars
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
    fi
}

# Resolve relative links against base URL
resolve_url() {
    local base_url="$1"
    local link="$2"

    if [[ -z "$base_url" || -z "$link" ]]; then
        printf '%s\n' "$link"
        return 0
    fi

    # Absolute URL
    if [[ "$link" == http://* || "$link" == https://* ]]; then
        printf '%s\n' "$link"
        return 0
    fi

    # Protocol-relative URL (//example.com/foo)
    if [[ "$link" == //* ]]; then
        local scheme="${base_url%%://*}"
        printf '%s:%s\n' "$scheme" "$link"
        return 0
    fi

    local scheme host base_path
    scheme=$(printf '%s\n' "$base_url" | grep -oP '^https?' || printf 'https')
    host=$(printf '%s\n' "$base_url" | grep -oP '^https?://\K[^/?#]+')
    base_path=$(printf '%s\n' "$base_url" | grep -oP '^https?://[^/?#]+\K[^?#]*')

    if [[ -z "$host" ]]; then
        printf '%s\n' "$link"
        return 0
    fi

    # Root-relative URL (/foo/bar)
    if [[ "$link" == /* ]]; then
        printf '%s://%s%s\n' "$scheme" "$host" "$link"
        return 0
    fi

    # Fragment (#section)
    if [[ "$link" == \#* ]]; then
        base_url="${base_url%%#*}"
        printf '%s%s\n' "$base_url" "$link"
        return 0
    fi

    # Query (?page=2)
    if [[ "$link" == \?* ]]; then
        base_url="${base_url%%#*}"
        base_url="${base_url%%\?*}"
        printf '%s%s\n' "$base_url" "$link"
        return 0
    fi

    # Relative path (foo/bar, ./foo, or ../foo)
    if [[ -z "$base_path" || "$base_path" == "/" ]]; then
        base_path="/"
    else
        base_path="${base_path%/*}/"
    fi

    # Handle leading ./
    while [[ "$link" == ./* ]]; do
        link="${link#./}"
    done

    # Handle ../ parent directory traversal
    while [[ "$link" == ../* ]]; do
        link="${link#../}"
        base_path="${base_path%/}"
        base_path="${base_path%/*}/"
        [[ -z "$base_path" ]] && base_path="/"
    done

    local combined="${base_path}${link}"
    combined=$(printf '%s\n' "$combined" | sed -E 's|/\./|/|g; s|^\./||')

    printf '%s://%s/%s\n' "$scheme" "$host" "${combined#/}"
    return 0
}

looks_like_url() {
    local input="$1"
    if [[ -z "$input" ]]; then
        return 1
    fi
    if [[ "$input" == http://* || "$input" == https://* ]]; then
        return 0
    fi
    if [[ "$input" == *.* && "$input" != *" "* ]]; then
        return 0
    fi
    return 1
}

normalize_url() {
    local input="$1"
    if [[ -z "$input" ]]; then
        return 1
    fi
    if [[ "$input" == http://* || "$input" == https://* ]]; then
        printf '%s\n' "$input"
        return 0
    fi
    printf 'https://%s\n' "$input"
    return 0
}