#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Default values
VERSION=13
WEBPAGE=true

# Parse positional arguments first (number of args gt 0 and not starting with -)
if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
  VERSION=$1
  shift  # Remove the first argument (VERSION) from the list
fi

# Parse options first
while getopts "n" opt; do
  case "$opt" in
    n) WEBPAGE=false ;;
    *) echo "Invalid option"; exit 1 ;;
  esac
done

# Remove parsed options from the argument list
shift $((OPTIND - 1))

# Define variables
PORT=$((30000 + VERSION))
DATA_PATH="$HOME/Documents/coding/foundry-vtt"
APP_DATA_PATH="$DATA_PATH/instances/v${VERSION}"
USER_DATA_PATH="$DATA_PATH/user-data/v${VERSION}"

# Compatibility
if [ "$VERSION" -lt 13 ]; then
    APP_DATA_PATH="$APP_DATA_PATH/resources/app/main.js"
else 
    APP_DATA_PATH="$APP_DATA_PATH/main.mjs"
fi

# Open a new terminal tab and run Foundry
node $APP_DATA_PATH --dataPath=$USER_DATA_PATH --port=$PORT &

# Capture the last running process ID
FOUNDRY_PID=$!

# `trap` catches certain signals and runs a command when they occur
# `EXIT` is triggered when the script ends (no matter how)
trap "kill $FOUNDRY_PID" EXIT


if [ "$WEBPAGE" = true ]; then
    # Wait for 2 seconds
    sleep 2
    
    # Open the browser at the specified URL
    xdg-open "http://localhost:$PORT"
fi

# Wait on output of the last running process (i.e. Foundry)
wait $FOUNDRY_PID
