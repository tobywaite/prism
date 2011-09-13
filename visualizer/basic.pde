interface Visualizer {
  void transform(color[][] previous, color[][] next);
}

class BasicVisualizer implements Visualizer {
  int numDots = 15;
  float cutoff;
  float[] averages;
  float[] tmpSort;
  int thisIndex = 0;
  int maxIndex = 0;
  float lastAverage;
  
  public BasicVisualizer() {
    thisIndex = 0;
    averages = new float[300];
    tmpSort = new float[1];
  }
  
  void transform(color[][] previous, color[][] next) {
    updateMath();
    
    colorMode(HSB, 100);
    
    if (lastAverage > cutoff) {
      for (int i=0; i<numDots; i++) {
        color randomColor = color(random(100), random(100), 100);
        previous[int(random(lightRows))][int(random(lightCols))] = randomColor;
      }
    }
  
    for (int r=0; r<lightRows; r++) {
      for (int c=0; c<lightCols; c++) {
        color pc = previous[r][c];
        color nc = color(hue(pc), saturation(pc), brightness(pc)*0.95);
        next[r][c] = nc;
      }
    }
  }
  
  void updateMath() {
    for(int i = 0; i < input.bufferSize(); i++)
    {
      averages[thisIndex] += input.left.get(i) + input.right.get(i);
    }
    averages[thisIndex] /= input.bufferSize();
    lastAverage = averages[thisIndex];
    maxIndex = max(thisIndex, maxIndex);
    thisIndex = (thisIndex + 1) % averages.length;
    
    if (tmpSort.length <= maxIndex) {
      tmpSort = new float[maxIndex+1];
    }
    for(int i = 0; i < tmpSort.length; i++) {
      tmpSort[i] = averages[i];
    }
    Arrays.sort(tmpSort);
    cutoff = tmpSort[int(tmpSort.length*0.9)];
  }
}
