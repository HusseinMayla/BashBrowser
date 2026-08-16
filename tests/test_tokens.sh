#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/parser.sh"

html=$(curl -LsS -A "Mozilla/5.0" "https://ums.usal.edu.lb/")
tokenize_html "$html" | head -n 40
