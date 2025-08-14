#!/bin/bash

# #############################################################################
# KALI GPT OSINT WORKFLOW
#
# Description:
# This script automates a comprehensive OSINT (Open Source Intelligence)
# investigation workflow. It uses a variety of tools to gather information
# on a specific target.
#
# DISCLAIMER:
# This script is for educational and research purposes only. The user is
# responsible for complying with all applicable laws and regulations
# regarding OSINT and data privacy. The author of this script is not
# responsible for any misuse or damage caused by this script.
# #############################################################################

# --- Usage ---
# To run the script, use:
#   chmod +x osint_workflow.sh
#   ./osint_workflow.sh -u <USERNAME> -p <PHONE_NUMBER> [-m <MEDIA_DIRECTORY>]
#
# Before running, set your API key:
#   export NUMVERIFY_API_KEY="your-key-here"
#
# To stop SpiderFoot gracefully, use 'kill <PID>'
# #############################################################################


# --- Configuration ---
RESULTS_DIR="osint_results_$(date +%Y%m%d_%H%M%S)"
# Add your API keys here
NUMVERIFY_API_KEY="${NUMVERIFY_API_KEY:-YOUR_NUMVERIFY_API_KEY}"
SPIDERFOOT_PID=""
TARGET_USERNAME=""
TARGET_PHONE=""
MEDIA_DIR=""

# --- Functions ---

# Function to display usage information
usage() {
    echo "Usage: $0 -u <USERNAME> -p <PHONE_NUMBER> [-m <MEDIA_DIRECTORY>]"
    echo "  -u    Target username"
    echo "  -p    Target phone number (e.g., +1234567890)"
    echo "  -m    (Optional) Directory with media files for EXIF analysis"
    exit 1
}

# Function to handle errors and exit gracefully
check_error() {
    if [ $? -ne 0 ]; then
        echo "[!] ERROR: '$1' failed. Check the output above for details."
        cleanup
        exit 1
    fi
}

# Function to clean up background processes
cleanup() {
    echo "[*] Cleaning up background processes..."
    if [ -n "${SPIDERFOOT_PID}" ]; then
        kill "${SPIDERFOOT_PID}" &> /dev/null
        echo "[+] SpiderFoot (PID: ${SPIDERFOOT_PID}) has been stopped."
    fi
}

# Function to create the results directory
setup_environment() {
    echo "[*] Creating results directory: ${RESULTS_DIR}"
    mkdir -p "${RESULTS_DIR}"
    check_error "mkdir"
    echo "[+] Environment setup complete."
}

# Function to run Sherlock for username enumeration
run_sherlock() {
    echo "[*] Running Sherlock for username enumeration..."
    if ! command -v sherlock &> /dev/null; then
        echo "[!] Sherlock is not installed. Please install it to use this feature."
        echo "[?] Try: pip install sherlock-project"
        return
    fi
    sherlock "${TARGET_USERNAME}" --output "${RESULTS_DIR}/sherlock_results.txt"
    check_error "Sherlock"
    echo "[+] Sherlock scan complete. Results saved in ${RESULTS_DIR}/sherlock_results.txt"
}

# Function to run Maigret for profile correlation
run_maigret() {
    echo "[*] Running Maigret for profile correlation..."
    if ! command -v maigret &> /dev/null; then
        echo "[!] Maigret is not installed. Please install it to use this feature."
        echo "[?] Try: pip install maigret"
        return
    fi
    maigret "${TARGET_USERNAME}" --report-path "${RESULTS_DIR}/maigret/"
    check_error "Maigret"
    echo "[+] Maigret scan complete. Results saved in ${RESULTS_DIR}/maigret/"
}

# Function to start SpiderFoot for automated reconnaissance
start_spiderfoot() {
    echo "[*] Starting SpiderFoot for automated reconnaissance..."
    if ! command -v spiderfoot &> /dev/null; then
        echo "[!] SpiderFoot is not installed. Please install it to use this feature."
        echo "[?] Try: pip install spiderfoot"
        return
    fi
    # Starting SpiderFoot in the background.
    # The user needs to manually interact with the web interface to perform scans.
    spiderfoot -l 127.0.0.1:5001 &
    SPIDERFOOT_PID=$!
    echo "[+] SpiderFoot started in the background (PID: ${SPIDERFOOT_PID})."
    echo "    Web UI should be available at http://127.0.0.1:5001"
    echo "    Remember to run 'cleanup' or 'kill ${SPIDERFOOT_PID}' to stop it."
}

# Function to run Twint for social media monitoring
run_twint() {
    echo "[*] Running Twint for social media monitoring..."
    if ! command -v twint &> /dev/null; then
        echo "[!] Twint is not installed. Please install it to use this feature."
        echo "[?] Try: pip install twint"
        echo "[!] Note: Twint may have issues due to changes in Twitter's API."
        return
    fi
    twint -u "${TARGET_USERNAME}" -o "${RESULTS_DIR}/twint_results.csv" --csv
    check_error "Twint"
    echo "[+] Twint scan complete. Results saved in ${RESULTS_DIR}/twint_results.csv"
}

# Function for Recon-ng data correlation
run_recon_ng() {
    echo "[*] Running Recon-ng for data correlation..."
    if ! command -v recon-ng &> /dev/null; then
        echo "[!] Recon-ng is not installed. Please install it to use this feature."
        echo "[?] Try: sudo apt update && sudo apt install recon-ng"
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

    if [ -z "${MEDIA_DIR}" ]; then
        echo "[+] No media directory provided (-m). Skipping EXIF analysis."
        return
    fi

    if [ ! -d "${MEDIA_DIR}" ]; then
        echo "[!] Media directory '${MEDIA_DIR}' not found. Skipping EXIF analysis."
        return
    fi

    if ! command -v exiftool &> /dev/null; then
        echo "[!] exiftool is not installed. Please install it to use this feature."
        echo "[?] Try: sudo apt update && sudo apt install libimage-exiftool-perl"
        return
    fi

    # Check if there are any files to analyze
    if [ -z "$(ls -A "${MEDIA_DIR}" 2>/dev/null)" ]; then
        echo "[!] No media files found in '${MEDIA_DIR}'. Skipping EXIF analysis."
        return
    fi

    echo "[*] Analyzing files in '${MEDIA_DIR}'..."
    exiftool "${MEDIA_DIR}"/* > "${RESULTS_DIR}/exif_analysis.txt"
    check_error "exiftool"
    echo "[+] EXIF analysis complete. Results saved in ${RESULTS_DIR}/exif_analysis.txt"
}

# Function for Numverify phone number lookup
run_numverify() {
    echo "[*] Running Numverify for phone number lookup..."
    if [ "${NUMVERIFY_API_KEY}" == "YOUR_NUMVERIFY_API_KEY" ]; then
        echo "[!] Numverify API key not set. Please add your key to the script or set it as an environment variable."
        return
    fi
    if ! command -v curl &> /dev/null; then
        echo "[!] curl is not installed. Please install it to use this feature."
        echo "[?] Try: sudo apt update && sudo apt install curl"
        return
    fi
    echo "[*] Querying Numverify API for ${TARGET_PHONE}..."
    curl -s "http://apilayer.net/api/validate?access_key=${NUMVERIFY_API_KEY}&number=${TARGET_PHONE}" -o "${RESULTS_DIR}/numverify_results.json"
    check_error "Numverify API call"
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
    # Parse command-line arguments
    while getopts "u:p:m:h" opt; do
        case ${opt} in
            u) TARGET_USERNAME=${OPTARG} ;;
            p) TARGET_PHONE=${OPTARG} ;;
            m) MEDIA_DIR=${OPTARG} ;;
            h) usage ;;
            *) usage ;;
        esac
    done

    # Check if required arguments are provided
    if [ -z "${TARGET_USERNAME}" ] || [ -z "${TARGET_PHONE}" ]; then
        usage
    fi

    # Set up a trap to ensure cleanup runs even if the script is terminated early
    trap cleanup EXIT

    echo "###########################################"
    echo "#         STARTING OSINT WORKFLOW         #"
    echo "###########################################"
    echo
    echo "Target Username: ${TARGET_USERNAME}"
    echo "Target Phone:    ${TARGET_PHONE}"
    [ -n "${MEDIA_DIR}" ] && echo "Media Directory: ${MEDIA_DIR}"
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
    echo "#         OSINT WORKFLOW COMPLETE         #"
    echo "###########################################"
    echo "All results have been saved in the '${RESULTS_DIR}' directory."
}

# Execute the main function
main
