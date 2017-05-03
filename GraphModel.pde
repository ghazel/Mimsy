public static class PolyGraph extends LXModel {

  //public String name;
  public boolean isCompound = false;
  public Node[] nodes;
  public Bar[] bars;
  public List<PolyGraph> subGraphs = new ArrayList<PolyGraph>();
  public String layer;
  public List<String> layers = new ArrayList<String>();

  //************************************************************* CONSTRUCTORS
  
  /*
   * Empty
   */
  public PolyGraph() {
    super();
    nodes = new Node[0];
    bars = new Bar[0];
  }

  /*
   * Known Nodes and Bars
   */
  public PolyGraph(Node[] nodes, Bar[] bars) {
    super(extractFixtures(bars));
    this.nodes = nodes;
    this.bars = bars;
  }
  
  /*
   * Compose from subgraphs
   */
  public PolyGraph(Node[] nodes, PolyGraph[] graphs) {
   this(nodes, PolyGraph.extractBars(graphs));
   this.addSubGraphs(graphs);
  }

  
  
  //**************************************************************** FACTORIES
  
  /*
   * Compose from an ordered traversal of nodes
   */
  public static PolyGraph fromNodes(Node[] nodes, int[][] ordering) {
    Bar[] bars = new Bar[ordering.length];
    for (int b = 0; b < ordering.length; b++) { 
      Node n1 = nodes[ordering[b][0]];
      Node n2 = nodes[ordering[b][1]];
      Bar bar = new Bar(n1, n2);
      bars[b] = bar;
    } 
    return new PolyGraph(nodes, bars);
  }

  public static Bar[] extractBars(PolyGraph[] graphs) {
    int bar_count = 0;
    for(PolyGraph graph : graphs) {
      bar_count += graph.bars.length;
    }
    Bar[] bars = new Bar[bar_count];
    int b = 0;
    for(PolyGraph graph : graphs) { 
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
  public PolyGraph markAsCompound() {
    this.isCompound = true;
    return this;
  }

  /**
   * Set the name of this graph layer
   */
  public PolyGraph setLayer(String layer) {
    this.layer = layer;
    return this;
  }

  /**
   * Add subgraphs to the model
   */
  public PolyGraph addSubGraph(PolyGraph graph) { 
    this.layers.add(graph.layer);
    this.subGraphs.add(graph);
    return this;
  }

  public PolyGraph addSubGraphs(PolyGraph[] graphs) {
    for (PolyGraph graph : graphs) {
      this.addSubGraph(graph);
    }
    return this;
  }


}



public static class Symmetry {

  Symmetry(){}

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
  public boolean reversed;
  public Bar parent;

  /** 
   * Full Constructor 
   */
  public Bar(Node node1, Node node2, boolean reversed) {
    super(new Fixture(node1, node2, reversed));
    this.name     = node1.name + "-" + node2.name;
    this.node1    = node1;
    this.node2    = node2;
    this.tags     = new ArrayList<String>();
    this.reversed = reversed;
  }



  /**
   * Typical constructor
   */
  public Bar(Node node1, Node node2) {
    this(node1, node2, false);
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
    this.name = parent.name;
    this.tags = parent.tags;
    this.reversed = reversed;
    
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
    return new Bar(this, true);
  }


  private static class Fixture extends LXAbstractFixture {

    private Fixture(List<LXPoint> points, boolean reversed) {
      for (LXPoint p : points) {
        this.points.add(p); }
      if (reversed) {
        Collections.reverse(this.points); }
    }

    private Fixture(Node node1, Node node2, boolean reversed) {
      if (reversed) {
        Node node_;
        node_ = node2;
        node2 = node1;
        node1 = node_;
      }

      PVector point;
      int steps = PIXELS_PER_BAR + 2 * PIXEL_NODE_BUFFER;
      float delta = 1.0 / (float)steps;
        
      System.out.format(" ++ Lerp nodes - %8.2f %8.2f %8.2f - %8.2f %8.2f %8.2f\n",
        node1.x, node1.y, node1.z, node2.x, node2.y, node2.z);

      for (float p = PIXEL_NODE_BUFFER; p < steps; p++) {
        point = PVector.lerp(node1, node2, p * delta);
        LXPoint _point = new LXPoint(point.x, point.y, point.z);
        this.points.add(_point);
        //System.out.format(" ++++ Point %5d - %8.2f %8.2f %8.2f - %8.2f %8.2f %8.2f\n",
        //  _point.index, point.x, point.y, point.z, _point.x, _point.y, _point.z);
      }
    }
  }
}



public static LXFixture[] extractFixtures(Bar[] bars) {
  System.out.format(" <--- extractFixtures %d\n", bars.length);
  LXFixture[] fixtures = (LXFixture[]) bars;
  return fixtures;
}


