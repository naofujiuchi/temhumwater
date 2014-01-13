//フォント使用
PFont font;
// Initialize image class
PImage imgA;
PImage imgB;
PImage imgC;
PImage imgD;
PImage imgE;
PImage imgF;
PImage img1;
PImage img2;
PImage img3;
boolean flag;
//シリアルライブラリの取り込み
import processing.serial.*;
//シリアルクラスのインスタンス
Serial myPort;
//変数宣言
int press;
int press1;
int press2;
int press3;
String state1 = "Stop";
String state2 = "Stop";
String state3 = "Stop";
String onoff1;
String onoff2;
String onoff3;
int level;
int inByte1;
int inByte2;
int inByte3;
float hum;
float temp;
int out1;
int out2;
int out3;
int s;
int m;
int h;
String t;

void setup(){
  size(1000, 400);
  frameRate(1);
  font = loadFont("Calibri-24.vlw");
  textFont(font);
  textAlign(RIGHT);
  myPort=new Serial(this, "/dev/cu.usbmodem1411", 9600);
  myPort.buffer(6);
  imgA = loadImage("playgreen.png");
  imgB = loadImage("pausegreen.png");
  imgC = loadImage("playorange.png");
  imgD = loadImage("pauseorange.png");
  imgE = loadImage("playgreen.png");
  imgF = loadImage("pausegreen.png");
  flag = false;
}

void draw(){
  background(100);
  getTime();
  onoff1 = onoffTime1(h, m);
  onoff2 = onoffTime2(h, m);
  onoff2 = onoffTime3(h, m);
  //シリアルbufferにデータが5個あるとき
  if(myPort.available() == 6){
    readData();
    myPort.clear();
    out1 = output1(inByte1, level, state1, onoff1);
    out2 = output1(inByte2, hum, state2, onoff2);
    out2 = output3(inByte3, hum, state3, onoff3);
    myPort.write(out1);
    myPort.write(out2);
    myPort.write(out3);
  }
  getPicture(state1, state2, state3);
  display(t, level, hum, temp,  state1, state2, state3, onoff1, onoff2, onoff3, inByte1, inByte2, inByte3);
}

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

void getTime(){
  h = int(hour());
  m = int(minute());
  s = int(second());
  t = h + ":" + nf(m, 2) + ":" + nf(s, 2);
}

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

void display(String _t, int _level, float _hum, float _temp, String _state1, String _state2, String _state3, String _onoff1, String _onoff2, String _onoff3, int _inByte1, int _inByte2, int _inByte3){
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
  text(_state1, 160, 110);
  text(_state2, 410, 110);
  text("onoffTime", 300, 130);
  text(_onoff1, 160, 130);
  text(_onoff2, 410, 130);
  text("inByte", 280, 150);
  text(_inByte1, 135, 150);
  text(_inByte2, 390, 150);
}

void readData(){
  inByte1 = myPort.read();
  inByte2 = myPort.read();
  inByte3 = myPort.read();
  level1 = myPort.read()
  level2 = myPort.read();
  hum = myPort.read();
  temp = myPort.read();
}

int output1(int _inByte1, int _level, String _state1, String _onoff1){
  if((_state1 == "Running") && (_level == 0) && (_onoff1 == "OnTime")){
    return 3;
  }else if(_inByte1 == 0){
    return 1;
  }else{
    return 1;
  }
}

int output2(int _inByte2, float _hum, String _state2, String _onoff2){
  if((_state2 == "Running") && (_hum < 90) && (_onoff2 == "OnTime")){
    return 3;
  }else if(_inByte2 == 0){
    return 1;
  }else{
    return 1;
  }
}

int output3(int _inByte3, int _level, String _state3, String _onoff3){
    if((_state3 == "Running") && (_level == 0) && (_onoff3 == "OnTime")){
    	return 3;
	}else if(_inByte3 == 0){
	      	return 1;
	}else{
		return 1;
	}
}

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

//ProcessingをRunしたときに出てくるウィンドウをクリックすると
void mousePressed(){
  press++;
  if(press == 1){
    myPort.clear();
    myPort.write(0);
    myPort.write(0);
    myPort.write(0);
  }
  if(mouseX >= 40 && mouseX <= 220 && mouseY >= 180 && mouseY <= 360){
    countPress1();
  }
  if(mouseX >= 290 && mouseX <= 470 && mouseY >= 180 && mouseY <= 360){
    countPress2();
  }
  if(mouseX >= 540 && mouseX <= 720 && mouseY >= 180 && mouseY <= 360){
    countPress3();
  }
}
