/** Pattern Ideas.
 *
 * Tracers extend from a single node along all bars of dodecahedron.
 * Split and recombine at each node but keep tracing greater graph distance. 
 * Color bars/points as a function of graph distance. Sparkle tetrahedra bars
 * whenever getting to a point connecting back to first node (i.e. at graph
 * distance 3). Color Tetrahedra by lerp from node colors.
 *
 */



public abstract class GraphPattern extends LXPattern {

  GraphModel model;

  protected GraphPattern(LX lx) {
    super(lx);
    this.model = (GraphModel) lx.model;    
  }

  public void fade(List<LXPoint> points, float fade) {
    for (LXPoint p : points) {
      colors[p.index] =
        LXColor.scaleBrightness(colors[p.index], fade);
    }      
  }


}



//*********************************************************** SYMMETRY PATTERN




class SymmetryPattern extends GraphPattern {

  /*
  private final BoundedParameter barRate 
    = new BoundedParameter("BAR",  5000, 0, 60000);
  private final BoundedParameter nodeRate 
    = new BoundedParameter("NODE",  5000, 0, 60000);
  private final BoundedParameter faceRate 
    = new BoundedParameter("FACE",  5000, 0, 60000);
  */


  private final BoundedParameter runRate 
    = new BoundedParameter("RUN",  5000, 0, 60000);
  private final BoundedParameter spinRate 
    = new BoundedParameter("SPIN",  100.0, 1.0, 10000.0);
  private final BoundedParameter fadeRate =
    new BoundedParameter("FADE", 0.1, 0.0, 1.0);
  private final SinLFO barPos = new SinLFO(0.0, 1.0, runRate);
  
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
  List<GraphModel> TLModels = new ArrayList<GraphModel>();
  List<GraphModel> TRModels = new ArrayList<GraphModel>();
  // Want the first bar of each tetrahedra
  List<Bar> TLBars = new ArrayList<Bar>();
  List<Bar> TRBars = new ArrayList<Bar>();
  
  LXPoint point;
  double totalMs;
  double lastSpin;
  double lastSwitch;
  double lastReset;
  int nodeI = 0;
  boolean toggle = false;
  float hue =   0.0;
  float sat = 100.0;
  float brt = 100.0;

  int barPosI;
  int lastBarPosI;
  Bar symBar;
  Element symBarE;



  Symmetry sym = new Symmetry(model);
  Element baseFace = sym.rotateFace(0, 1, 0);

  SymmetryPattern(LX lx) {
    super(lx);
    //addParameter(barRate);
    //addParameter(nodeRate);
    //addParameter(faceRate);
    
    addParameter(runRate);
    addParameter(spinRate);
    addParameter(fadeRate);
    addModulator(barPos).start();

    addParameter(colorSpread);
    addParameter(colorSaturation);
    addParameter(colorSaturationRange);
    addParameter(colorBrightness);
    addParameter(colorBrightnessRange);

    for (GraphModel g: model.getLayer(TL).subGraphs) { 
      tetrahedra.add(g);
      TLModels.add(g);
      TLBars.add(g.bars[0]);
    }
    for (GraphModel g: model.getLayer(TR).subGraphs) { 
      tetrahedra.add(g);
      TRModels.add(g);
      TRBars.add(g.bars[0]);
    }

    baseFace.bloom();

  }

  public void run(double deltaMs) {

    totalMs += deltaMs;
    fade(model.points, 1.0 - (fadeRate.getValuef() * (float)deltaMs / 1000.0));

    float dHue = colorSpread.getValuef();
    float bSat = colorSaturation.getValuef();
    float dSat = colorSaturationRange.getValuef();
    float bBrt = colorBrightness.getValuef();
    float dBrt = colorBrightnessRange.getValuef();

    hue = (hue + dHue * (float)deltaMs / 1000.0) % 360.0;


    float delayReset = 60000; 
    float delaySwitch = 5000;
    // Reset symmetry
    if ((totalMs - lastReset) > delayReset) {
      sym.reset();
      lastReset = totalMs;
    }

    //if ((totalMs - lastSwitch) > delaySwitch) {
    //  switchBar();
    //}





    // Spin the point around
    /*
    float spinMs = 10.0 / (float)Math.log(spinRate.getValuef());
    out("Spinning after %.2f Ms (%.2f)", spinMs, totalMs-lastSpin);
    if ((totalMs-lastSpin) > spinMs) {
      out("!! SPIN !!");
      baseFace.addStep();
      lastSpin = totalMs;
    }
    */

    Bar bar = TLBars.get(0);
    barPosI = (int)Math.floor(barPos.getValuef() * (float)bar.points.size());
    barPosI = LXUtils.constrain(barPosI, 0, bar.points.size()-1);
    for (int i = lastBarPosI; i <= barPosI; i++) {
      LXPoint point = bar.points.get(i);
      int c = lx.hsb(hue,sat,brt);
      sym.template[point.index] = c;
    }
    lastBarPosI = barPosI;
    if (barPosI == 0) {
      switchBar();
    }
    if (barPosI >= (bar.points.size() - 1)) {
      switchBar();
    }

    //for (LXPoint p: bar.points) {
      //colors[p.index] = lx.hsb(hue,sat,brt);
      //out("Coloring pixel %d #%h\n", p.index, c);
    //}
    sym.draw(colors);

  }

  void switchBar() {
    sym.pop();
    symBar = model.getRandomBar();
    symBarE = sym.rotateBar(symBar);
    lastSwitch = totalMs;
    sym.push(baseFace);
  }

}

//****************************************************** SYMMETRY TEST PATTERN


class SymmetryTestPattern extends GraphPattern {
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
  double diffMs;
  double totalMs;
  double lastSwitch;
  int nodeI = 0;
  boolean toggle = false;
  float hue =   0.0;
  float sat = 100.0;
  float brt = 100.0;


  Symmetry sym = new Symmetry(model);

  SymmetryTestPattern(LX lx) {
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

    float dHue = colorSpread.getValuef();
    float bSat = colorSaturation.getValuef();
    float dSat = colorSaturationRange.getValuef();
    float bBrt = colorBrightness.getValuef();
    float dBrt = colorBrightnessRange.getValuef();

    int symBarI = 0;
    Bar symBar;
    Node symNode;
    Element symBarE;
    Element symNodeE;
    diffMs += deltaMs;
    totalMs += deltaMs;
    

    // Switch nodes every 30 seconds
    if ((totalMs - lastSwitch) > 30000) {
      sym.reset();
      nodeI = (nodeI + 1) % model.nodes.length;
      lastSwitch = totalMs;
    }

    if (diffMs >= 1000) {
      hue = (hue + dHue) % 360.0;
      if (toggle) {
        symBar = model.getRandomBar();
        symBarE = sym.rotateBar(symBar);
        //symBarE.setStep(new int[]{0,1});
      } else if (deltaMs < 2000) {
        //symNode = model.getRandomNode();
        symNode = model.nodes[nodeI];
        symNodeE = sym.rotateNode(symNode);
        symNodeE.setStep(new int[]{0,1,2});
      }

      toggle = !toggle;
      diffMs = 0.0;
    }
    
    /*
    for (int i = 0; i < colors.length; i++) { 
      colors[i] = lx.hsb(0.0, 0.0, 0.0);
    }
    */

    GraphModel tetra = tetrahedra.get(0);
    Bar bar = tetra.bars[0];
    for (LXPoint p: bar.points) {
      //colors[p.index] = lx.hsb(hue,sat,brt);
      int c = lx.hsb(hue,sat,brt);
      sym.template[p.index] = c;
      //out("Coloring pixel %d #%h\n", p.index, c);
    }
    sym.draw(colors);

    /*
    for (int t = 0; t<tetrahedra.size(); t++) {
      GraphModel tetra = tetrahedra.get(t);
      float db = dBrt / (float)tetra.bars.length ;
      float ds = dSat / (float)tetra.bars.length ;
      hue = (float)t * dHue + baseHue;
      for (int b = 0; b < tetra.bars.length; b++) {
        sat = LXUtils.constrainf(bSat - (float)b * ds, 0., 100.);
        brt = LXUtils.constrainf(bBrt + (float)b * db, 0., 100.);
        Bar bar = tetra.bars[b];
        //int last_point = 0;
        for (LXPoint p: bar.points) {
          colors[p.index] = lx.hsb(hue,sat,brt);
          //last_point = p.index;
        }
        //colors[last_point] = -1;
      }
    }
    */
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
        //int last_point = 0;
        for (LXPoint p: bar.points) {
          colors[p.index] = lx.hsb(hue,sat,brt);
          //last_point = p.index;
        }
        //colors[last_point] = -1;
      }
    }
  }
}



/** ********************************************************* TETRAHEDRON TEST
 * Light each tetrahedron a different color, and blank the black pixel
 ****************************************************************************/

class TetrahedronTest extends GraphPattern {
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

  TetrahedronTest(LX lx) {
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
      if (t>=2 && t<5) { continue; }
      if (t>=7 && t<10) { continue; }
      GraphModel tetra = tetrahedra.get(t);
      float db = dBrt / (float)tetra.bars.length ;
      float ds = dSat / (float)tetra.bars.length ;
      hue = (float)t * dHue + baseHue;
      sat = LXUtils.constrainf(bSat - (float)t * ds, 0., 100.);
      brt = LXUtils.constrainf(bBrt + (float)t * db, 0., 100.);
      for (int b = 0; b < tetra.bars.length; b++) {
        Bar bar = tetra.bars[b];
        //int last_point = 0;
        for (LXPoint p: bar.points) {
          colors[p.index] = lx.hsb(hue,sat,brt);
          //last_point = p.index;
        }
        //colors[last_point] = -1;
      }
    }
  }
}






/** ********************************************************* TETRAHEDRON TEST
 * Light each tetrahedron a different color, and blank the black pixel
 ****************************************************************************/

/*
class TetrahedronTest extends LXPattern {
  private final BoundedParameter colorSpread
      = new BoundedParameter("CLR", 60.0, 0.0, 360.0);
  private final BoundedParameter cycleSpeed 
      = new BoundedParameter("SPD",  1., 0., 20.);
  //private final ColorParameter clr
  //    = new ColorParameter("COLOR", LXColor.hsb(Math.random() * 360, 100, 100));
  //private final FunctionalParameter period = new FunctionalParameter() {
  //  @Override
  //  public double getValue() {
  //    return (1000 / speed.getValue()) * lx.total;
  //  }
  //};

  private float baseHue = 0.0;
  private int pixelsPerChannel = 123;
  private int channelCount = 5;

  TetrahedronTest(LX lx) {
    super(lx);
    addParameter(colorSpread);
    addParameter(cycleSpeed);
    //addParameter(clr);
  }

  public void run(double deltaMs) {
    int pixel = 0;
    float hue = 0.0;
    baseHue += Math.log(cycleSpeed.getValuef());
    baseHue %= 360.;    
    for (int channel = 0; channel < channelCount; channel++) {
      hue = (float)channel * (float)colorSpread.getValue() + baseHue;
      for (int p = 0; p < pixelsPerChannel; p++) { 
        colors[pixel++] = lx.hsb(hue,100.,30.);
      }
    }
  }
}

*/

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
      colors[p.index] = LXColor.hsb(0.0,0.0,40.0);
    }
    for (LXPoint p: model.getLayer(TL).points) {
      colors[p.index] = LXColor.hsb(0.0,0.0,20.0);
    }
    for (LXPoint p: model.getLayer(TR).points) {
      colors[p.index] = LXColor.hsb(0.0,0.0,20.0);
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




/** ****************************************************** Dodecahedron MAPPING
 * Show the mapping for a single channel of a tetrahedron.
 ****************************************************************************/

class MappingDodecahedron extends GraphPattern {

  float hueRange = 270.f;
  //float dHue     =  30.f;
  float baseHue  =  0.f;
  float baseSat  = 80.f;
  float baseBrt  = 90.f;

  LXPoint point;

  MappingDodecahedron(LX lx) {
    super(lx);
    //for (GraphModel g: model.tetraL.subGraphs) { tetrahedra.add(g); }
    //for (GraphModel g: model.tetraR.subGraphs) { tetrahedra.add(g); }
  }

  public void run(double deltaMs) {

    for (LXPoint p: model.getLayer(DD).points) {
      colors[p.index] = LXColor.hsb(0.0,0.0,40.0);
    }
    for (LXPoint p: model.getLayer(TL).points) {
      colors[p.index] = LXColor.hsb(0.0,0.0,20.0);
    }
    for (LXPoint p: model.getLayer(TR).points) {
      colors[p.index] = LXColor.hsb(0.0,0.0,20.0);
    }

    GraphModel dodeca = model.getLayer(DD);
    //GraphModel tetraL = model.getLayer(TL).getLayer(0);
    //GraphModel tetraR = model.getLayer(TR).getLayer(0);
    Bar bar0 = dodeca.bars[0];
    //float dHue = hueRange / ((float)dodeca.bars.length) / ((float)bar0.points.size());
    //float dHue = hueRange / ((float)dodeca.bars.length);
    float dHue = 30.0;
    float hue = 0.0;
    for (int b = 0; b < dodeca.bars.length; b++) {
      if (b >= 6) { continue; }
      Bar bar = dodeca.bars[b];
      for (LXPoint p: bar.points) {
        colors[p.index] = lx.hsb(hue,baseSat,baseBrt);
      }
      hue += dHue;
    }
  }
}


/** ********************************************************** TEST BAR MATRIX
 *
 ****************************************************************************/

class TestBarMatrix extends GraphPattern {
  
  private final DiscreteParameter method = new DiscreteParameter("GEN", 1, 1, 5);
  private final BoundedParameter speed = new BoundedParameter("SPD",  5000, 0, 10000);
  private final BoundedParameter fadeRate =
    new BoundedParameter("FADE", 10.0, 0.0, 1000.0);

  //private final SinLFO xPeriod = new SinLFO(100, 1000, 10000); 
  private final SinLFO position = new SinLFO(0.0, 1.0, speed);
  
  
  float thisPos = 0.0;
  float lastPos = 0.0;
  float hueRange = 270.f;
  //float dHue     =  30.f;
  float baseHue  =  0.f;
  float baseSat  = 80.f;
  float baseBrt  = 90.f;

  LXPoint point;

  TestBarMatrix(LX lx) {
    super(lx);
    addParameter(method);
    addParameter(speed);
    addParameter(fadeRate);
    addModulator(position).start();
    //for (GraphModel g: model.tetraL.subGraphs) { tetrahedra.add(g); }
    //for (GraphModel g: model.tetraR.subGraphs) { tetrahedra.add(g); }
  }

  public void run(double deltaMs) {

    float hue = 0.0;
    float sat = 100.0;
    float brt = 100.0;

    thisPos = position.getValuef();
    boolean rev = thisPos >= lastPos;
    lastPos = thisPos;

    // Fade everything
    fade(model.points, fadeRate.getValuef() * (float)deltaMs / 1000.0);

    int M = method.getValuei();
    
    // Chase up one bar and back down its reverse
    if (M == 1) {
      int i, s;
      for (Bar _bar : model.bars) {
        Bar bar = _bar;
        s = bar.points.size();
        i = LXUtils.constrain((int)((float)s * thisPos), 0, s-1);
        if (rev) { 
          bar = _bar.reversed();
          hue = 270.0;
          i = s-i-1;
        }
        //System.out.format("Bar[%2d][%2d] R: %s   P: %8.2f   S: %3d   I: %3d\n",
        //  bar.node1.index, bar.node2.index, rev, thisPos, s, i);
        colors[bar.points.get(i).index] = lx.hsb(hue,sat,brt);
      }
    
    // Chase up one bar and back down its reverse by looking it up in barMatrix
    } else if (M == 2) {
      int i, s;
      for (Bar _bar : model.bars) {
        Bar bar = _bar;
        s = bar.points.size();
        i = LXUtils.constrain((int)((float)s * thisPos), 0, s-1);
        if (rev) { 
          bar = model.getBar(bar.node2, bar.node1);
          hue = 270.0;
          i = s-i-1;
        }
        //System.out.format("Bar[%2d][%2d] R: %s   P: %8.2f   S: %3d   I: %3d\n",
        //  bar.node1.index, bar.node2.index, rev, thisPos, s, i);
        colors[bar.points.get(i).index] = lx.hsb(hue,sat,brt);
      }
     
    // Color by bar direction
    } else if (M == 3) {
      for (Bar bar : model.bars) {
        if (bar.node1.index < bar.node2.index) {
          for (LXPoint p: bar.points) {
            colors[p.index]= lx.hsb(0.0, baseSat, baseBrt); 
          }
        } else {
          for (LXPoint p: bar.points) {
            colors[p.index]= lx.hsb(180.0, baseSat, baseBrt); 
          }
        }
      }
    }

  }
}








/** *********************************************** SYMMETRY TEST ROTATE FACES
 * Apply a test pattern to a tetrahedron, then iteratively rotate it around
 * faces.
 *
 * ---------------------------------------------------------------------------
 * - Instantiate a Symmetry object for Mimsy
 * -- By default, initial operation is to Rotate 0 times around Face 0
 * - Draw the test pattern into the Template
 * - Have Symmetry replicate it across Mimsy
 * - Every period, add a random rotation around a random Face
 *
 * **************************************************************************/



class TetraSymmetryFace extends GraphPattern {

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

  TetraSymmetryFace(LX lx) {
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
        //int last_point = 0;
        for (LXPoint p: bar.points) {
          colors[p.index] = lx.hsb(hue,sat,brt);
          //last_point = p.index;
        }
        //colors[last_point] = -1;
      }
    }
  }
}





