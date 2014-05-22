/*
  This project operates humidifier
	Please set INPUTPIN and OUTPUTPIN.
	Please set the value of CYCLE and WORKTIME [sec]
*/
#include "CycleJudge.h"

#define INPUTPIN A0
#define OUTPUTPIN 13
#define CYCLE 100
#define WORKTIME 3600

CycleJudge cj(INPUTPIN, CYCLE, WORKTIME);

void setup(){
  cj.begin();
  pinMode(OUTPUTPIN, OUTPUT);
}

void loop(){
  if(cj.judge(1000)){
    digitalWrite(OUTPUTPIN, HIGH);
  }else{
    digitalWrite(OUTPUTPIN, LOW);
  }
  delay(1000);;
}