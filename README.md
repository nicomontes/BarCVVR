# BarCVVR

Code raspberry pour débimètres : 

```python
#!/usr/bin/python3.5

import RPi.GPIO as GPIO
import time, sys
import requests
import asyncio

GPIO.setmode(GPIO.BOARD)
inpt = 8
inpt2 = 10
GPIO.setup(inpt,GPIO.IN)
GPIO.setup(inpt2,GPIO.IN)
rate_cnt = 0.0000
rate_cnt2 = 0.0000
constant = 9230
time_new = 0.0
state = GPIO.input(inpt)
state2 = GPIO.input(inpt2)

loop = asyncio.get_event_loop()  

async def send_data_blonde(liter):
    def do_req():
        requests.put("http://[URL]/beerflows/1", data={'_method': 'patch', 'beerflow[quantity]': liter, 'beerflow[drink_id]': '1'})
    loop.run_in_executor(None, do_req)
    
async def send_data_special(liter):
    def do_req():
        requests.put("http://[URL]/beerflows/2", data={'_method': 'patch', 'beerflow[quantity]': liter, 'beerflow[drink_id]': '9'})
    loop.run_in_executor(None, do_req)

while True:
    time_new = time.time() + 1
    rate_cnt = 0
    rate_cnt2 = 0
    while time.time() <= time_new:
        if GPIO.input(inpt)!= state:
            rate_cnt += 1
            state = GPIO.input(inpt)
        if GPIO.input(inpt2)!= state2:
            rate_cnt2 += 1
            state2 = GPIO.input(inpt2)
    liter = round(rate_cnt / constant,4)
    liter2 = round(rate_cnt2 / constant,4)
    if liter > 0:
      loop.run_until_complete(send_data_blonde(liter))
    if liter2 > 0:
      loop.run_until_complete(send_data_special(liter2)) 

loop.close()
GPIO.cleanup()
```
