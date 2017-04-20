/**
 * This is a very basic model class that is a 3-D matrix
 * of points. The model contains just one fixture.
 */
//import java.util.*;

/*
import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
*/




/* Extraction of desired methods and traversals
 *
 * model.getRandomNode()
 * model.getRandomLayer()
 * node.getBars()
 * node.getBars(Layer)
 * 
 *
 */


public enum Layer { Face, Cubic, TetraL, TetraR, Frabjous }

static class Model extends PolyGraph{
  
  public final PolyGraph faces;
  public final PolyGraph tetraL;
  public final PolyGraph tetraR;

  public Model(Node[] nodes, 
               PolyGraph faces, 
               PolyGraph tetraL, 
               PolyGraph tetraR) {
    super(nodes, new PolyGraph[]{faces, tetraL, tetraR});
    this.faces = faces;
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

}


