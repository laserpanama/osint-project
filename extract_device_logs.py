
import subprocess
import datetime

def extract_device_logs():
    try:
        # Run ADB logcat to capture recent logs
        logs = subprocess.check_output(["adb", "logcat", "-d", "-s", "Dialer"], text=True)
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        with open(f"device_log_{timestamp}.txt", "w") as f:
            f.write(logs)
        print(f"Device logs saved to device_log_{timestamp}.txt")
        
        # Check for specific dialer activity
        if "+50769674636" in logs:
            print("Found reference to +50769674636 in dialer logs. Possible custom mapping or malware.")
        else:
            print("No reference to +50769674636 in logs.")
    
    except Exception as e:
        print(f"Error extracting device logs: {e}")

if __name__ == "__main__":
    extract_device_logs()
