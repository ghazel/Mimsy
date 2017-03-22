/**
 * This is a very basic model class that is a 3-D matrix
 * of points. The model contains just one fixture.
 */
static class Model extends LXModel {
  
  private static boolean DRAW_FACES        = false;
  private static boolean DRAW_FRABJOUS     = false;
  private static boolean DRAW_TETRA_LEFT   = false;
  private static boolean DRAW_TETRA_RIGHT  = true;
  private static boolean DRAW_CUBIC        = false;

  protected static float radius = 144.0;
  private static Dodecahedron dd = new Dodecahedron(radius);
  private static int pixels_per_edge = 20;
  private static int pixels_between_edges = 1;
  
  public ArrayList<int[]> channelMap;

  
  public Model() {
    super(new Fixture());
  }
  
  /**
   * Gets a random point from the model.
   */
  public LXPoint getRandomPoint() {
    Random randomized = new Random();
    return this.points.get(randomized.nextInt(points.size()));
  }

  /**
   * Gets random points from the model.
   */
  public ArrayList<LXPoint> getRandomPoints(int num_requested) {
    Random randomized = new Random();
    ArrayList<LXPoint> returnpoints = new ArrayList<LXPoint>();
    
    while (returnpoints.size () < num_requested) {
      returnpoints.add(this.getRandomPoint());
    }
    
    return returnpoints;
  }

  private static class Fixture extends LXAbstractFixture {
    

    
    private Fixture() { 
      /*
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
      */
      
      // Tetra Edge Ordering
      if (DRAW_TETRA_LEFT) {
        Dodecahedron.Net T = dd.tetraLNet;
        for (int t = 0; t < T.subnets; t++) { 
          for (int e = 0; e < T.edge_count; e++) {
            int n1 = T.ordered[t][e][0];
            int n2 = T.ordered[t][e][1];
            System.out.format("Tetra %d Edge %d N %2d %2d\n", t, e, n1, n2);
            add_edge_points(n1,n2);
            // add blank pixel for Mimsy v1
            if ((e%2) == 0) {
              add_edge_points(n2, n2, 1);
            }
          }
        }
      }

      // Tetra Edge Ordering
      if (DRAW_TETRA_RIGHT) {
        Dodecahedron.Net T = dd.tetraRNet;
        for (int t = 0; t < T.subnets; t++) { 
          for (int e = 0; e < T.edge_count; e++) {
            int n1 = T.ordered[t][e][0];
            int n2 = T.ordered[t][e][1];
            System.out.format("Tetra %d Edge %d N %2d %2d\n", t, e, n1, n2);
            add_edge_points(n1,n2);
            // add blank pixel for Mimsy v1
            if ((e%2) == 0) {
              add_edge_points(n2, n2, 1);
            }
          }
        }
      }
    }


    /*
     * From sugarcubes demo
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
      add_edge_points(i1, i2, pixels_per_edge);
    }
    
    private void add_edge_points(int i1, int i2, int pixels_per_edge) { 
      float v1[] = dd.xyz[i1];
      float v2[] = dd.xyz[i2];
      
      float delta[] = {v2[0]-v1[0],v2[1]-v1[1],v2[2]-v1[2]};
      int buffer = 2;
      System.out.format("  Vertex: %2d   Coords %5.2f %5.2f %5.2f\n", i1, v1[0], v1[1], v1[2]);
      System.out.format("  Vertex: %2d   Coords %5.2f %5.2f %5.2f\n", i2, v2[0], v2[1], v2[2]);
      System.out.format("  Delta        Coords %5.2f %5.2f %5.2f\n", delta[0], delta[1], delta[2]);
      System.out.format("  Colors: %d\n", this.points.size());

      for (int p = 0; p < pixels_per_edge; p++) {
        float pt[] = new float[3];
        for (int i = 0; i<3; i++) { 
          //pt[i] = v1[i] + delta[i]*(float)(p)/((float)pixels_per_edge); 
          pt[i] = v1[i] + delta[i]*(float)(p+1)/(float)(pixels_per_edge+buffer); 
        }
        addPoint(new LXPoint(pt[0], pt[1], pt[2]));          
      }
      //System.out.format("\n");
      
    }
  }
  

}
