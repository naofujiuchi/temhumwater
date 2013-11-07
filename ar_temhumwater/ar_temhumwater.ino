// Example testing sketch for various DHT humidity/temperature sensors
// Written by ladyada, public domain


#include "DHT.h"

#define LEVELPIN A0
#define DHTPIN A2     // what pin we're connected to

// Uncomment whatever type you're using!
//#define DHTTYPE DHT11   // DHT 11 
#define DHTTYPE DHT22   // DHT 22  (AM2302)
//#define DHTTYPE DHT21   // DHT 21 (AM2301)

// Connect pin 1 (on the left) of the sensor to +5V
// Connect pin 2 of the sensor to whatever your DHTPIN is
// Connect pin 4 (on the right) of the sensor to GROUND
// Connect a 10K resistor from pin 2 (data) to pin 1 (power) of the sensor

DHT dht(DHTPIN, DHTTYPE);

int outPin_0 = 10;
int outPin_1 = 11;
int outPin_2 = 12;
int outPin_3 = 13;
int levelval = 0;
int level;
int inByteL;
int inByteR;
int highlowL;
int highlowR;

void setup() {
  Serial.begin(9600); 
  //ピンモード設定
  pinMode(outPin_0, OUTPUT);
  pinMode(outPin_1, OUTPUT);
  pinMode(outPin_2, OUTPUT);
  pinMode(outPin_3, OUTPUT);
  dht.begin();
}

void loop() {
  // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
  float hum = dht.readHumidity();
  float tem = dht.readTemperature();
  levelval = analogRead(LEVELPIN);
  // check if returns are valid, if they are NaN (not a number) then something went wrong!
  if (isnan(tem) || isnan(hum)) {
    Serial.println("Failed to read from DHT");
    delay(10000);
  } else {
/*
    Serial.print("Humidity: "); 
    Serial.print(h);
    Serial.print(" %\t");
    Serial.print("Temperature: "); 
    Serial.print(t);
    Serial.println(" *C");
    delay(10000);
*/
    if(levelval > 0){
      level = 1;
    }else{
      level = 0;
    }
    //シリアルbufferにデータが2個あるとき
    if(Serial.available() == 2){
      inByteL = Serial.read();
      inByteR = Serial.read();
      Serial.flush();
      inByteLeft(inByteL);
      inByteRight(inByteR);
      digitalWrite(outPin_0, highlowL);
      digitalWrite(outPin_1, highlowL);
      digitalWrite(outPin_2, highlowR);
      digitalWrite(outPin_3, highlowR);      
      // Serial write
      Serial.write(inByteL);
      Serial.write(inByteR);
      Serial.write(level);
      Serial.write(hum);
      Serial.write(tem);
    }
  }
}

void inByteLeft(int _inByteL){
  switch(_inByteL){
    case 0:
      highlowL = HIGH;
      break;
    case 1:
      highlowL = LOW;
      break;    
    case 2:
      highlowL = LOW;
      break;    
    case 3:
      highlowL = HIGH;
      break;    
  }
}

void inByteRight(int _inByteR){
  switch(_inByteR){
    case 0:
      highlowR = HIGH;
      break;
    case 1:
      highlowR = LOW;
      break;    
    case 2:
      highlowR = LOW;
      break;    
    case 3:
      highlowR = HIGH;
      break;    
  }
}
