#!/bin/bash

# Function to retrieve block height from endpoint
get_block_height() {
    endpoint=$1
    block_height=$(curl -sk "$endpoint" | jq -r '.result.sync_info.latest_block_height')
    echo "$block_height"
}

# Function to check if node is catching up
check_catching_up() {
    endpoint=$1
    catching_up=$(curl -sk "$endpoint" | jq -r '.result.sync_info.catching_up')
    echo "$catching_up"
}

# Endpoints
endpoint1="http://127.0.0.1:26657/status"
endpoint2="https://jackal-rpc.polkachu.com/status"

# Get block heights
height1=$(get_block_height "$endpoint1")
height2=$(get_block_height "$endpoint2")

# Check if node is catching up
catching_up=$(check_catching_up "$endpoint1")

# Compare block heights
if [ "$height1" -ne "$height2" ]; then
    difference=$((height1 - height2))
    if [ "$difference" -gt 2 ] || [ "$difference" -lt -2 ]; then
        # Check if node is catching up and restart if necessary
        if [ "$catching_up" == "false" ]; then
            echo "Node is not catching up and block height difference is more than 2. Restarting service."
            systemctl restart canined
        else
            echo "Node is catching up. No restart needed."
        fi
    else
        echo "Block heights are within acceptable range."
    fi
else
    echo "Block heights are equal."
fi

# Output actual block heights
echo "Block Height - Endpoint 1: $height1"
echo "Block Height - Endpoint 2: $height2"
