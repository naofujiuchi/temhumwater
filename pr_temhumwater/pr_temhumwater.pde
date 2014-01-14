//1: Water level sensor for watering
//2: Humidity sensor for humidifying
//3: Water level sensor for humidifying

//フォント使用
PFont font;
// Initialize image class
PImage imgA;
PImage imgB;
/*
PImage imgC;
PImage imgD;
*/
PImage[] img = new PImage[4];
/*
PImage img1;
 PImage img2;
 PImage img3;
 */
boolean flag;
//シリアルライブラリの取り込み
import processing.serial.*;
//シリアルクラスのインスタンス
Serial myPort;
//変数宣言
int[] level = new int[4];
float hum;
float temp;
int s;
int m;
int h;
String t;
int[] press = new int[4];
String[] state = new String[4];
String[] onoff = new String[4];
int[] inByte = new int[4];
int[] out = new int[4];
/*
int press1;
 int press2;
 int press3;
 String state1 = "Stop";
 String state2 = "Stop";
 String state3 = "Stop";
 String onoff1;
 String onoff2;
 String onoff3;
 int inByte1;
 int inByte2;
 int inByte3;
 int out1;
 int out2;
 int out3;
 */

void setup() {
  int i;
  size(1000, 400);
  frameRate(1);
  font = loadFont("Calibri-24.vlw");
  textFont(font);
  textAlign(RIGHT);
  myPort=new Serial(this, "/dev/cu.usbmodem1411", 9600);
  myPort.buffer(6);
  imgA = loadImage("playgreen.png");
  imgB = loadImage("pausegreen.png");
  /*
  imgC = loadImage("playorange.png");
   imgD = loadImage("pauseorange.png");
   */
  flag = false;
  //initialize variables
  for (i = 1; i <= 3; i++) {
    state[i] = "Stop";
  }
}

void draw() {
  int i;
  background(100);
  getTime();
  for (i = 1; i <= 3; i++) {
    onoff[i] = onoffTime(i, h, m);
  }
  /*    
   onoff1 = onoffTime1(h, m);
   onoff2 = onoffTime2(h, m);
   onoff2 = onoffTime3(h, m);
   */
  //シリアルbufferにデータが7個あるとき
  if (myPort.available() == 7) {
    readSerial();
    myPort.clear();
    for (i = 1; i <= 3; i++) {
      out[i] = getout(i);
    }
    /*
    out1 = output1(inByte1, level, state1, onoff1);
     out2 = output1(inByte2, hum, state2, onoff2);
     out2 = output3(inByte3, hum, state3, onoff3);
     */
    myPort.write(out[1]);
    myPort.write(out[2]);
    myPort.write(out[3]);
  }
  for (i = 1; i <= 3; i++) {
    getPicture(i, state[i]);
  }
  display();
  /*
  getPicture(state1, state2, state3);
   display(t, level, hum, temp,  state1, state2, state3, onoff1, onoff2, onoff3, inByte1, inByte2, inByte3);
   */
}

int getout(int _i) {
  int _out;
  switch(_i){
    case 1:
    case 3:
      _out = outlevel(inByte[_i], level[_i], state[_i], onoff[_i]);
      return _out;
    case 2:
      _out = outhum(inByte[_i], hum, state[_i], onoff[_i]);
      return _out;
    default:
      return 1;
  }
}

void getPicture(int _i, String _state) {
  if(_state == "Stop"){
    img[_i] = imgA;
  }else{
    img[_i] = imgB;
  }
  image(img[_i], 250 * (_i - 1), 140);
}

/*
void getPicture(String _state1, String _state2, String _state3){
 if(_state1 == "Stop"){
 img1 = imgA;
 }else{
 img1 = imgB;
 }
 if(_state2 == "Stop"){
 img2 = imgC;
 }else{
 img2 = imgD;
 }
 if(state3 == "Stop"){
 	    img3 = imgA;
 	    }else{
 	    img3 = imgB;
 	    }
 image(img1, 0, 140);
 image(img2, 250, 140);
 image(img3, 500, 140);
 }
 */

void getTime() {
  h = int(hour());
  m = int(minute());
  s = int(second());
  t = h + ":" + nf(m, 2) + ":" + nf(s, 2);
}

String onoffTime(int _i, int _h, int _m) {
  switch(_i) {
    case 1:
      if ((_h == 15) && (_m < 20)) {
        return "OnTime";
      }else{
        return "OffTime";
      }
    case 2:
      return "OnTime";
    case 3:
      return "OnTime";
    default:
      return "OffTime";
  }
}
/*
String onoffTime1(int _h, int _m){
 //  if((_h == 15) && (_m < 20)){
 return "OnTime";
 //  }else{
 //    return "OffTime";
 //  }
 }  
 
 String onoffTime2(int _h, int _m){
 //  if((_h == 15) && (_m < 20)){
 return "OnTime";
 //  }else{
 //    return "OffTime";
 //  }
 }
 
 String onoffTime3(int _h, int _m){
 return "OnTime";
 }
 */

void display() {
  text("Autowater", 180, 20);
  text("Humidifier1", 430, 20);
  text("Humidifier2", 680, 20);
  text(t, 295, 20);
  text("level", 275, 50);
  text(level[1], 135, 50);
  text(level[2], 635, 50);
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
}

void readSerial() {
  inByte[1] = myPort.read();
  inByte[2] = myPort.read();
  inByte[3] = myPort.read();
  level[1] = myPort.read();
  level[3] = myPort.read();
  hum = myPort.read();
  temp = myPort.read();
}

int outlevel(int _inByte, int _level, String _state, String _onoff) {
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

int outhum(int _inByte, float _hum, String _state, String _onoff) {
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

/*
int output3(int _inByte3, int _level, String _state3, String _onoff3){
 if((_state3 == "Running") && (_level == 0) && (_onoff3 == "OnTime")){
 	return 3;
 	}else if(_inByte3 == 0){
 	      	return 1;
 	}else{
 		return 1;
 	}
 }
 */
/*
void countPress1(){
 press1++;
 if(press1 % 2 == 1){
 state1 = "Running";
 }
 else if(press1 % 2 == 0){
 state1 = "Stop";
 }
 }
 
 void countPress2(){
 press2++;
 if(press2 % 2 == 1){
 state2 = "Running";
 }
 else if(press2 % 2 == 0){
 state2 = "Stop";
 }
 }
 
 void countPress3(){
 press3++;
 if(press3 % 2 ==1){
 	       state3 = "Running";
 	       }
 	       else if(press3 % 2 == 0){
 	       	    state3 = "Stop";
 		    }
 }
 */
void countPress(int _i) {
  press[_i]++;
  if (press[_i] % 2 == 1) {
    state[_i] = "Running";
  }
  else {
    state[_i] = "Stop";
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

