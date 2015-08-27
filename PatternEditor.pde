boolean patternEditing = false;
PatternEditor editor;

class PatternEditor {
  boolean[][] grid;
  PGraphics view;
  Controller menu;
  
  PatternEditor() {
    this.grid = new boolean[64][64];
    this.view = createGraphics(this.grid.length * 32, this.grid.length * 32);
  }
  
  void setSize(int size) {
    boolean[][] gridBuffer = this.grid;
    grid = new boolean[size][size];

    if (size > gridBuffer.length) {
      for (int i = 0; i<gridBuffer.length; i++) {
        for (int j = 0; j<gridBuffer.length; j++) {
          this.grid[i][j] = gridBuffer[i][j];
        }
      }
    } else {
      for (int i = 0; i<this.grid.length; i++) {
        for (int j = 0; j<this.grid.length; j++) {
          this.grid[i][j] = gridBuffer[i][j];
        }
      }
    }
    this.view = createGraphics(this.grid.length * 32, this.grid.length * 32);
  }

  void loadPattern() {
  }

  void savePattern() {
  }
}