//==CLASSES==============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
class rectText         // scrollable text class
{
  int number;          // text number
  
  String ntext;        // text name i.e. the text content is being referred to as the name (n)
  int nColor;          // name colour
  float nOpacity;      // name opacity
  PFont nFont;         // name font
  float nSize;         // name size
  
  float dY;  // amount by which to move the text vertically (up or down) while scroll button is pressed      

  int bColor;          // text box colour
  int bStroke;         // box stroke
  float bThick;        // box stroke thickness
  float bOpacity;      // box opacity
  float bX, bY;        // box location
  float bW, bH, bR;    // box size (width, height & corner radii)
  
  PImage screen;       // variable to capture the current screen
  
  boolean bHlight;     // for the scroll button, not the main scroll box!!!
  
  float ubX, ubY, ubW, ubH;
  float lbX, lbY, lbW, lbH;
 
  //  float uX1, uY1, uX2, uY2, uX3, uY3;
  //  float lX1, lY1, lX2, lY2, lX3, lY3;
  
  rectText(int iNU, String iNA, int inC, float inO, PFont inF, float inS, int ibC, int ibS, float ibT, float ibO, float ibX, float ibY, float ibW, float ibH, float ibR, boolean ihL)
  {
    number=iNU; ntext=iNA; nColor=inC; nOpacity=inO; nFont=inF; nSize=inS; bColor=ibC; bStroke=ibS; bThick=ibT; bOpacity=ibO; bX=ibX; bY=ibY; bW=ibW; bH=ibH; bR=ibR; bHlight=ihL;
    
    ubX=bX+bW; ubY=bY;        ubW=0.1*bW; ubH=0.1*bH;
    lbX=bX+bW; lbY=bY+bH-ubH; lbW=ubW;    lbH=ubH;
    
    //uX1=1.04*bW; uY1=0;  uX2=bW;  uY2=0.2*bH; uX3=1.08*bW; uY3=uY2;
    //lX1=uX1;     lY1=bH; lX2=uX2; lY2=0.8*bH; lX3=uX3;     lY3=lY2; 
    
    dY=0;  // initially; this will be changed by scrolling
    
    screen=createImage(width,height,RGB);
  }
  
  void display(float wS, float hS)
  {    
    //pushStyle();                    // store current drawing style (stroke, fill, etc)
    rectMode(CORNER);
    textAlign(CENTER,CENTER);
    
    //take a snapshot of the screen

    loadPixels();
    screen.loadPixels();
    for(int sX=0; sX<width; sX++)
    {
      for(int sY=0; sY<height; sY++)
      {
        int loc = sX + sY*width;
        screen.pixels[loc]=pixels[loc];
      }
    }
    updatePixels();
    screen.updatePixels();
    
    //OR
    //screen=get(); // which is slower         
    
    pushMatrix();                           // store coordinate system
    translate(bX*wS,bY*hS);         // shift coordinate system to location of button
    scale(wS,hS);                   // scale button & text

    if(bColor==-number){ noFill(); }
    else{ fill(bColor,bOpacity); }
    
    if(bStroke==-number){ noStroke(); }
    else{ stroke(bStroke,bOpacity); strokeWeight(bThick); }
    
    rect(0,0,bW,bH,bR);                // display text box
    
    if(nColor==-number){ noFill(); }
    else{ fill(nColor,nOpacity); }          // specify text color & opacity
    
    textFont(nFont,nSize);
    
    //float nX=0+5, nY=0+5+dY, nW=bW-10, nH=bH-10-dY;
    float nX=0.015*bW, nY=0.033*bH, nW=bW-(2*nX), nH=bH-(2*nY);
    nY=nY+dY; nH=nH-dY;
    
    //text(ntext,0+5,0+5+dY,bW-10,bH-10-dY);        // display text
    text(ntext,nX,nY,nW,nH);        // display text
    
  
    popMatrix();                            // restore coordinate system
    
    if(bColor==-number){ noFill(); }
    else{ fill(bColor,bOpacity); }
    
    if(bStroke==-number){ noStroke(); }
    else{ stroke(bStroke,bOpacity); strokeWeight(bThick); }

    strokeJoin(ROUND);
    
    pushMatrix();                           // store coordinate system
    translate(ubX*wS,ubY*hS);         // shift coordinate system to location of button
    scale(wS,hS);                   // scale button & text
    
    rect(0,0,ubW,ubH);          // display the scroll buttons
//    triangle(uX1,uY1, uX2,uY2, uX3,uY3);

    if(bHlight==true)                   
    {
      if(mouseOverU(wS,hS))
      {
        fill(#FFFFFF,70); 
        rect(0,0,ubW,ubH); // display highlight
        println("HIGHLIGHT"); 
      }
    }

    popMatrix();
    
    if(bColor==-number){ noFill(); }
    else{ fill(bColor,bOpacity); }
    
    if(bStroke==-number){ noStroke(); }
    else{ stroke(bStroke,bOpacity); strokeWeight(bThick); }
    
    pushMatrix();
    translate(lbX*wS,lbY*hS);         // shift coordinate system to location of button    
    scale(wS,hS);                   // scale button & text
    
    rect(0,0,lbW,lbH);
//    triangle(lX1,lY1, lX2,lY2, lX3,lY3);
    
    if(bHlight==true)                   
    {
      if(mouseOverL(wS,hS))
      {
        fill(#FFFFFF,70); 
        rect(0,0,lbW,lbH); // display highlight
        println("HIGHLIGHT"); 
      }
    }

    strokeJoin(MITER);
    
    popMatrix();                            // restore coordinate system
    
    //overlay the area above the textbox in the snapshot over the screen

    loadPixels();
    screen.loadPixels();
    
    for(int sX=0; sX<width; sX++)
    {
      for(int sY=0; sY<=(bY*hS); sY++)
      {
        int loc = sX + sY*width;
        pixels[loc]=screen.pixels[loc];
      }
    }
    
    updatePixels();
    screen.updatePixels();

    //popStyle();                             // restore previous drawing style
  }
  
  void display()
  {
    display(1,1);
  }
  
  boolean mouseOverU(float wS, float hS) 
  {
    if(mouseX>=ubX*wS && mouseX<=(ubX+ubW)*wS && mouseY>=ubY*hS && mouseY<=(ubY+ubH)*hS){ return true; }
    else{ return false; }
  }                   
  
  boolean mouseOverL(float wS, float hS) 
  {
    if(mouseX>=lbX*wS && mouseX<=(lbX+lbW)*wS && mouseY>=lbY*hS && mouseY<=(lbY+lbH)*hS){ return true; }
    else{ return false; }
  }                   
  
  boolean mouseOverU()
  {
    return mouseOverU(1,1);
    
  }
  
  boolean mouseOverL()
  {
    return mouseOverL(1,1);
  }
  
  void update(float wS, float hS)
  {
    if(mouseOverL(wS,hS))
    {
      dY=dY-2;
      println("HIGHLIGHT"); 
    }
      
    if(mouseOverU(wS,hS))
    {
      dY=dY+2;
      if(dY>=0){ dY=0; }
      println("HIGHLIGHT"); 
    }
  }
  
  void update()
  {
    update(1,1);
  }

}
//---------------------------------------------------------------------------------------------------------------------------------------
