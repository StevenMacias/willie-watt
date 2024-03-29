# coding: utf-8
'''
    File name: virtual_port_simulator.py
    Author: Steven Macías
    Date created: 19/11/2019
    Date last modified: 19/11/2019
    Python Version: 3.6
'''
import os, pty, time
from serial import Serial

pressure_max_val = 20.00
temp_max_val = 200.00
current_temp = 0.0
current_press = 0.0
heater = False
water_pump = False
valve_0 = False

def sendJsonString(ser):
    global pressure_max_val
    global temp_max_val
    global current_temp
    global current_press
    global heater
    global water_pump
    global valve_0
    ser.write('{"press_sensor_1":'+str(current_press)+', "temp_sensor_1":'+str(current_temp)+', "press_sensor_2":'+str(current_press)+', "temp_sensor_2":'+str(current_temp)+', "heater":'+str(heater)+', "water_pump":'+str(water_pump)+', "valve_0":'+str(valve_0)+', "temp_target":70, "valve_state_1":0, "uControllerState":0}\n')
    print('{"press_sensor_1":'+str(current_press)+', "temp_sensor_1":'+str(current_temp)+', "press_sensor_2":'+str(current_press)+', "temp_sensor_2":'+str(current_temp)+', "heater":'+str(heater)+', "water_pump":'+str(water_pump)+', "valve_0":'+str(valve_0)+', "temp_target":70, "valve_state_1":0, "uControllerState":0}\n')
    ser.flush()
    time.sleep(0.01)

def test_serial():
    global pressure_max_val
    global temp_max_val
    global current_temp
    global current_press
    global heater
    global water_pump
    global valve_0
    #open a pySerial connection to the slave
    ser = Serial("/dev/pts/3", 9600, timeout=1)

    time.sleep(1)
    while(True):
        sendJsonString(ser)
        valve_0 = True
        sendJsonString(ser)
        time.sleep(2)
        water_pump = True
        sendJsonString(ser)
        time.sleep(2)
        water_pump = False
        sendJsonString(ser)
        time.sleep(2)
        valve_0 = False
        sendJsonString(ser)
        time.sleep(2)
        heater = True
        sendJsonString(ser)
        time.sleep(2)
        for x in range(255):
            current_temp = (temp_max_val/255.00)*x
            current_press = (pressure_max_val/255.00)*x
            sendJsonString(ser)
        heater = False
        sendJsonString(ser)
        time.sleep(2)
        valve_0 = True
        sendJsonString(ser)
        for x in range(255):
            current_temp = temp_max_val-((temp_max_val/255.00)*x)
            current_press = pressure_max_val-((pressure_max_val/255.00)*x)
            sendJsonString(ser)


if __name__=='__main__':
    test_serial()
