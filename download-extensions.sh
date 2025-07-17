#!/bin/bash

# Configuration
DOWNLOAD_DIR="./extensions"
EXTRACT_DIR="./extracted-extensions"
OPENVSX_API="https://open-vsx.org/api"

# List of extensions to download
EXTENSIONS=(
    "project-accelerate.codex-editor-extension"
    "project-accelerate.shared-state-store"
    "project-accelerate.vscode-edit-table"
    "frontier-rnd.frontier-authentication"
)

# Create directories if they don't exist
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$EXTRACT_DIR"

# Function to download and extract extension
download_extension() {
    local extension="$1"
    local namespace="${extension%.*}"
    local name="${extension#*.}"
    
    echo "Processing extension: $extension"
    
    # Get latest version info
    local api_url="$OPENVSX_API/$namespace/$name"
    local version_info=$(curl -s "$api_url")
    
    if [ $? -ne 0 ] || [ -z "$version_info" ]; then
        echo "Error: Failed to fetch info for $extension"
        return 1
    fi
    
    # Extract latest version
    local latest_version=$(echo "$version_info" | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$latest_version" ]; then
        echo "Error: Could not determine latest version for $extension"
        return 1
    fi
    
    echo "Latest version: $latest_version"
    
    # Download URL
    local download_url="$OPENVSX_API/$namespace/$name/$latest_version/file/$namespace.$name-$latest_version.vsix"
    local filename="$namespace.$name-$latest_version.vsix"
    local filepath="$DOWNLOAD_DIR/$filename"
    
    # Download the extension
    echo "Downloading to: $filepath"
    curl -L -o "$filepath" "$download_url"
    
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded: $filename"
        
        # Extract the VSIX file
        local extract_path="$EXTRACT_DIR/$namespace.$name-$latest_version"
        echo "Extracting to: $extract_path"
        
        mkdir -p "$extract_path"
        unzip -q "$filepath" -d "$extract_path"
        
        if [ $? -eq 0 ]; then
            echo "Successfully extracted: $filename"
        else
            echo "Error: Failed to extract $filename"
            return 1
        fi
    else
        echo "Error: Failed to download $extension"
        return 1
    fi
    
    echo "---"
}

# Main execution
echo "Starting extension downloads and extraction..."
echo "Download directory: $DOWNLOAD_DIR"
echo "Extract directory: $EXTRACT_DIR"
echo "---"

for extension in "${EXTENSIONS[@]}"; do
    download_extension "$extension"
done

echo "Download and extraction process completed!"
