boolean placePattern = false;
float scaleFactor = 0.2;

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
    xOffset += (mouseX - pmouseX)*scale;
    yOffset += (mouseY - pmouseY)*scale;
    println(xOffset + ", " + yOffset);
  }
}

void zoom(boolean in) {
  if (in) {
    if (scale < gridDensity/16) {
      scale += 1+scaleFactor;
    } else {
      scale = gridDensity/16;
    }
  } else if (!in) {
    if (scale > 1) {
      scale -= 1+scaleFactor;
    } else {
      scale = 1;
    }
  }
}

void placePattern() {
}

void placeCells() {

  if (mouseX > 0 && mouseY > 0 && mouseX < gridWidth && mouseY < gridHeight) {
    int tileSize = int(gridWidth/gridDensity);
    float scaledOffsetX = xOffset*scale;
    float scaledOffsetY = yOffset*scale;
    int mX = int((mouseX-scaledOffsetX)/scale)/tileSize;
    int mY = int((mouseY-scaledOffsetY)/scale)/tileSize;
    if (mX >= 0 && mY >= 0) {
      if (mX < gridDensity && mY < gridDensity) {
        grid[mX][mY] = mouseButton == LEFT;
        process.steps.put(generation, grid);
        if (frameNum > 0 && recording) {
          frameNum++;
          FileThread frame = new FileThread(folderPath, process.steps.get(generation), "Frame"+frameNum+".png");
          frame.start();
        }
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