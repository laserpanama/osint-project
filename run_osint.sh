#!/bin/bash

# Automated OSINT Workflow Orchestrator
# This script reads its configuration from subject.yml and runs the selected tools.

# --- Configuration ---
# Source the configuration from the python parser script.
# The 'eval' command executes the 'export' statements printed by the python script.
eval "$(python3 /opt/config_parser.py)"
if [ $? -ne 0 ]; then
    echo "[!] Failed to parse subject.yml. Please check the file and its permissions."
    exit 1
fi

# Check if any usernames were provided
if [ -z "$USERNAMES" ]; then
  echo "[!] No usernames found in subject.yml. Nothing to do."
  echo "[*] Add at least one username to the 'usernames' list in subject.yml."
  exit 1
fi

DATE=$(date +"%Y%m%d_%H%M")
BASE_OUTDIR="/opt/output"
OUTDIR="$BASE_OUTDIR/investigation_${SUBJECT_NAME}_${DATE}"
LOGFILE="$OUTDIR/run.log"

# --- Setup ---
mkdir -p "$OUTDIR"
# Redirect all output to a log file and the console
exec > >(tee -a "$LOGFILE") 2>&1

echo "================================================="
echo "  Starting OSINT Investigation"
echo "  Subject: $SUBJECT_NAME"
echo "  Timestamp: $(date)"
echo "================================================="
echo "[*] Main output directory: $OUTDIR"

# Function for basic error checking
check_error() {
  if [ $? -ne 0 ]; then
    echo "[!] An error occurred during: $1."
    echo "[!] Check the log for details: $LOGFILE"
    # We don't exit here to allow the script to continue with other usernames/tools.
  fi
}

# --- Workflow ---

echo "[*] Starting Tor service for anonymized requests..."
sudo service tor start
check_error "Tor service start"

# Loop through each username provided in the config
for USERNAME in $USERNAMES; do
    echo ""
    echo "--- Processing username: $USERNAME ---"
    USER_OUTDIR="$OUTDIR/$USERNAME"
    mkdir -p "$USER_OUTDIR"

    # --- Run Sherlock ---
    if [ "$RUN_SHERLOCK" = "true" ]; then
        echo "[*] Running Sherlock for $USERNAME..."
        cd /opt/sherlock
        python3 sherlock "$USERNAME" --tor --output "$USER_OUTDIR/sherlock_${USERNAME}.txt"
        check_error "Sherlock scan for $USERNAME"
        cd /opt
    else
        echo "[-] Sherlock scan skipped by configuration."
    fi

    # --- Run Maigret ---
    if [ "$RUN_MAIGRET" = "true" ]; then
        echo "[*] Running Maigret for $USERNAME..."
        cd /opt/maigret
        # Maigret saves to current dir, so we cd into the output dir first
        cd "$USER_OUTDIR"
        python3 /opt/maigret/maigret "$USERNAME" --tor --print-found --pdf
        check_error "Maigret scan for $USERNAME"
        cd /opt
    else
        echo "[-] Maigret scan skipped by configuration."
    fi
done

# --- EXIF & Media Analysis ---
if [ "$RUN_EXIFTOOL" = "true" ]; then
    echo ""
    echo "--- Processing Media Files (EXIF Analysis) ---"
    MEDIA_DIR="$OUTDIR/media_for_analysis"
    mkdir -p "$MEDIA_DIR"
    echo "Place media files here and re-run if needed." > "$MEDIA_DIR/README.md"

    if [ -n "$(find "$MEDIA_DIR" -type f -maxdepth 1)" ]; then
        echo "[*] Media files found. Performing EXIF analysis..."
        exiftool "$MEDIA_DIR"/* > "$OUTDIR/exif_report.txt"
        check_error "EXIF analysis"
    else
        echo "[*] No media files found in $MEDIA_DIR. Skipping EXIF scan."
    fi
else
    echo "[-] EXIF analysis skipped by configuration."
fi

# --- Final Notes ---
echo ""
echo "================================================="
echo "[✔] OSINT workflow complete."
echo "[*] All results are located in: $OUTDIR"
echo "[*] Remember to check the SpiderFoot UI at http://localhost:5001 for broader scans."
echo "================================================="
