public abstract class GraphPattern extends LXPattern {

  GraphModel model;

  protected GraphPattern(LX lx) {
    super(lx);
    this.model = (GraphModel) lx.model;    
  }
}






/** *********************************************************** TETRA BAR TEST
 * Light each bar a different color, and blank the black pixel
 ****************************************************************************/

class TetraBarTest extends GraphPattern {
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


  List<GraphModel> tetrahedra = new ArrayList<GraphModel>();
  LXPoint point;

  TetraBarTest(LX lx) {
    super(lx);
    addParameter(cycleSpeed);
    addParameter(colorSpread);
    addParameter(colorSaturation);
    addParameter(colorSaturationRange);
    addParameter(colorBrightness);
    addParameter(colorBrightnessRange);

    for (GraphModel g: model.getLayer(TR).subGraphs) { tetrahedra.add(g); }
    for (GraphModel g: model.getLayer(TL).subGraphs) { tetrahedra.add(g); }
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
      GraphModel tetra = tetrahedra.get(t);
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



/** *********************************************************** TETRA BAR TEST
 * Light each bar a different color, and blank the black pixel
 ****************************************************************************/


class TetrahedronTest extends LXPattern {
  private final BoundedParameter colorSpread
      = new BoundedParameter("CLR", 60.0, 0.0, 360.0);
  private final BoundedParameter cycleSpeed = new BoundedParameter("SPD",  1., 0., 20.);
  private float baseHue = 0.0;

  private int pixelsPerChannel = 123;
  private int channelCount = 5;

  TetrahedronTest(LX lx) {
    super(lx);
    addParameter(colorSpread);
    addParameter(cycleSpeed);
  }

  public void run(double deltaMs) {
    int pixel = 0;
    float hue = 0.0;
    baseHue += cycleSpeed.getValuef();
    baseHue %= 360.;    
    for (int channel = 0; channel < channelCount; channel++) {
      hue = (float)channel * (float)colorSpread.getValue() + baseHue;
      for (int p = 0; p < pixelsPerChannel; p++) { 
        colors[pixel++] = lx.hsb(hue,100.,30.);
      }
    }
  }
}


/** ****************************************************** TETRAHEDRON MAPPING
 * Show the mapping for a single channel of a tetrahedron.
 ****************************************************************************/

class MappingTetrahedron extends GraphPattern {

  float hueRange = 270.f;
  //float dHue     =  30.f;
  float baseHue  =  0.f;
  float baseSat  = 80.f;
  float baseBrt  = 90.f;

  LXPoint point;

  MappingTetrahedron(LX lx) {
    super(lx);
    //for (GraphModel g: model.tetraL.subGraphs) { tetrahedra.add(g); }
    //for (GraphModel g: model.tetraR.subGraphs) { tetrahedra.add(g); }
  }

  public void run(double deltaMs) {

    for (LXPoint p: model.getLayer(DD).points) {
      colors[p.index] = lx.hsb(0.0,0.0,40.0);
    }
    for (LXPoint p: model.getLayer(TL).points) {
      colors[p.index] = lx.hsb(0.0,0.0,20.0);
    }
    for (LXPoint p: model.getLayer(TR).points) {
      colors[p.index] = lx.hsb(0.0,0.0,20.0);
    }

    GraphModel tetraL = model.getLayer(TL).getLayer(0);
    GraphModel tetraR = model.getLayer(TR).getLayer(0);
    Bar bar0 = tetraL.bars[0];
    float dHue = hueRange / ((float)tetraL.bars.length) / ((float)bar0.points.size());
    float hue = 0.0;
    for (int b = 0; b < tetraL.bars.length; b++) {
      Bar bar = tetraL.bars[b];
      for (LXPoint p: bar.points) {
        colors[p.index] = lx.hsb(hue,baseSat,baseBrt);
        hue += dHue;
      }
    }

    hue = 0.0;
    for (int b = 0; b < tetraR.bars.length; b++) {
      Bar bar = tetraR.bars[b];
      for (LXPoint p: bar.points) {
        colors[p.index] = lx.hsb(hue,baseSat,baseBrt);
        hue += dHue;
      }
    }    
  }
}

