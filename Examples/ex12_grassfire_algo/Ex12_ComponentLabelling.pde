/*Labels blobs; assumes black is foreground
  'b' displays binary image; 'L' displays labeled blobs
  NOTE: currently uses random colors for blobs; needs a
  better way to make sure colors are clearly different
*/
color[] colors = {color(255), color(255, 0, 0), color(0, 255, 0),
                  color(0, 0, 255), color(255, 255, 0),
                  color(0, 255, 255)};
String[] fname = {"coins_binary.png", "coins_binary_filled.png"};
PImage[] img = new PImage[3];
int display;  //index of image to display
int colorIndex = -1;

void setup() {
  size(500, 500);
  surface.setResizable(true);
  img[0] = loadImage(fname[1]);
  surface.setSize(img[0].width, img[0].height);
  img[1] = img[0].get();  //Copy of img[0]
  background(0);
  display = 0;  //display binary image
  grassFire(img[1]);
}
void draw() {
  image(img[display], 0, 0);
  //delay(3000);
}
void grassFire(PImage img) {
  for (int x = 0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      color c = color(random(0,255),random(0,255),random(0,255));
      label(img, x, y, c);
      if (colorIndex >= 2) {
      colorIndex = 0;
      }
    }
  }
}

void label(PImage img, int x, int y, color p) {
  if (img.get(x,y) == color(0)) {
    if (img.get(x,y) != p) {
      img.set(x,y,p);
      label(img, x-1, y, p);
      label(img, x+1, y, p);
      label(img, x, y-1, p);
      label(img, x, y+1, p);
    }
  }
}
void keyReleased() {
  if (key == 'b' || key == 'B') display = 0; //Binary image
  else if (key == 'l' || key == 'L') display = 1;  //Labeled image
}