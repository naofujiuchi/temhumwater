//1: Water level sensor for watering
//2: Humidity sensor for humidifying
//3: Water level sensor for humidifying

#include "DHT.h"

#define LEVELPIN1 A0
#define DHTPIN A2     // what pin we're connected to humidity sensor
#define LEVELPIN2 A4
#define LEVELPIN3 A5

// Uncomment whatever type you're using!
//#define DHTTYPE DHT11   // DHT 11 
#define DHTTYPE DHT22   // DHT 22  (AM2302)
//#define DHTTYPE DHT21   // DHT 21 (AM2301)

// Connect pin 1 (on the left) of the sensor to +5V
// Connect pin 2 of the sensor to whatever your DHTPIN is
// Connect pin 4 (on the right) of the sensor to GROUND
// Connect a 10K resistor from pin 2 (data) to pin 1 (power) of the sensor

DHT dht(DHTPIN, DHTTYPE);

float hum;
float tem;
int outPin[4];
int levelval[4];
int level[4];
int inByte[4];
int highlow[4];

void setup() {
  Serial.begin(9600); 
  for(int i = 1; i <= 3; i++){
    outPin[i] = 10 + i;
    pinMode(outPin[i], OUTPUT);
    levelval[i] = 0;
    level[i] = 0;
    inByte[i] = 0;
    highlow[i] = 0;
  }

  pinMode(10, OUTPUT);  // for moisture sensor connection

  dht.begin();
}

void loop(){
  // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 s  econds 'old' (its a very slow sensor)
  float hum = dht.readHumidity();  // !!Unless connecting to DHT sensor, errors would arise!!
  float tem = dht.readTemperature();
  // check if returns are valid, if they are NaN (not a number) then something went wrong!
//  checkDHT(tem, hum);
  for(int i = 1; i <= 3; i++){
    levelval[i] = getLevelval(i);
    level[i] = getLevel(i, levelval[i]);
  }
/*
//  Serial.print("1: ");
//  Serial.print(levelval[1]);
  Serial.print(", 3: ");
  Serial.println(levelval[3]);
  delay(1000);
*/
  if(Serial.available() == 3){
    for(int i = 1; i <= 3; i++){
      inByte[i] = getinByte();
    }
    for(int i = 1; i <= 3; i++){
      highlow[i] = getHighlow(inByte[i]);
      digitalWrite(outPin[i], highlow[i]);
    }
    
    digitalWrite(10, highlow[3]);  // for moisture sensor connection
    
    Serial.flush();
    // Serial write
    Serial.write(inByte[1]);
    Serial.write(inByte[2]);
    Serial.write(inByte[3]);
    Serial.write(level[1]);
    Serial.write(level[3]);
    Serial.write(hum);
    Serial.write(tem);
  }

}

int getinByte(){
  int _inByte = Serial.read();
  return _inByte;
}

int getHighlow(int _inByte){
  switch(_inByte){
    case 0:
      return HIGH;
    case 1:
      return LOW;
    case 2:
      return LOW;
    case 3:
      return HIGH;
    case 4:
      return LOW;
    default:
      return LOW;
  }
}

int getLevelval(int _i){
  int _levelval;
  switch(_i){
    case 1:
      _levelval = analogRead(LEVELPIN1);
      break;
    case 3:
//      _levelval = determineLevel();
      _levelval = analogRead(LEVELPIN2);
      break;
    default:
      _levelval = 0;
      break;
  }
  return _levelval;
}

/*
int determineLevel(){
  int _levelvalA4;
  int _levelvalA5;
  _levelvalA4 = analogRead(LEVELPIN2);
  _levelvalA5 = analogRead(LEVELPIN3);
//  return _levelvalA4;
  if((_levelvalA4 == 0) && (_levelvalA5 == 0)){
    return 0;
  }else if((_levelvalA4 > 0) && (_levelvalA5 == 0)){
    return 1;
  }else if((_levelvalA4 > 0) && (_levelvalA5 > 0)){
    return 2;
  }else{
    return 0;
  }
}
*/

/*
void checkDHT(float _tem, float _hum){
  if(isnan(_tem) || isnan(_hum)){
    Serial.println("Failed to read from DHT");
    delay(10000);
  }
}
*/
int getLevel(int _i, int _levelval){
  switch(_i){
    case 1:
      if(_levelval > 200){
        return 1;
      }else{
        return 0;
      }
    case 3:
      if(_levelval < 200){
        return 1;
      }else{
        return 0;
      }
/*
    case 3:  // fluid level sensor (eTape, MILONE Technologies); if level is 5 cm then output 400, and level is 10 cm then output 450 when connected input voltage 5 V and 1 kΩ resistance
      return _levelval;
*/
/*
      if(_levelval <= 400){
        return 0;
      }else if((_levelval > 400) && (_levelval <= 450)){
        return 1;
      }else if(_levelval > 450){
        return 2;
      }
*/
    default:
      return 0;
  }
}
