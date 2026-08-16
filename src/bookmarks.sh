#!/bin/bash

# Bookmarks Management Module

get_bookmark_file() {
    local data_dir="${BASE_DIR:-.}/data"
    mkdir -p "$data_dir"
    printf '%s/bookmarks' "$data_dir"
}

init_bookmarks() {
    local bookmark_file
    bookmark_file=$(get_bookmark_file)
    touch "$bookmark_file"
}

bookmark_add() {
    local url="$1"
    local bookmark_file
    bookmark_file=$(get_bookmark_file)

    if [[ -z "$url" ]]; then
        echo "No URL to bookmark." >&2
        return 1
    fi

    init_bookmarks

    if grep -Fxq "$url" "$bookmark_file" 2>/dev/null; then
        echo "Bookmark already exists."
        return 0
    fi

    printf '%s\n' "$url" >> "$bookmark_file"
    echo "Bookmark added: $url"
    return 0
}

bookmark_list() {
    local bookmark_file
    bookmark_file=$(get_bookmark_file)
    local line
    local number=1

    init_bookmarks

    if [[ ! -s "$bookmark_file" ]]; then
        echo "No bookmarks saved."
        return 0
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        printf '[%d] %s\n' "$number" "$line"
        number=$((number + 1))
    done < "$bookmark_file"
}

bookmark_get() {
    local number="$1"
    local bookmark_file
    bookmark_file=$(get_bookmark_file)
    local line
    local current=1

    init_bookmarks

    if [[ ! "$number" =~ ^[0-9]+$ ]] || (( number < 1 )); then
        echo "Invalid bookmark number: $number" >&2
        return 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        if (( current == number )); then
            printf '%s\n' "$line"
            return 0
        fi
        current=$((current + 1))
    done < "$bookmark_file"

    echo "Bookmark not found: $number" >&2
    return 1
}

bookmark_delete() {
    local number="$1"
    local bookmark_file
    bookmark_file=$(get_bookmark_file)
    local temp_file="${bookmark_file}.tmp"
    local current=1
    local line
    local found=0

    init_bookmarks

    if [[ ! "$number" =~ ^[0-9]+$ ]] || (( number < 1 )); then
        echo "Invalid bookmark number: $number" >&2
        return 1
    fi

    > "$temp_file"

    while IFS= read -r line || [[ -n "$line" ]]; do
        if (( current == number )); then
            found=1
        else
            printf '%s\n' "$line" >> "$temp_file"
        fi
        current=$((current + 1))
    done < "$bookmark_file"

    if (( found == 0 )); then
        rm -f "$temp_file"
        echo "Bookmark not found: $number" >&2
        return 1
    fi

    mv "$temp_file" "$bookmark_file"
    echo "Bookmark deleted: #$number"
    return 0
}
