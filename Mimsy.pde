/*
** The Phage presents
**    Mimsy
** 
**        _---~~(~~-_.
**      _{        )   )
**    ,   ) -~~- ( ,-' )_
**   (  `-,_..`., )-- '_,)
**  ( ` _)  (  -~( -_ `,  }
**  (_-  _  ~_-~~~~`,  ,' )
**    `~ -^(    __;-,((()))
**          ~~~~ {_ -_(())
**                 `\  }
**                   { }
**                    
** Authors:
**   Alex Scouras
**   Alex Maki-Jokela
**   Mike Pesavento
**     + pattern designers
** 
** @date: 2015.12.26
** @date: 2017.01.15
**/

import java.io.*;
import java.nio.file.*;
import java.util.*;

// **************************************************** USER FRIENDLY GLOBALS



static float RADIUS = 144.0;
static int DD_THICKNESS = 10;
static int TT_THICKNESS =  5;


static boolean DRAW_FACES        = true;
static boolean DRAW_FRABJOUS     = false;
static boolean DRAW_TETRA_LEFT   = true;
static boolean DRAW_TETRA_RIGHT  = true;
static boolean DRAW_CUBIC        = false;

double global_brightness = 1.0;
static int LIGHT_BRIGHTNESS = 50;


//---------------- Output Hardware
//String OUTPUT = "BeagleBone";
//String OUTPUT = null;
static boolean OUTPUT = false;






//---------------- Patterns
/*
LXPattern[] patterns(LX lx) {
  return new LXPattern[] {
    new Psychedelic(lx),
    new RainbowBarrelRoll(lx),
    new GradientPattern(lx),
    new LayerDemoPattern(lx),
    new IteratorTestPattern(lx).setTransition(new DissolveTransition(lx)),
  };
};
*/


//---------------- Transitions
/*
LXTransition[] transitions(P3LX lx) {
  return new LXTransition[] {
    new AddTransition(lx),
    new DissolveTransition(lx),
    new MultiplyTransition(lx),
    new SubtractTransition(lx),
    new FadeTransition(lx),
    // new ZebraTransition(lx),
    // new MaxTransition(lx),
    // TODO(mcslee): restore these blend modes in P2LX
    // new OverlayTransition(lx),
    // new DodgeTransition(lx),
    //new SlideTransition(lx),
    //new WipeTransition(lx),
    //new IrisTransition(lx),
  };
};
*/

//---------------- Effects
class Effects {
  FlashEffect flash = new FlashEffect(lx);
  //SparkleEffect sparkle = new SparkleEffect(lx);
  
  Effects() {
  }
}  
    

    
// Need to manually import minim
import ddf.minim.*;

// Let's work in inches
final static float INCHES = 25.4;
final static float FEET = 12.0*INCHES;



// Video Mixing Channels
static final int LEFT_CHANNEL = 0;
static final int RIGHT_CHANNEL = 1;
LXChannel L;
LXChannel R;

// Top-level, we have a model and a P3LX instance
static GraphModel model;
P3LX lx;
UI3dComponent pointCloudDodecahedron;
UI3dComponent pointCloudTetraLeft;
UI3dComponent pointCloudTetraRight;

UI3dComponent walls;
UI3dComponent vertices;

LXPattern[]       patterns;
LXTransition[]    transitions;
Effects           effects;
LXEffect[]        effectsArr;

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
void setup() {
  size(1920, 1100, P3D);
  //size(1200, 900, P3D);
  smooth(4);
  
  //==================================================================== Model 
  model = buildMimsyModel();
  System.out.format("Model Name: %s\n", model.layer);
  logTime("Finished Building Model");
  
  //===================================================================== P3LX
  
  //hint(ENABLE_DEPTH_TEST); 
  //hint(ENABLE_DEPTH_SORT);

  lx = new P3LX(this, model);
  
  // Set the patterns
  lx.setPatterns(new LXPattern[] {
    new MappingTetrahedron(lx),
    new TetraBarTest(lx),
    new TetrahedronTest(lx),
    //new CircleBounce(lx),
    //new Psychedelic(lx),
    //new StrobePattern(lx),
    //new ColorStatic(lx),
    //new WaveFrontPattern(lx),
    //new PixiePattern(lx),
    //new MoireManifoldPattern(lx),
    //new RainbowBarrelRoll(lx),
    //new GradientPattern(lx),
    //new LayerDemoPattern(lx),
    //new IteratorTestPattern(lx).setTransition(new DissolveTransition(lx)),
  });
  logTime("Finished Loading Patterns");
  
  //******************************************************************** 3D Model

  walls = new UIWalls();
  walls.setVisible(false);
  vertices = new UIVertices();
  pointCloudDodecahedron = new UIPointCloud(lx, model.getLayer(DD))
                               .setPointSize(DD_THICKNESS);
  pointCloudTetraLeft    = new UIPointCloud(lx, model.getLayer(TL))
                               .setPointSize(TT_THICKNESS);
  pointCloudTetraRight   = new UIPointCloud(lx, model.getLayer(TR))
                               .setPointSize(TT_THICKNESS);


  lx.ui.addLayer(
    // A camera layer makes an OpenGL layer that we can easily 
    // pivot around with the mouse
    new UI3dContext(lx.ui) {
      protected void beforeDraw(UI ui, PGraphics pg) {
        int H = 0;
        int S = 0;
        int B = LIGHT_BRIGHTNESS;
        // Let's add lighting and depth-testing to our 3-D simulation
        //pointLight(H,S,B, model.cx, model.cy,             -20*FEET);
        //pointLight(H,S,B, model.cx, model.yMax + 10*FEET, model.cz);
        //pointLight(H,S,B, model.cx, model.yMin - 10*FEET, model.cz);

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

        
        hint(ENABLE_DEPTH_TEST);
      }
      protected void afterDraw(UI ui, PGraphics pg) {
        // Turn off the lights and kill depth testing before the 2D layers
        noLights();
        hint(DISABLE_DEPTH_TEST);
      } 
    }
  
    .setRadius(1000)
    .setPerspective(0)
    .setCenter(model.cx, model.cy, model.cz)

    .setPhi(-PI/2) // Rotate around X
    //.setTheta(-PI/2) // Rotate around Y
    
    // Uncomment these lines to control camera movement 
    //.setRotationVelocity(12*PI)
    //.setRotationAcceleration(3*PI)
    
    // Let's add a point cloud of our animation points
    //.addComponent(pointCloud = new UIPointCloud(lx, model).setPointSize(BAR_THICKNESS))
    .addComponent(pointCloudDodecahedron)
    .addComponent(pointCloudTetraLeft)
    .addComponent(pointCloudTetraRight)
    // And a custom UI object of our own
    .addComponent(walls)
    .addComponent(vertices)
  );

  logTime("Finished 3D Layer");
  
  //************************************************************************* 2D UI
  lx.ui.addLayer(new UIChannelControl(lx.ui, lx.engine.getChannel(0), 4, 4));
  lx.ui.addLayer(new UISimulationControl(lx.ui, 4, 326));
  lx.ui.addLayer(new UIEngineControl(lx.ui, 4, 406));
  lx.ui.addLayer(new UIComponentsDemo(lx.ui, width-144, 4));
  
  logTime("Finished 2D Layer");

  //==================================================== Output to Controllers
  // create outputs via CortexOutput
  if (OUTPUT) {
    buildOutputs();
    logTime("Built output clients");
  }

  //ortho();

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
int startMillis, lastMillis;
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

//-------------------------------------------------------------------- Logger
public void logTime(String evt) {
  int now = millis();
  System.out.format("%5d ms: %s\n", (now - lastMillis), evt);
  lastMillis = now;
}  
    
