import java.util.*;
import processing.serial.*;
import processing.sound.*;

SoundFile soundfile;
Serial myPort;
//Serial triggerPort; //agregada
ArrayList<Stim> stims;

Serial ledPort;  // Create object from Serial class

int lastTime;
int startTime;
int time;

int currentStim;
int currentFrame = 0;

boolean soundSent = false;
float soundTime = -1;

boolean playing = false;
boolean started = false;
boolean paused = false;

float dt = -200;
float stimTime = 25;
float extraTime = 10;


//float isi = 40;
//int repetitions = 1;


int repetitions = 5;
float isi = 5;

void setup(){
  size(1024,360);
  
  
  ledPort = new Serial(this, "COM6", 9600);
  myPort = new Serial(this, "COM9", 9600);
  //triggerPort = new Serial(this, "COM3", 9600); //agregada
  
  soundfile = new SoundFile(this, "sin220.wav");
  
  currentStim = 0;
  stims = new ArrayList<Stim>();
  
  for(int i = 0; i < repetitions; i++){ 
    //stims.add(new Stim(1, 1, dt));
    //stims.add(new Stim(1, 0, dt));
    stims.add(new Stim(0, 1, dt));
    //stims.add(new Stim(0, 0.3, dt));
    //stims.add(new Stim(0.3, 0.3, dt));
    //stims.add(new Stim(1, 0.3, dt));
    //stims.add(new Stim(0.0, 0.0, dt));
    //stims.add(new Stim(0.3, 0, dt));
    //stims.add(new Stim(0.3, 1, dt));
  }
  Collections.shuffle(stims);
  
  for(Stim stim: stims){
    println(stim.v + "\t" + stim.a);
  }
  println("READY FOR V: " + stims.get(currentStim).v + " and A: " + stims.get(currentStim).a + ".");
  
  time = 0;
  lastTime = millis();
}

void init(){
  Stim stim = stims.get(currentStim);
  soundfile.amp(stim.a);
  
  currentFrame = 0;
  
  soundSent = false;
  playing = true;
  
  println("PLAYING!");
  
  startTime = time;
  
  
  if(stim.v > 0){
    sendLoom(int((1-stim.v)*15));
  }
  
  //triggerPort.write('a');
  ledPort.write(byte('S'));
}

void sendLoom(int r){
  myPort.write(r+48);
}

void soundUpdate(int now, float dt, float a){
  
  if(!soundSent && now - startTime >= stimTime*1000 + dt){
    if(a > 0){
      soundfile.play();
    }
    ledPort.write(byte('S'));
    soundSent = true;
  }
  
  

}

void nextStim(){
  playing = false;
  soundTime = -1;
  startTime = time;
  currentStim++;
  if(currentStim >= stims.size()){
    println("FINISHED PROGRAM SUCCESSFULLY");
    noLoop();
    exit();
  } else{
    println("READY FOR V: " + stims.get(currentStim).v + " and A: " + stims.get(currentStim).a + ".");
  }
}

void prevStim(){
  currentStim--;
  playing = false;
  soundTime = -1;
  startTime = time;
  
  if(currentStim < 0){
    currentStim = 0;
  } else{
    println("READY FOR V: " + int(stims.get(currentStim).v) + " and A: " + int(stims.get(currentStim).a) + ".");
  }
}

void update(int now){
  
  Stim stim = stims.get(currentStim);
  
  soundUpdate(now, stim.dt, stim.a);
  
  if(now - startTime >= (stimTime + extraTime)*1000){
    nextStim();
  }
  
}


String getStimInfo(Stim s){
  String stimInfo = "CTRL.";
  
  if(s.v > 0){
    if(s.a > 0){
      stimInfo = "MULTI (V = " + s.v + ", A = " + s.a + ").";
    } else{
      stimInfo = "VIS (V = " + s.v + ").";
    }
  } else if(s.a > 0){
    stimInfo = "AUD (A = " + s.a + ").";
  }
  
  return stimInfo;
}

void UI(int now){
  
  int textSize = 30;
  int xmargin = 10;
  int ymargin = 10;
  
  int interline = textSize + ymargin;
  
  background(255);
  
  String stimCounter = "Stim " + (currentStim + 1) + " of " + stims.size();
  
  if(!started){
    stimCounter = "Press ENTER to begin experiment";
  }
  
  noStroke();
  fill(0);
  textSize(textSize);
  textAlign(LEFT, TOP);
  text(stimCounter, xmargin,ymargin);
  
  String state = "-";
  
  String showTime = "";
  
  String regresiva = "";
  float reg = isi - ((now - startTime)/1000.0);
  
  if(started){
    if(playing){
      if(now - startTime < stimTime*1000){
        state = "Stimulation";
        showTime =  "" + int((now - startTime)/1000) + " s.";
      } else {
        state = "Post-stimulation";
        showTime =  "" + int((now - startTime - stimTime*1000)/1000) + " s.";
      }
      
    } else {
      state = "Inter-stimulus interval";
      showTime =  "" + int((now - startTime)/1000) + " s.";
      
      if(reg < 4){
        regresiva = "Stimulus in " + round(reg*10)/10.0 + " s.";
      }
      
    }
  }
  
  textAlign(RIGHT, TOP);
  text(state, width-xmargin, ymargin);
  text(showTime, width-xmargin, ymargin + interline);
  text(regresiva, width-xmargin, ymargin + 2*interline);
  
  if(!playing && reg < 4){
    noStroke();
    fill(255,0,0);
    int y = ymargin + 3*interline;
    int x = width-xmargin;
    float w = map(reg,0,4,0,200);
    rect(x-w,y, w, 20);
  }
  
  Stim s = stims.get(currentStim);
  
  if(s.a > 0 && soundTime==-1 && soundSent){
    
  }
  
  if(playing && s.a > 0 && soundSent){
    if(soundTime==-1){
      soundTime = (now - startTime)/1000.0;
    }
    textAlign(RIGHT, BOTTOM);
    text("Sound sent at " + round(soundTime*100)/100.0 + " s.", width-xmargin, height - ymargin);
  }
  
  
  
  
  String currentStimInfo = getStimInfo(s);
  
  String prevStimInfo = "";
  String nextStimInfo = "";
  
  if(currentStim > 0){
    s = stims.get(currentStim-1);
    prevStimInfo = getStimInfo(s);
  }
  
  if(currentStim < stims.size()-1){
    s = stims.get(currentStim+1);
    nextStimInfo = getStimInfo(s);
  }
  
  if(!started){
    nextStimInfo=currentStimInfo;
    currentStimInfo = "";
    prevStimInfo = "";
  }
  
  textAlign(LEFT, BOTTOM);

  fill(100);
  text("Previous: " + prevStimInfo, xmargin, height - ymargin - 2*interline);

  fill(100);
  text("Next: " + nextStimInfo, xmargin, height - ymargin);
  fill(0);
  text("Current: " + currentStimInfo, xmargin, height - ymargin - interline);
  
  
  if(playing && now - startTime < 1000){
    fill(255,0,0);
    noStroke();
    ellipse(width/2, height/2, 20, 20);
  }
  
};

void draw(){
  if(!paused){
    time = time + (millis() - lastTime);
  }
  lastTime = millis();
  
  UI(time);
  
  if(!started){
    return;
  }
  
  if(playing){
    update(time);
  } else{
    
    if(time - startTime > isi*1000){
      init();
    }
  }
  
}

void keyPressed(){
  if(playing){
    return;  
  }
  
  if(key == ENTER && !started){
    started = true;
    startTime = time;
    //init();
  }else if(keyCode == RIGHT){
    nextStim();
  }else if(keyCode == LEFT){
    prevStim();
  } else if(!playing && (key == 'P' || key == 'p')){
    paused = !paused;
  }
}
