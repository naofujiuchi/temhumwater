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
    img[i] = imgA;
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
      getPicture(i, state[i]);
    }
  }
  display();
  delay(1000);
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
      _out = outLevel(inByte[_i], level[_i], state[_i], onoff[_i]);
      break;
    case 2:
      _out = outHum(inByte[_i], hum, state[_i], onoff[_i]);
      break;
    case 3:
      _out = outLevel2(inByte[_i], level[_i], state[_i], onoff[_i]);
      break;
    default:
      println("Error in getout");
      _out = 4;
      break;
  }
  return _out;
}

int outLevel(int _inByte, int _level, String _state, String _onoff) {
  if ((_state == "Running") && (_level == 0) && (_onoff == "OnTime")) {
    return 3;
  }
  else if (_inByte == 0) {
    return 1;
  }
  else {
    return 1;
  }
}

int outLevel2(int _inByte, int _level, String _state, String _onoff) {
  int _outLevel;
  if ((_state == "Running") && (_level == 0) && (_onoff == "OnTime") && (workingtime[3] < 120)) {  // when water level decreased and comes to 5 cm
    workingtime[3]++;
    _outLevel = 3;
  }else if ((_state == "Running") && (_level == 1) && (_onoff == "OnTime") && (workingtime[3] < 120) && (workingtime[3] > 0)) {  // when water level is 5 - 10 cm, and later level increase
    workingtime[3]++;
    _outLevel = 2;
  } else if (_inByte == 0) {  // initial
    workingtime[3] = 0;
    _outLevel = 1;
  } else if (workingtime[3] >= 120){  // 4 means alert
    _outLevel = 4;
  }else if (_inByte == 4){  // keep alert
    _outLevel = 4;
  } else {  // when water level is up 10 cm, and later level decrease
    workingtime[3] = 0;
    _outLevel = 1;
  }
  println(workingtime[3]);
  return _outLevel;
}

int outHum(int _inByte, float _hum, String _state, String _onoff) {
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

void getPicture(int _i, String _state) {
  if(_state == "Stop"){
    img[_i] = imgA;
  }else{
    img[_i] = imgB;
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
