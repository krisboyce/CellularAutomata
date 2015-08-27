
boolean animLoop = true;
boolean recording;
long frameNum = 0;
File folderPath;
float scale = 1.0;
float xOffset = 0;
float yOffset = 0;

RenderThread renderer;

public class RenderThread extends Thread {
  PGraphics view;
  boolean rendering = true;

  RenderThread(int w, int h) {
    view = createGraphics(w, h);
  }

  void start() {

    super.start();
  }

  void run() {
    while (rendering) {
      draw();
    }
    super.run();
  }

  void draw() {
    drawGrid();
    if(patternEditing){
      drawEditorGrid();
      
    }
  }

  void drawEditorGrid() {
    editor.view.beginDraw();
    editor.view.background(0);
    editor.view.stroke(0);
    for (int i = 0; i<editor.grid.length; i++) {
      for (int j = 0; j<editor.grid.length; j++) {
         if(editor.grid[i][j]){
           editor.view.fill(0, 255, 0);
           editor.view.rect(i*(editor.view.width/editor.grid.length), j*(editor.view.width/editor.grid.length), (editor.view.width/editor.grid.length), (editor.view.width/editor.grid.length));
         }
      }
    }
    editor.view.endDraw();
  }

  void drawGrid() {
    this.view.beginDraw();
    this.view.background(0);
    

    
    
    if(gridDensity <= 256){
      this.view.stroke(0);
    }else{
      this.view.noStroke();
    }
    this.view.fill(0, 255, 0);
    for (int i = 0; i<gridDensity; i++) {
      for (int j = 0; j<gridDensity; j++) {
        if (grid[i][j]) {
          this.view.rect((i)*(view.width/gridDensity), j*(view.height/gridDensity), (view.width/(gridDensity)), (view.height/(gridDensity)));
        }
      }
    }

    this.view.endDraw();
    
  }
}

PGraphics takeFrame(boolean[][] grid) {
  PGraphics screen = createGraphics(gridDensity*4, gridDensity*4);
  screen.beginDraw();
  background(0, 0);
  screen.scale(scale);
  screen.translate(xOffset, yOffset);
  for (int i = 0; i<gridDensity; i++) {
    for (int j = 0; j<gridDensity; j++) {

      if (grid[i][j]) {
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