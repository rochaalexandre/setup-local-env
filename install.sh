#!/bin/sh

# Check if script is run as root
is_not_user_root() {
    [ "$(id -u)" -ne 0 ]
}

if is_not_user_root; then
    echo "You must be a root user to run this script. Please use: sudo ./install.sh" 2>&1
    exit 1
fi

# Get username for UID 1000
username=$(id -u -n 1000)
export username

# Counters for tracking results
success_count=0
fail_count=0
total_count=0

echo "🚀 Starting installation process..."

# Run each script in the scripts directory
for script in ./scripts/*.sh; do
    script_name=$(basename "$script")
    echo ""
    echo "=========================================="
    echo "📦 Running $script_name..."
    echo "=========================================="
    
    # Run the script and capture exit code
    if sh "$script"; then
        success_count=$((success_count + 1))
        echo ""
        echo "✅ SUCCESS: $script_name completed successfully"
    else
        exit_code=$?
        fail_count=$((fail_count + 1))
        echo ""
        echo "❌ FAILED: $script_name failed (exit code: $exit_code)"
    fi
    total_count=$((total_count + 1))
done

echo ""
echo "📊 Installation Summary:"
echo "=========================================="
echo "Total scripts: $total_count"
echo "Successful: $success_count"
echo "Failed: $fail_count"
echo "=========================================="

if [ $fail_count -eq 0 ]; then
    echo ""
    echo "🎉 All installations completed successfully!"
    exit 0
else
    echo ""
    echo "⚠️  Some installations failed. Please check the logs above for details."
    exit 1
fi
