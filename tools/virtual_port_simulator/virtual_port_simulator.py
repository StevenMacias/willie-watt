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

def test_serial():
    #open a pySerial connection to the slave
    ser = Serial("/dev/pts/2", 9600, timeout=1)

    time.sleep(1)

    while(True):
        for x in range(255):
            current_temp = (temp_max_val/255.00)*x
            current_press = (pressure_max_val/255.00)*x
            ser.write('{"press_sensor_1":'+str(current_press)+', "temp_sensor_1":'+str(current_temp)+', "press_sensor_2":'+str(current_press)+', "temp_sensor_2":'+str(current_temp)+', "temp_target":70, "valve_state_1":0, "uControllerState":0}\n')
            print('{"press_sensor_1":'+str(current_press)+', "temp_sensor_1":'+str(current_temp)+', "press_sensor_2":'+str(current_press)+', "temp_sensor_2":'+str(current_temp)+', "temp_target":70, "valve_state_1":0, "uControllerState":0}\n')
            ser.flush()
            time.sleep(0.01)
        for x in range(255):
            current_temp = temp_max_val-((temp_max_val/255.00)*x)
            current_press = pressure_max_val-((pressure_max_val/255.00)*x)
            ser.write('{"press_sensor_1":'+str(current_press)+', "temp_sensor_1":'+str(current_temp)+', "press_sensor_2":'+str(current_press)+', "temp_sensor_2":'+str(current_temp)+', "temp_target":70, "valve_state_1":0, "uControllerState":0}\n')
            print('{"press_sensor_1":'+str(current_press)+', "temp_sensor_1":'+str(current_temp)+', "press_sensor_2":'+str(current_press)+', "temp_sensor_2":'+str(current_temp)+', "temp_target":70, "valve_state_1":0, "uControllerState":0}\n')
            ser.flush()
            time.sleep(0.01)


if __name__=='__main__':
    test_serial()
