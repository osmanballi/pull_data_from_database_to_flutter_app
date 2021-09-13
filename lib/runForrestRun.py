import serial
import time
while True: 
    with serial.Serial('COM8', 9600, timeout=10) as ser:
        led_on="8\n"
        ser.write(bytes(led_on, 'utf-8'))
        print(led_on)
        time.sleep(1)
        ser.close()
        time.sleep(1)