import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

static int OUTPUT_WIDTH = 3600;
static int OUTPUT_HEIGHT = 3600;
ArrayList<PShape> shapes = new ArrayList<PShape>();
ArrayList<PImage> images = new ArrayList<PImage>();
PGraphics canvas;
VerletPhysics2D physics;
AttractionBehavior mouseAttractor;
Vec2D mousePos;
int currentSrc = 0;

void setup() {
  size((int) OUTPUT_WIDTH/4, (int) OUTPUT_HEIGHT/4);
  physics = new VerletPhysics2D();
  physics.setDrag(0.5f);
  loadVectors("retro");
  loadBitmaps("default");
  for (int i=0; i < shapes.size(); i++) {
    VerletParticle2D p = new VerletParticle2D(width/2, height/2, map(i, 0, shapes.size() - 1, 0.25, 2));
    physics.addParticle(p);
  }
  canvas = createGraphics(OUTPUT_WIDTH, OUTPUT_HEIGHT);
}

void draw() {
  background(255);
  canvas.beginDraw();
  canvas.noFill();
  canvas.noStroke();
  physics.update();
  for (VerletParticle2D p : physics.particles) {
    if (!mousePressed) break;
    PImage image = images.get(currentSrc);
    int relativeX = (int) map(p.x, 0, width, 0, image.width);
    int relativeY = (int) map(p.y, 0, height, 0, image.height);
    int c = image.get(relativeX, relativeY);
    PShape shape = shapes.get(physics.particles.indexOf(p));
    shape.resetMatrix();
    shape.disableStyle();
    shape.rotate(p.getVelocity().heading());
    float scaleFactor = p.getVelocity().magnitude();
    scaleFactor = map(scaleFactor, 0, 20, -6, 6);
    shape.scale(scaleFactor);
    canvas.fill(red(c), green(c), blue(c), random(255));
    //canvas.stroke(0, random(100, 255));
    canvas.strokeWeight(0.1);
    canvas.shape(shape, (int) map(p.x, 0, width, 0, OUTPUT_WIDTH), (int) map(p.y, 0, height, 0, OUTPUT_HEIGHT));
  }
  canvas.endDraw();
  image(canvas, 0, 0, width, height);
}

void loadBitmaps(String folderName) {
  File folder = new File(this.sketchPath + "/data/bitmap/" + folderName);
  File[] listOfFiles = folder.listFiles(new IgnoreSystemFileFilter());
  for (File file : listOfFiles) {
    PImage src = loadImage(file.getAbsolutePath());
    images.add(src);
  }
}

// Create an SVG with several shapes, each on its own layer.
// Make sure they're all crammed into the top-left of the artboard.

void loadVectors(String ... folderName) {
  for (int i = 0; i < folderName.length; i++) {
    int limit = 0;
    File folder = new File(this.sketchPath + "/data/vector/" + folderName[i]);
    File[] listOfFiles = folder.listFiles();
    for (File file : listOfFiles) {
      if (file.isFile()) {
        PShape shape = loadShape(file.getAbsolutePath());
        for (PShape layer : shape.getChildren()) {
          if (layer!=null && limit < 40) {
            layer.disableStyle();
            shapes.add(layer);
            limit++;
          }
        }
      }
    }
  }
}


void keyPressed() {
  if (key == ' ') {
    canvas.beginDraw();
    canvas.clear();
    canvas.endDraw();
  }
  if (key == 'b') {
    canvas.beginDraw();
    canvas.filter(BLUR, 2);
    canvas.endDraw();
  }
  if (key == 's') {
    PGraphics output = createGraphics(OUTPUT_WIDTH, OUTPUT_HEIGHT);
    output.beginDraw();
    output.background(255);
    output.image(canvas, 0, 0);
    output.scale(-1, 1);
    output.image(canvas, -OUTPUT_WIDTH, 0);
    output.endDraw();
    output.save("data/output/composition-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + ".tif");
  }
  if (key == 'n') {
    currentSrc = (currentSrc < images.size() - 1) ? currentSrc + 1 : 0;
  }
}

void mousePressed() {
  mousePos = new Vec2D(mouseX, mouseY);
  mouseAttractor = new AttractionBehavior(mousePos, width, 5.0f);
  physics.addBehavior(mouseAttractor);
}

void mouseDragged() {
  mousePos.set(mouseX, mouseY);
}

void mouseReleased() {
  physics.removeBehavior(mouseAttractor);
}

