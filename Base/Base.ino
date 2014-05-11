// Controlling a servo position using a potentiometer (variable resistor) 
// by Michal Rinott <http://people.interaction-ivrea.it/m.rinott> 

#include <Servo.h> 
#include <Encoder.h>
  
// Change these two numbers to the pins connected to your encoder.
//   Best Performance: both pins have interrupt capability
//   Good Performance: only the first pin has interrupt capability
//   Low Performance:  neither pin has interrupt capability
Encoder myEnc(5, 6);
//   avoid using pins with LEDs attached

// https://www.sparkfun.com/products/10932

long oldPosition  = -999;

Servo myservo;  // create servo object to control a servo 
 
int potpin = A13;  // analog pin used to connect the potentiometer
int val;    // variable to read the value from the analog pin 
 
void setup() 
{ 
  Serial.begin(9600);
  Serial.println("Basic Encoder Test:");  
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
} 
 
void loop() 
{ 
//  val = analogRead(potpin);            // reads the value of the potentiometer (value between 0 and 1023) 
//  val = map(val, 0, 1023, 0, 179);     // scale it to use it with the servo (value between 0 and 180) 
//  myservo.write(val);                  // sets the servo position according to the scaled value 
//  delay(15);                           // waits for the servo to get there 


  long newPosition = myEnc.read();
  if (newPosition != oldPosition) {
    oldPosition = newPosition;
    Serial.println(newPosition);
  }
} 
