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
                local field_label="${id:-$content}"
                local value="$extra"

                if [[ -n "$field_label" ]]; then
                    printf '\033[36m[Input: %s]\033[0m %s\n\n' "$field_label" "[ ${value} ]"
                else
                    printf '\033[36m[Input]\033[0m [ %s ]\n\n' "$value"
                fi
                ;;

            button)
                local btn_label="${content:-$id}"
                printf '\033[32m[Button]\033[0m [ %s ]\n\n' "$btn_label"
                ;;

            link)
                link_number=$((link_number + 1))

                printf '\033[34m[%d]\033[0m %s\n' "$link_number" "$content"
                ;;

        esac
    done
}