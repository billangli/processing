PImage img;
int IMG_W;
int IMG_H;
float[] maxRadius = {2.5, 5, 7.5, 15};
final float SCALE = 0.23;
int[] maxLength = {25, 50, 75, 150};
final int SPEED = 400;

final float X_MEAN = 0.45;
final float Y_MEAN = 0.48;
float[] sd = {0.15, 0.15, 0.15, 0.15};
int count = 0;
final int SD_CYCLE = 500;

int generation = 0;
int[] generationTime = {200, 200, 200, 140};
int[] generationSpeed = {800, 700, 600, 200};
final int MAX_GENERATION = 3;

void setup() {
  img = loadImage("/home/billangli/Pictures/fireworks.jpg");
  IMG_W = img.width;
  IMG_H = img.height;

  size(1200, 900);
  background(color(0, 0, 0));
}

void draw() {

  if (generation < MAX_GENERATION && count < generationTime[generation]) {
    // Draw for up to three generations
    for (int i = 0; i <= generation; i++) {
      drawFromCentre(0.46, 0.55, false, i);
      if (count > 30) {
        drawFromCentre(0.45, 0.48, false, i);
      }

      increaseTime(i);
    }
  } else if (generation == MAX_GENERATION) {
    count++;
    generationSpeed[MAX_GENERATION] += 1;
    drawFromCentre(0.46, 0.55, true, MAX_GENERATION);
    if (count > 30) {
      drawFromCentre(0.45, 0.48, true, MAX_GENERATION);
    }
  } else {
    count = 0;
    generation++;
  }

  // Save a copy 
  saveFrame("/home/billangli/Pictures/fireworks/fireworks-#####.jpg");
}

void increaseTime(int i) {
  // Increase the standard deviation every SD_CYCLE times
  count++;

  if (count % SD_CYCLE == 0) {
    count += 0.01;
  }

  sd[i] = sigmoid(count / 50.0 - 4);
}

void drawFromCentre(float xMean, float yMean, boolean drawBlack, int generation) {  
  // Draw lines
  for (int i = 0; i < generationSpeed[generation]; i++) {    
    //int x = int(random(IMG_W));
    //int y = int(random(IMG_H));
    int x = (int) (rnorm(xMean, sd[generation], 0, 1) * IMG_W);
    int y = (int) (rnorm(yMean, sd[generation], 0, 1) * IMG_H);

    // Calculate distance from point (x, y) to centre
    float distance = sqrt(pow(x - IMG_W / 2, 2) + pow(y - IMG_H / 2, 2));
    float max_distance = sqrt(pow(IMG_W / 2, 2) + pow(IMG_H / 2, 2));

    color c = getColor(img.pixels, x, y);
    float radius = random(maxRadius[generation]);

    if (drawBlack) {
      // Draw a black circle with increasing opacity
      float len = random(maxLength[generation]) * distance / max_distance;
      if (distance / max_distance < 1 / 8.0) {
        // Make sure circles are not too small
        len = random(maxLength[generation]) / 8.0;
      }

      noStroke();
      fill(0, sigmoid(count / 400.0) * 255);

      ellipse(SCALE * x, SCALE * y, len, len);
    } else {
      // Draw a line coming from the centre
      float len = random(maxLength[generation]) * distance / max_distance;

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
