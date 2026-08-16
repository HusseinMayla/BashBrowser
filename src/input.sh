#!/bin/bash

# Input Parser: Interprets CLI commands and routes actions

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

    # Bookmark commands
    elif [[ "$user_input" == "bm add" || "$user_input" == "bookmark add" ]]; then
        action="bookmark_add"

    elif [[ "$user_input" =~ ^(bm|bookmark)[[:space:]]+del[[:space:]]+([0-9]+)$ ]]; then
        action="bookmark_del"
        argument="${BASH_REMATCH[2]}"

    elif [[ "$user_input" =~ ^(bm|bookmark)[[:space:]]+([0-9]+)$ ]]; then
        action="bookmark_open"
        argument="${BASH_REMATCH[2]}"

    elif [[ "$user_input" == "bm" || "$user_input" == "bookmarks" || "$user_input" == "bm list" || "$user_input" == "bookmarks list" ]]; then
        action="bookmark_list"

    # History commands
    elif [[ "$user_input" =~ ^(h|history)[[:space:]]+([0-9]+)$ ]]; then
        action="history_jump"
        argument="${BASH_REMATCH[2]}"

    elif [[ "$user_input" == "history" || "$user_input" == "h" ]]; then
        action="history"

    # Form fill & submit
    elif [[ "$user_input" =~ ^fill[[:space:]]+([^[:space:]]+)[[:space:]]+(.+)$ ]]; then
        action="fill"
        argument="${BASH_REMATCH[1]}|${BASH_REMATCH[2]}"

    elif [[ "$user_input" =~ ^press[[:space:]]*(.*)$ ]]; then
        action="press"
        argument="${BASH_REMATCH[1]}"

    # Navigation & control
    elif [[ "$user_input" == "reload" || "$user_input" == "r" || "$user_input" == "refresh" ]]; then
        action="reload"

    elif [[ "$user_input" == "help" || "$user_input" == "?" ]]; then
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