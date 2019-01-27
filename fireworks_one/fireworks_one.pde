final int WIDTH = 1200;
final int HEIGHT = 900;
PImage img;
int IMG_W;
int IMG_H;

final float MAX_RADIUS = 2.5;
final float SCALE = 0.23;
final int MAX_LENGTH = 25;
int speed = 1500;
int fadeSpeed = 3;
final int FADE_CYCLE = 100;
int blackRadius = 5;
final int BLACK_CYCLE = 100;

final float X_MEAN = 0.45;
final float Y_MEAN = 0.48;
float sd = 0.15;
int count = 0;
final int SD_CYCLE = 500;


void setup() {
  img = loadImage("/home/billangli/Pictures/fireworks.jpg");
  IMG_W = img.width;
  IMG_H = img.height;

  size(1200, 900);
  background(color(0, 0, 0));
}

void draw() {
  // Increase the time
  increaseTime();

  // Draw from the two locations of the firework explosions
  drawFromCentre(0.46, 0.55);
  if (count > 30) {
    drawFromCentre(0.45, 0.48);
  }

  // Save a copy of the screen
  saveFrame("/home/billangli/Pictures/fireworks/fireworks-#####.jpg");
}

void increaseTime() {
  // Increase the standard deviation every SD_CYCLE times
  count++;

  if (count % SD_CYCLE == 0) {
    count += 0.01;
  }
  
  blackRadius = (int) count * 12;
  fadeSpeed = (int) count / 10;
  
  sd = sigmoid(count / 10.0 - 4);
}

void drawFromCentre(float xMean, float yMean) {  
  // Add a layer of transluscent black circle
  if (count > 0) {
    noStroke();
    fill(0, fadeSpeed);
    ellipse(SCALE * xMean * IMG_W, SCALE * yMean * IMG_H, blackRadius, blackRadius);
  }

  // Draw lines
  for (int i = 0; i < speed; i++) {    
    int x = (int) (rnorm(xMean, sd, 0, 1) * IMG_W);
    int y = (int) (rnorm(yMean, sd, 0, 1) * IMG_H);

    // Calculate distance from point (x, y) to centre
    float distance = sqrt(pow(x - xMean * IMG_W, 2) + pow(y - yMean * IMG_H, 2));
    float max_distance = sqrt(pow(IMG_W / 2, 2) + pow(IMG_H / 2, 2));

    if (distance > blackRadius) {
      color c = getColor(img.pixels, x, y);
      float radius = random(MAX_RADIUS);
  
      // Draw a line coming from the centre
      float len = random(MAX_LENGTH) * distance / max_distance;
  
      // Draw a line pointed to the centre
      float angle;
      if (x - IMG_W / 2 == 0) {
        angle = PI / 4;
      } else {
        angle = atan(((float) (y - IMG_H / 2)) / ((float) (x - IMG_W / 2)));
      }  
  
      stroke(c);
      strokeWeight(radius);
  
      float xOffset = (float) (len * Math.cos(angle));
      float yOffset = (float) (len * Math.sin(angle));
  
      line(
        SCALE * (x - xOffset), 
        SCALE * (y - yOffset), 
        SCALE * (x + xOffset), 
        SCALE * (y + yOffset)
        );
    }

    //println(x, y);
    //println(red(c), green(c), blue(c));
  }
}

/*
 * Return the color of the pixel specified at the coordinate (x, y)
 */
color getColor(color[] pix, int x, int y) {
  int location = y * IMG_W + x;

  return pix[location];
}

/*
 * Draw from a random distribution for given mean and standard deviation using the rejection method
 * It specifies a range to draw the points from
 */
float rnorm(float mean, float sd, float min, float max) {
  float a = 0;
  float b;
  float pdfMax = 1 / (sd * sqrt(2 * PI));
  boolean rejected = true;

  // Keep the loop going while the point generated is rejected
  while (rejected) {
    a = random(min, max);  // This will be the point that we generate
    b = random(pdfMax);  // This will be compared against the pdf of normal distribution

    // This will be the "probability" that we accept point a
    float prob = pdfMax * exp(- pow((a - mean) / sd, 2) / 2);

    // We accept point a if b has a value lower than f(a)
    if (b < prob) {
      rejected = false;
    }
  }

  return a;
}

/*
 * The sigmoid function
 */
float sigmoid(float x) {
  return 1 / (1 + exp(-x));
}

/*
 * The bump function
 */
float bump(float x) {
  return exp(-1 / (1 - pow(x, 2)));
}
