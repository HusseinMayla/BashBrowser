#!/bin/bash

render_page() {
    clear

    local link_number=0

    for element in "${page_elements[@]}"; do

        IFS='|' read -r type id content extra <<< "$element"

        case "$type" in

            heading)
                printf '\033[1m%s\033[0m\n\n' "$content"
                ;;

            text)
                printf '%s\n\n' "$content"
                ;;

            br)
                printf '\n'
                ;;

            label)
                printf '%s ' "$content"
                ;;

            input)
                local value="$extra"

                printf '[%s]\n\n' "$value"
                ;;

            button)
                printf '[ %s ]\n\n' "$content"
                ;;

            link)
                link_number=$((link_number + 1))

                printf '[%d] %s\n' "$link_number" "$content"
                ;;

        esac
    done
}