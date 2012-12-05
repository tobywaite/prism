// Prism - GE Color Effects Light Display
//
// Copyright (c) 2012 Toby Waite
// Heavily based on work by John Graham-Cumming
//
// I hacked a set of GE Color Effects 50 lights to make a 7x7 color display and
// this program controls the display to show different light patterns, based on
// serial input from prismd

#include "protocol.h"

const int modeSwitch = 2; // Sweep mode on digital 2
const int hueValue = 0; // Hue on analog 0
const int brightnessValue = 5; // Brightness on analog 5

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

// Number of bytes in the serial command.
const byte SERIAL_COMMAND_LENGTH = 4;
// Number of bits in each type of data.
const int START_SEQ_BIT_DEPTH = 4;
const int COLOR_BIT_DEPTH = 4;
const int INTENSITY_BIT_DEPTH = 8;
const int LIGHT_INDEX_BIT_DEPTH = 8;

const char SERIAL_START_SEQ = B1100;

// This struct is for populating the converter using 4 bytes of raw serial input.
typedef struct {
  char raw[SERIAL_COMMAND_LENGTH];
} serial_buffer;

// This struct is for indexing into the data to access individual values.
// The first 4 bits are a start sequence, followed by 4 bits for each color.
// The next 8 bits are the intensity value.
// The final 8 bits are a number to index which light we're commanding.
typedef struct {
  byte red: COLOR_BIT_DEPTH;
  byte start: START_SEQ_BIT_DEPTH;
  byte blue: COLOR_BIT_DEPTH;
  byte green: COLOR_BIT_DEPTH;
  byte intensity: INTENSITY_BIT_DEPTH;
  byte index: LIGHT_INDEX_BIT_DEPTH;
} light_command;

// This union allows easy conversion between serial buffer and command types.
typedef union {
  serial_buffer buffer;
  light_command command;
} serial_converter;

void setup()
{
  Serial.begin(115200);
  protocol_init();
  delay(100);
  protocol_broadcast(0, 0, 0, 0);

  // Initialize controlbox digital input
  pinMode(modeSwitch, INPUT);
  Serial.println("ready");
}

void execute_command(light_command command) {
  protocol_set_led_state_by_id(
    command.index,
    command.red,
    command.green,
    command.blue,
    command.intensity
  );
}

void serialEvent() {
  serial_converter cmd_buffer;
  if(Serial.available() >= SERIAL_COMMAND_LENGTH)
    Serial.readBytes(cmd_buffer.buffer.raw, SERIAL_COMMAND_LENGTH);
  execute_command(cmd_buffer.command);
}

void loop() {
}
