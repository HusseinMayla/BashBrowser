#!/bin/bash

fetch_page() {
    local url="$1"

    curl -L "$url"
}