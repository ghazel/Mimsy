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

//****************************************************** USER FRIENDLY GLOBALS


static final double GLOBAL_BRIGHTNESS = 1.0;

static final int UI_LIGHT_HUE        =  0;
static final int UI_LIGHT_SATURATION =  0; // white
static final int UI_LIGHT_BRIGHTNESS = 50; // half bright

//---------------- Mimsy Physical Parameters
static float RADIUS = 144.0;
static int DODECAHEDRON_BAR_THICKNESS = 10;
static int TETRAHEDRON_BAR_THICKNESS =  8;


//---------------- Which Components to Draw
static boolean DRAW_DODECAHEDRON = true;
static boolean DRAW_TETRA_LEFT   = true;
static boolean DRAW_TETRA_RIGHT  = true;
static boolean DRAW_FRABJOUS     = false; // not implemented
static boolean DRAW_CUBIC        = false; // not implemented


//---------------- Output Hardware
//String OUTPUT = "BeagleBone";
//String OUTPUT = null;
static boolean OUTPUT = true;



//---------------- Symmetry Validation
boolean TEST_SYMMETRY = false;
SymmetryTest symTest;



//---------------- Patterns
LXPattern[] patterns(LX lx) {
  return new LXPattern[] {
    new SymmetryPattern(lx),
    new SymmetryTestPattern(lx),
    new TestBarMatrix(lx),

    /*
    new MappingTetrahedron(lx),
    new MappingDodecahedron(lx),
    new TetraBarTest(lx),
    new TetrahedronTest(lx),
    new TetraSymmetryFace(lx),
    
    new CircleBounce(lx),
    new Psychedelic(lx),
    new StrobePattern(lx),
    */
    
    //new ColorStatic(lx),
    //new WaveFrontPattern(lx),
    //new PixiePattern(lx),
    //new MoireManifoldPattern(lx),
    //new RainbowBarrelRoll(lx),
    //new GradientPattern(lx),
    //new LayerDemoPattern(lx),
    //new IteratorTestPattern(lx).setTransition(new DissolveTransition(lx)),
  };
};



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
    

    



