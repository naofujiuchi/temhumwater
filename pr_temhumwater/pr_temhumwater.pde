//フォント使用
PFont font;
// Initialize image class
PImage imgA;
PImage imgB;
PImage imgC;
PImage imgD;
PImage imgL;
PImage imgR;
boolean flag;
//シリアルライブラリの取り込み
import processing.serial.*;
//シリアルクラスのインスタンス
Serial myPort;
//変数宣言
int press;
int pressL;
int pressR;
String stateL = "Stop";
String stateR = "Stop";
String onoffL;
String onoffR;
int level;
int inByteL;
int inByteR;
float hum;
float temp;
int outL;
int outR;
int s;
int m;
int h;
String t;
  
void setup(){
  size(500, 400);
  frameRate(1);
  font = loadFont("Calibri-24.vlw");
  textFont(font);
  textAlign(RIGHT);
  myPort=new Serial(this, "/dev/cu.usbmodem1411", 9600);
  myPort.buffer(5);
  imgA = loadImage("playgreen.png");
  imgB = loadImage("pausegreen.png");
  imgC = loadImage("playorange.png");
  imgD = loadImage("pauseorange.png");
  flag = false;
}

void draw(){
  background(100);
  getTime();
  onoffL = onoffTimeLeft(h, m);
  onoffR = onoffTimeRight(h, m);
  //シリアルbufferにデータが5個あるとき
  if(myPort.available() == 5){
    readData();
    myPort.clear();
    outL = outputLeft(inByteL, level, stateL, onoffL);
    outR = outputRight(inByteR, hum, stateR, onoffR);
    myPort.write(outL);
    myPort.write(outR);
  }
  getPicture(stateL, stateR);
  display(t, level, hum, temp,  stateL, stateR, onoffL, onoffR, inByteL, inByteR);
}

void getPicture(String _stateL, String _stateR){
  if(_stateL == "Stop"){
    imgL = imgA;
  }else{
    imgL = imgB;
  }
  if(_stateR == "Stop"){
    imgR = imgC;
  }else{
    imgR = imgD;
  }
  image(imgL, 0, 140);
  image(imgR, 250, 140);
}

void getTime(){
  h = int(hour());
  m = int(minute());
  s = int(second());
  t = h + ":" + nf(m, 2) + ":" + nf(s, 2);
}

String onoffTimeLeft(int _h, int _m){
//  if((_h == 15) && (_m < 20)){
    return "OnTime";
//  }else{
//    return "OffTime";
//  }
}  

String onoffTimeRight(int _h, int _m){
//  if((_h == 15) && (_m < 20)){
    return "OnTime";
//  }else{
//    return "OffTime";
//  }
}  

void display(String _t, int _level, float _hum, float _temp, String _stateL, String _stateR, String _onoffL, String _onoffR, int _inByteL, int _inByteR){
  text("Autowater", 180, 20);
  text("Humidifier", 430, 20);
  text(_t, 295, 20);
  text("level", 275, 50);
  text(_level, 135, 50);
  text("humidity", 295, 70);
  text(_hum, 410, 70);
  text("temperature", 315, 90);
  text(_temp, 410, 90);
  text("state", 275, 110);
  text(_stateL, 160, 110);
  text(_stateR, 410, 110);
  text("onoffTime", 300, 130);
  text(_onoffL, 160, 130);
  text(_onoffR, 410, 130);
  text("inByte", 280, 150);
  text(_inByteL, 135, 150);
  text(_inByteR, 390, 150);
}

void readData(){
  inByteL = myPort.read();
  inByteR = myPort.read();
  level = myPort.read();
  hum = myPort.read();
  temp = myPort.read();
}

int outputLeft(int _inByteL, int _level, String _stateL, String _onoffL){
  if((_stateL == "Running") && (_level == 0) && (_onoffL == "OnTime")){
    return 3;
  }else if(_inByteL == 0){
    return 1;
  }else{
    return 1;
  }
}

int outputRight(int _inByteR, float _hum, String _stateR, String _onoffR){
  if((_stateR == "Running") && (_hum < 90) && (_onoffR == "OnTime")){
    return 3;
  }else if(_inByteR == 0){
    return 1;
  }else{
    return 1;
  }
}

void countPressLeft(){
  pressL++;
  if(pressL % 2 == 1){
    stateL = "Running";
  }
  else if(pressL % 2 == 0){
    stateL = "Stop";
  }
}

void countPressRight(){
  pressR++;
  if(pressR % 2 == 1){
    stateR = "Running";
  }
  else if(pressR % 2 == 0){
    stateR = "Stop";
  }
}

//ProcessingをRunしたときに出てくるウィンドウをクリックすると
void mousePressed(){
  press++;
  if(press == 1){
    myPort.clear();
    myPort.write(0);
    myPort.write(0);
  }
  if(mouseX >= 40 && mouseX <= 220 && mouseY >= 180 && mouseY <= 360){
    countPressLeft();
  }
  if(mouseX >= 290 && mouseX <= 470 && mouseY >= 180 && mouseY <= 360){
    countPressRight();
  }
}

