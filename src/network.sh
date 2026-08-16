#!/bin/bash

# Network Module: HTTP GET / POST with cookie persistence and error handling

get_cookie_jar() {
    local data_dir="${BASE_DIR:-.}/data"
    mkdir -p "$data_dir"
    printf '%s/cookies.txt' "$data_dir"
}

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Check if URL has valid protocol format
validate_url() {
    local url="$1"

    if [[ -z "$url" ]]; then
        return 1
    fi

    if [[ "$url" =~ ^https?:// ]]; then
        return 0
    fi

    return 1
}

# Fetch URL via HTTP GET
fetch_page() {
    local url="$1"
    local status
    local cookie_jar
    cookie_jar=$(get_cookie_jar)

    if ! validate_url "$url"; then
        echo "Invalid URL: $url" >&2
        return 1
    fi

    if ! status=$(curl -LsS \
        --connect-timeout 15 \
        --max-time 30 \
        --cookie "$cookie_jar" \
        --cookie-jar "$cookie_jar" \
        -A "$USER_AGENT" \
        -o /tmp/bashbrowser_page \
        -w "%{http_code}\n%{url_effective}" \
        "$url" 2>/tmp/bashbrowser_curl_err); then

        local err_msg
        err_msg=$(head -n 1 /tmp/bashbrowser_curl_err 2>/dev/null)
        echo "${err_msg:-Connection timeout or network failure}" > /tmp/bashbrowser_error
        echo "Failed to fetch page: $url" >&2
        return 1
    fi

    local http_code effective_url
    http_code=$(printf '%s\n' "$status" | head -n 1)
    effective_url=$(printf '%s\n' "$status" | tail -n 1)
    echo "$effective_url" > /tmp/bashbrowser_effective_url

    if [[ "$http_code" -ge 200 && "$http_code" -lt 400 ]]; then
        echo "HTTP Status: $http_code" >&2
        cat /tmp/bashbrowser_page
        return 0
    else
        echo "HTTP error $http_code: $(head -n 1 /tmp/bashbrowser_page 2>/dev/null | cut -c 1-80)" > /tmp/bashbrowser_error
        echo "HTTP error: $http_code" >&2
        return 1
    fi
}

# Post data to URL via HTTP POST
post_page() {
    local url="$1"
    local data="$2"
    local referer="${3:-$url}"
    local status
    local cookie_jar
    cookie_jar=$(get_cookie_jar)

    if ! validate_url "$url"; then
        echo "Invalid URL: $url" > /tmp/bashbrowser_error
        return 1
    fi

    if ! status=$(curl -LsS \
        --data "$data" \
        -e "$referer" \
        --connect-timeout 15 \
        --max-time 30 \
        --cookie "$cookie_jar" \
        --cookie-jar "$cookie_jar" \
        -A "$USER_AGENT" \
        -o /tmp/bashbrowser_page \
        -w "%{http_code}\n%{url_effective}" \
        "$url" 2>/tmp/bashbrowser_curl_err); then

        local err_msg
        err_msg=$(head -n 1 /tmp/bashbrowser_curl_err 2>/dev/null)
        echo "${err_msg:-Connection timeout or network failure}" > /tmp/bashbrowser_error
        echo "Failed to post to page: $url" >&2
        return 1
    fi

    local http_code effective_url
    http_code=$(printf '%s\n' "$status" | head -n 1)
    effective_url=$(printf '%s\n' "$status" | tail -n 1)
    echo "$effective_url" > /tmp/bashbrowser_effective_url

    if [[ "$http_code" -ge 200 && "$http_code" -lt 400 ]]; then
        echo "HTTP Status: $http_code" >&2
        cat /tmp/bashbrowser_page
        return 0
    else
        echo "HTTP error $http_code" > /tmp/bashbrowser_error
        echo "HTTP error: $http_code" >&2
        return 1
    fi
}
