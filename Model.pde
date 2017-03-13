/**
 * This is a very basic model class that is a 3-D matrix
 * of points. The model contains just one fixture.
 */
static class Model extends LXModel {
  
  private static boolean DRAW_FACES        = true;
  private static boolean DRAW_FRABJOUS     = false;
  private static boolean DRAW_TETRA_LEFT   = false;
  private static boolean DRAW_TETRA_RIGHT  = false;
  private static boolean DRAW_CUBIC        = false;

  protected static float radius = 144.0;
  private static Dodecahedron dd = new Dodecahedron(radius);
  private static int pixels_per_edge = 100;
  
  public ArrayList<int[]> channelMap;

  
  public Model() {
    super(new Fixture());
  }
  
  private static class Fixture extends LXAbstractFixture {
    

    
    private Fixture() { 
      
      // Draw Dodecahedral Faces
      if (DRAW_FACES) {
        for (int v1 = 0; v1 < 20; v1++) {
          for (int i = 0; i < 3; i++) { 
            int v2 = dd.faceNet.edges[v1][i];
            if (v1 < v2) { 
              add_edge_points(v1, v2);
            }
          }
        }
      }
      
      // Draw Tetrahedra Left Faces
      if (DRAW_TETRA_LEFT) {
        for (int v1 = 0; v1 < 20; v1++) { 
          for (int i = 0; i < 3; i++) {
            int v2 = dd.tetraLNet.edges[v1][i];
            if (v1 < v2) { 
              add_edge_points(v1, v2);
            }
          }
        }
      }

      
      
      // Draw Dodecahedral Faces
      /*
      for (int f = 0; f < 12; f++) { 
        //System.out.format("Face %2d\n", f);
        int vertices[] = dd.faces[f];
        for (int i1 = 0; i1 < 5; i1++) {
          int i2 = (i1 + 1) % 5;
          int v1 = vertices[i1];
          int v2 = vertices[i2];
          //add_edge_points(v1, v2);
        }
      }
      */

      /*     
      // Draw Dodecahedral Faces
      if (DRAW_FACES) {
        for (int v1 = 0; v1 < 20; v1++) {
          for (int i = 0; i < 3; i++) { 
            int v2 = dd.connections[v1][i];
            if (v1 < v2) { 
              add_edge_points(v1, v2);
            }
          }
        }
      }
      
      // Draw Frabjous Edges
      if (DRAW_FRABJOUS) {
        for (int v1 = 0; v1 < 20; v1++) { 
          int[] f = dd.get_frabjous_connections(v1);
          for (int v2 = 0; v2 < 3; v2++) {
            if (v1 < f[v2]) { 
              add_edge_points(v1, f[v2]);
            }
          }
        }
      }

      /* 
      // Draw Tetrahedral Edges
      if (TETRA_LEFT) {
        for (int v1 = 0; v1 < 20; v1++) { 
          int[] f = dd.get_tetrahedral_connections(v1, "left");
          for (int v2 = 0; v2 < 3; v2++) { 
            if (v1 < f[v2]) { 
              add_edge_points(v1, f[v2]);
            }
          }
        }
      }

      if (TETRA_RIGHT) {
        for (int v1 = 0; v1 < 20; v1++) { 
          int[] f = dd.get_tetrahedral_connections(v1, "right");
          for (int v2 = 0; v2 < 3; v2++) { 
            if (v1 < f[v2]) { 
              add_edge_points(v1, f[v2]);
            }
          }
        }  
      }

    
      // Draw Cubic Edges
      if (CUBIC) {
        for (int v1 = 0; v1 < 20; v1++) { 
          int[] f = dd.get_cubic_connections(v1, "left");
          for (int v2 = 0; v2 < 3; v2++) { 
            if (v1 < f[v2]) { 
              add_edge_points(v1, f[v2]);
            }
          }
          f = dd.get_cubic_connections(v1, "right");
          for (int v2 = 0; v2 < 3; v2++) { 
            if (v1 < f[v2]) { 
              add_edge_points(v1, f[v2]);
            }
          }
        }
      }
      */
    }

    
    /*
    private static final int MATRIX_SIZE = 12;
    private Fixture() {
      // Here's the core loop where we generate the positions
      // of the points in our model
      for (int x = 0; x < MATRIX_SIZE; ++x) {
        for (int y = 0; y < MATRIX_SIZE; ++y) {
          for (int z = 0; z < MATRIX_SIZE; ++z) {
            // Add point to the fixture
            addPoint(new LXPoint(x*FEET, y*FEET, z*FEET));
          }
        }
      }
    }
    */ 

    private void add_edge_points(int i1, int i2) { 
      float v1[] = dd.xyz[i1];
      float v2[] = dd.xyz[i2];
      
      float delta[] = {v2[0]-v1[0],v2[1]-v1[1],v2[2]-v1[2]};
      //System.out.format("  Vertex: %2d   Coords %5.2f %5.2f %5.2f\n", i1, v1[0], v1[1], v1[2]);
      //System.out.format("  Vertex: %2d   Coords %5.2f %5.2f %5.2f\n", i2, v2[0], v2[1], v2[2]);
      //System.out.format("  Delta        Coords %5.2f %5.2f %5.2f\n", delta[0], delta[1], delta[2]);

      for (int p = 0; p <= pixels_per_edge; p++) {
        float pt[] = new float[3];
        for (int _i = 0; _i<3; _i++) { pt[_i] = v1[_i] + delta[_i]*(float)p/(float)pixels_per_edge; }
        addPoint(new LXPoint(pt[0], pt[1], pt[2]));          
      }
      //System.out.format("\n");
      
    }
  }
  
  
}
