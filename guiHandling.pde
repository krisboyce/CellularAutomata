ControlP5 ui;
Slider speed;
Toggle pause;
Accordion menu;
Range neighbors;
Slider frames;
Slider birthMin;
Toggle toggleLoop, reverse, record;
Group patternEditor;
CheckBox suffRules, birthRules;
boolean guiInit = false;

void gui() {
  int guiWidth = width-gridWidth;
  float tempTimeScale = timeScale;
  float tempSeedProb = seedProb;

  ui = new ControlP5(this);
  
  
  Group board = ui.addGroup("board").setSize(guiWidth, 75).setPosition(gridWidth, 10)
    .setBackgroundColor(color(255, 128, 0, 10));
  ui.addBang("reseed").setPosition(10, 30).setSize(40, 40).setGroup(board);
  
  ui.addSlider("seedProb").setPosition(10, 120).setSize(guiWidth-100, 40).setRange(0, 100).setLabel("Seed Amount").setGroup(board);
  toggleLoop = ui.addToggle("loop").setPosition(60, 30).setSize(40, 40).setValue(loop).setGroup(board);
  ui.addLabel("resize").setPosition(155, 15).setText("GRID SCALE").setGroup(board);
  ui.addButton("increase").setPosition(190, 30).setSize(40, 40).setLabel("Increase").setGroup(board);
  ui.addButton("decrease").setPosition(140, 30).setSize(40, 40).setLabel("Decrease").setGroup(board);
  
  
  Group time = ui.addGroup("time").setBackgroundColor(color(255, 128, 0, 10));
  pause = ui.addToggle("Pause").setPosition(10, 30).setSize(40, 40).setGroup(time);
  reverse = ui.addToggle("reverse").setPosition(70, 30).setSize(40, 40).setGroup(time);
  speed = ui.addSlider("timeScale").setPosition(10, 120).setSize(guiWidth-100, 40).setRange(1, 100).setGroup(time);
  ui.addLabel("steps").setPosition(145, 15).setText("Generations: " + generation).setGroup(time);
  ui.addButton("Step").setLabel(">").setPosition(190, 30).setSize(25, 40).setGroup(time).setVisible(true);
  ui.addButton("StepBack").setLabel("<").setPosition(140, 30).setSize(25, 40).setGroup(time).setVisible(true);
  Group ruleSettings = ui.addGroup("rules").setBackgroundColor(color(255, 128, 0, 10));
  ui.addLabel("Suffocation Rules (0...8 neighbors)").setPosition(10, 25).setGroup(ruleSettings);

  suffRules = ui.addCheckBox("suffRules").setPosition(10, 40).setItemsPerRow(9).setSize(45, 25).setSpacingColumn(30)
    .addItem("s0", 0)
    .addItem("s1", 1)
    .addItem("s2", 2)
    .addItem("s3", 3)
    .addItem("s4", 4)
    .addItem("s5", 5)
    .addItem("s6", 6)
    .addItem("s7", 7)
    .addItem("s8", 8)
    .hideLabels()
    .setGroup(ruleSettings);
  
  for(int i = 0; i<rules.suff.length; i++){
    if(rules.suff[i]){
      suffRules.activate(i);
    }
  }
  
  ui.addLabel("Birth Rules (0...8 neighbors)").setPosition(10, 75).setGroup(ruleSettings);
  birthRules = ui.addCheckBox("birthRules").setPosition(10, 90).setItemsPerRow(9).setSize(45, 25).setSpacingColumn(30)
    .addItem("b0", 0)
    .addItem("b1", 1)
    .addItem("b2", 2)
    .addItem("b3", 3)
    .addItem("b4", 4)
    .addItem("b5", 5)
    .addItem("b6", 6)
    .addItem("b7", 7)
    .addItem("b8", 8)
    .hideLabels()
    .setGroup(ruleSettings);
  
  for(int i = 0; i<rules.birth.length; i++){
    if(rules.birth[i]){
      birthRules.activate(i);
    }
  }
  
  Group options = ui.addGroup("options").setBackgroundColor(color(255, 128, 0, 10));
  ui.addButton("save")
    .setPosition(40, 25)
    .setSize(50, 50)
    .setLabel("Save Game")
    .setGroup(options);
    
  ui.addButton("load")
    .setPosition(100, 25)
    .setSize(50, 50)
    .setLabel("Load Game")
    .setGroup(options);
    
  ui.addButton("screenCapture")
    .setPosition(40, 90)
    .setSize(50, 50)
    .setLabel("Screenshot")
    .setGroup(options);
    
  record = ui.addToggle("record")
    .setPosition(100, 90)
    .setSize(50, 50)
    .setLabelVisible(false)
    .setGroup(options);
    
  ui.addLabel("recordLabel").setPosition(100, 110).setText("RECORD").setId(6).setGroup(options);
  
    ui.addToggle("editMode").setPosition(160, 25).setSize(40, 40).setLabel("Editor").setGroup(options);
  
  menu = ui.addAccordion("menu")
    .setPosition(gridWidth, 0).setWidth(width-gridWidth)
    .setMinItemHeight((height-40)/4).addItem(board)
    .addItem(time).addItem(ruleSettings).addItem(options)
    .setCollapseMode(Accordion.MULTI);
    
  menu.open(0, 1, 2);
  speed.setValue(tempTimeScale);
  ui.getController("seedProb").setValue(tempSeedProb);
  
  patternEditor = ui.addGroup("patternEditor").setPosition(0, gridHeight-gridHeight/3).setSize(gridWidth, gridHeight/3).disableCollapse().setBackgroundColor(color(8)).setVisible(false);
  guiInit = true;
}

void controlEvent(ControlEvent e){
  if(e.isFrom(suffRules) && guiInit){
    for(int i = 0; i<9; i++){
      rules.suff[i] = suffRules.getArrayValue()[i] > 0;
      configs.getJSONObject("rules").getJSONArray("suffocate").setInt(i, (int)suffRules.getArrayValue()[i]);
    }
  }
  if(e.isFrom(birthRules) && guiInit){
    for(int i = 0; i<9; i++){
      rules.birth[i] = birthRules.getArrayValue()[i] > 0;
      configs.getJSONObject("rules").getJSONArray("birth").setInt(i, (int)birthRules.getArrayValue()[i]);
    }
  }
  
}

void increase() {
  resize(true);
}

void decrease() {
  resize(false);
}

void reseed() {
  generation = 0;
  ui.getController("steps").setStringValue("Generation: " + generation);
  process.steps = new HashMap<Long, byte[][]>();
  seedBoard();
  pause.update();
  speed.update();
}

void loop(boolean value) {
  loop = value;
  configs.getJSONObject("settings").setBoolean("loop", value);
}

void seedProb(float value) {
  seedProb = value;
  configs.getJSONObject("settings").setFloat("seedProb", value);
}

void timeScale(float value) {
  timeScale = value;
  configs.getJSONObject("settings").setFloat("timeScale", value);
  if (value > 0) {
    process.delay = round(1000-((value*10)));
  }
}

void reverse(boolean value){
  process.reverse = value;
}

void Pause(boolean value) {
  paused = value;
  configs.getJSONObject("settings").setBoolean("paused", value);
  if (value) {
    pause.setLabel("Resume");
    process.running = false;
  } else {
    pause.setLabel("Pause");
    HashMap<Long, byte[][]> steps = process.steps;
    try {
      process.running = false;
      process.join();
    }
    catch(Exception e) {
    }
    process = new ProcessThread();
    process.steps = steps;
    speed.update();
    reverse.update();
    process.start();
  }
}

void screenCapture(){
  saveImage();
}

void record(boolean value){
  recording = value;
  
  if(recording){
      JFileChooser fc = new JFileChooser();
      fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
      int returnVal = fc.showSaveDialog(null);
      if (returnVal == JFileChooser.APPROVE_OPTION) {
        File file = fc.getSelectedFile();
        if(file.isDirectory()){
          folderPath = file;
          frameNum++;
          FileThread frame = new FileThread(folderPath, process.steps.get(generation), "Frame"+frameNum+".png");
          frame.start();
        }
        ui.get(Toggle.class, "recordLabel").setLabel("STOP");
      }else{
        recording = false;
        record.setValue(false);
        frameNum = 0;
      }
    }else{
    frameNum = 0;
    ui.getController("recordLabel").setLabel("record");
  }
}

void Step() {
  process.step();
}

void StepBack() {
  process.stepBack();
}

void save() {
  saveGol();
}

void load() {
  loadGol();
}