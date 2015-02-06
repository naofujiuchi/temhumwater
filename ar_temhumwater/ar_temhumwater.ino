//1: Water level sensor for watering
//2: Humidity sensor for humidifying
//3: Water level sensor for humidifying

import processing.serial.*;  // Import serial library

PFont font;  // Instance of font class
PImage imgA;  // Instance of image class
PImage imgB;
boolean flag;
Serial myPort;  // Instance of serial class

int s;
int m;
int h;
int period;
float hum;
float temp;
String t;
int[] workingtime = new int[4];
int[] press = new int[4];
int[] level = new int[4];
int[] inByte = new int[4];
int[] out = new int[4];
int[] serial = new int[8];
String[] state = new String[4];
String[] onoff = new String[4];
PImage[] img = new PImage[4];

void setup() {
  int i;
  size(1000, 400);
  frameRate(1);
  font = loadFont("Calibri-24.vlw");
  textFont(font);
  textAlign(RIGHT);
  myPort = new Serial(this, "/dev/cu.usbmodem1411", 9600);
  myPort.buffer(10);
  imgA = loadImage("playgreen.png");
  imgB = loadImage("pausegreen.png");
  flag = false;
  for (i = 1; i <= 3; i++) {
    workingtime[i] = 0;
    press[i] = 0;
    level[i] = 0;
    inByte[i] = 0;
    out[i] = 0;
    serial[i] = 0;
    state[i] = "Stop";
    onoff[i] = "default";
    img[i] = imgB;
  }
}

void draw() {
  int i;
  background(100);
  getTime();
  if (myPort.available() == 7) {
    readSerial();
    myPort.clear();  //clear serial buffer
    for (i = 1; i <= 3; i++) {
      onoff[i] = onoffTime(i, h, m);
      out[i] = getOut(i);
      myPort.write(out[i]);
      img[i] = getPicture(i, state[i]);
    }
  }
  display();
  if(period == 20){
    timeReset();
  }
  delay(1000);
}

void timeReset(){
  int i;
  period = 0;
  workingtime[3] = 0;
}

void getTime() {
  h = int(hour());
  m = int(minute());
  s = int(second());
  t = h + ":" + nf(m, 2) + ":" + nf(s, 2);
}

void readSerial() {
  int i;
  for(i = 1; i <= 7; i++){
    serial[i] = myPort.read();
//    println(i + ": " + serial[i]);
  }
  inByte[1] = serial[1];
  inByte[2] = serial[2];
  inByte[3] = serial[3];
  level[1] = serial[4];
  level[3] = serial[5];
  hum = serial[6];
  temp = serial[7];
}

String onoffTime(int _i, int _h, int _m) {
  switch(_i) {
    case 1:
      if ((_h == 5) && (_m < 20)) {
        return "OnTime";
      }else{
        return "OffTime";
      }
    case 2:
      return "OnTime";
    case 3:
      return "OnTime";
    default:
      println("Error in onoffTime");
      return "NoMatch";
  }
}

int getOut(int _i) {
  int _out;
  switch(_i){
    case 1:
      _out = outLevel(_i, inByte[_i], level[_i], state[_i], onoff[_i], workingtime[_i]);
      break;
    case 2:
      _out = outHum(_i, inByte[_i], hum, state[_i], onoff[_i]);
      break;
    case 3:
      _out = outLevel2(_i, inByte[_i], level[_i], state[_i], onoff[_i], workingtime[_i]);
      break;
    default:
      println("Error in getout");
      _out = 4;
      break;
  }
  return _out;
}

int outLevel(int _i, int _inByte, int _level, String _state, String _onoff, int _workingtime) {
  boolean _TFlevel = judgeLevel(_level);
  boolean _TFstate = judgeState(_state);
  boolean _TFonoff = judgeOnoff(_onoff);
  if(_TFlevel && _TFstate && _TFonoff){
    return 3;
  }
  else if (_inByte == 0) {
    return 1;
  }
  else {
    return 1;
  }
}

int outLevel2(int _i, int _inByte, int _level, String _state, String _onoff, int _workingtime) {
  int _outlevel;
  boolean _TFlevel = judgeLevel(_level);
  boolean _TFstate = judgeState(_state);
  boolean _TFonoff = judgeOnoff(_onoff);
  boolean _TFworkingtime = judgeWorkingtime(_workingtime);
  switch(_inByte){
    case 0:  // initial
      workingtime[_i] = 0;
      _outlevel = 1;
      break;
    case 1:  // period will not increase
      if (_TFlevel && _TFstate && _TFonoff && _TFworkingtime) { 
        period++;
        workingtime[_i]++;
        _outlevel = 3;
      }else if(!_TFstate){
        _outlevel = 1;
      }else{
        _outlevel = 2;
      }
      break;
    case 2:
      if (_TFlevel && _TFstate && _TFonoff && _TFworkingtime) {
        if(period == 0){
          workingtime[_i]++;
          _outlevel = 3;
        }else{
          _outlevel = 2;
        }
      }else if(!_TFstate){
        _outlevel = 1;
      }else{
        _outlevel = 2;
      }
      period++;
      break;
    case 3:
      if(!_TFworkingtime){
        _outlevel = 4;
      }else if(_TFlevel && _TFstate && _TFonoff) {
        period++;
        workingtime[_i]++;
        _outlevel = 3;
      }else{
        period++;
        _outlevel = 2;
      }
      break;  
    case 4:  // keep stop state
      if(!_TFstate){
        timeReset();
        _outlevel = 1;
      }else{
        _outlevel = 4;
      }
      break;
    default:
      _outlevel = 4;
  }
  println("WT: " + workingtime[_i] + ", period: " + period);
  return _outlevel;
}

boolean judgeLevel(int _level){
  if(_level == 0){
    return true;
  }else{
    return false;
  }
}

boolean judgeState(String _state){
  if(_state == "Running"){
    return true;
  }else{
    return false;
  }
}

boolean judgeOnoff(String _onoff){
  if(_onoff == "OnTime"){
    return true;
  }else{
    return false;
  }
}

boolean judgeWorkingtime(int _workingtime){
  if(_workingtime < 10){
    return true;
  }else{
    return false;
  }
}

int outHum(int _i, int _inByte, float _hum, String _state, String _onoff) {
  if ((_state == "Running") && (_hum < 90) && (_onoff == "OnTime")) {
    return 3;
  }
  else if (_inByte == 0) {
    return 1;
  }
  else {
    return 1;
  }
}

PImage getPicture(int _i, String _state) {
  boolean _TFstate = judgeState(_state);
  if(_TFstate){
    return imgA;
  }else{
    return imgB;
  }
}

//ProcessingをRunしたときに出てくるウィンドウをクリックすると
void mousePressed() {
  press[0]++;
  if (press[0] == 1) {
    myPort.clear();
    myPort.write(0);
    myPort.write(0);
    myPort.write(0);
    println("Serial initialized");
  }
  if (mouseX >= 40 && mouseX <= 220 && mouseY >= 180 && mouseY <= 360) {
    countPress(1);
  }
  if (mouseX >= 290 && mouseX <= 470 && mouseY >= 180 && mouseY <= 360) {
    countPress(2);
  }
  if (mouseX >= 540 && mouseX <= 720 && mouseY >= 180 && mouseY <= 360) {
    countPress(3);
  }
}

void countPress(int _i) {
  press[_i]++;
  if (press[_i] % 2 == 1) {
    state[_i] = "Running";
  }
  else {
    state[_i] = "Stop";
  }
}

void display() {
  int i;
  text("Autowater", 180, 20);
  text("Humidifier1", 430, 20);
  text("Humidifier2", 680, 20);
  text(t, 295, 20);
  text("level", 275, 50);
  text(level[1], 135, 50);
  text(level[3], 635, 50);
  text("humidity", 295, 70);
  text(hum, 410, 70);
  text("temperature", 315, 90);
  text(temp, 410, 90);
  text("state", 275, 110);
  text(state[1], 160, 110);
  text(state[2], 410, 110);
  text(state[3], 660, 110);
  text("onoffTime", 300, 130);
  text(onoff[1], 160, 130);
  text(onoff[2], 410, 130);
  text(onoff[3], 660, 130);
  text("inByte", 280, 150);
  text(inByte[1], 135, 150);
  text(inByte[2], 390, 150);
  text(inByte[3], 645, 150);
  for(i = 1; i <=3; i++){
    image(img[i], 250 * (i - 1), 140);
  }
}