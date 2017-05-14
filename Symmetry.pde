
/* SYMMETRY
 *
 * STATIC METHODS
 * --------------
 * Knows symmetry generators for dodecahedron and tetrahedra
 * ENUM of Face, Edge, Vertex Rotations and Inversion
 * Can parse a string into a series of operations
 * Factory creates a given symmetry, for repeated application
 * Generate a random symmetry
 *
 * NON-STATIC METHODS
 * ------------------
 * Apply the given color scheme / symmetry across a PolyGraph
 * TODO: How to apply inversion when inner tetrahedral compound has fewer points
 * Iterate the current symmetry by one+ operations
 *
 *
 * OPERATIONS
 * ----------
 * Rotate Bar  - 2
 * Rotate Node - 3
 * Rotate Face - 5
 * Invert - 2
 *
 * All operations are pre-computed and stored as the modulous of the operation.
 * Normally, symmetries are set as a given step of the operation. However, if
 * NULL is passed instead, the symmetry will be applied across ALL steps. This
 * is useful for painting the full pallate through various symmetry operations.
 *
 *
 *
 */





public static class Symmetry {

  public enum Generator { BAR, NODE, FACE, INVERT };
  public enum Kind { TETRAHEDRAL, ICOSAHEDRAL };
  
  /**
   *  Cached or derived data from the model
   */
  public final GraphModel model;
  public final Node[] nodes;
  public final List<LXPoint> points;
  public final Kind kind;

  /**
   * Vector form of relevant symmetry operations on nodes
   */
  private final int[] ID; // Identity
  private final int[] xN; // Rotation 120 deg about Node
  private final int[] xB; // Rotation 180 deg about Bar
  private final int[] xF; // Rotation  72 deg about Face
  private final int[] xI; // Inversion
  
  private final int[][] xX; // Arbitrary, computed from above


  /**
   * Colors in the template are applied to the whole object by symmetry ops.
   */
  public int[] template;
  //public final List<Integer> template;
  
  /**
   * Current symmetry state. Updated as new symmetry elements are added.
   */

  // A history of applied symmetry elements
  public List<Element> elements;

  // How many symmetries are there currently?
  public int symmetries;
  public List<int[]> xNodes;

  public HashMap<Node,List<Node>> nodeMap;
  public HashMap<Bar,List<Bar>> barMap;
  public HashMap<GraphModel,List<GraphModel>> faceMap;

  


  //******************************************************** SYMMETRY ELEMENTS

  /** 
   * Encapsulates and stores the base generators for later use
   */
  public static class Element {
    // The type of symmetry operation: Node, Bar, etc.
    public Generator type;
    // Reference to WHICH Node, Bar, etc it operates on.
    public int[] nodes;
    // How many operations before repeating
    public int modulus;
    // One (or more) steps of the operation to take
    public int[] steps;
    // Translation map
    public int[][] map;
    
    /**
     * Construct an element which take all steps
     */
    public Element(Generator type, int[] nodes) {
      this(type, nodes, new int[0]);
    }

    /**
     * Construct an Element which takes a specific step
     */
    public Element(Generator type, int[] nodes, int step) {
      this(type, nodes, new int[]{step});
    }
  
    /**
     * Construct an Element which takes specific steps
     */ 
    public Element(Generator type, int[] nodes, int[] steps) {
      this.type = type;
      this.nodes = nodes;;
      this.modulus = this.getModulus(type);
      this.steps = steps;
    }

    private int getModulus(Generator type) {
      switch (type) { 
        case BAR:     return 2;
        case NODE:    return 3;
        case FACE:    return 5;
        case INVERT:  return 2;
        default:      return 1;
      }
    }

    /**
     * Step an element through its rotations
     */
    public Element addStep() { return this.addStep(1); }
    public Element addStep(int step) {
      for (int i = 0; i < this.steps.length; i++) {
        this.steps[i] += step;
      }
      return this;
    }
    
    /*
    public Element addSteps(int[] steps) {
      

      boolean[] stepI = new boolean[modulus];
      if (steps.length == 0) { 
        return this;
      }

      for (int i = 0; i < this.steps.length; i++) {
        for (int j = 0; j < steps.length; j++) {
          newStep = (this.steps[i] + steps[j]) % modulus;;
          stepI[newStep] = true;
        }
      }

      ArrayList<Integer> stepA = new ArrayList<Integer>();
      for (int i = 0; i < stepI.length; i++) {
        if (stepI[i]) { stepA
      }
int[] arr = list.stream().mapToInt(i -> i).toArray();
      int[] newSteps = new int[count];
      for (int i = 0; i < stepI.length; i++) {
        if (stepI) { count++; }
      }

      


      // Do nothing if step is already infinite
      if (this.step == null) { return this; }
      
      // If new steps is null, set to null
      if (steps == null) { return setStep(null); } 
     
      // Otherwise increment the steps 
      else { return this.setStep(step + steps); }
    }
    */
    public Element setStep(int step) {
      return this.setStep(new int[]{step});
    }
    public Element setStep(int[] step) {
      this.steps = steps;
      for (int i = 0; i < this.steps.length; i++) {
        this.steps[i] %= this.modulus;
      }
      return this; 
    }
    
    /**
     * Set the translation map to apply to nodes
     */
    public Element setMap(int[] map) {
      this.map = new int[][]{map};
      return this;
    }
    public Element setMap(int[][] map) {
      this.map = map;
      return this;
    }
  }


  //************************************************************* CONSTRUCTORS


  public Symmetry() {
    this(new GraphModel());
  }

  public Symmetry(GraphModel model){
    this.model = model;
    this.nodes = model.nodes;
    this.points = model.points;
    this.template = new int[model.points.size()];
    //this.template = new ArrayList<LXColor>(model.points.size());
   
    // Populate all the symmetry operations 
    this.ID = new int[nodes.length];
    for (int i = 0; i<nodes.length; i++) { ID[i] = i; }
    //if (nodes.length == 20) {
      this.kind = Kind.ICOSAHEDRAL;


      // Inversion about the origin (anti-chiral)
      this.xI = new int[] { 17, 18, 19, 15, 16, 
                            12, 13, 14, 10, 11, 
                             8,  9,  5,  6,  7, 
                             3,  4,  0,  1,  2};

      // Rotation 180 degrees about the bar/edge (0,1)
      this.xB = new int[] { 1,  0,  5, 10,  6,  
                            2,  4, 14, 15, 11,
                            3,  9, 19, 16,  7,
                            8, 13, 18, 17, 12};


      // Rotation cc-wise of the face (0,1,2,3,4)
      this.xF = new int[] {  1,  2,  3,  4,  0, 
                             6,  7,  8,  9,  5, 
                            11, 12, 13, 14, 10, 
                            16, 17, 18, 19, 15};

      // Rotation cc-wise around the node/vertex 0
      this.xN = I(M(xB,xF));

      // Canonical transformations for all nodes, when node 0 is moved to any
      // other node.  May subsequently need to be corrected for orientation.
      // These are computed as rotations around nodes and bars to get to the
      // right place.
      this.xX = new int[][] {
        this.ID,
        this.xF,
        P(xF, 2),
        P(xF, 3),
        P(xF, 4),

        M(P(xF,4), M(xB, P(xF, 4))),
        M(xB, P(xF, 4)),
        M(xF, M(xB, P(xF, 4))),
        M(P(xF,2), M(xB, P(xF, 4))),
        M(P(xF,3), M(xB, P(xF, 4))),
        
        M(xB, P(xF, 3)),
        M(xF, M(xB, P(xF, 3))),
        M(P(xF,2), M(xB, P(xF,3))),
        M(P(xF,3), M(xB, P(xF,3))),
        M(P(xF,4), M(xB, P(xF,3))),

        M(xB,M(P(xF,2), M(xB, P(xF,4)))),
        M(xF, M(xB, M(P(xF, 2), M(xB, P(xF, 4))))),
        M(P(xF, 2), M(xB, M(P(xF, 2), M(xB, P(xF, 4))))),
        M(P(xF, 3), M(xB, M(P(xF, 2), M(xB, P(xF, 4))))),
        M(P(xF, 4), M(xB, M(P(xF, 2), M(xB, P(xF, 4)))))
      };


    //} else { 
    //  this.kind = Kind.TETRAHEDRAL;
    //}
    //

    initializeCache();
    
  }

  




  //********************************************************  GROUP OPERATIONS
  // !!!! NOTE: THIS IS DEEP VOODOO. MAY BE INCOMPREHENSIBLE WITHOUT PHD. !!!!

  /**
   * Compose h with g.
   *
   * @param g Tranformation vector for a symmetry operation
   * @param h Nodes to be translated
   * @return Vector of translated nodes
   */

  private int[] M(int[] g, int[] h) {
    int[] r = new int[h.length];
    for (int i = 0; i < nodes.length; i++) {
      r[i] = g[h[i]];
    }
    return r;
  }

  /**
   * Compute the transofmration from composing by g, n times.
   *
   * @param g Tranformation vector for a symmetry operation
   * @param n Number of times to transform
   * @return The product of the repeated transformation
   */

  private int[] P(int[] g, int n) {
    if      (n > 0) { return M(g, P(g, n-1)); }
    else if (n < 0) { return I(P(g, -n)); }
    else            { return ID; }
  }

  /**
   * Invert g, that is, undo the transformation performed by g.
   *
   * @param g Tranformation vector for a symmetry operation
   * @return g-inverse
   */
  private int[] I(int[] g) {
    int[] r = new int[nodes.length];
    for (int i = 0; i < nodes.length; i++) {
      r[g[i]] = i;
    }
    return r;
  }

  /**
   * Conugate h with g. 
   */

  private int[] conjugate(int[] g, int[] h) {
    return M(g,M(h,I(g)));
  }

  /**
   * Correct the orientation after applying a symmetry operation.
   */
  private int[] reorient(int[] g) {
    int n = I(xX[g[0]])[g[1]];
    int o = 0;
    if (n == 4) { o = 1; }
    if (n == 5) { o = 2; }
    return M(xX[g[0]], P(xB, o));
  }


  //************************************************ STATE & CACHE MAINTENANCE

  private void resetState() {
    elements = new ArrayList<Element>();
    xNodes = new ArrayList<int[]>();
    xNodes.add(ID);
    symmetries = 1;
    clear();
  }
    

  private void initializeCache() {
    resetState();
  }

  private void addElement(Element elem) {
   
    out("Adding Symmetry Element #%d: %s %d\n", 
      elements.size(), elem.type, elem.modulus);
    // TODO: If elem == elements[-1], pop the last element and combine it
    // with the new one.

    this.elements.add(elem);
    ArrayList<int[]> newMap = new ArrayList<int[]>();

    for (int[] cur : xNodes) {
      for (int[] map : elem.map) {
        newMap.add(M(map,cur));
      }
    }
    this.xNodes = newMap;
    this.symmetries = newMap.size();
  }
    


  //****************************************************** SYMMETRY OPERATIONS

  /**
   * Get the node map resulting from rotateing around a bar.
   */
  public int[] getMapBar(int n1, int n2, int[] nodes) {
    return conjugate(reorient(new int[]{n1, n2}), xB);
  }

  /**
   * Apply 180 degrees around a bar to this symmetry object.
   */
  public Symmetry rorateBar(Bar bar) {
    return rotateBar(bar.node1.index, bar.node2.index);
  }
  

  public Symmetry rotateBar(Bar bar) {
    return rotateBar(bar.node1.index, bar.node2.index);
  }

  public Symmetry rotateBar(int n1, int n2) {
    Element elem = new Element(Generator.BAR, new int[]{n1,n2});
    int[][] map = new int[symmetries][];
    for (int s = 0; s < symmetries; s++) {
      map[s] = getMapBar(n1, n2, xNodes.get(s));
    }
    elem.setMap(map);
    addElement(elem);
    return this;
  }
  
  //****************************************************************** METHODS

  /**
   * Clear the symmetry color template for the next frame
   */
  public void clear() {
    template = new int[points.size()];
    //template = new LinkedList<Integer>();
  }

  /**
   * Draw the template symmetrically into colors.
   */

  public void draw(int[] colors) {

    out("Drawing Symmetry Pattern\n");

    out("Loading %d Symmetric Bars\n", symmetries);
    int colored = 0;
    for (int i = 0; i < template.length; i++) {
      if (template[i] != 0) {
        colored++;
      }
    }
    out("--Found %d colored template pixels\n", colored);

    colored = 0;
    for (Bar refBar : model.bars) {

      int[] indexes = refBar.getPointIndexes();
      Bar[] symBars = getSymmetricBars(refBar);
      int refPoint, symPoint;
      
      for (int i = 0; i < indexes.length; i++) {
        refPoint = indexes[i];
        if (template[indexes[i]] != 0) {
          colored++;
          for (Bar symBar : symBars) {
            symPoint = symBar.points.get(i).index;
            colors[symPoint] = template[refPoint];
          }
        }
      }
    }
    out("--Found %d colored bar pixels\n", colored);
    clear();
  }


  public Node[] getSymmetricNodes(Node refNode) {
    Node[] symNodes = new Node[symmetries];
    for (int i = 0; i < symmetries; i++) {
      symNodes[i] = nodes[xNodes.get(i)[refNode.index]];
    }
    return symNodes;
  }

  public Bar[] getSymmetricBars(Bar refBar) {
    out("  Ref Bar    [%2d][%2d]\n", refBar.node1.index, refBar.node2.index);
    Node[] symNodes1 = getSymmetricNodes(refBar.node1);
    Node[] symNodes2 = getSymmetricNodes(refBar.node2);
    
    Bar[] symBars = new Bar[symmetries];
    Bar symBar;
    for (int i = 0; i < symmetries; i++) {
      symBar = model.getBar(symNodes1[i], symNodes2[i]);
      symBars[i] = symBar;
      out("  Sym Bar %2d [%2d][%2d]\n", i, symBar.node1.index, symBar.node2.index);
    }
    return symBars;
  }
}





