#!/bin/bash

resolve_url() {
    local base_url="$1"
    local link="$2"

    if [[ "$link" == http://* || "$link" == https://* ]]; then
        printf '%s\n' "$link"
        return 0
    fi

    if [[ "$link" == /* ]]; then
        local scheme
        local host

        scheme=$(printf '%s\n' "$base_url" | grep -oP '^https?')
        host=$(printf '%s\n' "$base_url" | grep -oP '^https?://\K[^/]+')

        printf '%s://%s%s\n' "$scheme" "$host" "$link"
        return 0
    fi

    return 1
}