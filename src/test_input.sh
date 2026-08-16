#!/bin/bash

source ./input.sh

while true; do

    read_browser_input

    printf 'action = "%s"\n' "$action"
    printf 'argument = "%s"\n\n' "$argument"

    [[ "$action" == "quit" ]] && break

done