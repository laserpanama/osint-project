
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import sys
import time

def check_whatsapp_profile(phone_number):
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    driver = webdriver.Chrome(options=chrome_options)
    
    try:
        driver.get("https://web.whatsapp.com")
        print("Please scan the QR code to log in to WhatsApp Web (manual step required).")
        time.sleep(30)  # Adjust time for manual login
        
        # Navigate to chat with phone number
        driver.get(f"https://wa.me/{phone_number}")
        time.sleep(5)
        
        # Check for profile info (e.g., name, status)
        try:
            profile_name = driver.find_element(By.CLASS_NAME, "title").text
            print(f"WhatsApp Profile Name: {profile_name}")
        except:
            print("No profile name found.")
        
        try:
            status = driver.find_element(By.CLASS_NAME, "status").text
            print(f"WhatsApp Status: {status}")
        except:
            print("No status found.")
    
    except Exception as e:
        print(f"Error checking WhatsApp profile: {e}")
    finally:
        driver.quit()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 whatsapp_scraper.py <phone_number>")
        sys.exit(1)
    check_whatsapp_profile(sys.argv[1])
