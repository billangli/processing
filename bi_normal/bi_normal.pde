final float MEAN = 0.5;
final float SD = 0.15;
final float MAX_COLOUR = 255;
final float RADIUS = 10;

void setup() {
  size(800, 600);
}

/*
 * Draw a point selected from a bivariate normal distributation every frame
 *
 * The range of values returned from rnorm is [0, 1]
 * So MEAN = 0.5 means that the distribution is centred at the centre of the screen
 */
void draw() {
  noStroke();
  
  // Independently pick x and y from normal distributions
  float x = rnorm(MEAN, SD, 0, 1) * width;
  float y = rnorm(MEAN, SD, 0, 1) * height;
  
  // Calucate the distance of the point (x, y) from the centre of the screen
  float distance = sqrt(pow(x - width / 2, 2) + pow(y - height / 2, 2));
  
  // Calculate the max distance of any point from the centre of the screen
  float maxDistFromCentre = sqrt(pow(width / 2, 2) + pow(height / 2, 2));
  
  // Draw the point
  fill(getRed(distance, maxDistFromCentre), getGreen(distance, maxDistFromCentre), 0);
  ellipse(x, y, RADIUS, RADIUS);
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
    float prob = pdfMax * exp(- pow((a - mean) / SD, 2) / 2);
    
    // We accept point a if b has a value lower than f(a)
    if (b < prob) {
      rejected = false;
    }
  }
  
  return a;
}

/*
 * Give the red RGB code from distance of point from centre
 */
float getRed(float dist, float maxDist) {
  if (dist > maxDist / 2) {
    return MAX_COLOUR - (dist - maxDist / 2) / (maxDist / 2) * MAX_COLOUR;
  } else {
    return MAX_COLOUR;
  }
}

/*
 * Give the green RGB code from distance of point from centre
 */
float getGreen(float dist, float maxDist) {
  if (dist > maxDist / 2) {
    return MAX_COLOUR;
  } else {
    return dist / (maxDist / 2) * MAX_COLOUR;
  }
}
