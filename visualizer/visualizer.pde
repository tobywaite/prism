import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

Minim minim;
AudioInput input;

int lightRows = 10;
int lightCols = 10;
color[][] backBuffer = new color[lightRows][lightCols];
color[][] frontBuffer = new color[lightRows][lightCols];

float lightSize = 80;

Visualizer v1 = null;

void setup() {
  initSerial();
  size(int(lightCols*lightSize), int(lightRows*lightSize));
  smooth();
  frameRate(60);
  
  for (int r=0; r<lightRows; r++) {
    for (int c=0; c<lightCols; c++) {
      backBuffer[r][c] = color(0, 0, 0);
      frontBuffer[r][c] = color(0, 0, 0);
    }
  }
  
  minim = new Minim(this);
  input = minim.getLineIn();
  
  v1 = new BasicVisualizer();
}

void draw() {
  v1.transform(backBuffer, frontBuffer);
  render(frontBuffer);
  color[][] tmp = backBuffer;
  backBuffer = frontBuffer;
  frontBuffer = tmp;
}

void stop()
{
  input.close();
  minim.stop();
  super.stop();
}
