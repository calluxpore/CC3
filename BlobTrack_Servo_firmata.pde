/*
Blob Tracking to Servo Control
Based ON
// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/1scFcY-xMrI
// FROM MODELES - Just Pixels - Blob Track to Servo

Adapted to track 4 colours by selection followed by movement & playing of 1 motor+ 1 Audio to each color 

*/
import processing.serial.*;
import cc.arduino.*;
import processing.video.*;
import processing.sound.*;
import java.awt.*;

Arduino arduino; // create an Arduino object to connect to the board
Capture video;

SoundFile[] soundFiles = new SoundFile[4]; // audio files

// Servo variables
int servored = 12;
int servogreen = 11;
int servoblue = 6;
int servoyellow = 5;

int servoAngle_value;

// Motor angle controles
int minServoAngle = 165;
int maxServoAngle = 20;

color redColor;  // To store the red color
color greenColor;// To store the green color
color blueColor;// To store the blue color
color yellowColor;// To store the yellow color

//color trackColor; 
float threshold = 15;
float distThreshold = 50;


boolean redDetected = false; // Flag to keep track of  color detection
boolean greenDetected = false; 
boolean blueDetected = false; 
boolean yellowDetected = false; 


boolean firstColorSelected = false;  // Flag to check if the first color (red) is selected
boolean secondColorSelected = false; // Flag to check if the second color (green) is selected
boolean thirdColorSelected = false; // Flag to check if the third color (blue) is selected
boolean fourthColorSelected = false; // Flag to check if the fourth color (yellow) is selected



ArrayList<Blob> blobs = new ArrayList<Blob>();

int cameraIndex = 0; // Change this index to pick a different camera

void setup() {
  size(640, 360);

  // Camera selection logic
  String[] cameras = Capture.list();
  printArray(cameras);
  if (cameras.length > 0 && cameraIndex < cameras.length) {
    video = new Capture(this, cameras[cameraIndex]);
  } else {
    println("Camera index is out of bounds.");
    exit();
  }
  video.start();
  //trackColor = color(255, 0, 0);

  // Firmata setup
  printArray(Arduino.list()); // List COM-ports
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(servored, Arduino.SERVO);
  arduino.pinMode(servogreen, Arduino.SERVO);
  arduino.pinMode(servoblue, Arduino.SERVO);
  arduino.pinMode(servoyellow, Arduino.SERVO);
    for (int i = 0; i < soundFiles.length; i++) {
    String filePath = dataPath("sound" + i + ".mp3");
    soundFiles[i] = new SoundFile(this, filePath);
  }
}

 

void captureEvent(Capture video) {
  video.read();
}

void keyPressed() {
  if (key == 'a') {
    distThreshold += 5;
  } else if (key == 'z') {
    distThreshold -= 5;
  }
  if (key == 's') {
    threshold += 5;
  } else if (key == 'x') {
    threshold -= 5;
  }

  println(distThreshold);
}

void draw() {
  video.loadPixels();
  image(video, 0, 0);
  redDetected = false;
  greenDetected = false;// Reset the detection flag
  blueDetected = false;// Reset the detection flag
  yellowDetected = false;// Reset the detection flag

  blobs.clear();

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      float r = red(currentColor);
      float g = green(currentColor);
      float b = blue(currentColor);
    
    
    // colour selection logic  
      if (firstColorSelected) {
        float d1 = distSq(r, g, b, red(redColor), green(redColor), blue(redColor));
        if (d1 < threshold * threshold) {
          redDetected = true;
          break;
        }
      }
      if (secondColorSelected) {
        float d2 = distSq(r, g, b, red(greenColor), green(greenColor), blue(greenColor));
        if (d2 < threshold * threshold) {
          greenDetected = true;
          break;
        }
      }
      if (thirdColorSelected) {
        float d3 = distSq(r, g, b, red(blueColor), green(blueColor), blue(blueColor));
        if (d3 < threshold * threshold) {
          blueDetected = true;
          break;
        }
      }
      if (fourthColorSelected) {
        float d4 = distSq(r, g, b, red(yellowColor), green(yellowColor), blue(yellowColor));
        if (d4 < threshold * threshold) {
          yellowDetected = true;
          break;
        }
      }
    }
  }
  
  // motor + audio logic
  if (redDetected) {
    arduino.servoWrite(servored, maxServoAngle);
    arduino.servoWrite(servogreen, minServoAngle);
    arduino.servoWrite(servoblue, minServoAngle);
    arduino.servoWrite(servoyellow, minServoAngle);
    if (!soundFiles[3].isPlaying()){  // important for good responsiveness
      soundFiles[3].play();
    }
  } else if (greenDetected) {
    arduino.servoWrite(servored, minServoAngle);
    arduino.servoWrite(servogreen, maxServoAngle);
    arduino.servoWrite(servoblue, minServoAngle);
    arduino.servoWrite(servoyellow, minServoAngle);
    if (!soundFiles[2].isPlaying()){
      soundFiles[2].play();
    }
  }else if (blueDetected) {
    arduino.servoWrite(servored, minServoAngle);
    arduino.servoWrite(servogreen, minServoAngle);
    arduino.servoWrite(servoblue, maxServoAngle);
    arduino.servoWrite(servoyellow, minServoAngle);
    if (!soundFiles[0].isPlaying()){
      soundFiles[0].play();
    }
  }
  else if (yellowDetected) {
    arduino.servoWrite(servored, minServoAngle);
    arduino.servoWrite(servogreen, minServoAngle);
    arduino.servoWrite(servoblue, minServoAngle);
    arduino.servoWrite(servoyellow, maxServoAngle);
    if (!soundFiles[1].isPlaying()){
      soundFiles[1].play();
    }
    // important for good responsiveness
  }else {
    arduino.servoWrite(servored, minServoAngle);
    arduino.servoWrite(servogreen, minServoAngle);
    arduino.servoWrite(servoblue, minServoAngle);
    arduino.servoWrite(servoyellow, minServoAngle);
     soundFiles[3].stop();
     soundFiles[2].stop();
     soundFiles[1].stop();
     soundFiles[0].stop();
  }

  //if (redDetected) {
  //  arduino.servoWrite(servored, maxServoAngle);
    
  //} else if (greenDetected) {
    
  //  arduino.servoWrite(servogreen, maxServoAngle);
   
  //}else if (blueDetected) {
  
  //  arduino.servoWrite(servoblue, maxServoAngle);
    
  //}
  //  else if (yellowDetected) {
  
  //  arduino.servoWrite(servoyellow, maxServoAngle);
  //}
  //else if (!redDetected) {
  //  arduino.servoWrite(servored, minServoAngle);
  //}
  //   else if (!greenDetected) {
  
  //  arduino.servoWrite(servogreen, minServoAngle);
   
  //}
  //else if (!blueDetected) {
  
  //  arduino.servoWrite(servoblue, minServoAngle);
    
  //}
  // else if (!yellowDetected) {
  
  //  arduino.servoWrite(servoyellow, minServoAngle);
  //}
  
  //else {
  //  arduino.servoWrite(servored, minServoAngle);
  //  arduino.servoWrite(servogreen, minServoAngle);
  //  arduino.servoWrite(servoblue, minServoAngle);
  //  arduino.servoWrite(servoyellow, minServoAngle);
  //}


     

  
  //arduino.servoWrite(servored, servoAngle_value);

  //for (Blob b : blobs) {
  //  if (b.size() > 500) {
  //    b.show();
  //    int blobCenterX = b.getCenterX();
  //    int blobCenterY = b.getCenterY();
  //    servoAngle_value = round(map(blobCenterX, 0, width, minServoAngle, maxServoAngle));
  //    // Send to Arduino
  //    arduino.servoWrite(servogreen, servoAngle_value);
      
  //    // Draw a bright pink vertical line at the blob center
  //    stroke(trackColor); 
  //    line(blobCenterX, 0, blobCenterX, height);
      
  //    fill(255);
  //    text("Face X: " + blobCenterX, blobCenterX+20, blobCenterY);
  //    text("Servo: " + servoAngle_value, blobCenterX+20, blobCenterY+30); 
  //  }
  //}


// screen data 
  textAlign(RIGHT);
  fill(0);
  text("distance threshold: " + distThreshold, width-10, 25);
  text("color threshold: " + threshold, width-10, 50);
  text("Red Detected: " + redDetected, width - 10, 75);
  text("Green Detected: " + greenDetected, width - 10, 100);
  text("Blue Detected: " + blueDetected, width - 10, 125);
  text("Yellow Detected: " + yellowDetected, width - 10, 150);
}

// Custom distance functions w/ no square root for optimization
float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*video.width;
  //trackColor = video.pixels[loc];
  if (!firstColorSelected) {
    redColor = video.pixels[loc];
    firstColorSelected = true;
    println("Red color selected");
  } else if (!secondColorSelected) {
    greenColor = video.pixels[loc];
    secondColorSelected = true;
    println("Green color selected");
  }
   else if (!thirdColorSelected) {
    blueColor = video.pixels[loc];
    thirdColorSelected = true;
    println("Blue color selected");
  }
   else if (!fourthColorSelected) {
    yellowColor = video.pixels[loc];
    fourthColorSelected = true;
    println("Yellow color selected");
  }

}
