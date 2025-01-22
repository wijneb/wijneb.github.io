
import os
import time
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium import webdriver
from selenium.common.exceptions import TimeoutException, WebDriverException
from selenium.webdriver.support.ui import WebDriverWait

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

# Open the website with authentication
username="Narrowcasting"
password="Narrowcasting2020"

url="https://leeuwenbergh.e-golf4u.nl/home.php"  

picx = os.getenv('PICX')
urlx = os.getenv('URLX')
wdth = os.getenv('WIDTH')
hght = os.getenv('HEIGHT')

options = FirefoxOptions()
options.add_argument("--headless")
options.add_argument("--kiosk")  # Enables full-screen mode

service = FirefoxService(executable_path='/usr/bin/geckodriver')
driver = webdriver.Firefox(service=service, options=options)

# Set timeouts
driver.set_page_load_timeout(30)  # Timeout for page load (in seconds)
driver.set_script_timeout(30)     # Timeout for scripts (in seconds)

try:
    driver.set_window_size(wdth, hght)

    driver.get(url)  # goto login page and login
    time.sleep(3)  # Wait for 3 seconds

    # Find the username and password fields and enter the credentials
    username_field = driver.find_element(By.NAME, "gebruikersnaam")  
    password_field = driver.find_element(By.NAME, "wachtwoord")

    username_field.send_keys("Narrowcasting")
    password_field.send_keys("Narrowcasting2020")

    # Find the login button and click it
    login_button = driver.find_element(By.NAME, "submit")   
    login_button.click()
    time.sleep(5)

    driver.get(urlx)  # after login goto actual webpage
    time.sleep(5)  # Wait for 5 seconds

    driver.save_screenshot(picx)

except Exception as e:
    print(f"py timeout Error: {e}")
finally:
    driver.quit()


