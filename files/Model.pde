

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




}


