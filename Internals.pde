


import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Stream;
import java.util.stream.IntStream;


// Need to manually import minim
import ddf.minim.*;





//*************************************************************** P3LX OBJECTS
// Top-level, we have a model and a P3LX instance
static GraphModel model;
P3LX lx;

LXPattern[]       patterns;
LXTransition[]    transitions;
Effects           effects;
LXEffect[]        effectsArr;

UI3dContext uiContext;
UI3dComponent pointCloudDodecahedron;
UI3dComponent pointCloudTetraLeft;
UI3dComponent pointCloudTetraRight;
UI3dComponent uiWalls;
UI3dComponent uiNodes;

public BooleanParameter uiOrthoCamera = new BooleanParameter("Ortho");

public BoundedParameter clipNear = new BoundedParameter("Clip Near", 0, 0, 100);
public BoundedParameter clipFar = new BoundedParameter("Clip Far", 100, 0, 100);



// Let's NOT work in inches, but will leave these here for porting 
// patterns that do.
final static float INCHES = 25.4;
final static float FEET = 12.0*INCHES;





// Video Mixing Channels
static final int LEFT_CHANNEL = 0;
static final int RIGHT_CHANNEL = 1;
LXChannel L;
LXChannel R;

//************************************* Engine Construction and Initialization

LXTransition _transition(P3LX lx) {
  return new DissolveTransition(lx).setDuration(1000);
}

/*
LXPattern[] _leftPatterns(P3LX lx) {
  LXPattern[] patterns = patterns(lx);
  for (LXPattern p : patterns) {
    p.setTransition(_transition(lx));
   }
  return patterns;
}

LXPattern[] _rightPatterns(P3LX lx) {
  LXPattern[] patterns = _leftPatterns(lx);
  LXPattern[] rightPatterns = new LXPattern[patterns.length+1];
  int i = 0;
  rightPatterns[i++] = new BlankPattern(lx).setTransition(_transition(lx));
  for (LXPattern p : patterns) {
    rightPatterns[i++] = p;
  }
  return rightPatterns;
}
*/

/*
LXEffect[] _effectsArray(Effects effects) {
  List<LXEffect> effectList = new ArrayList<LXEffect>();
  for (Field f : effects.getClass().getDeclaredFields()) {
    try {
      Object val = f.get(effects);
      if (val instanceof LXEffect) {
        effectList.add((LXEffect)val);
      }
    } catch (IllegalAccessException iax) {}
  }

  return effectList.toArray(new LXEffect[]{});
}

LXEffect getSelectedEffect() {
  return effectsArr[selectedEffect.getValuei()];
}
*/





/** *************************************************************** MAIN SETUP
 * Set up models etc for whole package (Processing thing)
 * Fill out UI elements
 * Connect to output hardware
************************************************************************** **/

public void settings() {
  size(1200, 900, "processing.opengl.PGraphics3D");
}

void setup() {

  startMillis = System.currentTimeMillis();
  lastMillis = startMillis;
  smooth(4);
  
  //==================================================================== Model 
  model = buildMimsyModel();
  System.out.format("Model Name: %s\n", model.layer);
  out("Finished Building Model");

  if (TEST_SYMMETRY) {
    symTest = new SymmetryTest(model);
    symTest.runSymmetryTests();
    exit();
  }
  
  //===================================================================== P3LX

  lx = new P3LX(this, model);
  lx.setPatterns(patterns(lx));
  out("Finished Loading Patterns");
  
  //================================================================= 3D Model

  //-------------- Prepare 3D Reference Elements
  uiWalls = new UIWalls();
  uiWalls.setVisible(false);
  uiNodes = new UINodes();
  
  //-------------- Prepare 3D Point Clouds
  pointCloudDodecahedron 
    = new UIPointCloud(lx, model.getLayer(DD))
          .setPointSize(DODECAHEDRON_BAR_THICKNESS);
  pointCloudTetraLeft
    = new UIPointCloud(lx, model.getLayer(TL))
          .setPointSize(TETRAHEDRON_BAR_THICKNESS);
  pointCloudTetraRight
    = new UIPointCloud(lx, model.getLayer(TR))
          .setPointSize(TETRAHEDRON_BAR_THICKNESS);


  //-------------- Build the 3D UI
  uiContext = 
    // A camera layer makes an OpenGL layer that we can easily 
    // pivot around with the mouse
    new UI3dContext(lx.ui) {

      protected void beforeDraw(UI ui, PGraphics pg) {
        int H = UI_LIGHT_HUE;
        int S = UI_LIGHT_SATURATION;
        int B = UI_LIGHT_BRIGHTNESS;

        //-------- Lights!
        for (float mx : new float[]{model.xMin, model.xMax}) {
          for (float my : new float[]{model.yMin, model.yMax}) {
            for (float mz : new float[]{model.zMin, model.zMax}) {
              float x = mx*10;
              float y = my*10;
              float z = mz*10;
              pointLight(H,S,B, x, y, z);
              pushMatrix();
              translate(x,y,z);
              sphere(10.0);
              popMatrix();
            }
          }
        }
  
        int scale = 6;
        if (uiOrthoCamera.isOn()) {
          ortho(-width/scale, width/scale, 
                -height/scale, height/scale,
                clipNear.getValuef() * radius.getValuef() / 100.0,
                clipFar.getValuef() * radius.getValuef() / 100.0 * 2.0);
        }
        hint(ENABLE_DEPTH_TEST);
      }
      protected void afterDraw(UI ui, PGraphics pg) {
        // Turn off the lights and kill depth testing before the 2D layers
        noLights();
        hint(DISABLE_DEPTH_TEST);
      } 
    }
  
    //------------ Camera!
    .setRadius(1000)
    .setPerspective(0)
    //.setDepth(4)
    .setCenter(model.cx, model.cy, model.cz)
    //.setPhi(-PI/2) // Rotate model around X
    //.setTheta(-PI/2) // Rotate around Y
    

    //------------ Action! (actually just some stuff)
    // Let's add a point cloud of our animation points
    //.addComponent(pointCloud = new UIPointCloud(lx, model).setPointSize(BAR_THICKNESS))
    .addComponent(pointCloudDodecahedron)
    .addComponent(pointCloudTetraLeft)
    .addComponent(pointCloudTetraRight)
    // And a custom UI object of our own
    .addComponent(uiWalls)
    .addComponent(uiNodes)
  ;

  lx.ui.addLayer(uiContext);
  out("Finished 3D Layer");
  
  //=========================================================== 2D Control GUI
  UI2dContext[] layers = new UI2dContext[] {
    // Left Side
    new UIChannelControl      (lx.ui, lx.engine.getChannel(0), 4,   4),
    new UISimulationControl   (lx.ui,                          4, 326),
    new UIEngineControl       (lx.ui,                          4, 466),
    new UICameraControlMimsy  (lx.ui, uiContext,               4, 600),

    // Right Side
    new UIComponentsDemo   (lx.ui,                          width-144, 4),
  };
  
  for (UI2dContext layer : layers) {
    lx.ui.addLayer(layer);
  }


  
  out("Finished 2D Layer");


  //==================================================== Output to Controllers
  // create outputs via CortexOutput
  if (OUTPUT) {
    buildChannelMap(model);
    buildOutputs();
    out("Built output clients");
  }

}

void draw() {
  // Wipe the frame...
  background(#292929);
  //background(#888888);
  // ...and everything else is handled by P3LX!
  drawFPS();

  // DMK:  Somewhat strongly suspect cubic gamma on APA102 is wild overkill, but we'll check /
  //       add as a config
  // Gamma correction here. Apply a cubic to the brightness
  // for better representation of dynamic range
  //
  /*
  color[] sendColors = lx.getColors();  
  float hsb[] = new float[3];
  for (int i = 0; i < sendColors.length; ++i) {
    LXColor.RGBtoHSB(sendColors[i], hsb);
    float b = hsb[2];
    sendColors[i] = lx.hsb(360.*hsb[0], 100.*hsb[1], (b*b)/256.);
  }
  */


}



   
//************************************************************ AUX SUBROUTINES
//------------------------------------------------------------------ FPS Meter
long simulationNanos = 0;
static long startMillis = System.currentTimeMillis();
static long lastMillis = startMillis;

int FPS_TARGET = 60;  
boolean DRAW_FPS = true;
void drawFPS() {  
  if (DRAW_FPS) {
    fill(#FFFFFF);
    textSize(9);
    textAlign(LEFT, BASELINE);
    text("FPS: " + ((int) (frameRate*10)) / 10. + " / " + "60" + " (-/+)", 4, height-4);
  }
}

//-------------------------------------------------------------------- Logging

import java.text.SimpleDateFormat;
public static void mark() {
  lastMillis = System.currentTimeMillis();
}

public static void out(String format, Object... args) {
  String timeStamp = new SimpleDateFormat("HH:mm:ss")
                         .format(new Date());
  //int now = millis();
  long now = System.currentTimeMillis();
  long dif = now - lastMillis;
  String prefix = String.format("%s (%5d ms): ", timeStamp, dif);
  System.out.format(prefix);
  System.out.format(format, args);
  if (!format.endsWith("\n")) { 
    System.out.format("\n");
  }
  lastMillis = now;
}


