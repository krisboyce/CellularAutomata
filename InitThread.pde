InitThread init;
class InitThread extends Thread {

  public void run() {
    try{
      InitThread.sleep(800);
    }catch(Exception e){
      
    }
    gridWidth = round(width)-250;
    gridHeight = height;
    initConfig();
    initBoard();
    gui();
    editor = new PatternEditor();
    pause.setValue(paused);
    speed.setValue(timeScale);
    
    super.run();
  }
}