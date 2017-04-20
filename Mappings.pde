
static final int PIXELS_PER_EDGE = 20;
static final int PIXELS_BETWEEN_EDGES = 1;
static final int PIXELS_PER_CHANNEL = 123;
static final int PIXEL_NODE_BUFFER = 2;



int FACES_BAR_ORDER[][] =
  new int[][] {{}};

int TETRAHEDRON_BAR_ORDER[][] = 
  new int[][] {{0,1},{1,2},{2,3},{3,1},{2,0},{0,3} };
int TETRAHEDRON_BARS_PER_CHANNEL = 6;

public ArrayList<int[]> channelMap;



public Model buildModel() {
  
  Dodecahedron dd = new Dodecahedron(RADIUS);
  Node[] nodes = new Node[dd.NODES];

  PolyGraph faces = new PolyGraph();
  PolyGraph tetraLCompound = new PolyGraph();
  PolyGraph tetraRCompound = new PolyGraph();

  // Build Nodes
  for (int n = 0; n < dd.NODES; n++) {
    nodes[n] = new Node(dd.xyz[n]).setName(dd.nodeNames[n]);
    System.out.format("+ Node %2d - %8.2f %8.2f %8.2f\n",
      nodes[n].index, nodes[n].x, nodes[n].y, nodes[n].z);
  }

  // Build Graphs
  if (DRAW_TETRA_LEFT) {
    tetraLCompound = buildGraph(nodes, dd.tetraLNet, TETRAHEDRON_BAR_ORDER);
  }
  if (DRAW_TETRA_RIGHT) {
    tetraRCompound = buildGraph(nodes, dd.tetraRNet, TETRAHEDRON_BAR_ORDER);
  }


  /*
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
  */

  //return new Model(nodes, bars);
  return new Model(nodes, faces, tetraLCompound, tetraRCompound);
}



public PolyGraph buildGraph(Node[] nodes, Dodecahedron.Net net, int[][] ordering) {
  PolyGraph[] compound = new PolyGraph[net.subnets];
  for (int t = 0; t < net.subnets; t++) {
    //System.out.format(" !! Creating TetraR %d\n", t);  
    Node[] pg_nodes = new Node[net.nodes[t].length];
    for(int n = 0; n < net.nodes[t].length; n++) {
      pg_nodes[n] = nodes[net.nodes[t][n]];
    }
    compound[t] = PolyGraph.fromNodes(pg_nodes, ordering);
  }
  return PolyGraph.fromGraphs(nodes, compound);
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



