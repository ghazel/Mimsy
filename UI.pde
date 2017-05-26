/**
 * Here's a simple extension of a camera component. This will be
 * rendered inside the camera view context. We just override the
 * onDraw method and invoke Processing drawing methods directly.
 */




class UINodes extends UI3dComponent {

  private final float NODE_RADIUS = 10.0;
  private String COLOR_SCHEME = "LEVEL_COLOR";

  protected void onDraw(UI ui, PGraphics pg) {
    float hue =   0.0;
    float sat = 100.0;
    float brt = 100.0;
    float alp = 100.0;

    float dHue =  60;
    float dSat =  20;
    float dBrt =  20;
    noStroke();
    for (Node node : model.nodes) {
      int level = (int)Math.floor(node.index / 5.0);
      int spin = node.index % 5;

      if (COLOR_SCHEME == "SPIN_COLOR") {
        hue = level * dHue;
        sat = 100.0 - (spin * dSat);
        brt = 100.0 - (spin * dBrt);
      } else if (COLOR_SCHEME == "LEVEL_COLOR") {
        hue = spin * dHue;
        sat = 100.0 - (level * dSat);
        brt = 100.0 - (level * dBrt);
      }

      fill(hue,sat,brt,alp);
      pushMatrix();
      translate(node.x, node.y, node.z);
      sphere(NODE_RADIUS);
      popMatrix();
    }

    // NOTE: This renders the labels oriented in 3D, which makes them useless.
    if (false) {
      //noLights();
      hint(DISABLE_DEPTH_TEST);
      textAlign(CENTER, CENTER);
      textSize(24);
      fill(0,0,255);
      //fill(0, 102, 153, 51);
      for (Node node : model.nodes) {
        pushMatrix();
        translate(node.x, node.y, node.z);
        text(node.index, 0, 0, 0);
        //text(node.index, node.x, node.y, node.z);
        popMatrix();
      }
      hint(ENABLE_DEPTH_TEST);
    }
  }

  protected void swapColorScheme() {
    if (COLOR_SCHEME == "LEVEL_COLOR") {
      COLOR_SCHEME = "ROW_COLOR";
    } else {
      COLOR_SCHEME = "LEVEL_COLOR";
    }
  }
}


class UIWalls extends UI3dComponent {
  
  private final float WALL_MARGIN = 2*FEET;
  private final float WALL_SIZE = model.xRange + 2*WALL_MARGIN;
  private final float WALL_THICKNESS = 1*INCHES;
  
  protected void onDraw(UI ui, PGraphics pg) {
    fill(#666666);
    noStroke();
    pushMatrix();
    // Bottom
    translate(model.cx, model.cy, model.zMax + WALL_MARGIN);
    box(WALL_SIZE, WALL_SIZE, WALL_THICKNESS);
    // Left
    translate(-model.xRange/2 - WALL_MARGIN, 0, -model.zRange/2 - WALL_MARGIN);
    //box(WALL_THICKNESS, WALL_SIZE, WALL_SIZE);
    // Right
    translate(model.xRange + 2*WALL_MARGIN, 0, 0);
    //box(WALL_THICKNESS, WALL_SIZE, WALL_SIZE);
    // Back
    translate(-model.xRange/2 - WALL_MARGIN, model.yRange/2 + WALL_MARGIN, 0);
    //box(WALL_SIZE, WALL_THICKNESS, WALL_SIZE);
    // Front
    translate(0, -model.yRange - 2*WALL_MARGIN, 0);
    //box(WALL_SIZE, WALL_THICKNESS, WALL_SIZE);
    popMatrix();
  }
}

class UISimulationControl extends UIWindow {
  UISimulationControl(UI ui, float x, float y) {
    super(ui, "SIMULATION", x, y, UIChannelControl.WIDTH, 100);
    y = UIWindow.TITLE_LABEL_HEIGHT;
    new UIButton(4, y, width-8, 20)
      .setLabel("Show Walls")
      .setParameter(uiWalls.visible)
      .addToContainer(this);
    y += 24;
    new UIButton(4, y, width-8, 20)
      .setLabel("Show Nodes")
      .setParameter(uiNodes.visible)
      .addToContainer(this);
    y += 24;

    int w = 20;
    int b = 4;
    new UIButton(4, y, 30, 20)
      .setLabel("DD")
      .setParameter(pointCloudDodecahedron.visible)
      .addToContainer(this);
    new UIButton(38, y, 30, 20)
      .setLabel("TL")
      .setParameter(pointCloudTetraLeft.visible)
      .addToContainer(this);
    new UIButton(72, y, 30, 20)
      .setLabel("TR")
      .setParameter(pointCloudTetraRight.visible)
      .addToContainer(this);
  }
}

class UIEngineControl extends UIWindow {
  
  final UIKnob fpsKnob;
  
  UIEngineControl(UI ui, float x, float y) {
    super(ui, "ENGINE", x, y, UIChannelControl.WIDTH, 124);
        
    y = UIWindow.TITLE_LABEL_HEIGHT;
    new UIButton(4, y, width-8, 20) {
      protected void onToggle(boolean enabled) {
        lx.engine.setThreaded(enabled);
        fpsKnob.setEnabled(enabled);
      }
    }
    .setActiveLabel("Multi-Threaded")
    .setInactiveLabel("Single-Threaded")
    .addToContainer(this);
   
    /* 
    y += 24;
    new UIButton(4, y, width-8, 20) {
      protected void onToggle(boolean enabled) {
        if (enabled) { ortho(); }
        else { perspective(); }
      }
    }
    .setActiveLabel("Orthoscopic")
    .setInactiveLabel("Perspective")
    .addToContainer(this);
    */
    
    y += 24;
    fpsKnob = new UIKnob(4, y);    
    fpsKnob
    .setParameter(lx.engine.framesPerSecond)
    .setEnabled(lx.engine.isThreaded())
    .addToContainer(this);
    
  }
}

class UIComponentsDemo extends UIWindow {
  
  static final int NUM_KNOBS = 4; 
  final BoundedParameter[] knobParameters = new BoundedParameter[NUM_KNOBS];  
  
  UIComponentsDemo(UI ui, float x, float y) {
    super(ui, "UI COMPONENTS", x, y, 140, 10);
    
    for (int i = 0; i < knobParameters.length; ++i) {
      knobParameters[i] = new BoundedParameter("Knb" + (i+1), i+1, 0, 4);
      knobParameters[i].addListener(new LXParameterListener() {
        public void onParameterChanged(LXParameter p) {
          println(p.getLabel() + " value:" + p.getValue());
        }
      });
    }
    
    y = UIWindow.TITLE_LABEL_HEIGHT;
    
    new UIButton(4, y, width-8, 20)
    .setLabel("Toggle Button")
    .addToContainer(this);
    y += 24;
    
    new UIButton(4, y, width-8, 20)
    .setActiveLabel("Boop!")
    .setInactiveLabel("Momentary Button")
    .setMomentary(true)
    .addToContainer(this);
    y += 24;
    
    for (int i = 0; i < 4; ++i) {
      new UIKnob(4 + i*34, y)
      .setParameter(knobParameters[i])
      .setEnabled(i % 2 == 0)
      .addToContainer(this);
    }
    y += 48;
    
    for (int i = 0; i < 4; ++i) {
      new UISlider(UISlider.Direction.VERTICAL, 4 + i*34, y, 30, 60)
      .setParameter(new BoundedParameter("VSl" + i, (i+1)*.25))
      .setEnabled(i % 2 == 1)
      .addToContainer(this);
    }
    y += 80;
    
    for (int i = 0; i < 2; ++i) {
      new UISlider(4, y, width-8, 24)
      .setParameter(new BoundedParameter("HSl" + i, (i + 1) * .25))
      .setEnabled(i % 2 == 0)
      .addToContainer(this);
      y += 44;
    }
    
    new UIToggleSet(4, y, width-8, 24)
    .setParameter(new DiscreteParameter("Ltrs", new String[] { "A", "B", "C", "D" }))
    .addToContainer(this);
    y += 28;
    
    for (int i = 0; i < 4; ++i) {
      new UIIntegerBox(4 + i*34, y, 30, 22)
      .setParameter(new DiscreteParameter("Dcrt", 10))
      .addToContainer(this);
    }
    y += 26;
    
    new UILabel(4, y, width-8, 24)
    .setLabel("This is just a label.")
    .setAlignment(CENTER, CENTER)
    .setBorderColor(ui.theme.getControlDisabledColor())
    .addToContainer(this);
    y += 28;
    
    setSize(width, y);
  }
} 
