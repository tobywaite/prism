// Prism - GE Color Effects Light Display
//
// Copyright (c) 2012 Toby Waite
// Heavily based on work by John Graham-Cumming
//
// I hacked a set of GE Color Effects 50 lights to make a 7x7 color display and
// this program controls the display to show different light patterns
//
// Specifically, there are two modes. A 'color cycle' mode that sweeps across
// the color spectrum, and a 'set' mode that displays a single color.
// These are controlled by an external switchbox, along with the brightness.

#include "protocol.h"

int sweepMode = 2; // Sweep mode on digital 2
int hueValue = 0; // Hue on analog 0
int brightnessValue = 5; // Brightness on analog 5

int hues[42][3] = {{7, 0, 0},
                   {7, 1, 0},
                   {7, 2, 0},
                   {7, 3, 0},
                   {7, 4, 0},
                   {7, 5, 0},
                   {7, 6, 0},
                   {7, 7, 0},
                   {6, 7, 0},
                   {5, 7, 0},
                   {4, 7, 0},
                   {3, 7, 0},
                   {2, 7, 0},
                   {1, 7, 0},
                   {0, 7, 0},
                   {0, 7, 1},
                   {0, 7, 2},
                   {0, 7, 3},
                   {0, 7, 4},
                   {0, 7, 5},
                   {0, 7, 6},
                   {0, 7, 7},
                   {0, 6, 7},
                   {0, 5, 7},
                   {0, 4, 7},
                   {0, 3, 7},
                   {0, 2, 7},
                   {0, 1, 7},
                   {0, 0, 7},
                   {1, 0, 7},
                   {2, 0, 7},
                   {3, 0, 7},
                   {4, 0, 7},
                   {5, 0, 7},
                   {6, 0, 7},
                   {7, 0, 7},
                   {7, 0, 6},
                   {7, 0, 5},
                   {7, 0, 4},
                   {7, 0, 3},
                   {7, 0, 2},
                   {7, 0, 1}};

void sequential_sweep(int r, int g, int b, int i){
  for(int n=1; n<50; n++){
    protocol_set_led_state_by_id(n, r, g, b, i);
    delay(10);
  }
}

int getBrightness(){
  return analogRead(brightnessValue)/4; // scale to between 0 & 255
}

int getHue(){
  int rawHue = analogRead(hueValue);
  int scaledHue = rawHue/24; // divide by 24 to scale 1024 to be ~between 0-42.
  if(rawHue > 41){
    rawHue = 41;
  }
  return scaledHue;
}

void setup()
{
  Serial.begin(115200);
  protocol_init();
  delay(1000);
  protocol_broadcast(0, 0, 0, 0);

  // Initialize controlbox digital input
  pinMode(sweepMode, INPUT);
}

void loop()
{
  for(int i=0; i<42; i++){
    int brightness = getBrightness();
    if(digitalRead(sweepMode))
      sequential_sweep(hues[i][0], hues[i][1], hues[i][2], brightness);
    else{
      // Hue value (from HSV color wheel)
      int hue = getHue();

      // Corresponding rgb values from lookup table
      int r = hues[hue][0];
      int g = hues[hue][1];
      int b = hues[hue][2];

      for(int n=1; n<50; n++){
        protocol_set_led_state_by_id(n, r, g, b, brightness);
      }
    }
  }
}
