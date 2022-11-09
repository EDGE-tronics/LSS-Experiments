/*
    Author:     EDGEtronics
    Version:    1.0
    Licence:    GNU General Public License v3.0
    Description:  Basic example of PPM control of LSS based wheeled robot with pan-tilt.
*/

#include "ppm.h"
#include <LSS.h>

#define BAUD (115200)
#define LSS_SERIAL  (Serial)

LSS pan = LSS(1);
LSS tilt = LSS(2);
LSS wright = LSS(3);
LSS wleft = LSS(4);
LSS all = LSS(254);

const long interval = 100;
unsigned long currentMillis = millis();
unsigned long previousMillis = 0;
int panAng, tiltAng, angY, angX, angle;
int prevTilt, prevPan, nitro;

void setup()
{
  LSS::initBus(LSS_SERIAL, BAUD);
  delay(2000);

  pan.setMotionControlEnabled(0);
  tilt.setMotionControlEnabled(0);
  pan.setFilterPositionCount(15);
  tilt.setFilterPositionCount(15);
  pan.move(0);
  tilt.move(0);
  wleft.setGyre(-1,1);
  wright.wheelRPM(0);
  wleft.wheelRPM(0);
  all.setColorLED(3);
  delay(2000);
  
  ppm.begin(A3, false);
}

void loop()
{
  if (currentMillis - previousMillis >= interval){
    
    tiltAng = constrain(map(ppm.read_channel(3), 1000, 2000, -500, 500), -500, 500);
    if (abs(prevTilt - tiltAng) > 100){
      tilt.move(-tiltAng);
      prevTilt = tiltAng;
    }
    panAng = constrain(map(ppm.read_channel(4), 1000, 2000, -900, 900), -900, 900);
    if (abs(prevPan - panAng) > 100){
      pan.move(panAng);
      prevPan = panAng;
    }

    if (ppm.read_channel(6) > 1500) nitro = 20;
    else nitro = 0;
    
    angY  = ppm.read_channel(1) - 1500;
    angX = 1500 - ppm.read_channel(2);
    if (abs(angY) > 250 || abs(angX) > 250) {
      angle = atan2(angY,angX)*4068/71;
      if (angle <= 0) angle = 360 + angle;
    }
    else{
      angle = 0;
      wright.wheelRPM(0);
      wleft.wheelRPM(0);
    }

    //Forward
    if (angle > 330 || angle <= 30){
      wright.wheelRPM(60+nitro);
      wleft.wheelRPM(60+nitro);
    }
    //Front-right
    if (angle > 30 && angle <= 60){
      wright.wheelRPM(50+nitro);
      wleft.wheelRPM(60+nitro);
    }
    //Rotate cw
    if (angle > 60 && angle <= 120){
      wright.wheelRPM(0);
      wleft.wheelRPM(60+nitro);
    }
    //Back-right
    if (angle > 120 && angle <= 150){
      wright.wheelRPM(-50-nitro);
      wleft.wheelRPM(-60-nitro);
    }
    //Backward
    if (angle > 150 && angle <= 210){
      wright.wheelRPM(-60-nitro);
      wleft.wheelRPM(-60-nitro);
    }
    //Back-left
    if (angle > 210 && angle <= 240){
      wright.wheelRPM(-60-nitro);
      wleft.wheelRPM(-50-nitro);
    }
    //Rotate ccw
    if (angle > 240 && angle <= 300){
      wright.wheelRPM(60+nitro);
      wleft.wheelRPM(0);
    }
    //Front-left
    if (angle > 300 && angle <= 330){
      wright.wheelRPM(60+nitro);
      wleft.wheelRPM(50+nitro);
    }
  }
  currentMillis = millis();
}
