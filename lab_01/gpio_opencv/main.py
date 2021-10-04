import cv2
import numpy as np
from PIL import Image
from time import sleep

import RPi.GPIO as GPIO

# GPIO init
GPIO.setmode(GPIO.BCM)
pin_sr = 14
pin_led = 17
GPIO.setup(pin_sr, GPIO.IN)
GPIO.setup(pin_led, GPIO.OUT)


def get_light_on():
    """Turn LED on"""
    GPIO.output(pin_led, True)
    print('Light on')
    
def get_light_off():
    """Turn LED off"""
    GPIO.output(pin_led, False)
    print('Light off')
    
def get_if_person():
    """Detect face. Captures 5 pictures, if detects faces on 3+ pictures, return True. Else False."""
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FPS, 24)
    res = []
    for i in range(5):
        FaceCascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        
        _, img = cap.read()
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
#         gray = cv2.resize(gray, (128, 256))
        faces = FaceCascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
        res.append(len(faces))
        faces = 0
    cap.release()
    k = 0
    for i in res:
        if i > 0:
            k += 1
    return k >= 3

# Main loop
while True:
    input_value = GPIO.input(pin_sr)
    if input_value:
        check = get_if_person()
        if check:
            get_light_on()
        else: get_light_off()
    else:
        get_light_off()
        
    sleep(1)


GPIO.cleanup()

