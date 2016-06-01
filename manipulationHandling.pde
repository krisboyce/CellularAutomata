boolean placePattern = false;
float scaleFactor = 0.5;

int viewHeight;
int viewWidth;
int centerY;
int centerX;

int panToX;
int panToY;
int panFromX;
int panFromY;

void pan() {
  if (mouseButton == LEFT) {
    
    xOffset += (float)(mouseX - pmouseX)*scale;
    yOffset += (float)(mouseY - pmouseY)*scale;
    limitOffset();
  }
}

void limitOffset(){
  
  if(xOffset > 0){
      xOffset = 0;
  }
  if(yOffset > 0){
    yOffset = 0;
  }
  
  
  if(xOffset < (-gridWidth * (scale*scale)) + (gridWidth)){
    xOffset = (-gridWidth * (scale*scale)) + (gridWidth);
  }
  if(yOffset < (-gridHeight * (scale*scale)) + (gridHeight)){
    yOffset = (-gridHeight * (scale*scale)) + (gridHeight);
  }
}

void zoom(MouseEvent e) {
  try{
  boolean in = e.getCount() < 0;
  Point2D mouse = new Point2D.Float(mouseX, mouseY);
  Point2D p = new Point2D.Float(); Point2D p2 = new Point2D.Float();
  AffineTransform tx = new AffineTransform();
  tx.translate(xOffset, yOffset);
  tx.scale(scale, scale);
  
  tx.inverseTransform(mouse, p);
  if (in) {
    if (scale < gridDensity/8) {
      scale += scaleFactor;
    } else {
      scale = gridDensity/8;
    }
  } else if (!in) {
    if (scale > 1) {
      scale -= scaleFactor;
      
    } else {
      scale = 1;
    }
  }
  scale = float(nf(scale, 4, 4));
  tx.setToScale(scale, scale);
  tx.inverseTransform(mouse, p2);
  xOffset = scale*(xOffset-mouseX);
  yOffset = scale*(yOffset-mouseY);
  }catch(Exception ex){
    
  }
  limitOffset();
}

void placePattern() {
}

void placeCells() {
  if(mouseX > gridWidth){
    return;
  }
  Point2D mouse = new Point2D.Float(mouseX, mouseY);
  AffineTransform transform = new AffineTransform();
  transform.translate(xOffset, yOffset);
  transform.scale(scale, scale);
  try{
  transform = transform.createInverse();
  }catch(Exception e){
    return;
  }
  transform.transform(mouse, mouse);
  double tileSize = (gridWidth*scale/gridDensity);
  int mX = (int)(Math.round((mouse.getX()/tileSize-0.5))*tileSize/tileSize);
  int mY = (int)(Math.round((mouse.getY()/tileSize-0.5))*tileSize/tileSize);
  if (mX >= 0 && mY >= 0) {
    if (mX < grid.length && mY < grid[0].length) {
      grid[mX][mY] = mouseButton == LEFT ? maxState : (byte)0;
      process.steps.put(generation, grid);
      if (frameNum > 0 && recording) {
        frameNum++;
        FileThread frame = new FileThread(folderPath, process.steps.get(generation), "Frame"+frameNum+".png");
        frame.start();
      }
    }
  }
}

void placeEditorCell(){
  if(mouseX > gridWidth/2-((gridHeight/3)) &&  mouseX < (gridWidth/2-((gridHeight/3))+((gridHeight/3))*2)-3){
    
    if(mouseY > 0 && mouseY < ((gridHeight/3))*2){
      int mX = (mouseX-(gridHeight/6)) / (((gridHeight/3)*2)/editor.grid.length);
      int mY = mouseY / (((gridHeight/3)*2)/editor.grid.length);
      editor.grid[mX][mY] = mouseButton == LEFT;
    }
    
  }
  
  
}