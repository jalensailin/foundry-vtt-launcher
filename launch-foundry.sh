#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Default values
webpage=true

# Parse options first
while getopts "n" opt; do
  case "$opt" in
    n) webpage=false ;;
    *) echo "Invalid option"; exit 1 ;;
  esac
done

# Remove parsed options from the argument list
shift $((OPTIND - 1))

# Define variables
VERSION=${1:-13} # Process positional argument.
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


if [ "$webpage" = true ]; then
    # Wait for 2 seconds
    sleep 2
    
    # Open the browser at the specified URL
    xdg-open "http://localhost:$PORT"
fi

# Wait on output of the last running process (i.e. Foundry)
wait $FOUNDRY_PID
