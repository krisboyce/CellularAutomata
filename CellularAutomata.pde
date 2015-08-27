import org.apache.commons.io.*;
import org.apache.commons.io.comparator.*;
import org.apache.commons.io.filefilter.*;
import org.apache.commons.io.input.*;
import org.apache.commons.io.monitor.*;
import org.apache.commons.io.output.*;

import controlP5.*;
import javax.swing.*;
import javax.swing.SwingUtilities;
import javax.swing.filechooser.*;
import javax.swing.filechooser.FileFilter.*;
import java.util.*;
import java.util.Collections.*;



void setup() {
  size(1024, 768);
  pixelDensity(displayDensity());
  init = new InitThread();
  init.start();
  background(0);
  textSize(25);
  text("Conway's Game of Life", width/2, height/2);
  try {
    init.join();
  }
  catch(Exception e) {
  }
  finally {
    renderer = new RenderThread(gridDensity <= 128 ? gridDensity*16 : gridDensity * 4, gridDensity <= 128 ? gridDensity*16 : gridDensity * 4);
    renderer.start();
  }
}
void draw() {
  background(0);

  if (!patternEditing) {  
    if (mousePressed) {
      if (keyPressed) {
        if (mouseButton == LEFT) {
        }
      } else {
        placeCells();
      }
    }

    if (keyPressed) {
      if (key == 'h') {
        scale = 1;
        xOffset = 0;
        yOffset = 0;
      }
      if (keyCode == UP) {
        yOffset += 2*scale;
      }
      if (keyCode == DOWN) {
        yOffset -= 2*scale;
      }
      if (keyCode == LEFT) {
        xOffset -= 2*scale;
      }
      if (keyCode == RIGHT) {
        xOffset += 2*scale;
      }
      if (key == 'r') {
        ui.getController("reseed").update();
      }
    }
    if(scale < 1){
      scale = 1;
    }
    if(scale > gridDensity/16){
      scale = gridDensity/16;
    }
    
    pushMatrix();
    
    translate(xOffset, yOffset);
      
    scale(scale);
    image(renderer.view, 0, 0, gridWidth, gridHeight);
    popMatrix();
    fill(0);
    rect(gridWidth, 0, width, height);
    fill(255, 128);
    text("x"+(scale), 5, 20);
  } else {
    fill(24);
    rect(0, 0, gridWidth, gridHeight);
    image(editor.view, gridWidth/2-((gridHeight/3)), 0, (gridHeight/3)*2, (gridHeight/3)*2);
    if(mousePressed){
      placeEditorCell();
    }
  }
}

void mouseDragged() {
  if(keyPressed && keyCode == CONTROL){
    pan();
  }
}

void dispose() {
  saveCurrentGol();
  configs.getJSONObject("settings").setFloat("Zoom", scale);
  configs.getJSONObject("settings").setFloat("offsetX", xOffset);
  configs.getJSONObject("settings").setFloat("offsetY", yOffset);
  saveConfig(configs);
  process.running = false;
  try {
    process.join();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  finally {
    println("Closing Sketch");
  }
}

void mouseWheel(MouseEvent e) {
  float val = e.getCount();
  if (val < 0) {
    zoom(true);
  } else {
    zoom(false);
  }
}