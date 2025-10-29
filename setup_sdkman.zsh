#!/usr/bin/env zsh

echo "\n<<< Starting SDKMAN Setup >>>\n"

# Set SDKMAN directory
export SDKMAN_DIR="$HOME/.sdkman"

# Check if SDKMAN is already installed
if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
    echo "SDKMAN is already installed at $SDKMAN_DIR"
else
    echo "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
fi

# Load SDKMAN
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Determine the best JDK 25 version to install
# Try OpenJDK first as it's the most common and open-source
JDK_VERSION="25.0.1-open"

# Check if JDK 25 is already installed
if sdk current java 2>/dev/null | grep -q "25\."; then
    CURRENT_JDK=$(sdk current java 2>/dev/null | awk '{print $NF}')
    echo "JDK 25 is already set as current: $CURRENT_JDK"
elif [ -d "$SDKMAN_DIR/candidates/java/$JDK_VERSION" ]; then
    echo "JDK $JDK_VERSION is already installed"
else
    echo "Installing JDK $JDK_VERSION..."
    sdk install java $JDK_VERSION
fi

# Set JDK 25 as default
echo "Setting JDK $JDK_VERSION as default..."
sdk default java $JDK_VERSION

# Verify installation
echo "\nJava version:"
java -version

echo "\nJAVA_HOME: $JAVA_HOME"

# List installed Java versions
echo "\nInstalled Java versions:"
sdk list java | grep installed

echo "\n<<< SDKMAN Setup Complete >>>\n"
