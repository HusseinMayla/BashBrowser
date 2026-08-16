#!/bin/bash


#validate url function


validate_url() {
    local url="$1"

    if [[ "$url" == http://* || "$url" == https://* ]]; then
        return 0
    else
        return 1
    fi
}



# fetch url, if validation is correct, curl it

fetch_page() {
    local url="$1"
    local status

    if ! validate_url "$url"; then
        echo "Invalid URL: $url" >&2
        return 1
    fi

COOKIE_JAR="/tmp/bashbrowser_cookies.txt"

# get the http code with safety timeouts, user-agent, and cookie persistence
    if ! status=$(curl -LsS \
        --connect-timeout 10 \
        --max-time 20 \
        --cookie "$COOKIE_JAR" \
        --cookie-jar "$COOKIE_JAR" \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) BashBrowser/1.0" \
        -o /tmp/bashbrowser_page \
        -w "%{http_code}" \
        "$url"); then

        echo "Failed to fetch page: $url" >&2
        return 1
    fi

     # process http codes, if its 200 or 300 and if its not

    if [[ "$status" -ge 200 && "$status" -lt 300 ]]; then
        echo "HTTP Status: $status" >&2
        cat /tmp/bashbrowser_page
        return 0
    else
        echo "HTTP error: $status" >&2
        return 1
    fi
}
