#!/usr/bin/env python3

import os
import time
import datetime
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium import webdriver

#import os
#import time
#import datetime
#from selenium.webdriver.firefox.service import Service
#from selenium.webdriver.firefox.options import Options
#from selenium import webdriver

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def print_time(input):
    current_time = datetime.datetime.now().time()
    formatted_time = current_time.strftime("%H:%M:%S")
    print(f"{formatted_time} {input}")

def main():
    # Hardcoded values for testing
    picx = "/home/bw/sel/pics2/Trackman_longest_30_dagen.png"
    urlx = "https://tm-short.me/77wP26z"
    wdth = 1920
    hght = 1080

    options = FirefoxOptions()
    options.add_argument("--headless")
    options.add_argument("--kiosk")  # Enables full-screen mode

    service = FirefoxService(executable_path='/usr/bin/geckodriver')

    print_time("start browser await")
    driver = webdriver.Firefox(service=service, options=options)

    # Set timeouts
    driver.set_page_load_timeout(30)  # Timeout for page load (in seconds)
    driver.set_script_timeout(30)     # Timeout for scripts (in seconds)

    try:
        print_time("start go to url")
        driver.get(urlx)

        print_time("start wait for body")
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, 'body')))

        print_time("start sleep 1")
        time.sleep(1)  # Wait for 1 second

        print_time("start take screenshot")
        driver.save_screenshot(picx)

    finally:
        print_time("start close browser")
        driver.quit()
        print_time("browser closed")

if __name__ == "__main__": 
    main()