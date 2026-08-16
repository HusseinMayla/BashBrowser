#!/bin/bash

read_browser_input() {
    local user_input

    read -r -p "Command: " user_input

    action=""
    argument=""

    if [[ "$user_input" =~ ^open[[:space:]]+(.+)$ ]]; then
        action="open"
        argument="${BASH_REMATCH[1]}"

    elif [[ "$user_input" =~ ^search[[:space:]]+(.+)$ ]]; then
        action="search"
        argument="${BASH_REMATCH[1]}"

    elif [[ "$user_input" =~ ^click[[:space:]]+(.+)$ ]]; then
        action="click"
        argument="${BASH_REMATCH[1]}"

    elif [[ "$user_input" =~ ^fill[[:space:]]+([^[:space:]]+)[[:space:]]+(.+)$ ]]; then
        action="fill"
        argument="${BASH_REMATCH[1]}|${BASH_REMATCH[2]}"

    elif [[ "$user_input" =~ ^press[[:space:]]+(.+)$ ]]; then
        action="press"
        argument="${BASH_REMATCH[1]}"

    elif [[ "$user_input" == "back" ]]; then
        action="back"

    elif [[ "$user_input" == "forward" ]]; then
        action="forward"

    elif [[ "$user_input" == "quit" ]]; then
        action="quit"

    else
        action="unknown"
        argument="$user_input"
    fi
}