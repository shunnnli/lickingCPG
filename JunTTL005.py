# -*- coding: utf-8 -*-
"""
Created on Tuesday 12 Dec 23:39:53 2017
@author: Youcef Bouchekioua & Koji Toda
"""

# Import libralies
import csv
import serial 
import time

# Initial setting
SerialP = "/dev/ttyACM1"
#SerialP = raw_input("Enter the Serial Port where is connected your device:")
print "Your Serial Port is =", SerialP
print ""
File = raw_input("Enter a file name :")
FileE = File + ".csv"
print "Your file name is =", FileE
print ""
Time = input("Enter the session length in seconds:")
print "The session will last =", Time
print""
Tableau = []

# Arduino setting
arduino = serial.Serial(SerialP, 115200) 

# Wait Arduino connection
connected = False
while not connected:
    serin = arduino.read()
    connected = True

timeout_start = time.time()
while time.time() < timeout_start + Time:       
    while (arduino.inWaiting()==0): 
        pass # Does Nothing
    arduinoString = arduino.readline()      
    dataArray = arduinoString.split(',')    
    dataArray[0] = int (dataArray[0])
    dataArray[0] = dataArray[0]
    dataArray[1] = int (dataArray[1])
    dataArray[2] = str (dataArray[2])
    dataArray.remove(dataArray[2])           
    print dataArray
    Tableau.append(dataArray)
  
# SAVE 
with open(FileE, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    for val in Tableau:
        writer.writerow(val)
        
# CLEAR
#%reset