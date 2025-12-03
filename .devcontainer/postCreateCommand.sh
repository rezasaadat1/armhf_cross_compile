#!/bin/bash
# ============================================================================
# Post-Create Setup Script for Dev Container
# ============================================================================
# This script runs after the dev container is created.
# Add any project-specific initialization here.
# ============================================================================

set -e

echo "==> Running post-create setup..."

# Verify cross-compilers are installed
echo "==> Verifying cross-compiler installation..."
for compiler in arm-linux-gnueabihf-g++ aarch64-linux-gnu-g++ riscv64-linux-gnu-g++; do
    if command -v $compiler &> /dev/null; then
        echo "   ✓ $compiler found"
    else
        echo "   ✗ $compiler not found"
    fi
done

# Create project directories if they don't exist
echo "==> Ensuring project directories exist..."
mkdir -p include lib host/include host/lib

# Set execute permissions on scripts
echo "==> Setting script permissions..."
chmod +x deploy.sh 2>/dev/null || true

# Display environment info
echo ""
echo "==> Environment Information:"
echo "   Host: $(uname -m)"
echo "   GCC:  $(gcc --version | head -n1)"
echo ""
echo "==> Dev container setup complete!"
echo "   Run 'make help' to see available build targets."
echo ""