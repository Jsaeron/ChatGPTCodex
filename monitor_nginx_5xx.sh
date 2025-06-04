#!/usr/bin/env bash
# Monitor Nginx access log for 5xx responses in the last five minutes.
# Exits with code 1 if more than 20 occur within that window.

set -euo pipefail

LOG_FILE="/var/log/nginx/access.log"
THRESHOLD=20
WINDOW_SECONDS=300

# Array to hold timestamps (in epoch seconds) of recent 5xx responses
declare -a events=()

while IFS= read -r line; do
    status=$(echo "$line" | awk '{print $9}')
    if [[ $status =~ ^5[0-9]{2}$ ]]; then
        ts=$(echo "$line" | awk -F'[][]' '{print $2}')
        epoch=$(date --date="$ts" +%s 2>/dev/null || true)
        if [[ -n $epoch ]]; then
            events+=("$epoch")
        fi
    fi

    current=$(date +%s)
    new=()
    for t in "${events[@]}"; do
        if (( current - t <= WINDOW_SECONDS )); then
            new+=("$t")
        fi
    done
    events=("${new[@]}")

    if (( ${#events[@]} > THRESHOLD )); then
        echo "5xx responses in last 5 minutes: ${#events[@]}" >&2
        exit 1
    fi

done < <(tail -n 0 -F "$LOG_FILE")
