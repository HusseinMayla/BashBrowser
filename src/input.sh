#!/bin/bash

read_browser_input() {
    local user_input

    read -r -p "Command: " user_input

    # Trim leading/trailing whitespace
    user_input="${user_input#"${user_input%%[![:space:]]*}"}"
    user_input="${user_input%"${user_input##*[![:space:]]}"}"

    action=""
    argument=""

    if [[ -z "$user_input" ]]; then
        action="noop"
        argument=""

    # Shortcut: typing just a number like "1" clicks that link
    elif [[ "$user_input" =~ ^[0-9]+$ ]]; then
        action="click"
        argument="$user_input"

    # Shortcut: "open 1" redirect to click if integer
    elif [[ "$user_input" =~ ^open[[:space:]]+([0-9]+)$ ]]; then
        action="click"
        argument="${BASH_REMATCH[1]}"

    elif [[ "$user_input" =~ ^open[[:space:]]+(.+)$ ]]; then
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

    elif [[ "$user_input" == "reload" || "$user_input" == "r" || "$user_input" == "refresh" ]]; then
        action="reload"

    elif [[ "$user_input" == "help" || "$user_input" == "h" || "$user_input" == "?" ]]; then
        action="help"

    elif [[ "$user_input" == "back" || "$user_input" == "b" ]]; then
        action="back"

    elif [[ "$user_input" == "forward" || "$user_input" == "f" ]]; then
        action="forward"

    elif [[ "$user_input" == "quit" || "$user_input" == "exit" || "$user_input" == "q" ]]; then
        action="quit"

    else
        action="unknown"
        argument="$user_input"
    fi
}