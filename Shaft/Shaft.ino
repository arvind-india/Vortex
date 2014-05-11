// Vortex sandbox code.
// Turn the LEDs on and off as fast as possible to evaluate arc length.

// #define FORCE_SOFTWARE_SPI
// #define FORCE_SOFTWARE_PINS
#include "FastLED.h"

// How many leds are in the strip?
#define NUM_LEDS 160

// Data pin that led data will be written out over
#define DATA_PIN 11

// Clock pin only needed for SPI based chipsets when not using hardware SPI
#define CLOCK_PIN 13

// This is an array of leds.  One item for each led in your strip.
CRGB leds[NUM_LEDS];

// This function sets up the ledsand tells the controller about them
void setup() {
  // sanity check delay - allows reprogramming if accidently blowing power w/leds
  delay(2000);
  FastLED.addLeds<LPD8806, DATA_PIN, CLOCK_PIN, RGB>(leds, NUM_LEDS);
}

void loop() {
  // On
  for(int i = 0; i < NUM_LEDS; i++) {
    leds[i] = CRGB::White;
  }
  FastLED.show();   
  
  // Off
  for(int i = 0; i < NUM_LEDS; i++) {
    leds[i] = CRGB::Black;
  }
  FastLED.show();     
}
