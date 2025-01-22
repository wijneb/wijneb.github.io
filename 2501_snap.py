#!/usr/bin/env python3

import os
import time
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium import webdriver

picx = os.getenv('PICX')
urlx = os.getenv('URLX')
wdth = os.getenv('WIDTH')
hght = os.getenv('HEIGHT')

#picx = "/home/bw/sel/pics2/Trackman_longest_30_dagen.png"
#urlx = "https://tm-short.me/77wP26z"
#wdth = 1920
#hght = 1080

#print(f'PICX: {picx}')
#print(f'URLX: {urlx}')

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
    driver.get(urlx)
    time.sleep(7)  # Wait for 7 seconds
    driver.save_screenshot(picx)
except Exception as e:
    print(f"py timeout Error: {e}")
finally:
    driver.quit()
