#
#	Author:			EDGEtronics
#	Version:		1.0.0
#	Licence:		GNU General Public License v3.0
#	
#	Desscription:	Basic example of the LSS rotating, changing the LED colors and giving feedback.

# Import required liraries
import time
import serial

# Import LSS library
import lss
import lss_const as lssc

# Constants
#CST_LSS_Port = "/dev/ttyUSB0"		# For Linux/Unix platforms
CST_LSS_Port = "COM6"				# For windows platforms
CST_LSS_Baud = lssc.LSS_DefaultBaud

# Create and open a serial port
lss.initBus(CST_LSS_Port, CST_LSS_Baud)

# Create an LSS object
myLSS = lss.LSS(0)

# Initialize LSS to position 0.0 deg
position = -1800
color = 1
myLSS.move(position)

# Wait for it to get there
time.sleep(2)

while 1:
	position = position + 100
	if position <= 1800:
		# Increment the position in 10 deg
		myLSS.move(position)
	else:
		break

	# Get the values from LSS
	print("\r\nQuerying LSS...")
	pos = myLSS.getPosition()
	rpm= myLSS.getSpeedRPM()
	curr = myLSS.getCurrent()
	volt = myLSS.getVoltage()
	temp = myLSS.getTemperature()
	
	# Display the values in terminal
	print("\r\n---- Telemetry ----")
	print("Position  (1/10 deg) = " + str(pos))
	print("Speed          (rpm) = " + str(rpm))
	print("Current          (mA) = " + str(curr))
	print("Voltage         (mV) = " + str(volt))
	print("Temperature (1/10 C) = " + str(temp))	

	color = color + 1
	if color <= 7:
		# Increment the position in 10 deg
		myLSS.setColorLED(color)
	else: color = 1
	# Wait for half a second
	time.sleep(0.5)