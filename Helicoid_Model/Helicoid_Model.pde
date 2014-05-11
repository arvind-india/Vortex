/**
 * Basic Use.
 * by Jean Pierre Charalambos.
 * 
 * This example illustrates a direct approach to using proscene by Scene proper
 * instantiation.
 * 
 * Press 'h' to display the global shortcuts in the console.
 * Press 'H' to display the current camera profile keyboard shortcuts
 * and mouse bindings in the console.
 */

int shaftHeight = 48;
int shaftSteps = 48;
int inchInterval = 4;

float ledInterval = 4 * 1.31023666667;
int ledsPerArm = 9;

int armSteps = 12;
int armCount = 15;
int armRotation = 12;

color ledMatrix[][];

import remixlab.proscene.*;
import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;

Scene scene;

void setup() {
  size(800, 800, OPENGL);
  colorMode(HSB);

  frameRate(60);
  rectMode(CENTER);
  //Scene instantiation
  scene = new Scene(this);
  // when damping friction = 0 -> spin
  scene.camera().frame().setDampingFriction(0);
  scene.camera().setPosition(new Vec(0, 0, inchInterval * 50));
  scene.setGridIsDrawn(false);
  scene.setAxisIsDrawn(false);

  ledMatrix = new color[armCount][ledsPerArm];
  float colorInterval = 255.0f/(armCount*ledsPerArm);
  println( colorInterval);
  
  int count = 0;
  for ( int i = 0; i < ledsPerArm; i++ )
  {
    for ( int j = 0; j < armCount; j++ )
    {
      float sat = count * colorInterval;
//      println(count + " " + colorInterval + " " + sat);
      ledMatrix[j][i] = color(sat, 255, 255 );
      count++;
    }
  }
}

void draw() {
  background(0);
  
  pushMatrix();
  translate( 0, -shaftSteps/2 * inchInterval, 0 );
  rotateY(radians(frameCount*2) );

  pushMatrix();
  for ( int i = 0; i < armCount; i++ )
  {
    if ( i != 0 ) {
      translate( 0, inchInterval * 2, 0 );
      rotateY( armRotation * 0.0174532925 );
    }
    drawArm();
    //drawELWire(sin(radians(i + frameCount)), 120);
    pushMatrix();
    rotateY(radians(90));
    //drawELWire(sin(radians(i + frameCount + 90)), 120);
    popMatrix();
    if ( i%2 == 1 )
    {
      pushMatrix();
      translate( ledInterval/2, 0, 0 );
      drawLEDArm(i);
      popMatrix();
    }
    else {
      drawLEDArm(i);
    }
  }  
  popMatrix();

  

  drawShaft();
  
  
  fill(204, 102, 255);
  stroke(0, 0, 0);
  pushMatrix();
  translate( 0, inchInterval * shaftHeight, 0 );
  box(10);
  popMatrix();
  popMatrix();
}

void keyPressed() {
  if (scene.camera().frame().dampingFriction() == 0)
    scene.camera().frame().setDampingFriction(0.5);
  else
    scene.camera().frame().setDampingFriction(0);
  println("Camera damping friction now is " + scene.camera().frame().dampingFriction());
}

