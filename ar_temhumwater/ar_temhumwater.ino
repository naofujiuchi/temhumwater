//1: Water level sensor for watering
//2: Humidity sensor for humidifying
//3: Water level sensor for humidifying

// Example testing sketch for various DHT humidity/temperature sensors
// Written by ladyada, public domain


#include "DHT.h"

#define LEVELPIN1 A0
#define DHTPIN A2     // what pin we're connected to humidity sensor
#define LEVELPIN2 A4

// Uncomment whatever type you're using!
//#define DHTTYPE DHT11   // DHT 11 
#define DHTTYPE DHT22   // DHT 22  (AM2302)
//#define DHTTYPE DHT21   // DHT 21 (AM2301)

// Connect pin 1 (on the left) of the sensor to +5V
// Connect pin 2 of the sensor to whatever your DHTPIN is
// Connect pin 4 (on the right) of the sensor to GROUND
// Connect a 10K resistor from pin 2 (data) to pin 1 (power) of the sensor

DHT dht(DHTPIN, DHTTYPE);

int outPin[4];
int levelval[4];
int level[4];
int inByte[4];
int highlow[4];
/*
int outPin_0 = 10;
int outPin_1 = 11;
int outPin_2 = 12;
int outPin_3 = 13;
int outPin_4 = 14;
int outPin_5 = 15;
int levelval1 = 0;
int levelval2 = 0;
int level1;
int level2;
int inByte1;
int inByte2;
int inByte3;
int highlow1;
int highlow2;
int highlow3;
*/

void setup() {
  Serial.begin(9600); 
  //ピンモード設定
  for(int i = 1; i <= 3; i++){
    outPin[i] = 10 + i;
    pinMode(outPin[i], OUTPUT);
  }
/*
  pinMode(outPin_0, OUTPUT);
  pinMode(outPin_1, OUTPUT);
  pinMode(outPin_2, OUTPUT);
  pinMode(outPin_3, OUTPUT);
  pinMode(outPin_4, OUTPUT);
  pinMode(outPin_5, OUTPUT);
*/
//Initialize levelval[i]
  for(int i = 1; i <= 3; i++){
    levelval[i] = 0;
  }
  dht.begin();
}

void loop(){
  // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
  float hum = dht.readHumidity();
  float tem = dht.readTemperature();
  // check if returns are valid, if they are NaN (not a number) then something went wrong!
  checkDHT(hum, tem);
  for(int i = 1; i <= 3; i++){
    levelval[i] = getlevelval(i);
  }
/*
  levelval1 = analogRead(LEVELPIN1);
  levelval2 = analogRead(LEVELPIN2);
*/
/*
  if(isnan(tem) || isnan(hum)){
    Serial.println("Failed to read from DHT");
    delay(10000);
  }else{
*/
/*
    Serial.print("Humidity: "); 
    Serial.print(h);
    Serial.print(" %\t");
    Serial.print("Temperature: "); 
    Serial.print(t);
    Serial.println(" *C");
    delay(10000);
*/
  for(int i = 1; i <= 3; i++){
    level[i] = getlevel(levelval[i]);
  }
/*
    if(levelval1 > 0){
      level1 = 1;
    }else{
      level1 = 0;
    }
    if(levelval2 > 0){
      level2 = 1;
    }else{
      level2 = 0
    } 
*/
  //シリアルbufferにデータが3個あるとき
  if(Serial.available() == 3){
    for(int i = 1; i <= 3; i++){
      inByte[i] = getinByte();
    }
    Serial.flush();
    for(int i = 1; i <= 3; i++){
      highlow[i] = gethighlow(inByte[i]);
      digitalWrite(outPin[i], highlow[i]);
    }
    // Serial write
    Serial.write(inByte[1]);
    Serial.write(inByte[2]);
    Serial.write(inByte[3]);
    Serial.write(level[1]);
    Serial.write(level[3]);
    Serial.write(hum);
    Serial.write(tem);
  }
/*
    if(Serial.available() == 3){
      inByte1 = Serial.read();
      inByte2 = Serial.read();
      inByte3 = Serial.read();
      Serial.flush();
      highlow1 = highlow(inByte1);
      highlow2 = highlow(inByte2);
      highlow3 = highlow(inByte3);
      digitalWrite(outPin_0, highlow1);
      digitalWrite(outPin_1, highlow1);
      digitalWrite(outPin_2, highlow2);
      digitalWrite(outPin_3, highlow2);
      digitalWrite(outPin_4, highlow3);
      digitalWrite(outPin_5, highlow3);
// Serial write
      Serial.write(inByte1);
      Serial.write(inByte2);
      Serial.write(inByte3);
      Serial.write(level1);
      Serial.write(level2);
      Serial.write(hum);
      Serial.write(tem);
    }
  }
*/
}

int gethighlow(int _inByte){
  switch(_inByte){
    case 0:
      return HIGH;
      break;
    case 1:
      return LOW;
      break;
    case 2:
      return LOW;
      break;
    case 3:
      return HIGH;
      break;
    default:
      break;
  }
}

int getlevelval(int _i){
  switch(_i){
    case 1:
      return analogRead(LEVELPIN1);
      break;
    case 3:
      return analogRead(LEVELPIN2);
      break;
    default:
      break;
  }
}

void checkDHT(float _tem, float _hum){
  if(isnan(_tem) || isnan(_hum)){
    Serial.println("Failed to read from DHT");
    delay(10000);
  }
}

int getlevel(int _levelval){
  if(_levelval > 0){
    return 1;
  }else{
    return 0;
  }
}

int getinByte(){
  int _inByte = Serial.read();
  return _inByte;
}
