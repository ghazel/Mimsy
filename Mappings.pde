
static int PIXELS_PER_BAR = 100;
static int PIXELS_BETWEEN_BARS = 1;
static int PIXELS_PER_CHANNEL = 123;
static int PIXEL_NODE_BUFFER = 2;

static int PIXELS_DODECAHEDRON = 24;
static int PIXELS_TETRA_LEFT = 50;
static int PIXELS_TETRA_RIGHT = 54;

int FACES_BAR_ORDER[][] =
  new int[][] {{}};

int TETRAHEDRON_BAR_ORDER[][] = 
  new int[][] {{0,1},{1,2},{2,3},{3,1},{2,0},{0,3}};
//int TETRAHEDRON_BARS_PER_CHANNEL = 6;


int DODECAHEDRON_BAR_ORDER[][] = 
  new int[][] {
    { 0, 1},
    { 1, 6},
    { 6,10},
    {10, 5},
    {10,15},
    {15,16},
    
    { 1, 2},
    { 2, 7},
    { 7,11},
    {11, 6},
    {11,16},
    {16,17},
    
    { 2, 3},
    { 3, 8},
    { 8,12},
    {12, 7},
    {12,17},
    {17,18},
    
    { 3, 4},
    { 4, 9},
    { 9,13},
    {13, 8},
    {13,18},
    {18,19},
    
    { 4, 0},
    { 0, 5},
    { 5,14},
    {14, 9},
    {14,19},
    {19,15}
  };


public ArrayList<int[]> channelMap;


static String DD = "Dodecahedron";
static String TL = "TetraL";
static String TR = "TetraR";

public static final Dodecahedron dd = new Dodecahedron(RADIUS);


public GraphModel buildMimsyModel() {

  Node[] nodes = new Node[dd.NODES];

  GraphModel dodecahedron = new GraphModel().setLayer(DD);
  GraphModel tetraLCompound = new GraphModel().setLayer(TL);
  GraphModel tetraRCompound = new GraphModel().setLayer(TR);

  // Build Nodes
  for (int n = 0; n < dd.NODES; n++) {
    nodes[n] = new Node(dd.xyz[n]).setName(dd.nodeNames[n]);
    //System.out.format("+ Node %2d - %8.2f %8.2f %8.2f\n",
    //  nodes[n].index, nodes[n].x, nodes[n].y, nodes[n].z);
  }


  // Build Graphs
  if (DRAW_DODECAHEDRON) {
    out("BUILDING DODECAHEDRON\n");
    PIXELS_PER_BAR = PIXELS_DODECAHEDRON;
    dodecahedron = GraphModel.fromNodes(nodes, DODECAHEDRON_BAR_ORDER)
                 . setLayer("Dodecahedron");
    //faces = buildCompound(nodes, dd.faceNet, DODECAHEDRON_BAR_ORDER);
  }

  if (DRAW_TETRA_LEFT) {
    out("BUILDING COMPOUND TETRAHEDRA LEFT (INNER 50 LEDs/Bar)\n");
    PIXELS_PER_BAR = PIXELS_TETRA_LEFT;
    tetraLCompound = buildCompound(
        nodes, 
        dd.tetraLNet, 
        TETRAHEDRON_BAR_ORDER,
        TL);
  }

  if (DRAW_TETRA_RIGHT) {
    out("BUILDING COMPOUND TETRAHEDRA RIGHT (OUTER 54 LEDs/Bar)\n");
    PIXELS_PER_BAR = PIXELS_TETRA_RIGHT;
    tetraRCompound = buildCompound(
        nodes, 
        dd.tetraRNet, 
        TETRAHEDRON_BAR_ORDER,
        TR);
  }

  return new GraphModel(nodes, 
    new GraphModel[]{dodecahedron, tetraLCompound, tetraRCompound})
    .setLayer("Mimsy");
}




public void buildChannelMap(GraphModel model) {

  GraphModel dodeca = model.getLayer(DD);
  GraphModel tetraL = model.getLayer(TL);
  GraphModel tetraR = model.getLayer(TR);


  // Initialize Channel Map
  channelMap = new ArrayList<int[]>();

  // Channel order is based on starting at a given node, 0-4, so that 
  // they can share a power supply at that node, and thus a receiver.

  // Repeat 5 times:
  //  - 6 bars of dodecahedron
  //  - 1 tetrahedron left
  //  - 1 tetrahedron right

  int channel = 0;
  Bar[] bars = new Bar[6];
  for (int i = 0; i < 5; i++) {

    // DD bars
    for (int b = 0; b < 6; b++) {
      bars[b] = dodeca.bars[i*6+b];
    }
    addBarsToChannel(bars, channel++);

    // Tetrahedra Bars
    addBarsToChannel(tetraL.subGraphs.get(i).bars, channel++);
    addBarsToChannel(tetraR.subGraphs.get(i).bars, channel++);
  }
}

public void addBarsToChannel(Bar[] bars, int channel) {
  int total = 0;
  for (Bar bar : bars) { total += bar.points.size(); }
  int[] pixels = new int[total];
  //List<Integer> c_list = new ArrayList<Integer>();
  //IntList c_list = new IntList(512);
  int pixel = 0;
  for (Bar bar : bars) {
    //int pix = 0;
    for (LXPoint point : bar.points) {
      pixels[pixel++] = point.index;
      //if (pix++ >= 512) { break; }
    }
  }
  //int[] c_array = c_list.toArray();
  //channelMap.add(channel, c_array);
  channelMap.add(channel, pixels);
}


/*
  public void setChannelMap() {
    ArrayList<int[]> channelmap = new ArrayList<int[]>();
    for(int i=0; i<this.stripMap.size(); i++) {
      IntList intce = new IntList(512);
      List<String> striplist=this.stripMap.get(i);
      for (String node1node2 : striplist) {
         List<String> nodes = Arrays.asList(node1node2.split("_"));
         Node node1 = this.nodemap.get(nodes.get(0));
         Node node2 = this.nodemap.get(nodes.get(1));
         List<LXPoint> nodetonodepoints = nodeToNodePoints(node1,node2);
         for (LXPoint p : nodetonodepoints) {
           intce.append(p.index);
         }
      }
      int[] intcearray = intce.array();
      channelmap.set(i,intcearray);
    }
    this.channelMap=channelmap;
  }
*/



/**
 * Build graphs based on Dodecahedral subNet geometries
 */

public GraphModel buildCompound( Node[] nodes, 
                                Dodecahedron.Net net, 
                                int[][] ordering,
                                String layer) {
  GraphModel[] compound = new GraphModel[net.subnets];
  for (int t = 0; t < net.subnets; t++) {
    //System.out.format(" !! Creating TetraR %d\n", t);  
    Node[] pg_nodes = new Node[net.nodes[t].length];
    for(int n = 0; n < net.nodes[t].length; n++) {
      pg_nodes[n] = nodes[net.nodes[t][n]];
    }
    compound[t] = GraphModel.fromNodes(pg_nodes, ordering)
                           .setLayer(layer + "_" + t);
  }
  return new GraphModel(nodes, compound).setLayer(layer).markAsCompound();
}










  /*
  Tetrahedral Edges (right)
  Object 0 -  0 15 13  7
  Object 1 -  1 16 14  8
  Object 2 -  2 17 10  9
  Object 3 -  3 18 11  5
  Object 4 -  4 19 12  6

  a-d 0-3 0-1
  d-c 3-2 1-2
  c-b 2-1 2-3
  b-d 1-3 3-1
  c-a 2-0 2-0
  a-b 0-1 0-3
  */


  /* There are several methods for navigating the connectiviety
   * 1) [OBJECT][NODE] - lists of nodes
   * 2) [OBJECT][EDGE] - lists of edges
   * 3) [VERTICES][VERTICES] - connectivity matrix
   * 4) [OBJECT][NODE1][NODE2] - neighbors
   */

  /*
  static int nodes_face[][] = {
    {0,1,2,3,4},
  
    {0,1,6,10,5},
    {1,2,7,11,6},
    {2,3,8,12,7},
    {3,4,9,13,8},
    {4,0,5,14,9},
  
    {15,16,11,6,10},
    {16,17,12,7,11},
    {17,18,13,8,12},
    {18,19,14,9,13},
    {19,15,10,5,14},
    
    {15,16,17,18,19},
  };

  */



