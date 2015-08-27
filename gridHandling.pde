int neighborMax = 3;
int neighborMin = 2;
int neighborBirth = 3;
int gridWidth;
int gridHeight;
float timeScale = 95.0;
boolean paused = false;
boolean loop = false;
float seedProb = 25;
volatile int gridDensity = 64;
volatile boolean[][] grid = new boolean[gridDensity][gridDensity];

void initBoard() {
  File file = new File(dataPath("save.data"));

  if (file.exists()) {
    process = new ProcessThread();
    loadLastGol(file);
    process.running = !paused;
    process.start();
  } else {
    seedBoard();
  }
}

void seedBoard() {
  if (process != null) {
    process.running = false;
    try {
      process.join();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
  process = new ProcessThread();
  for (int i = 0; i<gridDensity; i++) {
    for (int j = 0; j<gridDensity; j++) {
      if (random(100) < seedProb) {
        grid[i][j] = true;
      } else {
        grid[i][j] = false;
      }
    }
  }
  process.start();
}

void resize(boolean increase) {
  if (increase && gridDensity >= 1024) {
    return;
  }else if(!increase && gridDensity <= 16){
    return;
  }
  process.running = false;
  renderer.rendering = false;
  boolean[][] gridBuffer = grid;
  try {
    process.join();
    renderer.join();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  process = new ProcessThread();
  if (increase && gridDensity < 2048) {
    gridDensity *=2;
    grid = new boolean[gridDensity][gridDensity];
    for (int i = 0; i<gridBuffer.length; i++) {
      for (int j = 0; j<gridBuffer[0].length; j++) {
        grid[i][j] = gridBuffer[i][j];
      }
    }
  }
  if (!increase && gridDensity > 16) {
    process = new ProcessThread();
    gridDensity /=2;
    grid = new boolean[gridDensity][gridDensity];
    for (int i = 0; i<gridDensity; i++) {
      for (int j = 0; j<gridDensity; j++) {
        grid[i][j] = gridBuffer[i][j];
      }
    }
  }
  if(scale > 64){
    scale = 64;
  }
  renderer = new RenderThread(gridDensity <= 128 ? gridDensity*16 : gridDensity * 8, gridDensity <= 128 ? gridDensity*16 : gridDensity * 8);
  configs.getJSONObject("settings").setInt("resolution", gridDensity);
  renderer.start();
  process.start();
  pause.update();
  speed.update();
}