// Controlling a servo position using a potentiometer (variable resistor) 
// by Michal Rinott <http://people.interaction-ivrea.it/m.rinott> 

// Inbound commands from iPad bluetooth
const char SET_DRILL_SPEED = 'a'; // float from 0 to 1
const int SET_LED_BLINK_INTERVAL = 'b'; // int, microseconds ... 1000 is a millisecond, 1000000 is a second
const int SET_LEDS_ALL_ON = 'c'; // no params
const int SET_LEDS_ALL_OFF = 'd'; // no params
const int SET_LED = 'e'; // XXX address XXX red XXX green XXX blue

const int SET_LEDS_ALL_HUE = 'f'; // XXX hue
const int SET_LEDS_ALL_SATURATION = 'g'; // XXX sat
const int SET_LEDS_ALL_BRIGHTNESS = 'h'; // XXX bright


// IF YOU CHANGE THESE NUMBERS YOU WILL DAMAGE THE SERVO!!!
const float servoMin = 40.0;
const float servoMax = 150.0;

int blinkIntervalMicroseconds;

// #define FORCE_SOFTWARE_SPI
// #define FORCE_SOFTWARE_PINS
#include "FastLED.h"
#include <Servo.h> 

#define SERVO_PIN 23  // Teensy

// How many leds are in the strip?
#define NUM_LEDS 288

// Data pin that led data will be written out over  
#define DATA_PIN 11  // Teensy
// #define DATA_PIN 6  // Uno

// Clock pin only needed for SPI based chipsets when not using hardware SPI
#define CLOCK_PIN 13  // Teensy
//#define CLOCK_PIN 7  // Uno

// This is an array of leds.  One item for each led in your strip.
CRGB leds[NUM_LEDS];
int ledSetTimes[NUM_LEDS]; // remember when they were written




Servo drillTriggerServo;  // create servo object to control a servo  

void setup() {
  // sanity check delay - allows reprogramming if accidently blowing power w/leds
  delay(2000);
  FastLED.addLeds<LPD8806, DATA_PIN, CLOCK_PIN, RGB>(leds, NUM_LEDS);
  allLEDsOff();    
  
  // Initialize values
  blinkIntervalMicroseconds = 0;
  setDrillSpeedNormalized(0.0);
  // Set up stuff
  Serial1.begin(57600);
  drillTriggerServo.attach(SERVO_PIN);  // attaches the servo on pin 9 to the servo object

  //  Serial1.println("Hello from the shaft");  
} 
 
void loop() { 
  readSerial(); 
  
//  allLEDsOn();
  
//  // Flash the lights for testing purposes
//  if (blinkIntervalMicroseconds > 0) {
//    delayMicrosecondsFixed(blinkIntervalMicroseconds);    
//    allLEDsOff();
//    delayMicrosecondsFixed(blinkIntervalMicroseconds);
//  }
}

String incomingSerialPacket = "";

void readSerial() {
  char incomingChar;  
  
  while (Serial1.available()) {
    incomingChar = Serial1.read();

    if ((incomingChar == 10) && (incomingSerialPacket.length() > 0)) {
      // New line delimits packets
      receivedPacket(String(incomingSerialPacket)); // Copy packet string
      incomingSerialPacket = ""; // Reset
    }
    else if (incomingChar != 13) {
      // Ignore \r, packets break on \n instead
      // Legitimate character, add it to the packet
      incomingSerialPacket += incomingChar;
    }
  }
}

void receivedPacket(String packet) {
  char header = packet[0];
  String body = packet.substring(1);

  //sendPacket(DEBUG_MESSAGE_EVENT, packet);
  // Take action based on header
  switch (header) {

    case SET_DRILL_SPEED: {
      char bodyChars[body.length()];
      body.toCharArray(bodyChars, sizeof(bodyChars));
      float normalizedDrillSpeed = atof(bodyChars);
      setDrillSpeedNormalized(normalizedDrillSpeed);
      //Serial1.println(normalizedDrillSpeed);
      break;
    }
    case SET_LED_BLINK_INTERVAL: {
      char bodyChars[body.length()];
      body.toCharArray(bodyChars, sizeof(bodyChars));
      blinkIntervalMicroseconds = atoi(bodyChars);
      break;
    }
    case SET_LEDS_ALL_ON: {
      allLEDsOn();
      break;
    }    
    case SET_LEDS_ALL_OFF: {
      allLEDsOff();
      break;   
    }
    case SET_LED: {
      int pixelAddress = body.substring(0, 3).toInt();
      int redValue = body.substring(3, 6).toInt();      
      int greenValue = body.substring(6, 9).toInt();
      int blueValue = body.substring(9, 12).toInt();
      
      CRGB pixelColor = CRGB(redValue, greenValue, blueValue);
      leds[pixelAddress] = pixelColor;
      FastLED.show();        
      break;
    }
    case SET_LEDS_ALL_HUE: {
//      int hueValue = body.toInt();          
//       for(int i = 0; i < NUM_LEDS; i++) {
//         CHSV pixelsHSV = CHSV(leds[i]);
//         pixelsHSV.hue = hueValue;
//         hsv2rgb_spectrum(hueValue, leds[i]);
//      }
//      FastLED.show();
      break;      
    }
    default: {
      // Throw an error if header is unknown
      //String errorMessage = "UnknownCommand:";
      //errorMessage += header;
      //sendPacket(ERROR_EVENT, errorMessage);
    }
  }
}

void setDrillSpeedNormalized(float drillSpeed) {
  // Turn drill speed to servo position
  int servoPosition = round(mapfloat(drillSpeed, 0.0, 1.0, servoMin, servoMax));
  drillTriggerServo.write(servoPosition);
}  
  
float mapfloat(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}  


void allLEDsOn() {
  for(int i = 0; i < NUM_LEDS; i++) {
    leds[i] = CRGB::White;
  }  
  FastLED.show();  
}


void delayMicrosecondsFixed(int duration) {
  // Ugh http://arduino.cc/en/Reference/DelayMicroseconds
  if (blinkIntervalMicroseconds <= 16383) {
    delayMicroseconds(blinkIntervalMicroseconds);
   }
  else {
    delay(blinkIntervalMicroseconds / 1000);
  }
}




void allLEDsOff() {
  for(int i = 0; i < NUM_LEDS; i++) {
    leds[i] = CRGB::Black;
  }  
  FastLED.show();  
}

