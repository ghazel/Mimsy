/** ****************** DODECAHEDRON GENERATION *******************************
 * Converted from 
 * http://userpages.umbc.edu/~squire/reference/polyhedra.shtml#dodecahedron
 ****************************************************************************/
 
public static class Dodecahedron {
  static final int NODES = 20;
  static final int EDGES = 30;
  
  float radius = 1.0;
  float xyz[][] = new float[NODES][3]; 
  int edges[][] = new int[NODES][3];
  int matrix[][] = new int[NODES][NODES];

  int distance_graph[][] = new int[20][20];
  float distance_euclid[][] = new float[20][20];
    
  public Net faceNet = new Net(1, 20, 3);
  public Net tetraLNet = new Net(5, 4, 6);
  public Net tetraRNet = new Net(5, 4, 6);

  public static final String[] nodeNames = new String[] {
    "A1","A2","A3","A4","A5",
    "B1","B2","B3","B4","B5",
    "C1","C2","C3","C4","C5",
    "D1","D2","D3","D4","D5",
  };

  public class Net {
    int subnets;
    int node_count;
    int edge_count;
    int node_map[];
    int nodes[][];
    int edges[][];
    int matrix[][];

    Net(int subnets, int node_count, int edge_count) {
      this.subnets = subnets; // # of objects
      this.node_count = node_count;
      this.edge_count = edge_count;
      this.node_map = new int[NODES]; // map nodes to subnets
      this.nodes   = new int[subnets][node_count]; // list of nodes in each object
      this.edges   = new int[NODES][edge_count];   // neighboring edges per node
      this.matrix  = new int[NODES][NODES]; // connectivity matrix
    }

    // Set the nodes for a subnet
    void set_nodes(int subnet, int nodes[]) {
      this.nodes[subnet] = nodes;
    }

    // Add an edge to an given subnet
    void add_edges(int subnet, int source, int targets[]) {
      this.edges[source] = targets;
      for (int i = 0; i < targets.length; i++) { 
        this.matrix[source][targets[i]] = subnet;
      }
    }
  }



  
  /* Convenient constant */
  private float the72 = PI*72.0/180;


  public Dodecahedron(float radius) {
    this.radius = radius;
    generate_vertices();
    generate_edges_face();
    generate_edges_tetra(tetraLNet, "left");
    generate_edges_tetra(tetraRNet, "right");
  }

  /* ************************************************************* VERTICES */
  private void generate_vertices() {
    float phiaa = 52.62263590; /* the two phi angles needed for generation */
    float phibb = 10.81231754;
    float phia = PI*phiaa/180.0; /* 4 sets of five points each */
    float phib = PI*phibb/180.0;
    float phic = PI*(-phibb)/180.0;
    float phid = PI*(-phiaa)/180.0;
    float offset = the72/2.0; /* pairs of layers offset 36 degrees */
    _generate_vertex_layer(phia,      0,  0);
    _generate_vertex_layer(phib,      0,  5);
    _generate_vertex_layer(phic, offset, 10);
    _generate_vertex_layer(phid, offset, 15);
  }

  private void _generate_vertex_layer(float phi, float theta, int index) {
    int i;
    if (index == 0) {
      System.out.format("Dodecahedron Vertex Coordinates\n");
    }
    for(i=index; i<index+5; i++) {
      xyz[i][0]=radius*cos(theta)*cos(phi);
      xyz[i][1]=radius*sin(theta)*cos(phi);
      xyz[i][2]=radius*sin(phi);
      theta = theta+the72;
      System.out.format("Vertex: %2d  Phi: %6.2f  Theta: %6.2f  "
                      + "Coords %8.2f %8.2f %8.2f\n", 
        i,
        phi,
        theta,
        xyz[i][0],
        xyz[i][1],
        xyz[i][2]
      );
    }
  }

  // ******************************************************************* FACES
  // Edges are generated in clockwise order
  void generate_edges_face() {
    System.out.format("\nDodecahedron Edges\n");
    faceNet.set_nodes(0, new int[] {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19});
    int vs, rs, cs, vt, rt, ct, rtv, rth, co1, co2, top, middle;
    for (rs = 0; rs < 4; rs++) {   // Source Rows
      for (cs = 0; cs < 5; cs++) { // Source Columns
        vs = rs*5 + cs; // Source Vertex
        switch (rs) {
          case 0: rtv=1; rth=0; co1=+4; co2=+1; top=0; middle=0; break;
          case 1: rtv=0; rth=2; co1= 0; co2=+4; top=0; middle=1; break;
          case 2: rtv=3; rth=1; co1= 0; co2=+1; top=1; middle=1; break;
          case 3: rtv=2; rth=3; co1=+1; co2=+4; top=1; middle=0; break;
          default: rtv=0; rth=0; co1=0; co2=0; break;
        }

        // Vertical Edge
        rt = rtv;
        ct = cs;
        vt = rt*5 + ct;
        edges[vs][0] = vt;
        //System.out.format("VEdge   %3d# %2dr / %2dc   to   %3d# %2dr / %2dc\n", 
        //                  vs, rs, cs, vt, rt, ct);

        // Horizontal Edges
        rt = rth;
        ct = (cs+co1)%5;
        vt = rt*5 + ct;
        edges[vs][1] = vt;
        //System.out.format("HEdge   %3d# %2dr / %2dc   to   %3d# %2dr / %2dc\n", 
        //                  vs, rs, cs, vt, rt, ct);

        ct = (cs+co2)%5;
        vt = rt*5 + ct;
        edges[vs][2] = vt;
        //System.out.format("HEdge   %3d# %2dr / %2dc   to   %3d# %2dr / %2dc\n", 
        //                  vs, rs, cs, vt, rt, ct);
        faceNet.add_edges(0, vs, edges[vs]);
        //System.out.format("\n");
      }
    }
  }
  
  int get_branch(int v1, int v2, int number) {
    int c[] = edges[v2];
    //int c[] = faceNet.edges[v2];
    int n = -1;
    
    for (int i =0 ; i < c.length; i++) { 
      if (c[i]==v1) { n = i; };
    }
    if (false) {
      if (n==-1) { 
        System.out.format("Fuck %2d %2d [X]: %d %d %d\n", v1, v2, c[0], c[1], c[2]);
        n = 1/0;
      } else { 
        System.out.format("Yiss %2d %2d [%d]: %d %d %d\n", v1, v2, n, c[0], c[1], c[2]);
      }
    }
    return c[(n+c.length+number)%c.length];
  }
  
  int get_left_branch(int v1, int v2) { 
    return get_branch(v1, v2, -1);
  }
  
  int get_right_branch(int v1, int v2) { 
    return get_branch(v1, v2, 1);
  }


  // ***** TETRAHEDRAL ***** //
  /* Have graph distance 3 */
  
  void generate_edges_tetra(Net net, String chirality) {
    System.out.format("\nTetrahedral Edges (%s)\n", chirality);
    int v1, v2, v3, v4;

    for (int o = 0; o < net.subnets; o++) { 
      int n[] = new int[4];
      n[0] = o;

      // Nodes, and edges from first node
      for (int j = 0; j < 3; j++) { 
        //System.out.format(" - %d %d\n", i, j);
        v1 = o;
        v2 = edges[v1][j];
        //v2 = faceNet.edges[v1][j];
        if (chirality == "left") { 
          v3 = get_left_branch(v1, v2);
          v4 = get_right_branch(v2, v3);
        } else {
          v3 = get_right_branch(v1, v2);
          v4 = get_left_branch(v2, v3);
        }
        n[j+1] = v4;
        
        //net.add_edge(v1, v1, v4);
      }
      //System.out.format("Object %d - %2d %2d %2d %2d\n", n[0], n[0], n[1], n[2], n[3]);

      net.set_nodes(o, n);
      net.add_edges(o, n[0], new int[] {n[1], n[2], n[3]});
      net.add_edges(o, n[1], new int[] {n[0], n[3], n[2]});
      net.add_edges(o, n[2], new int[] {n[0], n[1], n[3]});
      net.add_edges(o, n[3], new int[] {n[0], n[2], n[1]});
      
      /*
      for (int e = 0; e < net.edge_count; e++) {
        int n1 = net.nodes[o][net.ordering[e][0]];
        int n2 = net.nodes[o][net.ordering[e][1]];
        net.ordered[o][e][0] = n1;
        net.ordered[o][e][1] = n2;
      }
      */
    }

  }


  /*
  // ******************************************************************* CUBIC
  // Have graph distance 2
  int[][] generate_edges_cubic(String chirality) {
    int[][] c = new int[VERTICES][3];
    for (int v=0; v<VERTICES; v++) {
      //int[] c = new int[3];
      int v1, v2, v3, v4, v5;
      for (int i = 0; i < 3; i++) { 
        v1 = v;
        v2 = edges_face[v1][i];
        if (chirality == "left") { 
          v3 = get_left_branch(v1, v2);
          //v4 = get_right_branch(v2, v3);
        } else {
          v3 = get_right_branch(v1, v2);
          //v4 = get_left_branch(v2, v3);
        }
        c[i] = v3;
      }
      System.out.format("\n");
      return c;
    }
  }

  // **************************************************************** FRABJOUS
  // Have graph distance 4
  int[] generate_edges_frabjous(int v) {
    int[] c = new int[3];
    int v1, v2, v3, v4, v5;
    for (int i = 0; i < 3; i++) {
      v1 = v;
      v2 = connections[v][i];
      v3 = get_left_branch(v1, v2);
      v4 = get_right_branch(v2, v3);
      v5 = get_left_branch(v3, v4);
      c[i] = v5;
    }
    System.out.format("\n");
    return c;
  }
  */

  // The dodecahedron coordinates:
  // Vertex       coordinate
  int A1 =   0; //,  x= 0.607, y= 0.000, z= 0.795 
  int A2 =   1; //,  x= 0.188, y= 0.577, z= 0.795 
  int A3 =   2; //,  x=-0.491, y= 0.357, z= 0.795 
  int A4 =   3; //,  x=-0.491, y=-0.357, z= 0.795 
  int A5 =   4; //,  x= 0.188, y=-0.577, z= 0.795 
  int B1 =   5; //,  x= 0.982, y= 0.000, z= 0.188 
  int B2 =   6; //,  x= 0.304, y= 0.934, z= 0.188 
  int B3 =   7; //,  x=-0.795, y= 0.577, z= 0.188 
  int B4 =   8; //,  x=-0.795, y=-0.577, z= 0.188 
  int B5 =   9; //,  x= 0.304, y=-0.934, z= 0.188 
  int C1 =  10; //,  x= 0.795, y= 0.577, z=-0.188 
  int C2 =  11; //,  x=-0.304, y= 0.934, z=-0.188 
  int C3 =  12; //,  x=-0.982, y= 0.000, z=-0.188 
  int C4 =  13; //,  x=-0.304, y=-0.934, z=-0.188 
  int C5 =  14; //,  x= 0.795, y=-0.577, z=-0.188 
  int D1 =  15; //,  x= 0.491, y= 0.357, z=-0.795 
  int D2 =  16; //,  x=-0.188, y= 0.577, z=-0.795 
  int D3 =  17; //,  x=-0.607, y= 0.000, z=-0.795 
  int D4 =  18; //,  x=-0.188, y=-0.577, z=-0.795 
  int D5 =  19; //,  x= 0.491, y=-0.357, z=-0.795 
  
  //  Length of every edge is  0.713644 

}



  

  
    
/*


    

  DD Connectivity
  Node order is chiral. 
    Find source node index i. 
    (i+1)%3 is a left branch. 
    (i+2)%5 is a right branch.
  
  A1 - B1 A5 A2  Rs+1/Ca, Rs/Cs-1, Rs/Cs+1 
  A2 - B2 A1 A3
  
  B1 - A1 C1 C5 = Rs-1/Cs, Rs+1/Cs, Rs+1/Cs-1
  B2 - A2 C2 C1
  
  C1 - D1 B1 B2 = Rs+1/Cs, Rs-1/Cs, Rs+1/Cs+1

  D1 - C1 D2 D5
  D2 - C2 D3 D1 = Rs-1/Cs, Rs/Cs+1, Rs/Cs-1


  Frabjous connectivity
  

  A1 - D5
  A2 - D1
  A3 - D2
  A4 - D3
  A5 - D4
  
  B1 - B3 B4      
  B2 - B4 B5
  B3 - B5 B1
  B4 - B1 B2
  B5 - B2 B3

  C1 - C3 C4      10 - 12 13
  C2 - C4 C5
  C3 - C5 C1
  C4 - C1 C2
  C5 - C2 C3
  
  D1 - A2
  D2 - A3
  D3 - A4 B5 
  D4 - A5 
  D5 - A1 
  
  
  
*/
