#!/bin/bash

# get any title from the extracted html page

get_title() {
    local html="$1"

    printf '%s\n' "$html" |
        grep -oiP '(?<=<title>).*?(?=</title>)'
}

# get any link from the extracted html page 

extract_links() {
    local html="$1"

    printf '%s\n' "$html" |
        grep -oiP 'href="\K[^"]+'
}

trim_text() {
    local text="$1"

    # Remove inner HTML tags (e.g. <b>...</b> or <span>...</span>)
    text=$(printf '%s\n' "$text" | sed -E 's/<[^>]+>//g')

    # Trim leading and trailing whitespace
    text="${text#"${text%%[![:space:]]*}"}"
    text="${text%"${text##*[![:space:]]}"}"

    printf '%s\n' "$text"
}

# character translator, remove scripts/styles and make every tag a token

tokenize_html() {
    local html="$1"

    # 1. Strip script and style blocks
    local clean_html
    clean_html=$(printf '%s\n' "$html" | perl -0777 -pe 's/<script\b[^>]*>.*?<\/script>//gis; s/<style\b[^>]*>.*?<\/style>//gis')

    # 2. Convert newlines to spaces, then insert newlines between HTML tags
    printf '%s' "$clean_html" |
        tr '\n\r\t' ' ' |
        sed -E 's/>[[:space:]]*</>\n</g'
}

# get value attrivutes 

get_attribute() {
    local attributes="$1"
    local name="$2"

    local double_regex
    local single_regex

    double_regex="(^|[[:space:]])${name}[[:space:]]*=[[:space:]]*\"([^\"]*)\""
    single_regex="(^|[[:space:]])${name}[[:space:]]*=[[:space:]]*'([^']*)'"

    if [[ "$attributes" =~ $double_regex ]]; then
        printf '%s\n' "${BASH_REMATCH[2]}"
        return 0
    fi

    if [[ "$attributes" =~ $single_regex ]]; then
        printf '%s\n' "${BASH_REMATCH[2]}"
        return 0
    fi

    printf '\n'
    return 1
}


#output  the  
parse_page() {
    local html="$1"
    local token
    local text
    local level

    local label_regex='^<label([^>]*)>(.*)</label>$'
    local input_regex='^<input([^>]*)/?>$'
    local button_regex='^<button([^>]*)>(.*)</button>$'
    local heading_regex='^<h([1-6])[^>]*>(.*)</h[1-6]>$'
    local paragraph_regex='^<p[^>]*>(.*)</p>$'
    local link_regex='^<a([^>]*)>(.*)</a>$'
    local br_regex='^<br[[:space:]]*/?>$'

    while IFS= read -r token || [[ -n "$token" ]]; do

        if [[ "$token" =~ $heading_regex ]]; then
            level="${BASH_REMATCH[1]}"
            text="${BASH_REMATCH[2]}"
            text=$(trim_text "$text")

            [[ -n "$text" ]] && printf 'heading\tlevel=%s\ttext=%s\n' "$level" "$text"

        elif [[ "$token" =~ $paragraph_regex ]]; then
            text="${BASH_REMATCH[1]}"
            text=$(trim_text "$text")

            [[ -n "$text" ]] && printf 'text\ttext=%s\n' "$text"

        elif [[ "$token" =~ $link_regex ]]; then
            local attributes="${BASH_REMATCH[1]}"
            text="${BASH_REMATCH[2]}"
            text=$(trim_text "$text")

            local href
            href=$(get_attribute "$attributes" "href")

            [[ -n "$text" || -n "$href" ]] && printf 'link\thref=%s\ttext=%s\n' "$href" "${text:-$href}"

        elif [[ "$token" =~ $button_regex ]]; then
            local attributes="${BASH_REMATCH[1]}"
            text="${BASH_REMATCH[2]}"
            text=$(trim_text "$text")

            local button_id
            local button_type

            button_id=$(get_attribute "$attributes" "id")
            button_type=$(get_attribute "$attributes" "type")

            printf 'button\tid=%s\ttype=%s\ttext=%s\n' \
                "$button_id" \
                "$button_type" \
                "${text:-Submit}"

        elif [[ "$token" =~ $input_regex ]]; then
            local attributes="${BASH_REMATCH[1]}"

            local input_id
            local input_name
            local input_type
            local input_value
            local input_placeholder

            input_id=$(get_attribute "$attributes" "id")
            input_name=$(get_attribute "$attributes" "name")
            input_type=$(get_attribute "$attributes" "type")
            input_value=$(get_attribute "$attributes" "value")
            input_placeholder=$(get_attribute "$attributes" "placeholder")

            # Skip hidden CSRF/anti-forgery tokens so they don't clutter the UI
            if [[ "$input_type" != "hidden" ]]; then
                # If value is empty, use placeholder as initial prompt text
                local display_value="${input_value:-$input_placeholder}"
                printf 'input\tid=%s\tname=%s\ttype=%s\tvalue=%s\n' \
                    "$input_id" \
                    "$input_name" \
                    "${input_type:-text}" \
                    "$display_value"
            fi

        elif [[ "$token" =~ $label_regex ]]; then
            local attributes="${BASH_REMATCH[1]}"
            text="${BASH_REMATCH[2]}"
            text=$(trim_text "$text")

            local label_for
            label_for=$(get_attribute "$attributes" "for")

            [[ -n "$text" ]] && printf 'label\tfor=%s\ttext=%s\n' "$label_for" "$text"

        elif [[ "$token" =~ $br_regex ]]; then
            printf 'br\n'
        fi

    done < <(tokenize_html "$html")
}
