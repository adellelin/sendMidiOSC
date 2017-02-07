// SimpleMidi.pde

import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; 

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress phone;

MidiBus myBus; 

boolean ledOn = false;

boolean PRINT_NOTES = true;
boolean PRINT_NOTE_OFF = false;
boolean PRINT_CC = false;

int currentColor = 0;
int midiDevice  = 0;
int note;
int vel;

int maxCounter = 1000;
long timestamps[] = new long[maxCounter];
int counter = 0;

void setup() {
  size(1024, 720);
  background(0);
  frameRate(25);
  MidiBus.list(); 
  myBus = new MidiBus(this, midiDevice, 0);

  oscP5 = new OscP5(this, 12000);
  //phone = new NetAddress("10.175.92.101", 9000);
  //phone = new NetAddress("192.168.1.5", 8000);
  phone = new NetAddress("10.10.11.150", 8000);
  //phone = new NetAddress("10.175.88.128", 8000); // to send to unity
}

void draw() {
  background(0);
  noStroke();
  fill(note * 3, (note - 50) * 50, 0);
  ellipse(width/3, 200, 200, 200);

  fill(255);
  text("note", width/3, 400);
  fill(0, (vel-60) * 5, 100);

  ellipse(width * 2/3, 200, 200, 200);
  fill(255);
  text("velocity", width * 2/3, 400);

  /*
  fill(note * 3, (note - 50) * 50, 0);
  for (int i = 0; i < maxCounter; i++) {
    float placement = map(timestamps[i], 0, 20000, 0, 1280);  
    ellipse(placement, 600, 10, 10);
  }
  */
  
}

/*
void midiMessage(MidiMessage message, long timestamp, String bus_name) { 
  note = (int)(message.getMessage()[1] & 0xFF) ;
  vel = (int)(message.getMessage()[2] & 0xFF);
  //sendOSCNotes(note, vel);
  println("Bus " + bus_name + ": Note "+ note + ", vel " + vel);
  
}*/

void noteOn(int channel, int pitch, int vel) { 
  if (PRINT_NOTES) {
    print(millis());
    print(" Ch:"+channel);
    println(" P:"+pitch);
   
  }
  sendOSCNotes(pitch, vel);
  addTimestamp(); // only draws circle when note is on
  //addDataPoint(channel, pitch);
 
  
  if (vel > 0 ) {
    currentColor = color(note*3, vel*2, vel/2);
  }
}

void oscEvent(OscMessage theOscMessage) {
  print(" addpattern: " + theOscMessage.addrPattern());
  print(" typetag: " + theOscMessage.typetag());
  float firstVal = theOscMessage.get(0).floatValue();
  println(" value " + firstVal);
}

void addTimestamp() {
  timestamps[counter] = millis();
  counter++;
  counter = counter % maxCounter;
  return;
}

void sendOSCNotes(int note, int vel) { //53 (F), 52 (E), 55 (G), 57 (A), 48 (C), 50 (D)
  OscMessage myMessage = new OscMessage("/midiNote");
  //OscMessage myMessage = new OscMessage("/48");
  myMessage.add(note);
  myMessage.add(vel);
  println("notesent" + note);
  oscP5.send(myMessage, phone);
  //myMessage.add(velocity);
}

void mousePressed() {

  OscMessage myMessage = new OscMessage("/1/led1");
  println("sendingOsc");

  // myMessage.add(123); /* add an int to the osc message */
  if (!ledOn) {
    myMessage.add(1.0);
    ledOn = true;
  } else {
    myMessage.add(0.0);
    ledOn = false;
  }

  oscP5.send(myMessage, phone);
}