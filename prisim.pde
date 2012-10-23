// Prism - GE Color Effects Light Display
//
// Copyright (c) 2012 Toby Waite
// Heavily based on work by John Graham-Cumming
//
// I hacked a set of GE Color Effects 50 lights to make a 7x7 color display and
// this program controls the display to show different light patterns, based on
// serial input from prismd

#include "protocol.h"

/* Map of N to x,y.     y:
x: 0  1  2  3  4  5  6
//42 43 44 45 46 47 48  6
//41 40 39 38 37 36 35  5
//28 29 30 31 32 33 34  4
//27 26 25 24 23 22 21  3
//14 15 16 17 18 19 20  2
//13 12 11 10 09 08 07  1
//00 01 02 03 04 05 06  0
*/
// Struct to read in serial data and partition it into correct rgb led commands
union serial_convertor
{
  struct
  {
    byte start: 4;
    byte red: 4;
    byte green: 4;
    byte blue: 4;
    byte intensity: 8;
    byte n: 8;
  } data;
  struct
  {
    byte raw[4];
  } raw;
};

void sequential_sweep(int r, int g, int b, int i){
  for(int n=0; n<50; n++){
    protocol_set_led_state_by_id(n, r, g, b, i);
    delay(10);
  }
}

void setup()
{
  Serial.begin(115200);
  protocol_init();
  delay(1000);
  protocol_broadcast(0, 0, 0, 0);
}

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

void loop()
{
  for(int i=0; i<42; i++){
    sequential_sweep(hues[i][0], hues[i][1], hues[i][2], 255);
  }
  /*
  // read in all serial data in 3 byte chunks and update the frame buffer accordingly.
  if (Serial.available() >=4)
  {
    // read 4 bytes into the convertor.
    union serial_convertor input;
    int i=0;
    for(i; i<4; i++)
    {
      input.raw.raw{i} = Serial.read();
      if(input.data.start != B0011){
        Serial.flush();
        break;
      }
    }
    if(input.data.start == B0011){
      // update the frame buffer with the input data
      protocol_set_led_state_by_id(input.data.n, 
                             input.data.red,
                             input.data.green,
                             input.data.blue,
                             input.data.intensity);
    }
  }
  */
}
