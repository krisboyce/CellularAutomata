InitThread init;
class InitThread extends Thread {

  public void run() {
    try{
      InitThread.sleep(800);
    }catch(Exception e){
      
    }
    gridWidth = width-(width-height);
    gridHeight = height;
    rules = new Rules();
    println(rules);
    initConfig();
    initBoard();
    gui();
    editor = new PatternEditor();
    pause.setValue(paused);
    speed.setValue(timeScale);
    
    super.run();
  }
}
