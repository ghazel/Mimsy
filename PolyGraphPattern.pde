public abstract class PolyGraphPattern extends LXPattern {

  PolyGraph model;

  protected PolyGraphPattern(LX lx) {
    super(lx);
    this.model = (PolyGraph) lx.model;    
  }
}






/** *********************************************************** TETRA BAR TEST
 * Light each bar a different color, and blank the black pixel
 ****************************************************************************/

class TetraBarTest extends PolyGraphPattern {
  private final BoundedParameter cycleSpeed 
      = new BoundedParameter("SPD",  5.0, 1.0, 100.0);
  private final BoundedParameter colorSpread
      = new BoundedParameter("dHUE", 30.0, 0.0, 360.0);
  private final BoundedParameter colorSaturation
      = new BoundedParameter("SAT",  70.0, 0.0, 100.0);
  private final BoundedParameter colorSaturationRange
      = new BoundedParameter("dSAT", 50.0, 0.0, 100.0);
  private final BoundedParameter colorBrightness
      = new BoundedParameter("BRT",  30.0, 0.0, 100.0);
  private final BoundedParameter colorBrightnessRange
      = new BoundedParameter("dBRT", 50.0, 0.0, 100.0);
  private float baseHue = 0.0;


  List<PolyGraph> tetrahedra = new ArrayList<PolyGraph>();
  LXPoint point;

  TetraBarTest(LX lx) {
    super(lx);
    addParameter(cycleSpeed);
    addParameter(colorSpread);
    addParameter(colorSaturation);
    addParameter(colorSaturationRange);
    addParameter(colorBrightness);
    addParameter(colorBrightnessRange);

    for (PolyGraph g: model.getLayer(TR).subGraphs) { tetrahedra.add(g); }
    for (PolyGraph g: model.getLayer(TL).subGraphs) { tetrahedra.add(g); }
  }

  public void run(double deltaMs) {
    float hue = 0.;
    float sat = 0.;
    float brt = 0.;
    
    float dHue = colorSpread.getValuef();
    float bSat = colorSaturation.getValuef();
    float dSat = colorSaturationRange.getValuef();
    float bBrt = colorBrightness.getValuef();
    float dBrt = colorBrightnessRange.getValuef();

    baseHue += Math.log(cycleSpeed.getValuef());
    baseHue %= 360.;
    
    for (int t = 0; t<tetrahedra.size(); t++) {
      PolyGraph tetra = tetrahedra.get(t);
      float db = dBrt / (float)tetra.bars.length ;
      float ds = dSat / (float)tetra.bars.length ;
      hue = (float)t * dHue + baseHue;
      for (int b = 0; b < tetra.bars.length; b++) {
        sat = LXUtils.constrainf(bSat - (float)b * ds, 0., 100.);
        brt = LXUtils.constrainf(bBrt + (float)b * db, 0., 100.);
        Bar bar = tetra.bars[b];
        for (LXPoint p: bar.points) {
          colors[p.index] = lx.hsb(hue,sat,brt);
        }
      }
    }
  }
}



/** ****************************************************** TETRAHEDRON MAPPING
 * Show the mapping for a single channel of a tetrahedron.
 ****************************************************************************/

class MappingTetrahedron extends PolyGraphPattern {

  float hueRange = 270.f;
  //float dHue     =  30.f;
  float baseHue  =  0.f;
  float baseSat  = 80.f;
  float baseBrt  = 90.f;

  LXPoint point;

  MappingTetrahedron(LX lx) {
    super(lx);
    //for (PolyGraph g: model.tetraL.subGraphs) { tetrahedra.add(g); }
    //for (PolyGraph g: model.tetraR.subGraphs) { tetrahedra.add(g); }
  }

  public void run(double deltaMs) {

    for (LXPoint p: model.getLayer(DD).points) {
      colors[p.index] = lx.hsb(0.0,0.0,40.0);
    }
    for (LXPoint p: model.getLayer(TL).points) {
      colors[p.index] = lx.hsb(0.0,0.0,20.0);
    }
    for (LXPoint p: model.getLayer(TR).points) {
      colors[p.index] = lx.hsb(225.0,20.0,40.0);
    }

    PolyGraph tetraL = model.getLayer(TL).getLayer(0);
    //PolyGraph tetraR = model.tetraR.subGraphs.get(0);
    Bar bar0 = tetraL.bars[0];
    float dHue = hueRange / ((float)tetraL.bars.length) / ((float)bar0.points.size());
    float hue = 0.0;

    for (int b = 0; b < tetraL.bars.length; b++) {
      Bar bar = tetraL.bars[b];
      //hue = dHue * (float) b;
      for (LXPoint p: bar.points) {
        colors[p.index] = lx.hsb(hue,baseSat,baseBrt);
        hue += dHue;
      }
    }
    /*
    hue = 180.0;
    for (int b = 0; b < tetraR.bars.length; b++) {
      Bar bar = tetraR.bars[b];
      //hue = dHue * (float) b;
      for (LXPoint p: bar.points) {
        colors[p.index] = lx.hsb(hue,baseSat,baseBrt);
        hue += dHue;
      }
    }
    */
  }
}

