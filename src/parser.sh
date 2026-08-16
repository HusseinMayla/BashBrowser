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

# charcter treasnlator, new line = space

normalize_html() {
    local html="$1"

    printf '%s' "$html" |
        tr '\n' ' '
}

trim_text() {
    local text="$1"

    text="${text#"${text%%[![:space:]]*}"}"
    text="${text%"${text##*[![:space:]]}"}"

    printf '%s\n' "$text"
}

#make every line a token

tokenize_html() {
    local html="$1"
    local normalized

    normalized=$(normalize_html "$html")

    printf '%s\n' "$normalized" |
        sed 's/></>\n</g'
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

    local label_regex='^<label[^>]*for="([^"]*)"[^>]*>(.*)</label>$'
    local input_regex='^<input([^>]*)/?>$'
    local button_regex='^<button([^>]*)>(.*)</button>$'
    local heading_regex='^<h([1-3])[^>]*>(.*)</h[1-3]>$'
    local paragraph_regex='^<p[^>]*>(.*)</p>$'
    local link_regex='^<a([^>]*)>(.*)</a>$'
    local br_regex='^<br[[:space:]]*/?>$'

    while IFS= read -r token || [[ -n "$token" ]]; do

        if [[ "$token" =~ $heading_regex ]]; then
            level="${BASH_REMATCH[1]}"
            text="${BASH_REMATCH[2]}"
            text=$(trim_text "$text")

            printf 'heading\tlevel=%s\ttext=%s\n' "$level" "$text"

        elif [[ "$token" =~ $paragraph_regex ]]; then
            text="${BASH_REMATCH[1]}"
            text=$(trim_text "$text")

            printf 'text\ttext=%s\n' "$text"

        elif [[ "$token" =~ $link_regex ]]; then
            local href="${BASH_REMATCH[1]}"
            text="${BASH_REMATCH[2]}"
            text=$(trim_text "$text")

            printf 'link\thref=%s\ttext=%s\n' "$href" "$text"


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
                "$text"

        elif [[ "$token" =~ $input_regex ]]; then
            local attributes="${BASH_REMATCH[1]}"

            local input_id
            local input_name
            local input_type
            local input_value

            input_id=$(get_attribute "$attributes" "id")
            input_name=$(get_attribute "$attributes" "name")
            input_type=$(get_attribute "$attributes" "type")
            input_value=$(get_attribute "$attributes" "value")

            printf 'input\tid=%s\tname=%s\ttype=%s\tvalue=%s\n' \
                "$input_id" \
                "$input_name" \
                "$input_type" \
                "$input_value"


        elif [[ "$token" =~ $label_regex ]]; then
            local label_for="${BASH_REMATCH[1]}"
            text="${BASH_REMATCH[2]}"
            text=$(trim_text "$text")

            printf 'label\tfor=%s\ttext=%s\n' "$label_for" "$text"

        elif [[ "$token" =~ $br_regex ]]; then
            printf 'br\n'
        fi

    done < <(tokenize_html "$html")
}
