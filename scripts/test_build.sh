#!/bin/bash
# ============================================================================
# Test Script - Verify Build for All Supported Architectures
# ============================================================================
# This script builds the project for all supported architectures and reports
# any failures. Useful for CI and verifying the build setup.
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Track results
PASSED=0
FAILED=0
declare -a FAILED_ARCHS

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }

echo "============================================="
echo "  Cross-Compilation Build Test"
echo "============================================="
echo ""

# Clean first
log_info "Cleaning previous builds..."
make clean > /dev/null 2>&1 || true

# Test host compilation
log_info "Testing host compilation..."
if make host_compile > /dev/null 2>&1; then
    log_pass "Host compilation"
    PASSED=$((PASSED + 1))
else
    log_error "Host compilation"
    FAILED_ARCHS+=("host")
    FAILED=$((FAILED + 1))
fi

# Test default ARM HF compilation
log_info "Testing ARM HF compilation..."
if make > /dev/null 2>&1; then
    log_pass "ARM HF compilation"
    PASSED=$((PASSED + 1))
else
    log_error "ARM HF compilation"
    FAILED_ARCHS+=("armhf")
    FAILED=$((FAILED + 1))
fi

# Test cross-compilation for each architecture
declare -A ARCH_COMPILERS=(
    ["arm64"]="aarch64-linux-gnu-g++"
    ["armel"]="arm-linux-gnueabi-g++"
    ["riscv64"]="riscv64-linux-gnu-g++"
    ["amd64"]="x86_64-linux-gnu-g++"
    ["i386"]="i686-linux-gnu-g++"
)

for arch in "${!ARCH_COMPILERS[@]}"; do
    compiler="${ARCH_COMPILERS[$arch]}"

    # Check if compiler is available
    if ! command -v "$compiler" &> /dev/null; then
        log_warn "Skipping $arch - $compiler not found"
        continue
    fi

    log_info "Testing $arch compilation..."
    if CROSS_ARCH="$arch" CPP="$compiler" make cross_compile > /dev/null 2>&1; then
        log_pass "$arch compilation"
        PASSED=$((PASSED + 1))
    else
        log_error "$arch compilation"
        FAILED_ARCHS+=("$arch")
        FAILED=$((FAILED + 1))
    fi
done

# Summary
echo ""
echo "============================================="
echo "  Build Test Summary"
echo "============================================="
echo -e "  ${GREEN}Passed:${NC} $PASSED"
echo -e "  ${RED}Failed:${NC} $FAILED"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "  Failed architectures:"
    for arch in "${FAILED_ARCHS[@]}"; do
        echo "    - $arch"
    done
fi

echo "============================================="

# Clean up
make clean > /dev/null 2>&1 || true

# Exit with appropriate code
[ $FAILED -eq 0 ]
