

//#define DEBUG 1

// Inbound commands from iPad bluetooth
const char SET_DRILL_SPEED = 'a'; // float from 0 to 1
const char SET_TIME_SCALE = 'b'; // float, percentage of actual duration
const char SET_LEDS_ALL_ON = 'c'; // no params
const char SET_LEDS_ALL_OFF = 'd'; // no params
const char SET_LED = 'e'; // XXX address XXX red XXX green XXX blue



const char SET_LEDS_ALL_HUE = 'f'; // XXX hue
const char SET_LEDS_ALL_SATURATION = 'g'; // XXX sat
const char SET_LEDS_ALL_BRIGHTNESS = 'h'; // XXX bright

// IF YOU CHANGE THESE NUMBERS YOU WILL DAMAGE THE SERVO!!!
const float servoMin = 40.0;
const float servoMax = 150.0;
// IF YOU CHANGE THESE NUMBERS YOU WILL DAMAGE THE SERVO!!!

// #define FORCE_SOFTWARE_SPI
// #define FORCE_SOFTWARE_PINS
#include "FastLED.h"
#include <Servo.h> 

#define SERVO_PIN 23  // Teensy

// How many leds are in the strip?
#define NUM_LEDS 256

// Data pin that led data will be written out over  
#define DATA_PIN 11  // Teensy
// #define DATA_PIN 6  // Uno

// Clock pin only needed for SPI based chipsets when not using hardware SPI
#define CLOCK_PIN 13  // Teensy
//#define CLOCK_PIN 7  // Uno


CRGB ledsModel[NUM_LEDS]; // The "model"
CRGB ledsView[NUM_LEDS]; // The "view" (what's actually displayed)
unsigned long ledSetTimes[NUM_LEDS]; // remember when they were written... millis or micros!?
unsigned long ledDrawLoopSetTimes[NUM_LEDS]; // optimization, scales set times to draw loop duration

float timeScale; // microseconds
unsigned long scaledTimeRange; // generated

Servo drillTriggerServo;  // create servo object to control a servo  

void setup() {
  // sanity check delay - allows reprogramming if accidently blowing power w/leds
  delay(2000);
  FastLED.addLeds<LPD8806, DATA_PIN, CLOCK_PIN, RGB>(ledsView, NUM_LEDS);
  allLEDsOff(); // Initializes model and time array
  
  // Initialize values
  timeScale = 0.0;
  
  Serial1.begin(57600);
  drillTriggerServo.attach(SERVO_PIN);  // attaches the servo on pin 9 to the servo object
  
  #ifdef DEBUG
  //Serial.begin(57600);
  Serial.println("Hello from the shaft.");
  #endif

  setDrillSpeedNormalized(0.0);  
} 
 
void loop() { 
  readSerial(); 
  updateLEDs();
}


void updateLEDs() {
  if (timeScale == 0) {
      // Draw whatever's in the model immediately    
      for (int i = 0; i < NUM_LEDS; i++) {
        ledsView[i] = ledsModel[i];
      }        
  }
  else {
    // Draw progressively
    unsigned long drawLoopTime = millis() % scaledTimeRange;
      for (int i = 0; i < NUM_LEDS; i++) {
        if (ledDrawLoopSetTimes[i] < drawLoopTime) {
                ledsView[i] = ledsModel[i];
        }
        else {
          ledsView[i] = CRGB::Black;
        }
      }
  }
  
  FastLED.show();
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
      Serial.println(normalizedDrillSpeed);
      break;
    }
    case SET_TIME_SCALE: {
      char bodyChars[body.length()];
      body.toCharArray(bodyChars, sizeof(bodyChars));
      timeScale = atof(bodyChars);      
      recalculateDrawLoopTimes();
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
      
      ledsModel[pixelAddress] = CRGB(redValue, greenValue, blueValue);
      ledSetTimes[pixelAddress] = millis();
      recalculateDrawLoopTimes();
      
      break;
    }
    case SET_LEDS_ALL_HUE: {
//      int hueValue = body.toInt();          
//       for(int i = 0; i < NUM_LEDS; i++) {
//         CHSV pixelsHSV = CHSV(leds[i]);
//         pixelsHSV.hue = hueValue;
//         hsv2rgb_spectrum(hueValue, leds[i]);
//      }
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

void allLEDsOn() {
  unsigned long ledSetTime = millis();
  
  for(int i = 0; i < NUM_LEDS; i++) {
    ledsModel[i]  = CRGB::White;
    ledSetTimes[i] = ledSetTime;
  }
  recalculateDrawLoopTimes();
}

void allLEDsOff() {
  for(int i = 0; i < NUM_LEDS; i++) {
    ledsModel[i]  = CRGB::Black;
    ledSetTimes[i] = 0; // "0" is null time
  }
  recalculateDrawLoopTimes();  
}




void recalculateDrawLoopTimes() {
  // find limits of drawing
  unsigned long ledSetTimeOldest = 4294967294;
  unsigned long ledSetTimeNewest = 0;  
  
  for (int i = 0; i < NUM_LEDS; i++) {
    if (ledSetTimes[i] > 0) { // "0" is null time
     ledSetTimeOldest = min(ledSetTimeOldest, ledSetTimes[i]);
     ledSetTimeNewest = max(ledSetTimeNewest, ledSetTimes[i]);       
    }
  }
    
  // map these to the duration of a draw loop...


      
      
  for (int i = 0; i < NUM_LEDS; i++) {
    if (ledSetTimes[i] > 0) {

          unsigned long timeSinceStart = ledSetTimes[i] - ledSetTimeOldest;
        unsigned long totalTimeRange = ledSetTimeNewest - ledSetTimeOldest;
      double timePercent = ((double)timeSinceStart / (double)totalTimeRange);
      unsigned long drawLoopTime = (unsigned long)(timePercent * ((double)totalTimeRange) * timeScale);

      scaledTimeRange = (unsigned long)((double)totalTimeRange * timeScale);

      #ifdef DEBUG
            Serial.print("Time scale: ");      
      Serial.println(timeScale);
            Serial.print("Mapping time : ");
            Serial.print(ledSetTimes[i]);      
            Serial.print(" from Oldest: ");
            Serial.print(ledSetTimeOldest);            
            Serial.print(" to Newest: ");      
            Serial.print(ledSetTimeNewest);
            Serial.print(" to value between 0 and ");


            Serial.print("timeSinceStart ");
            Serial.println(timeSinceStart);            
            Serial.print("totalTimeRange ");
            Serial.println(totalTimeRange);                        
            Serial.print("timePercent "); 
            Serial.println(timePercent);      
            Serial.print("drawLoopTime ");             
            Serial.println(drawLoopTime);                 
            
       #endif   
      
      ledDrawLoopSetTimes[i] = drawLoopTime;
      
      if (ledDrawLoopSetTimes[i] == 0) {
      ledDrawLoopSetTimes[i] = 1;
      }
      

   
    }
    else {
      ledDrawLoopSetTimes[i] = 0; // null
    }
  }

//    #ifdef DEBUG
//    Serial.println(ledSetTimeOldest);
//    Serial.println(ledSetTimeNewest);    
//    #endif
  
  
}

// utilities

void delayMicrosecondsFixed(int duration) {
  // Ugh http://arduino.cc/en/Reference/DelayMicroseconds
  if (duration <= 16383) {
    delayMicroseconds(duration);
   }
  else {
    delay(duration / 1000);
  }
}

float mapfloat(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}  

float mapUnsignedLong(unsigned long x, unsigned long in_min, unsigned long in_max, unsigned long out_min, unsigned long out_max) {
  return (unsigned long)((double)((x - in_min) * (out_max - out_min)) / (double)((in_max - in_min) + out_min));
}  



