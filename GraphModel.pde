public static class GraphModel extends LXModel {

  //public String name;
  public boolean isCompound = false;
  public Node[] nodes;
  public Bar[] bars;
  public List<GraphModel> subGraphs = new ArrayList<GraphModel>();
  public String layer;
  public List<String> layers = new ArrayList<String>();
 
  // Connectivity matrix for looking up bars by (ordered) node pair
  private Bar[][] barMatrix;

  //************************************************************* CONSTRUCTORS
  
  /*
   * Empty
   */
  public GraphModel() {
    super();
    this.nodes = new Node[0];
    this.bars = new Bar[0];
    this.barMatrix = new Bar[0][0];
  }

  /*
   * Known Nodes and Bars
   */
  public GraphModel(Node[] nodes, Bar[] bars) {
    super(extractFixtures(bars));
    this.nodes = nodes;
    this.bars = bars;
    this.addBarsToMatrix();
  }
  
  /*
   * Compose from subgraphs
   */
  public GraphModel(Node[] nodes, GraphModel[] graphs) {
   this(nodes, GraphModel.extractBars(graphs));
   this.addSubGraphs(graphs);
   // TODO: Copy bars into main graph
  }

  
  
  //**************************************************************** FACTORIES
  
  /*
   * Compose from an ordered traversal of nodes
   */
  public static GraphModel fromNodes(Node[] nodes, int[][] ordering) {
    Bar[] bars = new Bar[ordering.length];
    for (int b = 0; b < ordering.length; b++) {
      Node n1 = nodes[ordering[b][0]];
      Node n2 = nodes[ordering[b][1]];
      System.out.format("Bar [%d]: %2d %2d / %2s %2s\n", 
        b, n1.index, n2.index, dd.nodeNames[n1.index], dd.nodeNames[n2.index]);
      Bar bar = new Bar(n1, n2);
      bars[b] = bar;
    }
    System.out.format("\n");
    return new GraphModel(nodes, bars);
  }

  public static Bar[] extractBars(GraphModel[] graphs) {
    int bar_count = 0;
    for(GraphModel graph : graphs) {
      bar_count += graph.bars.length;
    }
    Bar[] bars = new Bar[bar_count];
    int b = 0;
    for(GraphModel graph : graphs) { 
      for(Bar bar : graph.bars) {
        bars[b++] = bar;
      }
    }
    return bars;
  }
   

  //****************************************************************** SETTERS
  /**
   * Indicate that this is a compound of identical subgraphs
   */
  public GraphModel markAsCompound() {
    this.isCompound = true;
    return this;
  }

  /**
   * Set the name of this graph layer
   */
  public GraphModel setLayer(String layer) {
    this.layer = layer;
    return this;
  }


  /**
   * Add subgraphs to the model
   */
  public GraphModel addSubGraph(GraphModel graph) { 
    this.layers.add(graph.layer);
    this.subGraphs.add(graph);
    this.addBarsToMatrix();
    return this;
  }

  public GraphModel addSubGraphs(GraphModel[] graphs) {
    for (GraphModel graph : graphs) {
      this.addSubGraph(graph);
    }
    return this;
  }


  //******************************************************************* LAYERS
  /**
   * Get Layer
   */
  public GraphModel getLayer(String layer) {
    int index = layers.indexOf(layer);
    if (index < 0) {
      System.out.format("!! Could not find layer named '%s'.\n", layer);
    }
    return subGraphs.get(index);
  }

  public GraphModel getLayer(int index) {
    return subGraphs.get(index);
  }

  public GraphModel getLayer() {
    Random randomized = new Random();
    return subGraphs.get(randomized.nextInt(subGraphs.size()));
  }

  public List<GraphModel> getLayers() {
    return subGraphs;
  }


  //******************************************************************* POINTS
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



  //********************************************************************* BARS

  public Node getRandomNode() {
    Random randomized = new Random();
    return nodes[randomized.nextInt(nodes.length)];
  }


  public Bar getRandomBar() {
    Random randomized = new Random();
    return bars[randomized.nextInt(bars.length)];
  }


  private void addBarsToMatrix() {
    if (barMatrix == null) {
      System.out.format("CREATING BAR MATRIX [%d]\n", nodes.length);
      // TODO: This should be this.nodes.length, but doing a crazy hack
      // for now because tetrahedra only have 4 of the nodes, and those
      // aren't consistent with the full context!
      barMatrix = new Bar[dd.NODES][dd.NODES];
    }
    for (Bar bar : bars) {
      int n1 = bar.node1.index;
      int n2 = bar.node2.index;
      if (barMatrix[n1][n2] == null) {
        barMatrix[n1][n2] = bar;
        barMatrix[n2][n1] = bar.reversed();
      }
    }
  }
    


  /*
   * Select a Bar matching given properties
   */
  public Bar getBar() {
    Random r = new Random();
    return bars[r.nextInt(bars.length)];
  }

  public Bar getBar(Node node1, Node node2) {
    return getBar(node1.index, node2.index);
  }

  public Bar getBar(int node1, int node2) {
    return this.barMatrix[node1][node2];
  }







}




//********************************************************************* NODE
/**
 * Connection point for bars, usually virtual except to define bars themselves.
 * Name, coordinates, and other properties.
 * Adjacent bars and nodes.
 * Pixel mapping, for effects at nodes?
 *********************************************************************** **/
public static class Node extends PVector{
  private static int counter = 0;
  public int index;
  public String name;
  public List<String> tags;
  //public final float x, y, z;
  //public final PVector xyz;
  //public final List<String> properties = new ArrayList<String>();
  //public final List<Node> adjacent_nodes = new ArrayList<Node>();
  //public final List<Bar> adjacent_bars = new ArrayList<Bar>();
 
  /*
   * Full Constructor 
   */
  public Node(float x, float y, float z) {
    super(x, y, z);
    this.index  = counter++;
    this.tags   = new ArrayList<String>();
    //System.out.format("+ Node %2d - %8.2f %8.2f %8.2f\n",
    //  this.index, this.x, this.y, this.z);
  }

  public Node(float[] xyz) {
    this(xyz[0], xyz[1], xyz[2]);
  }


  /*
   * Set the node name
   */
  public Node setName(String name) {
    this.name = name;
    return this;
  }
}

//********************************************************************** BAR
/**
 * Edges between nodes with strips of LEDs along their length.
 * Name, nodes, direction, and other properties.
 * Adjacent bars.
 * Pixel map, reversed when traversing opposite direction.
 *********************************************************************** **/

public static class Bar extends LXModel {
  public String name;
  public Node node1;
  public Node node2;
  public int channel;
  public List<String> tags;
  public boolean isReversed;
  public Bar parent;
  public Bar reverse;
  public List<Bar> children;

  /** 
   * Full Constructor 
   */
  public Bar(Node node1, Node node2) {
    super(new Fixture(node1, node2));
    this.name       = node1.name + "-" + node2.name;
    this.node1      = node1;
    this.node2      = node2;
    this.tags       = new ArrayList<String>();
    this.isReversed = false;
    this.children   = new ArrayList<Bar>();
  }

  /**
   * Copy Constructor
   */
  public Bar(Bar parent) {
    this(parent, false);
  }

  /**
   * Copy a bar in reverse
   */
  public Bar(Bar parent, boolean reversed) {
    super(new Fixture(parent.points, reversed));
    this.parent = parent;
    parent.reverse = this;
    parent.children.add(this);
    this.name = parent.name;
    this.tags = parent.tags;
    this.isReversed = reversed;
    
    if (reversed) {
      this.node1 = parent.node2;
      this.node2 = parent.node1;
    } else {
      this.node1 = parent.node1;
      this.node2 = parent.node2;
    }
  }

  /**
   * Make a reversed copy of this bar
   */
  public Bar reversed() {
    if (this.reverse != null) {
      return this.reverse;
    }
    return new Bar(this, true);
  }

  /**
   * Get indexes for first and last points in the bar.
   */
  public int[] getPointRange() {
    int min = points.get(0).index;
    int max = points.get(points.size()-1).index;
    return new int[]{min, max};
  }

  public int[] getPointIndexes() {
    int[] indexes = new int[points.size()];
    for (int i = 0; i < points.size(); i++) {
      indexes[i] = points.get(i).index;
    }
    return indexes;
  }


  private static class Fixture extends LXAbstractFixture {

    private Fixture(List<LXPoint> points, boolean reversed) {
      for (LXPoint p : points) {
        this.points.add(p); }
      if (reversed) {
        Collections.reverse(this.points); }
    }

    private Fixture(Node node1, Node node2) {
      PVector point;
      float delta = 1.0 / (float)PIXELS_PER_BAR;
      for (int i = 0; i < PIXELS_PER_BAR; i++) {
        point = PVector.lerp(node1, node2, i * delta);
        LXPoint _point = new LXPoint(point.x, point.y, point.z);
        this.points.add(_point);
      }
    }
  }
}



public static LXFixture[] extractFixtures(Bar[] bars) {
  //System.out.format(" <--- extractFixtures %d\n", bars.length);
  LXFixture[] fixtures = (LXFixture[]) bars;
  return fixtures;
}




