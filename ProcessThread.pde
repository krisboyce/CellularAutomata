

long generation = 0;
class Rules{
  boolean[] suff;
  boolean[] birth;
  Rules(){
    birth = new boolean[]{false, false, false, true, false, false, false, false, false};
    suff = new boolean[]{false, false, true, true, false, false, false, false, false};
  }
  
}
Rules rules = new Rules();
public class ProcessThread extends Thread {
  long delay = 0;
  boolean running = true;
  HashMap<Long, boolean[][]> steps = new HashMap<Long, boolean[][]>();
  boolean reverse = false;

  
  
  public void start() {
    
    steps.put(generation, grid);
    super.start();
  }

  public synchronized void step() {
    boolean[][] gridBuffer = new boolean[gridDensity][gridDensity];
    try {
      steps.put(generation, grid);
      for (int x = 0; x<gridDensity; x++) {
        for (int y = 0; y<gridDensity; y++) {
          int neighbors = 0;
          for (int i = -1; i<2; i++) {
            for (int j = -1; j<2; j++) {
              if (i == 0 && j == 0) {
                continue;
              }
              int nX = 0; 
              int nY = 0;
              if (loop) {
                nX = i+x < 0 ? gridDensity-1 : i+x > gridDensity-1 ? 0 : i+x;
                nY = j+y < 0 ? gridDensity-1 : j+y > gridDensity-1 ? 0 : j+y;
              } else {
                nX = i+x;
                nY = j+y;
              }
              if (nX < 0 || nX > gridDensity-1) {
                continue;
              }
              if (nY < 0 || nY > gridDensity-1) {
                continue;
              }
              if (grid[nX][nY]) {
                neighbors++;
              }
            }
          }
          if (!rules.suff[neighbors]) {
            gridBuffer[x][y] = false;
          } else if (rules.birth[neighbors]) {
            gridBuffer[x][y] = true;
          } else {
            gridBuffer[x][y] = grid[x][y];
          }
        }
      }
      grid = gridBuffer;
      if (steps.size() > 600) {
        steps.remove(generation-600);
      }
      generation++;

      if (ui != null) {
        if (ui.getController("steps") != null) {
          ui.getController("steps").setStringValue("Generation: " + generation);
        }
      }
      steps.put(generation, grid);
      if (recording && frameNum != 0) {
        frameNum++;

        FileThread frame = new FileThread(folderPath, steps.get(generation), "Frame"+frameNum+".png");
        frame.start();
        try{
          frame.join();
        }catch(Exception e){
          
        }
      } else {
        frameNum = 0;
      }
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  public void stepBack() {
    Long minEntry = null;

    for (Long entry : steps.keySet()) {
      if (minEntry == null || entry < minEntry) {
        minEntry = entry;
      }
    }
    
    if (generation > minEntry) {
      if (steps.get(generation) != null) {
        grid = steps.get(generation-1);
      }
      generation -= 1;
      ui.getController("steps").setStringValue("Generation: " + generation);
      if (recording && frameNum > 0) {
        frameNum++;
        FileThread frame = new FileThread(folderPath, steps.get(generation), "Frame"+frameNum+".png");
        frame.start();
        try{
          frame.join();
        }catch(Exception e){
          
        }
      } else {
        frameNum = 0;
      }
    }
  }

  public long getMinStep() {
    Long minEntry = null;

    for (Long entry : steps.keySet()) {
      if (minEntry == null || entry < minEntry) {
        minEntry = entry;
      }
    }
    if (minEntry != null) {
      return minEntry+1;
    } else {
      return 0;
    }
  }

  public long getMaxStep() {
    Long maxEntry = null;

    for (Long entry : steps.keySet()) {
      if (maxEntry == null || entry > maxEntry) {
        maxEntry = entry;
      }
    }

    if (maxEntry != null) {
      return maxEntry+1;
    } else {
      return 0;
    }
  }

  public void stepToFrame(long i) {

    if (i > getMinStep() && i < getMaxStep()) {
      if (steps.get(i) != null) {
        grid = steps.get(i);
      }
      generation = i;
      ui.getController("steps").setStringValue("Generation: " + generation);
    }
  }

  public void run() {

    while (running) {


      try
      {
        ProcessThread.sleep(delay);
      }
      catch(Exception e)
      {
      }
      
      if(!reverse){
        step();
      }else{
        if(generation > 0){
          stepBack(); 
        }
      }
    }
    super.run();
  }
}
