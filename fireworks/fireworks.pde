PImage img;
int IMG_W;
int IMG_H;
final float RADIUS = 2.5;
final float SCALE = 0.25;
final int LENGTH = 25;
final int SPEED = 400;

final float X_MEAN = 0.45;
final float Y_MEAN = 0.48;
float sd = 0.15;
int count = 0;
final int SD_CYCLE = 50;

void setup() {
  img = loadImage("/home/billangli/Pictures/fireworks.jpg");
  IMG_W = img.width;
  IMG_H = img.height;
  
  size(1600, 1200);
  background(color(0, 0, 0));
}

void draw() {
  // Increase the standard deviation every SD_CYCLE times
  count++;
  if (count % SD_CYCLE == 0) {
    sd += 0.01;
  }
  sd = sigmoid(count / 50.0 - 4);
  
  // Draw lines
  for (int i = 0; i < SPEED; i++) {    
    //int x = int(random(IMG_W));
    //int y = int(random(IMG_H));
    int x = (int) (rnorm(X_MEAN, sd, 0, 1) * IMG_W);
    int y = (int) (rnorm(Y_MEAN, sd, 0, 1) * IMG_H);
    
    // Calculate distance from point (x, y) to centre
    float distance = sqrt(pow(x - IMG_W / 2, 2) + pow(y - IMG_H / 2, 2));
    float max_distance = sqrt(pow(IMG_W / 2, 2) + pow(IMG_H / 2, 2));
    
    color c = getColor(img.pixels, x, y);
    float radius = random(RADIUS);
    float len = random(LENGTH) * distance / max_distance;
    
    //noStroke();
    //fill(red(c), green(c), blue(c));
    //ellipse(x * SCALING, y * SCALING, radius, radius);
    
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
