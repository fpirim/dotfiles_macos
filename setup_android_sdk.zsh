#!/usr/bin/env zsh

echo "\n<<< Starting Android SDK Setup >>>\n"

# Set Android SDK directory
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export CMDLINE_TOOLS_DIR="$ANDROID_SDK_ROOT/cmdline-tools/latest"

# Check if Android SDK command-line tools are already installed
if [ -d "$CMDLINE_TOOLS_DIR" ] && [ -f "$CMDLINE_TOOLS_DIR/bin/sdkmanager" ]; then
    echo "Android SDK command-line tools are already installed at $CMDLINE_TOOLS_DIR"
else
    echo "Installing Android SDK command-line tools..."

    # Create temporary download directory
    TEMP_DIR=$(mktemp -d)
    ZIP_FILE="$TEMP_DIR/commandlinetools.zip"

    # Download command-line tools
    echo "Downloading Android command-line tools..."
    curl -L -o "$ZIP_FILE" "https://dl.google.com/android/repository/commandlinetools-mac-13114758_latest.zip"

    # Check if download was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download Android command-line tools"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Extract the zip file
    echo "Extracting command-line tools..."
    unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

    # Create Android SDK directory structure
    echo "Creating Android SDK directory structure..."
    mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"

    # Move cmdline-tools to the correct location
    echo "Moving command-line tools to $CMDLINE_TOOLS_DIR..."
    mv "$TEMP_DIR/cmdline-tools" "$CMDLINE_TOOLS_DIR"

    # Clean up
    rm -rf "$TEMP_DIR"

    echo "Android SDK command-line tools installed successfully"
fi

# Verify installation
if [ -f "$CMDLINE_TOOLS_DIR/bin/sdkmanager" ]; then
    echo "\nVerifying installation..."
    echo "Android SDK location: $ANDROID_SDK_ROOT"
    echo "Command-line tools location: $CMDLINE_TOOLS_DIR"
    echo "sdkmanager found at: $CMDLINE_TOOLS_DIR/bin/sdkmanager"
else
    echo "\nWarning: sdkmanager not found. Installation may have failed."
fi

echo "\n<<< Android SDK Setup Complete >>>\n"
