#!/bin/bash

# Function to install speedtest-cli based on package manager
install_speedtest() {
    pip install speedtest-cli
}

# Check if speedtest-cli is installed
if ! command -v speedtest-cli &> /dev/null; then
    echo "speedtest-cli not found. Installing..."
    install_speedtest
fi

# Run the speed test
speedtest-cli


# Make sure you give it executable permissions
# chmod +x test_speed.sh
