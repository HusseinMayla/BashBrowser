#!/bin/bash

# History Management (Linear Stack with Cursor Pointer)

history_urls=()
history_index=-1
history_result=""

history_add() {
    local url="$1"

    if [[ -z "$url" ]]; then
        return 1
    fi

    # Do not add the same current URL twice consecutively
    if (( history_index >= 0 )); then
        if [[ "${history_urls[$history_index]}" == "$url" ]]; then
            return 0
        fi
    fi

    # If we navigated back and then visit a new page,
    # truncate forward history
    if (( history_index < ${#history_urls[@]} - 1 )); then
        history_urls=("${history_urls[@]:0:$((history_index + 1))}")
    fi

    history_urls+=("$url")
    history_index=$((${#history_urls[@]} - 1))

    return 0
}

history_current() {
    if (( history_index < 0 )); then
        return 1
    fi

    printf '%s\n' "${history_urls[$history_index]}"
}

history_back() {
    if (( history_index <= 0 )); then
        return 1
    fi

    history_index=$((history_index - 1))
    history_result="${history_urls[$history_index]}"

    return 0
}

history_forward() {
    local last_index=$((${#history_urls[@]} - 1))

    if (( history_index >= last_index )); then
        return 1
    fi

    history_index=$((history_index + 1))
    history_result="${history_urls[$history_index]}"

    return 0
}

history_list() {
    local i

    if (( ${#history_urls[@]} == 0 )); then
        echo "No history entries."
        return 0
    fi

    for ((i = 0; i < ${#history_urls[@]}; i++)); do
        if (( i == history_index )); then
            printf '* [%d] %s\n' "$((i + 1))" "${history_urls[$i]}"
        else
            printf '  [%d] %s\n' "$((i + 1))" "${history_urls[$i]}"
        fi
    done
}

history_get() {
    local num="$1"
    if [[ ! "$num" =~ ^[0-9]+$ ]] || (( num < 1 || num > ${#history_urls[@]} )); then
        return 1
    fi
    local idx=$((num - 1))
    history_index=$idx
    history_result="${history_urls[$idx]}"
    return 0
}
