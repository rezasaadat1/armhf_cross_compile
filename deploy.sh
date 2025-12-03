#!/bin/bash
# ============================================================================
# Deploy and Debug Script for Cross-Compiled Binaries
# ============================================================================
# This script deploys a binary to a remote target and starts gdbserver
# for remote debugging.
#
# Usage: ./deploy.sh <IP> <DEBUG_PORT> <BINARY> <DEST_DIR> <USER> <PASS>
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse arguments
DEST_IP="${1:?Error: TARGET_IP is required}"
DEBUG_PORT="${2:?Error: DEBUG_PORT is required}"
BINARY="${3:?Error: BINARY name is required}"
DEST_DIR="${4:?Error: DEST_DIR is required}"
USER="${5:?Error: USER is required}"
PASS="${6:?Error: PASS is required}"

# Validate binary exists
if [ ! -f "${BINARY}" ]; then
    log_error "Binary file '${BINARY}' not found!"
    log_info "Run 'make' first to build the binary."
    exit 1
fi

# Check if sshpass is available
if ! command -v sshpass &> /dev/null; then
    log_error "sshpass is not installed. Install it with: sudo apt install sshpass"
    exit 1
fi

log_info "Deploying to ${USER}@${DEST_IP}:${DEST_DIR}/${BINARY}"

# Kill existing gdbserver on target and delete old binary
log_info "Cleaning up previous deployment..."
sshpass -p "${PASS}" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
    "${USER}@${DEST_IP}" \
    "sh -c 'pkill -f gdbserver 2>/dev/null; rm -rf ${DEST_DIR}/${BINARY}; exit 0'" || true

# Send binary to target
log_info "Uploading binary..."
sshpass -p "${PASS}" scp -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
    "${BINARY}" "${USER}@${DEST_IP}:${DEST_DIR}/${BINARY}"

# Make binary executable
sshpass -p "${PASS}" ssh -o StrictHostKeyChecking=no \
    "${USER}@${DEST_IP}" "chmod +x ${DEST_DIR}/${BINARY}"

# Start gdbserver on target
log_info "Starting gdbserver on ${DEST_IP}:${DEBUG_PORT}..."
sshpass -p "${PASS}" ssh -t -o StrictHostKeyChecking=no \
    "${USER}@${DEST_IP}" \
    "sh -c 'cd ${DEST_DIR}; gdbserver localhost:${DEBUG_PORT} ${BINARY}'"

# ============================================================================
# Alternative: Run with root privileges (uncomment if needed)
# ============================================================================
# sshpass -p "${PASS}" ssh -t "${USER}@${DEST_IP}" \
#     "cd ${DEST_DIR}; echo '${PASS}' | sudo -S gdbserver localhost:${DEBUG_PORT} ${BINARY}"