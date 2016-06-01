
boolean animLoop = true;
boolean recording;
long frameNum = 0;
File folderPath;
float scale = 1.0;
float xOffset = 0;
float yOffset = 0;
HashMap<Byte, Integer> states;

int[] stateColors = new int[]{
  #000000, #006600, #007700, #008800, #009900, #00aa00, #00bb00, #00cc00, #00dd00, #00ee00, #00ff00
};

void initStates(){
  maxState = (byte)(stateColors.length-1);
  states = new HashMap<Byte, Integer>();
  for(byte i = 0; i<stateColors.length; i++){
    states.put(i, stateColors[i]);
  }
}

void drawGrid(){
  if(states == null){
    initStates();
  }
  AffineTransform transform = new AffineTransform();
  transform.scale(scale, scale);
  pushMatrix();
  translate(xOffset, yOffset);
  scale(scale);
  background(states.get((byte)0));
  Point2D cellSize = new Point2D.Float(gridHeight/gridDensity, gridWidth/gridDensity);
  transform.transform(cellSize, cellSize);
  
  strokeWeight(0.25);
  stroke(0);
  for (int i = 0; i<gridDensity; i++) {
    for (int j = 0; j<gridDensity; j++) {
      try{
      fill(states.get(grid[i][j]));
      }catch(Exception e){
        // //<>//
      }
      if (grid[i][j] > 0) {
        rect((float)(i*cellSize.getX()), (float)(j*cellSize.getY()), (float)(cellSize.getX()), (float)(cellSize.getY()));
      }
    }
  }
  popMatrix();
}

PGraphics takeFrame(byte[][] grid) {
  PGraphics screen = createGraphics(gridDensity*4, gridDensity*4);
  screen.beginDraw();
  background(0, 0);
  screen.scale(scale);
  screen.translate(xOffset, yOffset);
  for (int i = 0; i<gridDensity; i++) {
    for (int j = 0; j<gridDensity; j++) {

      if (grid[i][j] > 0) {
        screen.fill(0, 255, 0);
      } else {
        screen.fill(0);
      }
      screen.rect(i*(screen.width/gridDensity), j*(screen.height/gridDensity), (screen.width/(gridDensity)), (screen.height/(gridDensity)));
    }
  }
  screen.endDraw();
  return screen;
}