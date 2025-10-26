#!/bin/bash

echo "Cleaning up..."
apt autoremove -y
apt autoclean

if [ $? -ne 0 ]; then
    echo "❌ Cleanup failed!"
    exit 1
fi

echo "🏁 Installation completed! ✅"
