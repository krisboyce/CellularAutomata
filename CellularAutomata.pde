import org.apache.commons.io.*;
import org.apache.commons.io.comparator.*;
import org.apache.commons.io.filefilter.*;
import org.apache.commons.io.input.*;
import org.apache.commons.io.monitor.*;
import org.apache.commons.io.output.*;

import controlP5.*;

import java.awt.*;
import java.awt.geom.Point2D;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;

import javax.swing.*;
import javax.swing.SwingUtilities;
import javax.swing.filechooser.*;
import javax.swing.filechooser.FileFilter.*;

import java.util.*;
import java.util.Map.*;
import java.lang.Math.*;

ProcessThread process;
void setup() {
  size(1920, 1024);
  init = new InitThread();
  init.start();
  background(0);
  textSize(25);
  text("Conway's Game of Life", width/2, height/2);
  textSize(16);
  try {
    init.join();
  }
  catch(Exception e) {
  }
  initStates();
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
        limitOffset();
      }
      if (keyCode == DOWN) {
        yOffset -= 2*scale;
        limitOffset();
      }
      if (keyCode == LEFT) {
        xOffset -= 2*scale;
        limitOffset();
      }
      if (keyCode == RIGHT) {
        xOffset += 2*scale;
        limitOffset();
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
    
    drawGrid();
    Point2D mouse = new Point2D.Float(mouseX, mouseY);
    AffineTransform mouseTx = new AffineTransform();
    mouseTx.translate(xOffset, yOffset);
    mouseTx.scale(scale, scale);
    
    
    try{
      mouseTx = mouseTx.createInverse();
    }catch(Exception e){
      e.printStackTrace();
    }
    
    mouseTx.transform(mouse, mouse);
    float tile = (gridWidth/gridDensity)*scale;
    if(round((float)mouseX/tile-0.5)*tile < gridWidth && round((float)mouseY/tile-0.5)*tile < gridHeight){
      fill(255, 255, 255, 128);
      noStroke();
      pushMatrix();
      
      translate(xOffset, yOffset);
      scale(scale);
      
      
      rect(round(((float)mouse.getX())/(tile)-0.5)*(tile), round(((float)mouse.getY())/tile-0.5)*tile, tile, tile);
      popMatrix();
    }
    fill(0);
    rect(gridWidth, 0, width, height);
    fill(64, 64);
    rect(0, 0, gridWidth, 25);
    fill(255);
    text(String.format("X: %.2f - Y: %.2f Scale: x"+(scale), abs(xOffset)/(tile*scale), abs(yOffset)/(tile*scale)), 5, 20);
    text("Grid Size: " + gridDensity, gridWidth-150, 20);
  }
  

  limitOffset();
}

void mouseDragged() {
  if(keyPressed && keyCode == CONTROL){
    pan();
  }
}

void dispose() {
  println("Shutting Down Simulation");
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
  if(mouseX < gridWidth){
    zoom(e);
    limitOffset();
  }
}
