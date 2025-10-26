#!/bin/bash
echo "Updating system packages..."
apt update && apt upgrade -y

if [ $? -ne 0 ]; then
    echo "❌ System update failed!"
    exit 1
fi

echo "✅ System update completed!\n"
