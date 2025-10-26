#!/bin/bash

echo "Cleaning up..."
apt autoremove -y
apt autoclean

echo "🏁 Installation completed! ✅"
