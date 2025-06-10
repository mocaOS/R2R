#!/bin/bash

set -e

echo 'Starting token creation process...'

# Check if required tools are available
if ! command -v jq &> /dev/null; then
    echo 'Warning: jq not found, some validations will be skipped'
fi

# Check if config directory exists and has content
if [ ! -d "/hatchet/config" ]; then
    echo 'Error: /hatchet/config directory does not exist' >&2
    exit 1
fi

echo 'Checking config directory contents:'
ls -la /hatchet/config/

# Check if hatchet-admin is available
if ! command -v /hatchet/hatchet-admin &> /dev/null; then
    echo 'Error: hatchet-admin command not found' >&2
    exit 1
fi

echo 'Hatchet admin command available'

# First, try to list tenants to see what's available
echo 'Attempting to list tenants...'
TENANT_LIST_OUTPUT=$(/hatchet/hatchet-admin tenant list --config /hatchet/config 2>&1 || echo "TENANT_LIST_FAILED")

if [ "$TENANT_LIST_OUTPUT" = "TENANT_LIST_FAILED" ]; then
    echo 'Warning: Could not list tenants, proceeding with token creation...'
else
    echo 'Available tenants:'
    echo "$TENANT_LIST_OUTPUT"
fi

# Try to create a tenant first (this might fail if it already exists, which is fine)
echo 'Attempting to create default tenant...'
TENANT_CREATE_OUTPUT=$(/hatchet/hatchet-admin tenant create --name "default" --config /hatchet/config 2>&1 || echo "TENANT_CREATE_FAILED")

if [ "$TENANT_CREATE_OUTPUT" = "TENANT_CREATE_FAILED" ]; then
    echo 'Note: Could not create tenant (may already exist)'
else
    echo 'Tenant creation output:'
    echo "$TENANT_CREATE_OUTPUT"
fi

# Try to get the tenant ID from the list
TENANT_ID=""
if [ "$TENANT_LIST_OUTPUT" != "TENANT_LIST_FAILED" ]; then
    # Try to extract tenant ID from the output
    TENANT_ID=$(echo "$TENANT_LIST_OUTPUT" | grep -o '[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}' | head -1 || echo "")
fi

# If we couldn't extract a tenant ID, use the default one
if [ -z "$TENANT_ID" ]; then
    TENANT_ID="707d0855-80ab-4e1f-a156-f1c4546cbf52"
    echo "Using default tenant ID: $TENANT_ID"
else
    echo "Using extracted tenant ID: $TENANT_ID"
fi

# Attempt to create token and capture both stdout and stderr
echo 'Attempting to create token...'
TOKEN_OUTPUT=$(/hatchet/hatchet-admin token create --config /hatchet/config --tenant-id "$TENANT_ID" 2>&1)

echo 'Token creation command output:'
echo "$TOKEN_OUTPUT"

# Extract the token (looking for JWT pattern)
TOKEN=$(echo "$TOKEN_OUTPUT" | grep -Eo 'eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*' | head -1)

if [ -z "$TOKEN" ]; then
    echo 'Error: Failed to extract token from output' >&2
    echo 'Full command output was:' >&2
    echo "$TOKEN_OUTPUT" >&2
    
    # Try alternative extraction methods
    echo 'Trying alternative token extraction methods...' >&2
    
    # Look for any string that looks like a token
    ALT_TOKEN=$(echo "$TOKEN_OUTPUT" | grep -Eo '[A-Za-z0-9_-]{20,}' | head -1)
    if [ -n "$ALT_TOKEN" ]; then
        echo "Found potential token: $ALT_TOKEN" >&2
        TOKEN="$ALT_TOKEN"
    else
        echo 'No token-like string found in output' >&2
        exit 1
    fi
fi

echo 'Token extracted successfully'
echo "Token length: ${#TOKEN}"
echo "Token (first 20 chars): ${TOKEN:0:20}..."

# Save token to temporary file first
echo "$TOKEN" > /tmp/hatchet_api_key
echo 'Token saved to /tmp/hatchet_api_key'

# Create the API key directory if it doesn't exist
mkdir -p /hatchet_api_key

# Copy token to final destination
echo -n "$TOKEN" > /hatchet_api_key/api_key.txt
echo 'Token copied to /hatchet_api_key/api_key.txt'

# Verify token was copied correctly
if [ "$(cat /tmp/hatchet_api_key)" != "$(cat /hatchet_api_key/api_key.txt)" ]; then
    echo 'Error: Token copy failed, files do not match' >&2
    echo 'Content of /tmp/hatchet_api_key:'
    cat /tmp/hatchet_api_key
    echo 'Content of /hatchet_api_key/api_key.txt:'
    cat /hatchet_api_key/api_key.txt
    exit 1
fi

echo 'Hatchet API key has been saved successfully'

# Enhanced token validation
if [[ "$TOKEN" =~ ^eyJ.*\.eyJ.*\.[A-Za-z0-9_-]*$ ]]; then
    echo 'Token appears to be a valid JWT format'
    
    # Try to validate JWT structure if jq is available
    if command -v jq &> /dev/null; then
        echo 'Attempting to validate JWT payload...'
        JWT_PAYLOAD=$(echo "$TOKEN" | cut -d. -f2)
        
        # Add padding if needed for base64 decoding
        while [ $((${#JWT_PAYLOAD} % 4)) -ne 0 ]; do
            JWT_PAYLOAD="${JWT_PAYLOAD}="
        done
        
        if echo "$JWT_PAYLOAD" | base64 -d 2>/dev/null | jq . >/dev/null 2>&1; then
            echo 'JWT payload is valid JSON'
            echo 'JWT payload:'
            echo "$JWT_PAYLOAD" | base64 -d 2>/dev/null | jq .
        else
            echo 'Warning: JWT payload is not valid JSON or base64 decode failed'
        fi
    fi
else
    echo 'Warning: Token does not appear to be in JWT format'
fi

echo 'Token setup completed successfully'
