#!/bin/bash

source ./renderer.sh

page_elements=(
    "heading||Login"
    "text||Please enter your credentials."
    "label|username-label|Username:"
    "input|username|text|"
    "label|password-label|Password:"
    "input|password|password|"
    "button|login|Login"
    "link|about|About|/about"
)

render_page