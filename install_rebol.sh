#!/bin/bash
#
# This script installs the Rebol/Bulk version 3.19.0 for Linux x86-64.
# It is designed to be run in a fresh environment to make the 'rebol3-bulk'
# executable available.

# Exit immediately if a command exits with a non-zero status.
set -e

# 1. Download the specific bulk binary
echo "Downloading Rebol binary..."
curl -LJO https://github.com/Oldes/Rebol3/releases/download/3.19.0/rebol3-bulk-linux-x64.gz

# 2. Extract the executable
echo "Decompressing the binary..."
gunzip rebol3-bulk-linux-x64.gz

# 3. Prepare the executable: Rename and make it executable
echo "Preparing the executable..."
mv rebol3-bulk-linux-x64 rebol3-bulk
chmod +x rebol3-bulk

# 4. Verify the installation
echo "Verifying the installation..."
./rebol3-bulk -v

echo "Rebol/Bulk 3.19.0 installation complete."
