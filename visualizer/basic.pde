interface Visualizer {
  void transform(color[][] previous, color[][] next);
}

class BasicVisualizer implements Visualizer {
  int numDots = 3;
  void transform(color[][] previous, color[][] next) {
    float maxAmplitude = getMaxAmplitude()*100;
    
    colorMode(HSB, 100);
    
    for (int i=0; i<numDots; i++) {
      color randomColor = color(random(100), random(100), maxAmplitude);
      previous[int(random(lightRows))][int(random(lightCols))] = randomColor;
    }
  
    for (int r=0; r<lightRows; r++) {
      for (int c=0; c<lightCols; c++) {
        color pc = previous[r][c];
        color nc = color(hue(pc), saturation(pc), brightness(pc)*0.95);
        next[r][c] = nc;
      }
    }
  }
  
  float getMaxAmplitude() {
    float maxAmplitude = 0;
    for(int i = 0; i < input.bufferSize(); i++)
    {
      maxAmplitude = max(maxAmplitude, input.left.get(i));
      maxAmplitude = max(maxAmplitude, input.right.get(i));
    }
    return maxAmplitude;
  }
}
