import java.util.Queue;
import java.util.LinkedList;

PImage img;
int IMG_WIDTH;
int IMG_HEIGHT;
final int WIDTH = 480;
final int HEIGHT = 473;
float SCALE;
final int THRESHOLD = 100;

Queue<Coordinate> queue1 = new LinkedList<Coordinate>();
Queue<Coordinate> queue2 = new LinkedList<Coordinate>();
Coordinate start;
boolean[] visited;

int time = 0;
final int RAINDROP_SPEED = 1;
ArrayList<Raindrop> raindrops = new ArrayList<Raindrop>();

class Coordinate {
  int x;
  int y;
  
  Coordinate(int x_, int y_) {
    x = x_;
    y = y_;
  }
  
  int hashCode() {
    return x + y;
  }
}

class Raindrop {
  int x;
  int y;
  int radiusLimit;
  int radius;
  int colour;
  static final int MAX_RADIUS = 50;
  
  Raindrop(color[] p, int w, int h) {
    x = (int) random(w);
    y = (int) random(h);
    radiusLimit = (int) random(MAX_RADIUS);
    radius = 0;
    colour = p[y * w + x];
  }
  
  void paintRaindrop() {
    if (radius < radiusLimit) {
      radius++;
      fill(colour);
      noStroke();
      ellipse(x, y, radius, radius);
    }
  }
}

void setup() {
  img = loadImage("/home/billangli/Pictures/trees/tree-reflection.JPG");
  IMG_WIDTH = img.width;
  IMG_HEIGHT = img.height;
  
  queue1.add(new Coordinate(0, HEIGHT / 2));
  queue2.add(new Coordinate(WIDTH * 7 / 11, HEIGHT - 1));
  visited = new boolean[WIDTH * HEIGHT];
  
  size(480, 473);
  SCALE = min(IMG_WIDTH / (WIDTH * 1.0), IMG_HEIGHT / (HEIGHT * 1.0));
}

void draw() {
  time++;
  
  // Perform BFS on the pixels that are dark //<>//
  bfs_draw(queue1, 200);
  bfs_draw(queue2, 100);
  
  // Randomly draw raindrops
  if (time % RAINDROP_SPEED == 0) {
    raindrops.add(new Raindrop(img.pixels, WIDTH, HEIGHT));
  }
  
  for (Raindrop r : raindrops) {
    r.paintRaindrop();
  }
}

void bfs_draw(Queue<Coordinate> q, int speed) {
  int count = 0;
  
  while (count < speed && !q.isEmpty()) {
    Coordinate p = q.remove();
    color c = img.pixels[int(p.y * SCALE) * IMG_WIDTH + int(p.x * SCALE)];
    
    // Check if the pixel is dark enough
    if (red(c) < THRESHOLD && green(c) < THRESHOLD && blue(c) < THRESHOLD) {
      // Draw the pixel
      stroke(c);
      point(p.x, p.y);      
      
      // Add surrounding pixels to queue
      addChildren(q, p, visited);
    }
    
    count++;
  }
}

/*
 * Add the pixel p's surrounding pixels if they have not already been visited
 */
void addChildren(Queue queue, Coordinate p, boolean[] visited) {
  ArrayList<Coordinate> children = new ArrayList<Coordinate>();
  
  if (p.x > 0) {
    children.add(new Coordinate(p.x - 1, p.y));
  }
  if (p.y > 0) {
    children.add(new Coordinate(p.x, p.y - 1));  
  }
  if (p.x + 1 < WIDTH) {
    children.add(new Coordinate(p.x + 1, p.y));
  }
  if (p.y + 1 < HEIGHT) {
    children.add(new Coordinate(p.x, p.y + 1));
  }
  
  for (Coordinate c : children) {
    if (visited[c.y * WIDTH + c.x] == false) {
      queue.add(c);
      visited[c.y * WIDTH + c.x] = true;
    }
  }
}
