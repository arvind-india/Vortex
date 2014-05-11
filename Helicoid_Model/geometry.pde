void drawShaft()
{
  stroke(255);
  fill( 0 );
  for( int i = 0; i < shaftSteps; i++ )
  {
    pushMatrix();
    translate( 0, i * inchInterval, 0 );
    box( 1 );    
    popMatrix();
  }
}

void drawArm()
{
  fill(0, 200);
  stroke(200, 50);
  for( int i = 0; i < armSteps; i++ )
  {
    pushMatrix();
//    translate( 0, -shaftSteps / 2 * inchInterval );
    pushMatrix();
    translate( i * inchInterval - armSteps * inchInterval, 0, 0 );
    box( 1 );    
    popMatrix();
    popMatrix();
  }
  
  for( int i = 0; i < armSteps; i++ )
  {
    pushMatrix();
//    translate( 0, -shaftSteps / 2 * inchInterval );
    pushMatrix();
    translate( i * inchInterval, 0, 0 );
    box( 1 );    
    popMatrix();
    popMatrix();
  }
}

void drawELWire( float _length, int _opacity )
{
  fill(255, 0, 255, _opacity );
  box( armSteps * inchInterval * 2 * _length, 1, -1 );
}



void drawLEDArm( int _armNumber )
{

  for( int i = 0; i < ledsPerArm; i++ )
  {
      fill( ledMatrix[_armNumber][i] );
      pushMatrix();
      translate( i * ledInterval - armSteps * inchInterval, 0, -1 );
      noStroke();
      rect(0, 0, 1, 1 );
      popMatrix();
  }
  
    for( int i = 0; i < ledsPerArm; i++ )
  {
      fill( ledMatrix[_armNumber][i] );
      pushMatrix();
      translate( i * ledInterval, 0, -1 );
      noStroke();
      rect(0, 0, 1, 1 );
      popMatrix();
  }
}
