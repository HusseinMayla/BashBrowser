#!/bin/bash
rm -f /tmp/bashbrowser_cookies.txt
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/network.sh"

html1=$(fetch_page "https://ums.usal.edu.lb/")
token=$(printf '%s\n' "$html1" | grep -oiP '__RequestVerificationToken.*value="\K[^"]+')

echo "Extracted token: ${token:0:30}..."

# Step 1: POST to /
curl -s -L \
    --cookie /tmp/bashbrowser_cookies.txt \
    --cookie-jar /tmp/bashbrowser_cookies.txt \
    -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    --data "id=1124171&__RequestVerificationToken=${token}" \
    "https://ums.usal.edu.lb/" \
    -o /tmp/step2_page.html

echo "Step 2 HTML Length: $(wc -c < /tmp/step2_page.html)"
echo "--- Step 2 Head ---"
head -n 40 /tmp/step2_page.html
