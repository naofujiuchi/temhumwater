//フォント使用
PFont font;
//シリアルライブラリの取り込み
import processing.serial.*;
//シリアルクラスのインスタンス
Serial myPort;
//変数宣言
float level;
float time;
float zerotime;
float temptime;
float temp;
float hum;
int inByte;
int s;
int m;
int h;
int d;
int press;
String state="Stop";
String onoff;

void setup(){
  size(100, 100);
  frameRate(1);
  font = loadFont("Calibri-24.vlw");
  textFont(font);
  textAlign(RIGHT);
  //シリアルポートの設定
  myPort=new Serial(this,"COM7",9600);
  //シリアルbufferの大きさ指定
  myPort.buffer(2);
}

void draw(){
  background(inByte);
  //press回数が2の倍数のとき
/*
  if(press%2==0){
    time=temptime;
  }
  //それ以外のとき
  else if(press%2==1){
    time=temptime+millis()-zerotime;
  }
  //日・時・分・秒計算
  d=int(time/86400000);
  h=int((time%86400000)/3600000);
  m=int((time%3600000)/60000);
  s=int((time%60000)/1000);
*/
  h=int(hour());
  m=int(minute());
  s=int(second());
  //時間表示
  String t = h + ":" + nf(m, 2) + ":" + nf(s, 2);
  //稼働時間指定
  if((h!=7)||(m>=10)){
    onoff="OnTime";
  }else{
    onoff="OffTime";
  }
  //ウィンドウにテキスト表示
  text(state,85,15);
  text(t, 85, 30);  
  text(hum, 85, 45);
  text(temp, 85, 60);
  text(onoff,85,75);
  text(inByte,55,90);
  //シリアルbufferにデータが2個あるとき
  if(myPort.available()==4){
    //Arduinoからのデータを読み込む
    level = myPort.read();
    inByte=myPort.read();
    hum=myPort.read();
    temp=myPort.read();
    //bufferクリア
    myPort.clear();
    //条件分岐で異なるシグナルをArduinoに送る
   if(((state=="Running")&&(level==1)&&(onoff=="OnTime"))||(inByte==3)){
      myPort.write(2);
    }else if(((state=="Running")&&(level==1)&&(onoff=="OnTime"))&&(inByte==0)){
      myPort.write(2);
    }else if((state=="Running")&&(level==1)&&(onoff=="OnTime")){
      myPort.write(1);
    }else{
      myPort.write(0);
    }
  }
}

void countPress(){
  press++;
  //ウィンドウクリック初回時は
  if(press==1){
    //Initialシグナル
    myPort.write(3);
    zerotime=millis();
    //Running状態
    state="Running";
  }
  //それ以外で奇数回時はInitialシグナルなしで
  else if(press%2==1){
    zerotime=millis();
    //Running状態
    state="Running";
  }
  //偶数回時は
  else if(press%2==0){
    temptime=time;
    //Stop状態
    state="Stop";
  }
}

//ProcessingをRunしたときに出てくるウィンドウをクリックすると
void mousePressed(){
  //bufferクリア
  myPort.clear();
  //countPressファンクションに飛ぶ
  countPress();
}

