










public static class SymmetryTest extends Symmetry {

  public SymmetryTest() {
    super();
  }

  public SymmetryTest(GraphModel model) {
    super(model);
  }


  public void runSymmetryTests() {
    testDataRef();
    testBaseElements();
  }

  public void testDataRef() {

    int[][] REF_xX = new int[][]
      {{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19},
       {1, 2, 3, 4, 0, 6, 7, 8, 9, 5, 11, 12, 13, 14, 10, 16, 17, 18, 19, 15},
       {2, 3, 4, 0, 1, 7, 8, 9, 5, 6, 12, 13, 14, 10, 11, 17, 18, 19, 15, 16},
       {3, 4, 0, 1, 2, 8, 9, 5, 6, 7, 13, 14, 10, 11, 12, 18, 19, 15, 16, 17},
       {4, 0, 1, 2, 3, 9, 5, 6, 7, 8, 14, 10, 11, 12, 13, 19, 15, 16, 17, 18},
       {5, 0, 4, 9, 14, 10, 1, 3, 13, 19, 6, 2, 8, 18, 15, 11, 7, 12, 17, 16},
       {6, 1, 0, 5, 10, 11, 2, 4, 14, 15, 7, 3, 9, 19, 16, 12, 8, 13, 18, 17},
       {7, 2, 1, 6, 11, 12, 3, 0, 10, 16, 8, 4, 5, 15, 17, 13, 9, 14, 19, 18},
       {8, 3, 2, 7, 12, 13, 4, 1, 11, 17, 9, 0, 6, 16, 18, 14, 5, 10, 15, 19},
       {9, 4, 3, 8, 13, 14, 0, 2, 12, 18, 5, 1, 7, 17, 19, 10, 6, 11, 16, 15},
       {10, 6, 1, 0, 5, 15, 11, 2, 4, 14, 16, 7, 3, 9, 19, 17, 12, 8, 13, 18},
       {11, 7, 2, 1, 6, 16, 12, 3, 0, 10, 17, 8, 4, 5, 15, 18, 13, 9, 14, 19},
       {12, 8, 3, 2, 7, 17, 13, 4, 1, 11, 18, 9, 0, 6, 16, 19, 14, 5, 10, 15},
       {13, 9, 4, 3, 8, 18, 14, 0, 2, 12, 19, 5, 1, 7, 17, 15, 10, 6, 11, 16},
       {14, 5, 0, 4, 9, 19, 10, 1, 3, 13, 15, 6, 2, 8, 18, 16, 11, 7, 12, 17},
       {15, 10, 5, 14, 19, 16, 6, 0, 9, 18, 11, 1, 4, 13, 17, 7, 2, 3, 8, 12},
       {16, 11, 6, 10, 15, 17, 7, 1, 5, 19, 12, 2, 0, 14, 18, 8, 3, 4, 9, 13},
       {17, 12, 7, 11, 16, 18, 8, 2, 6, 15, 13, 3, 1, 10, 19, 9, 4, 0, 5, 14},
       {18, 13, 8, 12, 17, 19, 9, 3, 7, 16, 14, 4, 2, 11, 15, 5, 0, 1, 6, 10},
       {19, 14, 9, 13, 18, 15, 5, 4, 8, 17, 10, 0, 3, 12, 16, 6, 1, 2, 7, 11}};

    Symmetry sym = new Symmetry(model);
    out("Reference xX\n");
    for (int i = 0; i < model.nodes.length; i++) {
      for (int j = 0; j < model.nodes.length; j++) {
        out("%4d", REF_xX[i][j]);
      }
      out("\n");
    }
    out("\n");

    out("Computed xX\n");
    assert model.nodes.length == 20;
    assert sym.xX.length == 20;
    for (int i = 0; i < model.nodes.length; i++) {
      assert sym.xX[0].length == 20;
      for (int j = 0; j < model.nodes.length; j++) {
        out("%4d", sym.xX[i][j]);
      }
      out("\n");
    }
    out("\n");

    out("Comparison xX\n");
    for (int i = 0; i < model.nodes.length; i++) {
      for (int j = 0; j < model.nodes.length; j++) {
        if (REF_xX[i][j] == sym.xX[i][j]) { out("%4s", "."); }
        else                              { out("%4s", "X"); }
      }
      out("\n");
    }
    out("\n");

  }


  public void testBaseElements() {

    int REF_NODE = 5;
    int[] REF_EDGE = new int[] {8, 12};
    int[] REF_FACE = new int[] {3, 8, 13, 9, 4};


  }



}



public static int[] range(int end) {
  return range(0, end);
}
public static int[] range(int start, int end) {
  int l = end-start;
  int[] r = new int[l];
  for (int i = 0; i < l; i++) {
    r[i] = i+start;
  }
  return r;
}
      
