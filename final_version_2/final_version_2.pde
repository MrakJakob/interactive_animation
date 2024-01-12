import processing.video.*;
import gab.opencv.*;

int cols;
int rows;
PVector[] flowField;
int scale = 80;
float increase = 0.2;
float zOffset = 0;
final int NUM_OF_PARTICLES = 8000;
Particle[] particles = new Particle[NUM_OF_PARTICLES];



int[] prevVideoImage;
Capture video;
PImage prev;
float threshold = 50;
float magnitude = 0.3;

float motionX = 0;
float motionY = 0;

float prevLerpX = 0;
float prevLerpY = 0;

float lerpX = 0;
float lerpY = 0;

int particleIndex = 0;

int[] pixelsChanged;
int minPixelChangeDistance = 10;

int max = 0;


void setup() {
    fullScreen();
    // size(1400, 900, P2D);
    // size(640, 480);
    // size(1000, 600);
    cols = (int)(width / scale);
    rows = (int)(height / scale);
    System.out.println(cols + " " + rows);
    flowField = new PVector[cols * rows];
    
    
    // for (int i = 0; i < NUM_OF_PARTICLES; i++) {
        //particles[i] = new Particle(50, -1, -1);
        // particles[i].pColor = color(0, noise(i) * 255, 120);
    // }
    String[] cameras = Capture.list();
    // size(1280, 960);
    // size(640, 480);
    
    video = new Capture(this, cameras[0]);
    video.start();
    
    prev = createImage(640, 480, RGB);
    pixelsChanged = new int[video.width * video.height];
    //size(1400, 900, P2D);  
    background(0);
}

void captureEvent(Capture video) {
    prev.copy(video, 0, 0, video.width, video.height, 0, 0, prev.width, prev.height);
    prev.updatePixels();
    video.read();
}

void draw() {
    System.out.println(frameRate);
    background(0);
                
    int currentPixelChangeDistance = 0;
    float ratio_x = float(width) / float(video.width);
    float ratio_y = float(height) / float(video.height);
    
    int x_flow = 0;
    int y_flow = 0;
    float yOffset = 0;
    float xOffset = 0;

    for (int x = 0; x < video.width; x++) {                   
        for (int y = 0; y < video.height; y++) {                          
            int loc_A = x + y * video.width;    
            
            if (loc_A >= video.pixels.length) {   
                continue;
            }
                    
            color currentColor = video.pixels[loc_A];      
            float r1 = red(currentColor);            
            float g1 = green(currentColor);       
            float b1 = blue(currentColor);        
            color prevColor = prev.pixels[loc_A];        
            float r2 = red(prevColor);          
            float g2 = green(prevColor);            
            float b2 = blue(prevColor);             
            
            float d = distSq(r1, g1, b1, r2, g2, b2);                  
           
            // int loc_B = int(x * ratio_x + (y * ratio_y) * width);
            
            
            
            if (d > threshold * threshold && currentPixelChangeDistance >= minPixelChangeDistance) { 
                currentPixelChangeDistance = 0;      
                
                // pixels[loc_B] = color(255); 
                pixelsChanged[loc_A] = 1;
            } else {            
                // pixels[loc_B] = color(0);
                pixelsChanged[loc_A] = 0;
                currentPixelChangeDistance++;
            }                


            //////////////////////////// FLOW FIELD ////////////////////////////
            if (y_flow < rows) {
                int index = x_flow + y_flow * cols;
                
                double angle = noise(x_flow, y_flow, zOffset) * Math.PI * 5;
                flowField[index] = PVector.fromAngle((float) angle);
                flowField[index].setMag(this.magnitude);
                
                xOffset += increase;
                x_flow++;
                if (x_flow >= cols) {
                    x_flow = 0;
                    y_flow++;
                    xOffset = 0;
                    yOffset += increase;
                    zOffset += 0.00015;
                }
            }

            ////////////////////////////////////////////////////////////////
            /////////////////////////// PIXELS CHANGED /////////////////////
            if (pixelsChanged[loc_A] == 1) {         
                int y_pixels = loc_A / video.width;
                int x_pixels = loc_A % video.width;
              
                x_pixels = int(x_pixels * ratio_x);
                y_pixels = int(y_pixels * ratio_y);
                
                particles[(particleIndex % particles.length)] = new Particle(50, x_pixels, y_pixels);  
              
                particleIndex++;
            }
        }                    
    }                                       
    
    for (int i = 0; i < NUM_OF_PARTICLES; i++) {    
        if (particles[i] != null) {
            particles[i].update(flowField, i);
            particles[i].show();
        }
    }
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
    float d = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1);
    return d;
}

// eksperimentiraj z barvami
// drugačen input (na primer mikrofon - glasba)
