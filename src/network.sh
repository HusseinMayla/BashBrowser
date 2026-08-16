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


# get the http code 

    if ! status=$(curl -LsS \
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
