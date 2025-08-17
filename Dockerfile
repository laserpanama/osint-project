FROM kali:latest

# Install base tools
RUN apt-get update && apt-get install -y \
    python3 python3-pip git tor exiftool firefox-esr curl python3-yaml \
    libx11-xcb1 libnss3 xvfb xdg-utils

# Install Sherlock
RUN git clone https://github.com/sherlock-project/sherlock.git /opt/sherlock && \
    pip3 install -r /opt/sherlock/requirements.txt

# Install Maigret
RUN git clone https://github.com/soxoj/maigret.git /opt/maigret && \
    pip3 install -r /opt/maigret/requirements.txt

# Install SpiderFoot
RUN git clone https://github.com/smicallef/spiderfoot.git /opt/spiderfoot && \
    pip3 install -r /opt/spiderfoot/requirements.txt

# Setup Working Directory
WORKDIR /opt

# Default entrypoint for SpiderFoot GUI
CMD ["python3", "spiderfoot/sf.py", "-l", "0.0.0.0:5001"]
