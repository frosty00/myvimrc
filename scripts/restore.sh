#!/usr/local/bin/bash

# ==============================================================================
# LEASEWEB OBJECT STORAGE INTERACTIVE RESTORE SCRIPT (BASH EDITION)
# ==============================================================================
# MODIFIED: Now overwrites an existing partition (4-8) instead of creating a new one
#           Two interactive select menus: 1) backup file from S3, 2) target partition

# 1. Configuration Settings
REMOTE_NAME="leaseweb"
BUCKET_NAME="freebsd-seedbox"

# Verify rclone is configured
if ! rclone listremotes | grep -q "^${REMOTE_NAME}:$"; then
    echo "CRITICAL ERROR: Rclone remote profile '${REMOTE_NAME}' not found."
    exit 1
fi

# Verify pv (Pipe Viewer) is installed
if ! command -v pv &> /dev/null; then
    echo "CRITICAL ERROR: 'pv' is not installed. Run: pkg install pv"
    exit 1
fi

echo "======================================================================"
echo " STEP 1: Fetching available backups from Leaseweb S3..."
echo "======================================================================"

# Read backup objects into a Bash array
IFS=$'\n' read -r -d '' -a FILE_LIST < <(rclone lsf --recursive --files-only "${REMOTE_NAME}:${BUCKET_NAME}" --include "*.dump.gz" && printf '\0')

if [ ${#FILE_LIST[@]} -eq 0 ]; then
    echo "ERROR: No backup files (.dump.gz) found in bucket '${BUCKET_NAME}'."
    exit 1
fi

# Present interactive menu to the user for backup selection
echo "Select the backup file you want to restore from:"
echo "----------------------------------------------------------------------"
PS3="Enter the number of your choice: "
select CHOSEN_FILE in "${FILE_LIST[@]}"; do
    if [ -n "$CHOSEN_FILE" ]; then
        echo -e "\nYou selected backup file: ${CHOSEN_FILE}"
        break
    else
        echo "Invalid choice. Please enter a valid number from the menu."
    fi
done

# Extract base partition name from the path string (for reference only)
PART_NAME=$(echo "${CHOSEN_FILE}" | cut -d'/' -f1)
FULL_REMOTE_PATH="${REMOTE_NAME}:${BUCKET_NAME}/${CHOSEN_FILE}"

echo -e "\n======================================================================"
echo " STEP 2: Select Target Partition to OVERWRITE"
echo "======================================================================"
echo "WARNING: This will DESTROY ALL DATA on the selected partition!"
echo "         The operation is IRREVERSIBLE without a separate backup."
echo ""

# The options are partitions 4-8 with the labels torrent to oldroot
PART_DISPLAY=(
    "torrent   (16G)"
    "nginx     (16G)"
    "olduser   (64G)"
    "oldvar    (8.0G)"
    "oldroot   (8.0G)"
    "oldscripts (32G)"
)
PART_LABELS=("torrent" "nginx" "olduser" "oldvar" "oldroot" "oldscripts")

PS3="Select partition to overwrite (enter number 1-5): "
select CHOICE in "${PART_DISPLAY[@]}"; do
    if [ -n "$CHOICE" ]; then
        # Map selection to label
        idx=$((REPLY - 1))
        TARGET_LABEL="${PART_LABELS[$idx]}"
        DEV_TARGET="/dev/gpt/${TARGET_LABEL}"
        echo -e "\nYou selected to OVERWRITE: ${CHOICE} → ${DEV_TARGET}"
        break
    else
        echo "Invalid choice. Please enter a valid number from the menu."
    fi
done

# Automatically unmount if the target is currently mounted
if mount | grep -q "${DEV_TARGET}"; then
    echo "Target partition is mounted - unmounting now..."
    umount "${DEV_TARGET}" 2>/dev/null || umount -f "${DEV_TARGET}" 2>/dev/null || true
    echo "Unmounted successfully."
fi

# Verify the target device actually exists
if [ ! -c "${DEV_TARGET}" ]; then
    echo "CRITICAL ERROR: Target device ${DEV_TARGET} does not exist in /dev/gpt."
    exit 1
fi

# Optional size info (kept for user awareness, no longer used for gpart)
echo -e "\nQuerying Leaseweb S3 for backup file metrics..."
REMOTE_SIZE=$(rclone size "${FULL_REMOTE_PATH}" --json 2>/dev/null | tr -d '[:space:]' | sed -E 's/.*"bytes":([0-9]+).*/\1/')

if [[ -z "$REMOTE_SIZE" || "$REMOTE_SIZE" -eq 0 ]]; then
    echo "CRITICAL ERROR: Could not locate backup file or file is empty on Leaseweb."
    exit 1
fi

COMPRESSED_MB=$(( REMOTE_SIZE / 1024 / 1024 ))
UNCOMPRESSED_EST_MB=$(( COMPRESSED_MB * 2 ))
echo "Compressed S3 Object Size: ${COMPRESSED_MB} MB"
echo "Estimated Uncompressed Footprint: ${UNCOMPRESSED_EST_MB} MB"
echo "======================================================================"

# Double confirmation before destructive action
echo -e "\nYou are about to RESTORE '${CHOSEN_FILE}' OVERWRITING '${TARGET_LABEL}' (${DEV_TARGET})"
read -p "Type 'YES' (all caps) to confirm and proceed: " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
    echo "Operation aborted by user."
    exit 0
fi

set -e
echo -e "\n======================================================================"
echo " STEP 3: Initializing File System & Streaming Restore Pipeline"
echo "======================================================================"

echo "Formatting target partition ${DEV_TARGET} with fresh UFS layout (1% Minfree)..."
newfs -m 1 -U "${DEV_TARGET}" > /dev/null

MOUNT_POINT="/mnt/restore_$$"
mkdir -p "${MOUNT_POINT}"
mount "${DEV_TARGET}" "${MOUNT_POINT}"

echo "Restoring into ${MOUNT_POINT}..."
cd "${MOUNT_POINT}"


echo "Streaming data blocks down from cloud instance..."
echo "----------------------------------------------------------------------"

# Stream execution loop: Rclone → PV → Gzip → Restore
rclone cat "${FULL_REMOTE_PATH}" | \
pv -s "${REMOTE_SIZE}" -N "Downloading & Restoring to ${TARGET_LABEL}" -p -t -e -r -b | \
/usr/bin/gzip -d | \
/sbin/restore -rf -

# Track the pipeline statuses
PIPES_STATUS=("${PIPESTATUS[@]}")

if [[ "${PIPES_STATUS[0]}" -eq 0 && "${PIPES_STATUS[3]}" -eq 0 ]]; then
    echo -e "\n======================================================================"
    echo " SUCCESS: System volume restoration sequence complete."
    echo " Restored backup '${CHOSEN_FILE}' to: ${DEV_TARGET}"
    echo " You can mount it using: mount ${DEV_TARGET} <your_mount_point>"
    echo "======================================================================"
    cd /mnt
    umount "${MOUNT_POINT}"
    rmdir "${MOUNT_POINT}"
else
    echo -e "\n======================================================================"
    echo " CRITICAL FAILURE: Pipeline broke mid-operation."
    echo " Debug PIPESTATUS: Rclone=${PIPES_STATUS[0]}, PV=${PIPES_STATUS[1]}, Gzip=${PIPES_STATUS[2]}, Restore=${PIPES_STATUS[3]}"
    echo "======================================================================"
fi
