

/* Extraction of desired methods and traversals
 *
 * model.getRandomNode()
 * model.getRandomLayer()
 * node.getBars()
 * node.getBars(Layer)
 * 
 *
 */


public enum Layer { Dodecahedron, Cubic, TetraL, TetraR, Frabjous }

public static class MimsyModel extends PolyGraph{
  
  public final PolyGraph dodecahedron;
  public final PolyGraph tetraL;
  public final PolyGraph tetraR;

  public MimsyModel(Node[] nodes, 
               PolyGraph dodecahedron, 
               PolyGraph tetraL, 
               PolyGraph tetraR) {
    super(nodes, new PolyGraph[]{dodecahedron, tetraL, tetraR});
    this.dodecahedron = dodecahedron;
    this.tetraL = tetraL;
    this.tetraR = tetraR;
  }





  /**
   * Currently there is only one layer, so this is easy.
   */
  public Layer getRandomLayer() {
    return Layer.TetraL;
  }



  //******************************************************** GET RANDOM POINTS
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

  /*
   * Select a Bar matching given properties
   */
  public Bar selectBar() {
    Random r = new Random();
    return bars[r.nextInt(bars.length)];
  }




  //******************************************************************* GRAPHS

  /*
   * Select graphs matching given properties
   */
  public PolyGraph selectGraph() {
    Random r = new Random();
    return subGraphs.get(r.nextInt(subGraphs.size()));
  }



}


