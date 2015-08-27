
JSONObject configs = new JSONObject();
FileFilter filter = new FileNameExtensionFilter("Game of Life save files (*.gol)", "gol", "gameoflife");
FileFilter imageFilter = new FileNameExtensionFilter("Image files", "tif", "jpg", "png", "tga");
FileFilter gifFilter = new FileNameExtensionFilter("Animated Image files (*.gif)", "gif");

void initConfig() {
  File configFile = new File(dataPath("config.json"));
  if (!configFile.exists()) {
    println("Config not found");
    JSONObject settings = new JSONObject();
    JSONObject rules = new JSONObject();

    settings.setInt("resolution", gridDensity);
    settings.setFloat("Zoom", scale);
    settings.setFloat("offsetX", xOffset);
    settings.setFloat("offsetY", yOffset);
    settings.setFloat("seedProb", seedProb);
    settings.setFloat("timeScale", timeScale);
    settings.setBoolean("paused", paused);
    settings.setBoolean("loop", loop);
    rules.setInt("neighborMin", neighborMin);
    rules.setInt("neighborMax", neighborMax);
    rules.setInt("neighborBirth", neighborBirth);
    configs.setJSONObject("settings", settings);
    configs.setJSONObject("rules", rules);
    saveConfig(configs);
  } else {
    loadConfig(configFile);
  }
}

void loadConfig(File file) {
  configs = loadJSONObject(file);
  JSONObject settings = configs.getJSONObject("settings");
  JSONObject rules = configs.getJSONObject("rules");
  gridDensity = settings.getInt("resolution");
  grid = new boolean[gridDensity][gridDensity];
  scale = settings.getInt("Zoom");
  xOffset = settings.getInt("offsetX");
  yOffset = settings.getInt("offsetY");
  seedProb = settings.getFloat("seedProb");
  neighborMin = rules.getInt("neighborMin");
  neighborMax = rules.getInt("neighborMax");
  neighborBirth = rules.getInt("neighborBirth");
  timeScale = settings.getFloat("timeScale");
  paused = settings.getBoolean("paused");
  loop = settings.getBoolean("loop");
  
}

void saveConfig(JSONObject config) {
  saveJSONObject(config, "data/config.json");
}

void saveGol() {
  JFileChooser fc = new JFileChooser();
  fc.setAcceptAllFileFilterUsed(false);
  fc.setFileFilter(filter);
  int returnVal = fc.showSaveDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    File file = fc.getSelectedFile();
    JSONObject save = new JSONObject();
    if (FilenameUtils.getExtension(file.getName()).equalsIgnoreCase("gol")) {
    } else {
      file = new File(file.toString() + ".gol");
    }

    JSONObject settings = new JSONObject();
    settings.setInt("resolution", gridDensity);
    settings.setFloat("Zoom", scale);
    settings.setFloat("offsetX", xOffset);
    settings.setFloat("offsetY", yOffset);
    settings.setInt("neighborMin", neighborMin);
    settings.setInt("neighborMax", neighborMax);
    settings.setInt("neighborBirth", neighborBirth);
    settings.setBoolean("paused", paused);
    settings.setBoolean("loop", loop);
    settings.setFloat("timeScale", timeScale);

    JSONArray data = new JSONArray();

    for (int x = 0; x<gridDensity; x++) {
      JSONArray row = new JSONArray();
      for (int y = 0; y<gridDensity; y++) {
        row.setInt(y, int(grid[x][y]));
      }
      data.setJSONArray(x, row);
    }
    save.setJSONObject("parameters", settings);
    save.setJSONArray("grid", data);
    saveJSONObject(save, file.getAbsolutePath());
  }
}

void loadGol() {
  final JFileChooser fc = new JFileChooser();
  fc.setAcceptAllFileFilterUsed(false);

  fc.setFileFilter(filter);
  int returnVal = fc.showOpenDialog(null);

  if (returnVal == JFileChooser.APPROVE_OPTION) {
    File file = fc.getSelectedFile();  
    JSONObject saveFile = loadJSONObject(file);
    try {
      process.running = false;
      process.join();
    }
    catch(Exception e) {
    }
    process = new ProcessThread();
    JSONArray data = saveFile.getJSONArray("grid");
    JSONObject params = saveFile.getJSONObject("parameters");
    gridDensity = params.getInt("resolution");
    paused = params.getBoolean("paused");
    loop = params.getBoolean("loop");
    neighborMin = params.getInt("neighborMin");
    neighborMax = params.getInt("neighborMax");
    neighborBirth = params.getInt("neighborBirth");
    timeScale = params.getFloat("timeScale");
    scale = params.getFloat("Zoom");
    xOffset = params.getFloat("offsetX");
    yOffset = params.getFloat("offsetY");
    grid = new boolean[gridDensity][gridDensity];

    for (int x = 0; x<gridDensity; x++) {
      JSONArray row = data.getJSONArray(x);
      for (int y = 0; y<gridDensity; y++) {
        grid[x][y] = boolean(row.getInt(y));
      }
    }
    process.start();
    speed.setValue(timeScale);
    pause.setValue(paused);
    neighbors.setBroadcast(false).setLowValue(neighborMin).setBroadcast(true);
    neighbors.setBroadcast(false).setHighValue(neighborMax).setBroadcast(true);
    neighbors.setLowValueLabel(str(neighborMin));
    neighbors.setHighValueLabel(str(neighborMax));
    birthMin.setValue(neighborBirth);
    toggleLoop.setValue(loop);
    generation = 0;
    ui.getController("steps").setStringValue("Generation: " + generation);
    
  } else {
  }
}

void saveCurrentGol() {
  JSONObject saveGame = new JSONObject();
  JSONArray data = new JSONArray();

  for (int x = 0; x<gridDensity; x++) {
    JSONArray row = new JSONArray();
    for (int y = 0; y<gridDensity; y++) {
      row.setInt(y, int(grid[x][y]));
    }
    data.setJSONArray(x, row);
  }
  saveGame.setJSONArray("data", data);
  saveJSONObject(saveGame, "data/save.data");
}

void loadLastGol(File gol) {
  JSONObject saveData = loadJSONObject(gol);
  JSONArray data = saveData.getJSONArray("data");
  for (int x = 0; x<gridDensity; x++) {
    JSONArray row = data.getJSONArray(x);
    for (int y = 0; y<gridDensity; y++) {
      grid[x][y] = boolean(row.getInt(y));
    }
  }
}

void saveImage() {
  pause.setValue(true);
  JFileChooser fc = new JFileChooser();
  fc.setAcceptAllFileFilterUsed(false);
  fc.setFileFilter(imageFilter);
  int returnVal = fc.showSaveDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    File file = fc.getSelectedFile();
    PGraphics g = takeFrame(process.steps.get(generation));
    FileThread frame = new FileThread(file, g, "");
    frame.start();
  }
}

class FileThread extends Thread{
  File file;
  String fileName;
  JSONObject jsonObj;
  PGraphics pg;
  boolean[][] grid;
  
  
  FileThread(File f, PGraphics g, String filename){
    this.file = f;
    this.fileName = filename;
    this.pg = g;
  }
  
  FileThread(FileThread thread){
    this.file = thread.file;
    this.fileName = thread.fileName;
    this.pg = thread.pg;
    this.grid = thread.grid;
    this.jsonObj  = thread.jsonObj;
  }
  
  FileThread(File f, JSONObject j, String filename){
    this.file = f;
    this.fileName = filename;
    this.jsonObj = j;
  }
  
  FileThread(File f, boolean[][] grid, String filename){
    this.file = f;
    this.fileName = filename;
    this.grid = grid;
  }
  
  void setImage(PGraphics g){
    this.pg = g;
  }
  
  void setJson(JSONObject j){
    this.jsonObj  = j;
  }
  
  void run(){
    
    if(jsonObj != null){
      saveJSON();
    }
    
    if(pg != null && grid == null){
      saveImage();
    }else if(grid != null){
      saveScreenShot();
    }
    
    super.run();
  }
  
  void saveScreenShot(){
    pg = takeFrame(grid);
    this.saveImage();
  }
  
  void saveImage(){
    pg.save(file.getAbsolutePath() + (file.isDirectory() ? "\\" : "") + fileName);
  }
  
  void saveJSON(){
    saveJSONObject(jsonObj, file.getAbsolutePath() + (file.isDirectory() ? "/" : "") + fileName);
  }
  
}