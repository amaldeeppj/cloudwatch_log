#!/bin/bash

# Variables
LOG_GROUP_NAME="/ecs/my-service" # Replace with your log group name
START_TIME=1737958800000 # Start time in Unix timestamp (milliseconds)
END_TIME=1737962400000   # End time in Unix timestamp (milliseconds)
OUTPUT_FILE="logs.json"  # Output file to save logs
NEXT_TOKEN=""            # Initialize nextToken
LIMIT=10000              # Maximum number of events per request

# Create or empty the output file
> $OUTPUT_FILE

# Function to fetch logs
fetch_logs() {
    if [ -z "$NEXT_TOKEN" ]; then
        aws logs filter-log-events \
            --log-group-name "$LOG_GROUP_NAME" \
            --start-time "$START_TIME" \
            --end-time "$END_TIME" \
            --limit "$LIMIT" \
            --output json
    else
        aws logs filter-log-events \
            --log-group-name "$LOG_GROUP_NAME" \
            --start-time "$START_TIME" \
            --end-time "$END_TIME" \
            --limit "$LIMIT" \
            --next-token "$NEXT_TOKEN" \
            --output json
    fi
}

# Loop until all logs are fetched
while :; do
    echo "Fetching logs..."
    RESPONSE=$(fetch_logs)
   
    # Append logs to the output file
    echo "$RESPONSE" | jq -c '.events[]' >> $OUTPUT_FILE

    # Check if there's a nextToken for pagination
    NEXT_TOKEN=$(echo "$RESPONSE" | jq -r '.nextToken')

    # Exit the loop if there's no nextToken
    if [ "$NEXT_TOKEN" == "null" ]; then
        break
    fi
done

echo "All logs have been fetched and saved to $OUTPUT_FILE"