/**
 * This file has a bunch of example patterns, each illustrating the key
 * concepts and tools of the LX framework.
 */
 
class LayerDemoPattern extends LXPattern {
  
  private final BoundedParameter colorSpread = new BoundedParameter("Clr", 0.5, 0, 3);
  private final BoundedParameter stars = new BoundedParameter("Stars", 100, 0, 100);
  
  public LayerDemoPattern(LX lx) {
    super(lx);
    addParameter(colorSpread);
    addParameter(stars);
    addLayer(new CircleLayer(lx));
    addLayer(new RodLayer(lx));
    for (int i = 0; i < 200; ++i) {
      addLayer(new StarLayer(lx));
    }
  }
  
  public void run(double deltaMs) {
    // The layers run automatically
  }
  
  private class CircleLayer extends LXLayer {
    
    private final SinLFO xPeriod = new SinLFO(3400, 7900, 11000); 
    private final SinLFO brightnessX = new SinLFO(model.xMin, model.xMax, xPeriod);
  
    private CircleLayer(LX lx) {
      super(lx);
      addModulator(xPeriod).start();
      addModulator(brightnessX).start();
    }
    
    public void run(double deltaMs) {
      // The layers run automatically
      float falloff = 100 / (4*FEET);
      for (LXPoint p : model.points) {
        float yWave = model.yRange/2 * sin(p.x / model.xRange * PI); 
        float distanceFromCenter = dist(p.x, p.y, model.cx, model.cy);
        float distanceFromBrightness = dist(p.x, abs(p.y - model.cy), brightnessX.getValuef(), yWave);
        colors[p.index] = LXColor.hsb(
          lx.getBaseHuef() + colorSpread.getValuef() * distanceFromCenter,
          100,
          max(0, 100 - falloff*distanceFromBrightness)
        );
      }
    }
  }
  
  private class RodLayer extends LXLayer {
    
    private final SinLFO zPeriod = new SinLFO(2000, 5000, 9000);
    private final SinLFO zPos = new SinLFO(model.zMin, model.zMax, zPeriod);
    
    private RodLayer(LX lx) {
      super(lx);
      addModulator(zPeriod).start();
      addModulator(zPos).start();
    }
    
    public void run(double deltaMs) {
      for (LXPoint p : model.points) {
        float b = 100 - dist(p.x, p.y, model.cx, model.cy) - abs(p.z - zPos.getValuef());
        if (b > 0) {
          addColor(p.index, LXColor.hsb(
            lx.getBaseHuef() + p.z,
            100,
            b
          ));
        }
      }
    }
  }
  
  private class StarLayer extends LXLayer {
    
    private final TriangleLFO maxBright = new TriangleLFO(0, stars, random(2000, 8000));
    private final SinLFO brightness = new SinLFO(-1, maxBright, random(3000, 9000)); 
    
    private int index = 0;
    
    private StarLayer(LX lx) { 
      super(lx);
      addModulator(maxBright).start();
      addModulator(brightness).start();
      pickStar();
    }
    
    private void pickStar() {
      index = (int) random(0, model.size-1);
    }
    
    public void run(double deltaMs) {
      if (brightness.getValuef() <= 0) {
        pickStar();
      } else {
        addColor(index, LXColor.hsb(lx.getBaseHuef(), 50, brightness.getValuef()));
      }
    }
  }
}




/** ************************************************************** PSYCHEDELIC
 * Colors entire brain in modulatable psychadelic color palettes
 * Demo pattern for GeneratorPalette.
 * @author scouras
 ************************************************************************** */
class Psychedelic extends LXPattern {
 
  double ms = 0.0;
  double offset = 0.0;
  private final BoundedParameter colorScheme = new BoundedParameter("SCM", 0, 3);
  private final BoundedParameter cycleSpeed = new BoundedParameter("SPD",  10, 0, 200);
  private final BoundedParameter colorSpread = new BoundedParameter("LEN", 5, 2, 1000);
  private final BoundedParameter colorHue = new BoundedParameter("HUE",  0., 0., 359.);
  private final BoundedParameter colorSat = new BoundedParameter("SAT", 80., 0., 100.);
  private final BoundedParameter colorBrt = new BoundedParameter("BRT", 50., 0., 100.);
  private GeneratorPalette gp = 
      new GeneratorPalette(
          new ColorOffset(0xDD0000).setHue(colorHue)
                                   .setSaturation(colorSat)
                                   .setBrightness(colorBrt),
          //GeneratorPalette.ColorScheme.Complementary,
          GeneratorPalette.ColorScheme.Monochromatic,
          //GeneratorPalette.ColorScheme.Triad,
          //GeneratorPalette.ColorScheme.Analogous,
          100
      );
  private int scheme = 0;
  //private EvolutionUC16 EV = EvolutionUC16.getEvolution(lx);

  public Psychedelic(LX lx) {
    super(lx);
    addParameter(colorScheme);
    addParameter(cycleSpeed);
    addParameter(colorSpread);
    addParameter(colorHue);
    addParameter(colorSat);
    addParameter(colorBrt);
    /*println("Did we find an EV? ");
    println(EV);
    EV.bindKnob(colorHue, 0);
    EV.bindKnob(colorSat, 8);
    EV.bindKnob(colorBrt, 7);
    */
  }
    
    public void run(double deltaMs) {
    int newScheme = (int)Math.floor(colorScheme.getValue());
    if ( newScheme != scheme) { 
      switch(newScheme) { 
        case 0: gp.setScheme(GeneratorPalette.ColorScheme.Analogous); break;
        case 1: gp.setScheme(GeneratorPalette.ColorScheme.Monochromatic); break;
        case 2: gp.setScheme(GeneratorPalette.ColorScheme.Triad); break;
        case 3: gp.setScheme(GeneratorPalette.ColorScheme.Complementary); break;
        }
      scheme = newScheme;
      }

    ms += deltaMs;
    offset += deltaMs*cycleSpeed.getValue()/1000.;
    int steps = (int)colorSpread.getValue();
    if (steps != gp.steps) { 
      gp.setSteps(steps);
    }
    gp.reset((int)offset);
    for (LXPoint p : model.points) {
      colors[p.index] = gp.getColor();
    }
  }
}
  


/** *********************************************************** TETRA BAR TEST
 * Light each bar a different color, and blank the black pixel
 ****************************************************************************/

class TetraBarTest extends LXPattern {
  private final BoundedParameter colorSpread
      = new BoundedParameter("CLR", 30.0, 0.0, 360.0);
  private final BoundedParameter cycleSpeed = new BoundedParameter("SPD",  1., 0., 20.);
  private float baseHue = 0.0;

  private int bars = 30;
  private int pixelsPerBar = 20;
  private int pixelsBetweenBars = 1;

  TetraBarTest(LX lx) {
    super(lx);
    addParameter(colorSpread);
    addParameter(cycleSpeed);
  }

  public void run(double deltaMs) {
    int pixel = 0;
    float hue = 0.;
    baseHue += cycleSpeed.getValuef();
    baseHue %= 360.;
    for (int bar = 0; bar < bars; bar++) {
      hue = (float)bar * (float)colorSpread.getValuef() + baseHue;
      for (int p = 0; p < pixelsPerBar; p++) { 
        colors[pixel++] = lx.hsb(hue,100.,30.);
      }
      if ((bar % 2) == 0) {
        colors[pixel++] = lx.hsb(0,0,0);
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

/** *************************************************************** TETRA SPIN
 * 
 ****************************************************************************/

/*
class TetraSpin extends LXPattern {
  private final BoundedParameter colorSpread
      = new BoundedParameter("CLR", 60.0, 0.0, 360.0);
  private float hue = 0.0;

  private int pixelsPerChannel = 123;
  private int channelCount = 5;

  TetrahedronTest(LX lx) {
    super(lx);
    addParameter(colorSpread);
  }

  public void run(double deltaMs) {
    int pixel = 0;
    baseHue = (new Random()).nextDouble() * 360;
    
    for (int channel = 0; channel < channelCount; channel++) {
      hue = (float)channel * (float)colorSpread.getValue();
      for (int p = 0; p < pixelsPerChannel; p++) { 
        colors[pixel++] = lx.hsb(hue,80.,100.);
      }
    }
  }
}
*/
 
/** ****************************************************** RAINBOW BARREL ROLL
 * A colored plane of light rotates around an axis
 ************************************************************************* **/
class RainbowBarrelRoll extends LXPattern {
   float hoo;
   float anglemod = 0;
    
  public RainbowBarrelRoll(LX lx){
     super(lx);
  }
  
 public void run(double deltaMs) {
     anglemod=anglemod+1;
     if (anglemod > 360){
       anglemod = anglemod % 360;
     }
     
    for (LXPoint p: model.points) {
      //conveniently, hue is on a scale of 0-360
      hoo=((atan(p.x/p.z))*360/PI+anglemod);
      colors[p.index]=lx.hsb(hoo,80,50);
    }
  }
}


/** ***************************************************************** GRADIENT
 * Example class making use of LXPalette's X/Y/Z interpolation to set
 * the color of each point in the model
 * @author Scouras
 ************************************************************************* **/

class GradientPattern extends LXPattern {
  GradientPattern(LX lx) {
    super(lx);
  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      colors[p.index] = palette.getColor(p);
    }
  }
}



/*****************************************************************************
 *    PATTERNS PRIMARILY INTENDED TO DEMO CONCEPTS, BUT NOT BE DISPLAYED
 ****************************************************************************/
class BlankPattern extends LXPattern {
  BlankPattern(LX lx) {
    super(lx);
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
  }
}




/** ************************************************************ CIRCLE BOUNCE
 * A plane bounces up and down the brain, making a circle of color.
 ************************************************************************** */
class CircleBounce extends LXPattern {
  
  private final BoundedParameter bounceSpeed 
      = new BoundedParameter("BNC",  1000, 0, 10000);
  private final BoundedParameter colorSpread 
      = new BoundedParameter("CLR", 0.0, 0.0, 360.0);
  private final BoundedParameter colorFade   
      = new BoundedParameter("FADE", 1, 0.0, 10.0);

  public CircleBounce(LX lx) {
    super(lx);
    addParameter(bounceSpeed);
    addParameter(colorSpread);
    addParameter(colorFade);
    addLayer(new CircleLayer(lx));
  }

  public void run(double deltaMs) {}

  private class CircleLayer extends LXLayer {
    private final SinLFO xPeriod = new SinLFO(model.zMin, model.zMax, bounceSpeed);

    private CircleLayer(LX lx) {
      super(lx);
      addModulator(xPeriod).start();
    }

    public void run(double deltaMs) {
      float falloff = 5.0 / colorFade.getValuef();
      for (LXPoint p : model.points) {
        float distanceFromBrightness = abs(xPeriod.getValuef() - p.z);
        colors[p.index] = LXColor.hsb(
          lx.getBaseHuef() + colorSpread.getValuef(),
          100.0,
          max(0.0, 100.0 - falloff*distanceFromBrightness)
        );
      }
    }
  }
}


/** ************************************************************ PIXIE PATTERN
 * Points of light that chase along the edges.
 *
 * More ideas for later:
 * - Scatter/gather (they swarm around one point, then fly by
 *   divergent paths to another point)
 * - Fireworks (explosion of them coming out of one point)
 * - Multiple colors (maybe just a few in a different color)
 *
 * @author Geoff Schmiddt
 ************************************************************************* **/
/*
class PixiePattern extends LXPattern{
  // How many pixies are zipping around.
  private final BoundedParameter numPixies =
      new BoundedParameter("NUM", 100, 0, 1000);
  // How fast each pixie moves, in pixels per second.
  private final BoundedParameter speed =
      new BoundedParameter("SPD", 60.0, 10.0, 1000.0);
  // How long the trails persist. (Decay factor for the trails, each frame.)
  // XXX really should be scaled by frame time
  private final BoundedParameter fade =
      new BoundedParameter("FADE", 0.9, 0.8, .99);
  // Brightness adjustment factor.
  private final BoundedParameter brightness =
      new BoundedParameter("BRIGHT", 1.0, .25, 2.0);
  private final BoundedParameter colorHue = new BoundedParameter("HUE", 210, 0, 359.0);
  private final BoundedParameter colorSat = new BoundedParameter("SAT", 63.0, 0.0, 100.0);


  class Pixie {
    public Node fromNode, toNode;
    public double offset;
    public int kolor;

    public Pixie() {
    }
  }
  private ArrayList<Pixie> pixies = new ArrayList<Pixie>();

  public PixiePattern(LX lx) {
    super(lx);
    addParameter(numPixies);
    addParameter(fade);
    addParameter(speed);
    addParameter(brightness);
    addParameter(colorHue);
    addParameter(colorSat);

  }

  public void setPixieCount(int count) {
    //make sure all pixies are set to current color
    for (Pixie p : this.pixies) {
      p.kolor = lx.hsb(colorHue.getValuef(), colorSat.getValuef(), 100);
    }
      
    while (this.pixies.size() < count) {
      Pixie p = new Pixie();
      p.fromNode = model.getRandomNode();
      p.toNode = p.fromNode.random_adjacent_node();
      p.kolor = lx.hsb(colorHue.getValuef(), colorSat.getValuef(), 100);
      this.pixies.add(p);
    }
    if (this.pixies.size() > count) {
      this.pixies.subList(count, this.pixies.size()).clear();
    }
  } 

  public void run(double deltaMs) {
    this.setPixieCount(Math.round(numPixies.getValuef()));
    //    System.out.format("FRAME %.2f\n", deltaMs);
    float fadeRate = 0;
    float speedRate = 0;
    if (museActivated) {
      fadeRate = map(muse.getMellow(), 0.0, 1.0, (float)fade.range.min, (float)fade.range.max);
      speedRate = map(muse.getConcentration(), 0.0, 1.0, (float)20.0, 300);
    }
    else {
      fadeRate = fade.getValuef();
      speedRate = speed.getValuef();
    }

    for (LXPoint p : model.points) {
     colors[p.index] =
         LXColor.scaleBrightness(colors[p.index], fadeRate);
    }

    for (Pixie p : this.pixies) {
      double drawOffset = p.offset;
      p.offset += (deltaMs / 1000.0) * speedRate;
      //      System.out.format("from %.2f to %.2f\n", drawOffset, p.offset);

      while (drawOffset < p.offset) {
          //        System.out.format("at %.2f, going to %.2f\n", drawOffset, p.offset);
        List<LXPoint> points = nodeToNodePoints(p.fromNode, p.toNode);

        int index = (int)Math.floor(drawOffset);
        if (index >= points.size()) {
          Node oldFromNode = p.fromNode;
          p.fromNode = p.toNode;
          do {
            p.toNode = p.fromNode.random_adjacent_node();
          } while (angleBetweenThreeNodes(oldFromNode, p.fromNode, p.toNode)
                   < 4*PI/360*3); // don't go back the way we came
          drawOffset -= points.size();
          p.offset -= points.size();
          //          System.out.format("next edge\n");
          continue;
        }

        // How long, notionally, was the pixie at this pixel during
        // this frame? If we are moving at 100 pixels per second, say,
        // then timeHereMs will add up to 1/100th of a second for each
        // pixel in the pixie's path, possibly accumulated over
        // multiple frames.
        double end = Math.min(p.offset, Math.ceil(drawOffset + .000000001));
        double timeHereMs = (end - drawOffset) /
            speedRate * 1000.0;

        LXPoint here = points.get((int)Math.floor(drawOffset));
        //        System.out.format("%.2fms at offset %d\n", timeHereMs, (int)Math.floor(drawOffset));

        addColor(here.index,
                 LXColor.scaleBrightness(p.kolor,
                                         (float)timeHereMs / 1000.0
                                         * speedRate
                                         * brightness.getValuef()));
        drawOffset = end;
      }
    }
  }
}
*/

/** ******************************************************************* STROBE
 * Simple monochrome strobe light.
 * @author Geoff Schmidt
 ************************************************************************* **/

class StrobePattern extends LXPattern{
  private final BoundedParameter speed = new BoundedParameter("SPD",  5000, 0, 10000);
  private final BoundedParameter min = new BoundedParameter("MIN",  60, 10, 500);
  private final BoundedParameter max = new BoundedParameter("MAX",  500, 0, 2000);
  private final BoundedParameter bright = new BoundedParameter("BRT",  50, 0, 100);
  private final SinLFO rate = new SinLFO(min, max, speed);
  private final SquareLFO strobe = new SquareLFO(0, 100, rate);

  private final BoundedParameter saturation =
      new BoundedParameter("SAT", 100, 0, 100);
  // hue rotation in cycles per minute
  private final BoundedParameter hueSpeed = new BoundedParameter("HUE", 15, 0, 120);
  private final LinearEnvelope hue = new LinearEnvelope(0, 360, 0);

  private boolean wasOn = false;
  private int latchedColor = 0;

  public StrobePattern(LX lx) {
    super(lx);
    addParameter(speed);
    addParameter(min);
    addParameter(max);
    addParameter(bright);
    addModulator(rate).start();
    addModulator(strobe).start();
    addParameter(saturation);
    addParameter(hueSpeed);
    hue.setLooping(true);
    addModulator(hue).start();
  }

  public void run(double deltaMs) {
    hue.setPeriod(60 * 1000 / (hueSpeed.getValuef() + .00000001));

    boolean isOn = strobe.getValuef() > .5;
    if (isOn && ! wasOn) {
      latchedColor =
        lx.hsb(hue.getValuef(), saturation.getValuef(), bright.getValuef());
  }
  
    wasOn = isOn;
    int kolor = isOn? latchedColor : LXColor.BLACK;
    for (LXPoint p : model.points) {
      colors[p.index] = kolor;
    }
 }
}




/** ******************************************************************** MOIRE
 * Moire patterns, computed across the actual topology of the brain.
 *
 * Basically this is the classic demoscene Moire effect:
 * http://www.youtube.com/watch?v=XtCW-axRJV8&t=2m54s
 *
 * but distance is defined as the actual shortest path along the bars,
 * so the effect happens across the actual brain structure (rather
 * than a 2D plane).
 *
 * Potential improvements:
 * - Map to a nice color gradient, then run several of these in parallel
 *   (eg, 2 sets of 2 generators, each with a different palette)
 *   and mix the colors
 * - Make it more efficient so you can sustain full framerate even with
 *   higher numbers of generators
 *
 * @author Geoff Schmidt
 ************************************************************************* **/


/*
class MovableDistanceField {
  private LXPoint origin;
  double width;
  int[] distanceField;
  SemiRandomWalk walk;

  LXPoint getOrigin() {
    return origin;
  }

  void setOrigin(LXPoint newOrigin) {
    origin = newOrigin;
    distanceField = distanceFieldFromPoint(origin);
    walk = new SemiRandomWalk(origin);
  }

  void advanceOnWalk(double howFar) {
    origin = walk.step(howFar);
    distanceField = distanceFieldFromPoint(origin);
  }
};

class MoireManifoldPattern extends LXPattern{
  // Stripe width (generator field periodicity), in pixels
  private final BoundedParameter width = new BoundedParameter("WID", 65, 500);
  // Rate of movement of generator centers, in pixels per second
  private final BoundedParameter walkSpeed = new BoundedParameter("SPD", 100, 1000);
  // Number of generators
  private final DiscreteParameter numGenerators =
      new DiscreteParameter("GEN", 2, 1, 8 + 1);
  // Number of generators that are smooth
  private final DiscreteParameter numSmooth =
      new DiscreteParameter("SMOOTH", 2, 0, 8 + 1);

  ArrayList<Generator> generators = new ArrayList<Generator>();

  class Generator extends MovableDistanceField {
    boolean smooth = false;

    double contributionAtPoint(LXPoint where) {
      int dist = distanceField[where.index];
      double ramp = ((float)dist % (float)width) / (float)width;
      if (smooth) {
        return ramp;
      } else {
        return ramp < .5 ? 0.5 : 0.0;
  }
      }
      }
      
  public MoireManifoldPattern(LX lx) {
    super(lx);
    addParameter(width);
    addParameter(walkSpeed);
    addParameter(numGenerators);
    addParameter(numSmooth);
    }
      
  public void setGeneratorCount(int count) {
    while (generators.size() < count) {
      Generator g = new Generator();
      g.setOrigin(model.getRandomPoint());
      generators.add(g);
    }
    if (generators.size() > count) {
      generators.subList(count, generators.size()).clear();
        }
      }
      
  public void run(double deltaMs) {
    setGeneratorCount(numGenerators.getValuei());
    numSmooth.setRange(0, numGenerators.getValuei() + 1);

    int i = 0;
    for (Generator g : generators) {
      g.width = width.getValuef();
      g.advanceOnWalk(deltaMs / 1000.0 * walkSpeed.getValuef());
      g.smooth = i < numSmooth.getValuei();
      i ++;
        }

    for (LXPoint p : model.points) {
      float sumField = 0;
      for (Generator g : generators) {
        sumField += g.contributionAtPoint(p);
      }

      sumField = (cos(sumField * 2 * PI) + 1)/2;
      colors[p.index] = lx.hsb(0.0, 0.0, sumField * 100);
    }
      
    //for (Generator g : generators) {
    //  colors[g.getOrigin().index] = LXColor.RED;
    //}
  } 
}
*/



/** *************************************************************** WAVE FRONT
 * Colorful splats that spread out across the topology of the brain
 * and wobble a bit as they go.
 *
 * Simple application of MovableDistanceField.
 *
 * Potential improvements:
 * - Nicer set of color gradients. Maybe 1D textures?
 *
 * Some nice settings (NUM/WSPD/GSPD/WID):
 * - 6, 170, 285, 190
 * - 1, 0, 85, 162.5
 * - 5, 110, 85, 7.5
 *
 * @author Geoff Schmidt
 ************************************************************************* **/

/*
class WaveFrontPattern extends LXPattern {
  // Number of splats
  private final DiscreteParameter numSplats =
      new DiscreteParameter("NUM", 4, 1, 10 + 1);
  // Rate at which splat center moves (pixels / sec)
  private final BoundedParameter walkSpeed =
      new BoundedParameter("WSPD", 70, 0, 1000);
  // Rate at which splats grow (pixels / sec)
  private final BoundedParameter growSpeed =
      new BoundedParameter("GSPD", 125, 0, 500);
  // Width of splat band (pixels)
  private final BoundedParameter width =
      new BoundedParameter("WID", 30, 0, 250);

  class Splat extends MovableDistanceField {
    double age; // seconds
    double size; // pixels
    double walkSpeed;
    double growSpeed;
    double width = 50;
    double baseHue;
    double hueWidth = 90; // degrees of hue covered by the band
    double timeSinceAnyUnreached = 0;
    double timeToReset = -1;

    Splat() {
      this.reset();
    }

    void reset() {
      age = 0;
      size = 0;
      baseHue = (new Random()).nextDouble() * 360;
      timeSinceAnyUnreached = 0;
      timeToReset = -1;
      this.setOrigin(model.getRandomPoint());
    }

    void advanceTime(double deltaMs) {
      age += deltaMs / 1000;
      timeSinceAnyUnreached += deltaMs / 1000;
      size += deltaMs / 1000 * growSpeed;
      this.advanceOnWalk(deltaMs / 1000.0 * walkSpeed);

      if (timeSinceAnyUnreached > .5 && timeToReset < 0) {
        // For the last half a second, we've been big enough to cover
        // the whole brain. Time to think about resetting. Do it at a
        // random point in the future such that we're active about 80%
        // of the time. This will help the resets of different splats
        // to stay spaced out rather than getting bunched up.
        timeToReset = age + age * (new Random()).nextDouble() * .25;
      }

      if (timeToReset > 0 && age > timeToReset)
        // The planned reset time has come.
        reset();
    }

    int colorAtPoint(LXPoint p) {
      double pixelsBehindFrontier = size - (double)distanceField[p.index];
      if (pixelsBehindFrontier < 0) {
        timeSinceAnyUnreached = 0;
        return LXColor.hsba(0, 0, 0, 0);
      } else {
        double positionInBand = 1.0 - pixelsBehindFrontier / width;
        if (positionInBand < 0.0) {
          return LXColor.hsba(0, 0, 0, 0);
        } else {
            double hoo = baseHue + positionInBand * hueWidth;
    
            // return LXColor.hsba(hoo, Math.min((1 - positionInBand) * 250, 100), Math.min(100, 500 + positionInBand * 100), 1.0);
            return LXColor.hsba(hoo, 100, 100, 1.0);
  }
      }
    }
      }

  ArrayList<Splat> splats = new ArrayList<Splat>();

  public WaveFrontPattern(LX lx) {
    super(lx);
    addParameter(numSplats);
    addParameter(walkSpeed);
    addParameter(growSpeed);
    addParameter(width);
    }

  public void setSplatCount(int count) {
    while (splats.size() < count) {
      splats.add(new Splat());
        }
    if (splats.size() > count) {
      splats.subList(count, splats.size()).clear();
      }
    }

  public void run(double deltaMs) {
    setSplatCount(numSplats.getValuei());
    for (Splat s : splats) {
      s.advanceTime(deltaMs);
      s.walkSpeed = walkSpeed.getValuef();
      s.growSpeed = growSpeed.getValuef();
      s.width = width.getValuef();
      }

    Random rand = new Random();
    for (LXPoint p : model.points) {
      int kolor = LXColor.BLACK;
      for (Splat s : splats) {
        kolor = LXColor.blend(kolor, s.colorAtPoint(p), LXColor.Blend.ADD);
      }
      colors[p.index] = kolor;
   }  
  }
}
*/


/** *********************************************************** COLORED STATIC
 * MultiColored static, with black and white mode
 * @author: Codey Christensen
 ************************************************************************* **/

/* 
class ColorStatic extends LXPattern {
 
  ArrayList<LXPoint> current_points = new ArrayList<LXPoint>();
  ArrayList<LXPoint> random_points = new ArrayList<LXPoint>();
 
  int i;
  int h;
  int s;
  int b;
 
  private final BoundedParameter number_of_points = new BoundedParameter("PIX",  340, 50, 1000);
  private final BoundedParameter decay = new BoundedParameter("DEC",  0, 5, 100);
  private final BoundedParameter black_and_white = new BoundedParameter("BNW",  0, 0, 1);
   
  private final BoundedParameter color_change_speed = new BoundedParameter("SPD",  205, 0, 360);
  private final SinLFO whatColor = new SinLFO(0, 360, color_change_speed);
    
  public ColorStatic(LX lx){
     super(lx);
     addParameter(number_of_points);
     addParameter(decay);
     addParameter(color_change_speed);
     addParameter(black_and_white);
     addModulator(whatColor).trigger();
  }
  
 public void run(double deltaMs) {
   i = i + 1;
     
   random_points = model.getRandomPoints(int(number_of_points.getValuef()));

   for (LXPoint p : random_points) {
      h = int(whatColor.getValuef());
      if(int(black_and_white.getValuef()) == 1) {
        s = 0;
      } else {
        s = 100;
 }
      b = 100;

      colors[p.index]=lx.hsb(h,s,b);
      current_points.add(p);
  }

   if(i % int(decay.getValuef()) == 0) {
     for (LXPoint p : current_points) {
        h = 0;
        s = 0;
        b = 0;

        colors[p.index]=lx.hsb(h,s,b);
    }
     current_points.clear();
    }
  }
}
*/
