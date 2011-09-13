// GE Christmas light control for Arduino  
 // Ported by Scott Harris <scottrharris@gmail.com>  
 // scottrharris.blogspot.com  
   
   
 // Based on this code:  
   
 /*!     Christmas Light Control  
 **     By Robert Quattlebaum <darco@deepdarc.com>  
 **     Released November 27th, 2010  
 **  
 **     For more information,  
 **     see <http://www.deepdarc.com/2010/11/27/hacking-christmas-lights/>.
 **  
 **     Originally intended for the ATTiny13, but should  
 **     be easily portable to other microcontrollers.  
 */  
   
 #define xmas_color_t uint16_t // typedefs can cause trouble in the Arduino environment  
   
 // Eliminate the .h file  
   
 #define XMAS_LIGHT_COUNT          (36) //I only have a 36 light strand. Should be 50 or 36  
 #define XMAS_CHANNEL_MAX          (0xF)  
 #define XMAS_DEFAULT_INTENSITY     (0xCC)  
 #define XMAS_HUE_MAX               ((XMAS_CHANNEL_MAX+1)*6-1)  
 #define XMAS_COLOR(r,g,b)     ((r)+((g)<<4)+((b)<<8))  
 #define XMAS_COLOR_WHITE     XMAS_COLOR(XMAS_CHANNEL_MAX,XMAS_CHANNEL_MAX,XMAS_CHANNEL_MAX)  
 #define XMAS_COLOR_BLACK     XMAS_COLOR(0,0,0)  
 #define XMAS_COLOR_RED          XMAS_COLOR(XMAS_CHANNEL_MAX,0,0)  
 #define XMAS_COLOR_GREEN     XMAS_COLOR(0,XMAS_CHANNEL_MAX,0)  
 #define XMAS_COLOR_BLUE          XMAS_COLOR(0,0,XMAS_CHANNEL_MAX)  
 #define XMAS_COLOR_CYAN          XMAS_COLOR(0,XMAS_CHANNEL_MAX,XMAS_CHANNEL_MAX)  
 #define XMAS_COLOR_MAGENTA     XMAS_COLOR(XMAS_CHANNEL_MAX,0,XMAS_CHANNEL_MAX)  
 #define XMAS_COLOR_YELLOW     XMAS_COLOR(XMAS_CHANNEL_MAX,XMAS_CHANNEL_MAX,0)  
   
 // Pin setup  
 #define XMASPIN 4 // I drive the LED strand from pin #4  
 #define STATUSPIN 13 // The LED  
   
 // The delays in the begin, one, and zero functions look funny, but they give the correct  
 // pulse durations when checked with a logic analyzer. Tested on an Arduino Uno.  
   
 void xmas_begin()  
 {  
  digitalWrite(XMASPIN,1);  
  delayMicroseconds(7); //The pulse should be 10 uS long, but I had to hand tune the delays. They work for me  
  digitalWrite(XMASPIN,0);   
 }  
   
 void xmas_one()  
 {  
  digitalWrite(XMASPIN,0);  
  delayMicroseconds(11); //This results in a 20 uS long low  
  digitalWrite(XMASPIN,1);  
  delayMicroseconds(7);   
  digitalWrite(XMASPIN,0);  
 }  
   
 void xmas_zero()  
 {  
  digitalWrite(XMASPIN,0);  
  delayMicroseconds(2);   
  digitalWrite(XMASPIN,1);  
  delayMicroseconds(20-3);   
  digitalWrite(XMASPIN,0);  
 }  
   
 void xmas_end()  
 {  
  digitalWrite(XMASPIN,0);  
  delayMicroseconds(40); // Can be made shorter  
 }  
   
   
 // The rest of Robert's code is basically unchanged  
   
 void xmas_fill_color(uint8_t begin,uint8_t count,uint8_t intensity,xmas_color_t color)  
 {  
      while(count--)  
      {  
           xmas_set_color(begin++,intensity,color);  
      }  
 }  
   
 void xmas_fill_color_same(uint8_t begin,uint8_t count,uint8_t intensity,xmas_color_t color)  
 {  
      while(count--)  
      {  
           xmas_set_color(0,intensity,color);  
      }  
 }  
   
   
 void xmas_set_color(uint8_t led,uint8_t intensity,xmas_color_t color) {  
      uint8_t i;  
      xmas_begin();  
      for(i=6;i;i--,(led<<=1))  
           if(led&(1<<5))  
                xmas_one();  
           else  
                xmas_zero();  
      for(i=8;i;i--,(intensity<<=1))  
           if(intensity&(1<<7))  
                xmas_one();  
           else  
                xmas_zero();  
      for(i=12;i;i--,(color<<=1))  
           if(color&(1<<11))  
                xmas_one();  
           else  
                xmas_zero();  
      xmas_end();  
 }  
   
   
 xmas_color_t  
 xmas_color(uint8_t r,uint8_t g,uint8_t b) {  
      return XMAS_COLOR(r,g,b);  
 }  
   
 xmas_color_t  
 xmas_color_hue(uint8_t h) {  
      switch(h>>4) {  
           case 0:     h-=0; return xmas_color(h,XMAS_CHANNEL_MAX,0);  
           case 1:     h-=16; return xmas_color(XMAS_CHANNEL_MAX,(XMAS_CHANNEL_MAX-h),0);  
           case 2:     h-=32; return xmas_color(XMAS_CHANNEL_MAX,0,h);  
           case 3:     h-=48; return xmas_color((XMAS_CHANNEL_MAX-h),0,XMAS_CHANNEL_MAX);  
           case 4:     h-=64; return xmas_color(0,h,XMAS_CHANNEL_MAX);  
           case 5:     h-=80; return xmas_color(0,XMAS_CHANNEL_MAX,(XMAS_CHANNEL_MAX-h));  
      }  
 }  
   
   
   
 void setup()  
 {
  Serial.begin(115200);
  pinMode(XMASPIN, OUTPUT);  
  pinMode(STATUSPIN, OUTPUT);  
  digitalWrite(XMASPIN, LOW);
  
  Serial.println("Ready to initialize. Send '%' to begin."); 
  
  while(true){
  while(!Serial.available());
  if(Serial.read() == byte('%'))
    break;
  }
  Serial.flush();
  Serial.println("Initializing...");
  
  xmas_fill_color(0,XMAS_LIGHT_COUNT,XMAS_DEFAULT_INTENSITY,XMAS_COLOR_BLACK); //Enumerate all the lights  
  xmas_fill_color(0,XMAS_LIGHT_COUNT,XMAS_DEFAULT_INTENSITY,XMAS_COLOR_WHITE); //Make them all blue  
  delay(100);
  Serial.println("Complete!");
  Serial.println();
 }  
  
int light_position_map[10][10] = { // [x][y]
  { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
  {10,11,12,13,14,15,16,17,18,19},
  {20,21,22,23,24,25,26,27,28,29},
  {30,31,32,33,34,35,36,37,38,39},
  {40,41,42,43,44,45,46,47,48,49},
  {50,51,52,53,54,55,56,57,58,59},
  {60,61,62,63,64,65,66,67,68,69},
  {70,71,72,73,74,75,76,77,78,79},
  {80,81,82,83,84,85,86,87,88,89},
  {90,91,92,93,94,95,96,97,98,99}};
 
int light_buffer[10][10][4];
int command_buffer[4];
int inByte;
  
int intensity;
int red;
int green;
int blue;
  
int grid_x_max = 10;
int grid_y_max = 10;
  
/* PLEASE NOTE: The default serial buffer size has been increased from 128 bytes to 512 bytes.
This setting is on line 43 of the following file:
/Applications/Arduino.app/Contents/Resources/Java/hardware/arduino/cores/arduino/HardwareSerial.cpp

If things don't seem to be working correctly, check this to ensure the configuration is correct.
*/
  
void loop(){  
  Serial.flush();
  while(!Serial.available()){
    digitalWrite(STATUSPIN, 0);
    delay(100);
    digitalWrite(STATUSPIN, 1);  
    delay(100);
  }
  
  // start timer to keep track of timeout
  int start = millis();
  boolean timeout = false;
  
  inByte = Serial.read();

  // ensure we are looking at a the beginning of a new frame.  
  if (inByte == byte('.')){
    
    for(int x=0; x<grid_x_max; x++){
      for(int y=0; y<grid_y_max; y++){
        for(int cmd=0; cmd<4; cmd++){
          while(Serial.peek() == -1 && !timeout){
//            if(millis() - start > 1000){
//              Serial.print("elapsed time: ");
//              Serial.println(millis() - start);
//              //timeout = true; // timeout after 1000ms.
//            }
          }
          if(timeout)
            break;
          light_buffer[x][y][cmd] = Serial.read();  // intensity value
        }
        if(timeout)
          break;
      }
      if(timeout){
        Serial.println("timeout");
        break;
      }
    }
    // serial success test code.
/*  if(!timeout){
      int elapsed = millis() - start;
      Serial.print("success! Elapsed time: ");
      Serial.println(elapsed);
      
      for(int x=0; x<grid_x_max; x++){
        for(int y=0; y<grid_y_max; y++){
          for(int cmd=0; cmd<4; cmd++){
            Serial.print("[");
            Serial.print((x));
            Serial.print("][");
            Serial.print((y));
            Serial.print("][");
            Serial.print(cmd);
            Serial.print("]: ");
            Serial.println(char(light_buffer[x][y][cmd]));
          }
        }
      }
    }*/
    if(!timeout){
      // write buffer to leds
      for(int x=0; x<grid_x_max; x++){
        for(int y=0; y<grid_y_max; y++){
          int bulb_position = light_position_map[x][y];
          int intensity = light_buffer[x][y][0];
          int red = light_buffer[x][y][1];
          int green = light_buffer[x][y][2];
          int blue = light_buffer[x][y][3];
          
          xmas_set_color(bulb_position, intensity, XMAS_COLOR(red, green, blue));
        }
      }
      Serial.println("byte array set!");
    }
  }
}
