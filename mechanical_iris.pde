int windowDim = 800;

float radiusInner = 200;
float radiusOuter = 400;
int numBlades = 8;

float thickness = radiusOuter - radiusInner;
float radius = radiusInner + 0.5*thickness;

float x1Min = radius - 0.5*thickness;
// When computing theta2, the argument to acos must be in [-1, 1] (it goes towards -1 as the blades move in; solving for alpha with x1 = its minimum gives maximum value of alpha).
float alphaMax = 2*asin(sqrt((2*radius*x1Min + radius*radius + x1Min*x1Min)/(4*radius*radius)));
float alpha = alphaMax;

float theta2Max;

float chord = 2*radius*sin(alpha/2);
float distanceAlongBisectorToCentre = sqrt(radius*radius - (chord/2)*(chord/2));

float minimumApertureRadius = radiusInner - thickness/2; // Not accurate for larger values of alpha.
// Another consideration: mechanical interference.

color cBackground = color(255, 255, 255);
color cLine = color(0, 0, 0);

void settings(){
  size(windowDim, windowDim, P2D); // Default renderer can't render between integer pixel values.
  smooth(4);
}

void setup(){
  noFill();
  strokeWeight(4);
  
  minimumApertureRadius = ComputeMinimumApertureRadius();
  theta2Max = Theta2(radius - (thickness/2));
}

void draw(){
  background(cBackground);
  
  translate(windowDim/2, windowDim/2);
  
  float time = millis()/1000.0;
  for (int i = 0; i < numBlades; ++i){
    DrawBlade(i, 0.5 + 0.5*sin(2*PI*0.3*time - PI/4));
  }
  
  DrawStaticElements();
}

void DrawStaticElements(){
  ellipse(0, 0, 2*radiusInner, 2*radiusInner);
  ellipse(0, 0, 2*radiusOuter, 2*radiusOuter);
  
  pushStyle();
  strokeWeight(1);
  
  ellipse(0, 0, 2*radius, 2*radius);
  
  PVector start = new PVector(radiusInner, 0);
  PVector end = new PVector(radiusOuter - 0.5*thickness, 0);
  
  float anglePerBlade = 2*PI/numBlades;
  
  for(int i = 0; i < numBlades; ++i){
    line(start.x, start.y, end.x, end.y);
    start.rotate(anglePerBlade);
    end.rotate(anglePerBlade);
  }
  
  ellipse(0, 0, 2*minimumApertureRadius, 2*minimumApertureRadius);
  
  popStyle();
}

void DrawBlade(int bladeNumber, float progress){
  bladeNumber = constrain(bladeNumber, 0, numBlades-1);
  progress = constrain(progress, 0, 1);
  
  float theta2 = alpha + progress*(theta2Max - alpha);
  
  // Point 1 corresponds to the peg in the slot.
  //float x1 = radius - progress*(thickness/2);
  float x1 = X1(theta2);
  float y1 = 0;
  
  // Point 2 corresponds to the peg that moves along the perimeter circle.
  
  //float theta2 = acos((radius*radius + x1*x1 - chord*chord)/(2*radius*x1));
  //float theta2 = Theta2(x1);
  
  float x2 = radius*cos(theta2);
  float y2 = radius*sin(theta2);
  
  PVector p1 = new PVector(x1, y1);
  PVector p2 = new PVector(x2, y2);
  
  float anglePerBlade = 2*PI/numBlades;
  
  p1.rotate(bladeNumber*anglePerBlade);
  p2.rotate(bladeNumber*anglePerBlade);
  
  // Bisector stuff
  
  float x3 = (x1+x2)/2;
  float y3 = (y1+y2)/2;
  
  // Unit vector rotated by 90 degrees
  float xCentre = x3 + distanceAlongBisectorToCentre*((y1-y2)/chord);
  float yCentre = y3 + distanceAlongBisectorToCentre*((x2-x1)/chord);
  
  PVector pCentre = new PVector(xCentre, yCentre);
  pCentre.rotate(bladeNumber*anglePerBlade);
  
  float angleP1 = atan2(p1.y - pCentre.y, p1.x - pCentre.x);
  
  pushStyle();
  colorMode(HSB, 255, 255, 255);
  
  stroke((bladeNumber*1.0/numBlades)*255, 255, 255, 128);
  strokeWeight(thickness);
  
  arc(pCentre.x, pCentre.y, 2*radius, 2*radius, angleP1, angleP1+alpha);
  
  stroke((bladeNumber*1.0/numBlades)*255, 255, 128);
  strokeWeight(4);
  ellipse(p1.x, p1.y, thickness, thickness);
  ellipse(p2.x, p2.y, thickness, thickness);
  
  popStyle();
}

float ComputeMinimumApertureRadius(){
  float x1 = radius - (thickness/2);
  float y1 = 0;
  
  float theta2 = Theta2(x1);
  
  float x2 = radius*cos(theta2);
  float y2 = radius*sin(theta2);
  
  float x3 = (x1+x2)/2;
  float y3 = (y1+y2)/2;
  
  float xCentre = x3 - distanceAlongBisectorToCentre*((y2-y1)/chord);
  float yCentre = y3 - distanceAlongBisectorToCentre*((x1-x2)/chord);
  
  PVector pCentre = new PVector(xCentre, yCentre);
  PVector CentreToOriginUnitVector = new PVector(-xCentre, -yCentre);
  CentreToOriginUnitVector.normalize();
  
  CentreToOriginUnitVector.mult(radius - thickness/2);
  PVector pClosestToOrigin = pCentre;
  pClosestToOrigin.add(CentreToOriginUnitVector);
  
  return pClosestToOrigin.mag();
}

float Theta2(float x1){
  return acos((radius*radius + x1*x1 - chord*chord)/(2*radius*x1));
}

float X1(float theta2){
  return -1*(-sqrt(chord*chord - radius*radius*sin(theta2)*sin(theta2)) - radius*cos(theta2));
}