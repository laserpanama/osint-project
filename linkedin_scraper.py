
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import time
import sys

def search_linkedin(name):
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    driver = webdriver.Chrome(options=chrome_options)
    
    try:
        driver.get("https://www.linkedin.com/login")
        print("Please log in to LinkedIn manually (required for search).")
        time.sleep(30)  # Adjust time for manual login
        
        # Search for the name in Panama
        driver.get(f"https://www.linkedin.com/search/results/people/?keywords={name}&origin=SWITCH_SEARCH_VERTICAL&geoUrn=104621616")
        time.sleep(5)
        
        # Extract profile names
        profiles = driver.find_elements(By.CLASS_NAME, "entity-result__title-text")
        for profile in profiles[:5]:  # Limit to top 5 results
            print(f"LinkedIn Profile: {profile.text}")
    
    except Exception as e:
        print(f"Error searching LinkedIn: {e}")
    finally:
        driver.quit()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 linkedin_scraper.py <name>")
        sys.exit(1)
    search_linkedin(sys.argv[1])
