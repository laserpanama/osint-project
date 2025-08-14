#!/bin/bash

# #############################################################################
# KALI GPT OSINT WORKFLOW
#
# Description:
# This script automates a comprehensive OSINT (Open Source Intelligence)
# investigation workflow. It uses a variety of tools to gather information
# on a specific target.
#
# Target: Yahaira Arosemena
#
# DISCLAIMER:
# This script is for educational and research purposes only. The user is
# responsible for complying with all applicable laws and regulations
# regarding OSINT and data privacy. The author of this script is not
# responsible for any misuse or damage caused by this script.
# #############################################################################

# --- Configuration ---
TARGET_USERNAME="Yahaira Arosemena"
TARGET_PHONE="+50769674636"
RESULTS_DIR="osint_results_$(date +%Y%m%d_%H%M%S)"
# Add your API keys here
NUMVERIFY_API_KEY="YOUR_NUMVERIFY_API_KEY"


# --- Functions ---

# Function to create the results directory
setup_environment() {
    echo "[*] Creating results directory: ${RESULTS_DIR}"
    mkdir -p "${RESULTS_DIR}"
    echo "[+] Environment setup complete."
}

# Function to run Sherlock for username enumeration
run_sherlock() {
    echo "[*] Running Sherlock for username enumeration..."
    if ! command -v sherlock &> /dev/null; then
        echo "[!] Sherlock is not installed. Please install it to use this feature."
        return
    fi
    # The username might contain spaces, which Sherlock doesn't handle well in some versions.
    # Using quotes is important.
    sherlock "${TARGET_USERNAME}" --output "${RESULTS_DIR}/sherlock_results.txt"
    echo "[+] Sherlock scan complete. Results saved in ${RESULTS_DIR}/sherlock_results.txt"
}

# Function to run Maigret for profile correlation
run_maigret() {
    echo "[*] Running Maigret for profile correlation..."
    if ! command -v maigret &> /dev/null; then
        echo "[!] Maigret is not installed. Please install it to use this feature."
        return
    fi
    maigret "${TARGET_USERNAME}" --report-path "${RESULTS_DIR}/maigret/"
    echo "[+] Maigret scan complete. Results saved in ${RESULTS_DIR}/maigret/"
}

# Function to start SpiderFoot for automated reconnaissance
start_spiderfoot() {
    echo "[*] Starting SpiderFoot for automated reconnaissance..."
    if ! command -v spiderfoot &> /dev/null; then
        echo "[!] SpiderFoot is not installed. Please install it to use this feature."
        return
    fi
    # Starting SpiderFoot in the background.
    # The user needs to manually interact with the web interface to perform scans.
    spiderfoot -l 127.0.0.1:5001 &
    SPIDERFOOT_PID=$!
    echo "[+] SpiderFoot started in the background (PID: ${SPIDERFOOT_PID})."
    echo "    Web UI should be available at http://127.0.0.1:5001"
    echo "    Run 'kill ${SPIDERFOOT_PID}' to stop it."
}

# Function to run Twint for social media monitoring
run_twint() {
    echo "[*] Running Twint for social media monitoring..."
    if ! command -v twint &> /dev/null; then
        echo "[!] Twint is not installed. Please install it to use this feature."
        echo "[!] Note: Twint may have issues due to changes in Twitter's API."
        return
    fi
    twint -u "${TARGET_USERNAME}" -o "${RESULTS_DIR}/twint_results.csv" --csv
    echo "[+] Twint scan complete. Results saved in ${RESULTS_DIR}/twint_results.csv"
}

# Function for Recon-ng data correlation
run_recon_ng() {
    echo "[*] Running Recon-ng for data correlation..."
    if ! command -v recon-ng &> /dev/null; then
        echo "[!] Recon-ng is not installed. Please install it to use this feature."
        return
    fi
    echo "[+] Recon-ng is an interactive framework. Automation can be complex."
    echo "    It's recommended to run it manually to explore the data:"
    echo "    1. Run 'recon-ng'"
    echo "    2. 'workspaces create ${TARGET_USERNAME// /_}'"
    echo "    3. 'db insert contacts ...' (with found data)"
    echo "    4. 'modules load ...' and run them."
}

# Function for EXIF analysis
run_exif_analysis() {
    echo "[*] Performing EXIF analysis..."
    if ! command -v exiftool &> /dev/null; then
        echo "[!] exiftool is not installed. Please install it to use this feature."
        return
    fi
    MEDIA_DIR="${RESULTS_DIR}/media_for_exif"
    mkdir -p "${MEDIA_DIR}"
    echo "[+] Created directory ${MEDIA_DIR} for media files."
    echo "    Please place any media files (images, videos, documents) in this directory before running the script."

    # Check if there are any files to analyze
    if [ -z "$(ls -A ${MEDIA_DIR} 2>/dev/null)" ]; then
        echo "[!] No media files found in ${MEDIA_DIR}. Skipping EXIF analysis."
        return
    fi
    echo "[*] Analyzing files in ${MEDIA_DIR}..."
    exiftool "${MEDIA_DIR}"/* > "${RESULTS_DIR}/exif_analysis.txt"
    echo "[+] EXIF analysis complete. Results saved in ${RESULTS_DIR}/exif_analysis.txt"
}

# Function for Numverify phone number lookup
run_numverify() {
    echo "[*] Running Numverify for phone number lookup..."
    if [ "${NUMVERIFY_API_KEY}" == "YOUR_NUMVERIFY_API_KEY" ]; then
        echo "[!] Numverify API key not set. Please add your key to the script."
        return
    fi
    if ! command -v curl &> /dev/null; then
        echo "[!] curl is not installed. Please install it to use this feature."
        return
    fi
    echo "[*] Querying Numverify API for ${TARGET_PHONE}..."
    curl -s "http://apilayer.net/api/validate?access_key=${NUMVERIFY_API_KEY}&number=${TARGET_PHONE}" -o "${RESULTS_DIR}/numverify_results.json"
    echo "[+] Numverify scan complete. Results saved in ${RESULTS_DIR}/numverify_results.json"
}

# Placeholder for manual checks
manual_checks() {
    echo "[*] Manual checks and instructions:"
    echo "    - WhatsApp Profile: Check if the phone number ${TARGET_PHONE} is associated with a WhatsApp profile."
    echo "    - LinkedIn Profile: Manually search for '${TARGET_USERNAME}' on LinkedIn."
    echo "    - Android Device Logs: On the target's Android device (if accessible), dial *#*#4636#*#* to check app usage statistics."
    echo "    - Maltego: Import all data from the ${RESULTS_DIR} folder into a Maltego CaseFile for visualization."
}


# --- Main Workflow ---
main() {
    echo "###########################################"
    echo "#         STARTING OSINT WORKFLOW         #"
    echo "###########################################"
    echo
    echo "Target Username: ${TARGET_USERNAME}"
    echo "Target Phone:    ${TARGET_PHONE}"
    echo

    setup_environment
    run_sherlock
    run_maigret
    start_spiderfoot
    run_twint
    run_recon_ng
    run_exif_analysis
    run_numverify
    manual_checks

    echo
    echo "###########################################"
    echo "#          OSINT WORKFLOW COMPLETE        #"
    echo "###########################################"
    echo "All results have been saved in the '${RESULTS_DIR}' directory."
}

# Execute the main function
main
