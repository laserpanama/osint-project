
#!/bin/bash

# Kali GPT - Prioritized OSINT Workflow
USERNAME="<font color='red'>[USERNAME]</font>"
DATE=$(date +"%Y%m%d_%H%M")
OUTDIR="osint_<font color='red'>[USERNAME]</font>_$DATE"

mkdir -p $OUTDIR

# Step 1: Sherlock - Username Enumeration
echo "[*] Step 1: Running Sherlock for <font color='red'>[USERNAME]</font>..."
cd /opt/sherlock
python3 sherlock $USERNAME --tor --output ../$OUTDIR/sherlock_<font color='red'>[USERNAME]</font>.txt
cd ..

# Step 2: Maigret - Profile Correlation
echo "[*] Step 2: Running Maigret for <font color='red'>[USERNAME]</font>..."
cd /opt/maigret
python3 maigret $USERNAME --tor --print-found --pdf -o ../$OUTDIR
cd ..

# Step 3: SpiderFoot - Automated Recon
echo "[*] Step 3: Starting SpiderFoot for <font color='red'>[USERNAME]</font>..."
cd /opt/spiderfoot
nohup python3 sf.py -l 127.0.0.1:5001 > /dev/null 2>&1 &
sleep 10
xdg-open http://127.0.0.1:5001 &
cd ..

# Step 4: Leak Detection (HIBP)
echo "[*] Step 4: Checking for leaks on <font color='red'>[USERNAME_EMAIL]</font>..."
curl -s -H "hibp-api-key: <font color='red'>[YOUR_API_KEY]</font>" \
"https://haveibeenpwned.com/api/v3/breachedaccount/<font color='red'>[USERNAME_EMAIL]</font>" \
> $OUTDIR/hibp_<font color='red'>[USERNAME]</font>.json

# Step 5: EXIF Analysis (if media exists)
echo "[*] Step 5: Checking for media files for EXIF analysis..."
MEDIA_DIR="$OUTDIR/media"
mkdir -p $MEDIA_DIR
if [ "$(ls -A $MEDIA_DIR 2>/dev/null)" ]; then
  for img in "$MEDIA_DIR"/*.{jpg,jpeg,png,mp4,webm}; do
    if [ -f "$img" ]; then
      echo "[*] Analyzing $img"
      exiftool "$img" >> "$OUTDIR/exif_report_<font color='red'>[USERNAME]</font>.txt"
    fi
  done
else
  echo "[!] No media files found. Skipping EXIF scan."
fi

# Step 6: Maltego CaseFile Prep
echo "[*] Step 6: Preparing Maltego CaseFile import..."
cat << EOF > $OUTDIR/maltego_import_<font color='red'>[USERNAME]</font>.txt
[Maltego CaseFile Instructions for <font color='red'>[USERNAME]</font>]
---------------------------------------
1. Open Maltego CaseFile (run: maltego).
2. Create new graph, select "Person" or "Alias" entity.
3. Label it: <font color='red'>[USERNAME]</font>
4. Import CSV from $OUTDIR/sherlock_<font color='red'>[USERNAME]</font>.txt and $OUTDIR/maigret_<font color='red'>[USERNAME]</font>.csv.
5. Run transforms: "To Social Network Profiles", "To Email Addresses", "To Domains".
6. Export graph as CSV or screenshot for reporting.
---------------------------------------
EOF

echo "[✔] Workflow Complete."
echo "Results stored in: $OUTDIR"
echo "SpiderFoot UI: http://127.0.0.1:5001"
