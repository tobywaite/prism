void render(color[][] colors) {
  ellipseMode(CENTER);
  background(0);
  stroke(0, 0);
  for (int r=0; r<colors.length; r++) {
    for (int c=0; c<colors[r].length; c++) {
      fill(colors[r][c]);
      ellipse(lightSize/2+c*lightSize,
              lightSize/2+r*lightSize,
              lightSize/2,
              lightSize/2);
    }
  }
}
